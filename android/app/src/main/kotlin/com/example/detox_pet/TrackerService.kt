package com.example.detox_pet

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.ServiceInfo
import android.content.res.Configuration
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.provider.Settings
import androidx.core.app.NotificationCompat
import org.json.JSONArray
import org.json.JSONObject
import java.util.Calendar
import java.util.Locale

class TrackerService : Service() {

    private class Config(
        val thresholdMs: Long,
        val pollMs: Long,
        val apps: Map<String, String>,
        val language: String
    )

    // What is happening during the current visit to a guarded app.
    private enum class Visit { NEW, SHOWING, PASSED, SENT_HOME }

    companion object {
        // Tune these freely. Set DAILY_PASSES high while testing the lower levels.
        const val DAILY_PASSES = 3
        val PASS_OPTIONS = listOf(5, 10, 15)       // minutes
        val WAIT_SECONDS = listOf(5, 10, 20)       // countdown per level
    }

    private val handler = Handler(Looper.getMainLooper())
    private val overlay by lazy { InterceptOverlay(this) }
    private var running = false
    private var screenOn = true
    private var currentPkg: String? = null
    private var lastQuery = 0L
    private var blacklistedSince: Long? = null
    private var alerted = false
    private var lang = "system"

    private var visit = Visit.NEW
    private val passUntil = mutableMapOf<String, Long>() // package -> pass end time
    private var shownApp: String? = null
    private var shownLevel = 0

    private val screenReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            if (intent.action == Intent.ACTION_SCREEN_OFF) {
                screenOn = false
                blacklistedSince = null // a locked screen counts as a break
                alerted = false
                dismissAsLeft()
            } else if (intent.action == Intent.ACTION_SCREEN_ON) {
                screenOn = true
            }
        }
    }

    private val tick = object : Runnable {
        override fun run() {
            val cfg = loadConfig()
            lang = cfg.language
            if (screenOn) check(cfg)
            handler.postDelayed(this, cfg.pollMs)
        }
    }

    // ---------- settings ----------

    private fun loadConfig(): Config {
        val prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val raw = prefs.getString("flutter.tracker_config", null)
        var minutes = 15
        var language = "system"
        val apps = mutableMapOf<String, String>()
        if (raw != null) {
            try {
                val obj = JSONObject(raw)
                minutes = obj.optInt("thresholdMinutes", 15)
                language = obj.optString("language", "system")
                val arr = obj.optJSONArray("apps")
                if (arr != null) {
                    for (i in 0 until arr.length()) {
                        val a = arr.getJSONObject(i)
                        apps[a.getString("pkg")] = a.getString("name")
                    }
                }
            } catch (_: Exception) {
                // bad or missing settings: fall back to defaults
            }
        }
        // Poll often so the overlay appears right after the app opens.
        val poll = 2_000L
        return Config(minutes * 60_000L, poll, apps, language)
    }

    // ---------- language ----------

    private fun localized(locale: Locale): Context {
        val config = Configuration(resources.configuration)
        config.setLocale(locale)
        return createConfigurationContext(config)
    }

    private fun str(id: Int, vararg args: Any): String {
        val ctx: Context = when (lang) {
            "en" -> localized(Locale.ENGLISH)
            "ja" -> localized(Locale.JAPANESE)
            else -> this // follow the device language
        }
        return ctx.getString(id, *args)
    }

    // ---------- service lifecycle ----------

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        lang = loadConfig().language
        createChannels()
        val n = statusNotification(str(R.string.status_watching))
        if (Build.VERSION.SDK_INT >= 34) {
            startForeground(1, n, ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE)
        } else {
            startForeground(1, n)
        }
        if (!running) {
            running = true
            val filter = IntentFilter().apply {
                addAction(Intent.ACTION_SCREEN_ON)
                addAction(Intent.ACTION_SCREEN_OFF)
            }
            if (Build.VERSION.SDK_INT >= 33) {
                registerReceiver(screenReceiver, filter, Context.RECEIVER_NOT_EXPORTED)
            } else {
                registerReceiver(screenReceiver, filter)
            }
            handler.post(tick)
        }
        return START_STICKY
    }

    override fun onDestroy() {
        overlay.hide()
        handler.removeCallbacks(tick)
        if (running) unregisterReceiver(screenReceiver)
        running = false
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null

    // ---------- tracking ----------

    private fun labelFor(pkg: String?): String {
        if (pkg == null) return "?"
        return try {
            val info = packageManager.getApplicationInfo(pkg, 0)
            packageManager.getApplicationLabel(info).toString()
        } catch (_: Exception) {
            pkg // apps without a launcher icon (system screens etc.) keep the package name
        }
    }

    private fun check(cfg: Config) {
        val usm = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val now = System.currentTimeMillis()
        val from = if (lastQuery == 0L) now - 60 * 60 * 1000 else lastQuery
        val events = usm.queryEvents(from, now)
        val e = UsageEvents.Event()
        while (events.hasNextEvent()) {
            events.getNextEvent(e)
            if (e.eventType == UsageEvents.Event.MOVE_TO_FOREGROUND) currentPkg = e.packageName
        }
        lastQuery = now

        val pkg = currentPkg
        val appName = if (pkg != null) cfg.apps[pkg] else null
        if (appName != null && pkg != null) {
            if (blacklistedSince == null) {
                blacklistedSince = now
                visit = Visit.NEW
            }

            // The intercept: decide what this moment in the visit needs.
            when (visit) {
                Visit.NEW -> {
                    val until = passUntil[pkg] ?: 0L
                    if (until > now) {
                        visit = Visit.PASSED // came back during an unused pass
                    } else {
                        showIntercept(pkg, appName, (cfg.thresholdMs / 60_000L).toInt())
                    }
                }
                Visit.PASSED -> {
                    if (now >= (passUntil[pkg] ?: 0L)) {
                        showIntercept(pkg, appName, (cfg.thresholdMs / 60_000L).toInt())
                    }
                }
                else -> {} // SHOWING: wait for a tap. SENT_HOME: wait for the launcher.
            }

            val elapsed = now - blacklistedSince!!
            updateStatus(str(R.string.status_on_app, appName, elapsed / 1000))
            if (elapsed >= cfg.thresholdMs && !alerted) {
                alerted = true
                sendAlert(appName, elapsed / 60_000)
            }
        } else {
            dismissAsLeft()
            blacklistedSince = null
            alerted = false
            updateStatus(str(R.string.status_watching_now, labelFor(pkg)))
        }
    }

    // ---------- the overlay ----------

    private fun showIntercept(pkg: String, appName: String, capMinutes: Int) {
        if (!Settings.canDrawOverlays(this)) return

        val used = passesToday()
        val locked = used >= DAILY_PASSES
        val level = minOf(used, 2)

        val title = when {
            locked -> str(R.string.overlay_title_locked, appName)
            level == 0 -> str(R.string.overlay_title, appName)
            level == 1 -> str(R.string.overlay_title_2, appName)
            else -> str(R.string.overlay_title_3, appName, used + 1)
        }
        // Pass lengths never exceed the length set in Settings (always at least one choice).
        val options = if (locked) {
            emptyList()
        } else {
            PASS_OPTIONS.filter { it <= capMinutes }.ifEmpty { listOf(capMinutes) }
        }

        visit = Visit.SHOWING
        shownApp = appName
        shownLevel = used

        overlay.show(
            title = title,
            backLabel = str(R.string.overlay_back),
            options = options,
            optionLabel = { m -> str(R.string.overlay_more, m) },
            optionWaitLabel = { m, s -> str(R.string.overlay_more_wait, m, s) },
            waitSeconds = WAIT_SECONDS[level],
            onBack = {
                logIntercept(appName, "back", used, 0)
                visit = Visit.SENT_HOME
                goHome()
            },
            onPass = { m ->
                logIntercept(appName, "pass", used, m)
                passUntil[pkg] = System.currentTimeMillis() + m * 60_000L
                visit = Visit.PASSED
            }
        )
    }

    /** The user left (home, recents, screen off) without answering the card. */
    private fun dismissAsLeft() {
        if (overlay.isShowing) {
            overlay.hide()
            shownApp?.let { logIntercept(it, "left", shownLevel, 0) }
        }
        visit = Visit.NEW
    }

    private fun goHome() {
        startActivity(
            Intent(Intent.ACTION_MAIN)
                .addCategory(Intent.CATEGORY_HOME)
                .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        )
    }

    // ---------- intercept log ----------

    private fun readLog(): JSONArray {
        val prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        return try {
            JSONArray(prefs.getString("flutter.intercepts", "[]") ?: "[]")
        } catch (_: Exception) {
            JSONArray()
        }
    }

    /** outcome is "back", "pass" or "left". level = passes already used today. */
    private fun logIntercept(appName: String, outcome: String, level: Int, minutes: Int) {
        val old = readLog()
        old.put(
            JSONObject()
                .put("t", System.currentTimeMillis())
                .put("app", appName)
                .put("outcome", outcome)
                .put("level", level)
                .put("min", minutes)
        )
        val trimmed = JSONArray()
        val start = maxOf(0, old.length() - 300)
        for (i in start until old.length()) trimmed.put(old.get(i))
        getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            .edit().putString("flutter.intercepts", trimmed.toString()).apply()
    }

    private fun passesToday(): Int {
        val cal = Calendar.getInstance().apply {
            set(Calendar.HOUR_OF_DAY, 0)
            set(Calendar.MINUTE, 0)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
        }
        val start = cal.timeInMillis
        val arr = readLog()
        var n = 0
        for (i in 0 until arr.length()) {
            val o = arr.getJSONObject(i)
            if (o.optString("outcome") == "pass" && o.optLong("t") >= start) n++
        }
        return n
    }

    // ---------- memory log ----------

    private fun logIntervention(appName: String, minutes: Long) {
        val prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val old = try {
            JSONArray(prefs.getString("flutter.interventions", "[]") ?: "[]")
        } catch (_: Exception) {
            JSONArray()
        }
        old.put(
            JSONObject()
                .put("t", System.currentTimeMillis())
                .put("app", appName)
                .put("min", minutes)
        )
        // Keep only the newest 200 entries so the file never grows forever.
        val trimmed = JSONArray()
        val start = maxOf(0, old.length() - 200)
        for (i in start until old.length()) trimmed.put(old.get(i))
        prefs.edit().putString("flutter.interventions", trimmed.toString()).apply()
    }

    // ---------- notifications ----------

    private fun createChannels() {
        if (Build.VERSION.SDK_INT >= 26) {
            val nm = getSystemService(NotificationManager::class.java)
            nm.createNotificationChannel(
                NotificationChannel(
                    "tracker", str(R.string.channel_tracker), NotificationManager.IMPORTANCE_LOW
                )
            )
            nm.createNotificationChannel(
                NotificationChannel(
                    "alerts", str(R.string.channel_alerts), NotificationManager.IMPORTANCE_HIGH
                )
            )
        }
    }

    private fun statusNotification(text: String) =
        NotificationCompat.Builder(this, "tracker")
            .setSmallIcon(android.R.drawable.ic_menu_view)
            .setContentTitle(str(R.string.tracker_status_title))
            .setContentText(text)
            .setOnlyAlertOnce(true)
            .setOngoing(true)
            .build()

    private fun updateStatus(text: String) {
        getSystemService(NotificationManager::class.java).notify(1, statusNotification(text))
    }

    private fun sendAlert(appName: String, minutes: Long) {
        logIntervention(appName, minutes)
        val intent = Intent(this, MainActivity::class.java)
            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
            .putExtra("alert_app", appName)
            .putExtra("alert_minutes", minutes)
        val open = PendingIntent.getActivity(
            this, 0, intent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )
        val n = NotificationCompat.Builder(this, "alerts")
            .setSmallIcon(android.R.drawable.ic_dialog_alert)
            .setContentTitle(str(R.string.alert_title))
            .setContentText(str(R.string.alert_text, appName))
            .setContentIntent(open)
            .setAutoCancel(true)
            .build()
        getSystemService(NotificationManager::class.java).notify(2, n)
    }
}