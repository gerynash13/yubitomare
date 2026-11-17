package com.example.detox_pet

import android.Manifest
import android.app.AppOpsManager
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.Process
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import android.provider.Settings
import android.util.Log
import androidx.core.content.ContextCompat
import androidx.core.app.NotificationManagerCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class MainActivity : FlutterActivity() {
    private val channelName = "detox_pet/usage"

    private var pendingAlert: Map<String, Any>? = null
    private var pendingIntercept: Map<String, Any>? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        Log.d("Tomarin", "MainActivity onCreate (card request: ${intent?.getStringExtra("intercept_app")})")
        captureAlert(intent)
        super.onCreate(savedInstanceState)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        Log.d("Tomarin", "MainActivity onNewIntent (card request: ${intent.getStringExtra("intercept_app")})")
        setIntent(intent)
        captureAlert(intent)
    }

    override fun onResume() {
        super.onResume()
        Log.d("Tomarin", "MainActivity onResume")
    }

    private fun captureAlert(intent: Intent?) {
        if (intent == null) return

        // A request from TrackerService to show the intercept card (drawn by Flutter).
        val interceptApp = intent.getStringExtra("intercept_app")
        if (interceptApp != null) {
            pendingIntercept = mapOf(
                "app" to interceptApp,
                "level" to intent.getIntExtra("intercept_level", 0),
                "total" to intent.getIntExtra("intercept_total", 3),
                "locked" to intent.getBooleanExtra("intercept_locked", false),
                "options" to (intent.getIntArrayExtra("intercept_options")?.toList() ?: listOf(5, 10, 15))
            )
            intent.removeExtra("intercept_app") // So it can't fire twice
        }

        // The older notification alert.
        val app = intent.getStringExtra("alert_app") ?: return
        val minutes = intent.getLongExtra("alert_minutes", 0L)
        pendingAlert = mapOf("app" to app, "minutes" to minutes)
        intent.removeExtra("alert_app") // So it can't fire twice
    }

    private fun goHome() {
        startActivity(
            Intent(Intent.ACTION_MAIN)
                .addCategory(Intent.CATEGORY_HOME)
                .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        )
    }

    private fun isXiaomi(): Boolean {
        val brand = Build.BRAND.lowercase()
        return Build.MANUFACTURER.equals("xiaomi", ignoreCase = true) ||
            brand == "xiaomi" || brand == "redmi" || brand == "poco"
    }

    // Xiaomi's "Display pop-up windows while running in the background" is a hidden app-op (10021).
    // There is no public API, so this is best effort: null means "cannot tell".
    private fun backgroundStartAllowed(): Boolean? {
        return try {
            val ops = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
            val m = ops.javaClass.getMethod(
                "checkOpNoThrow",
                Int::class.javaPrimitiveType,
                Int::class.javaPrimitiveType,
                String::class.java
            )
            (m.invoke(ops, 10021, Process.myUid(), packageName) as Int) == AppOpsManager.MODE_ALLOWED
        } catch (e: Exception) {
            null
        }
    }

    private fun openXiaomiPermissions() {
        val attempts = listOf(
            Intent("miui.intent.action.APP_PERM_EDITOR").apply {
                setClassName("com.miui.securitycenter", "com.miui.permcenter.permissions.PermissionsEditorActivity")
                putExtra("extra_pkgname", packageName)
            },
            Intent("miui.intent.action.APP_PERM_EDITOR").apply {
                setClassName("com.miui.securitycenter", "com.miui.permcenter.permissions.AppPermissionsEditorActivity")
                putExtra("extra_pkgname", packageName)
            },
            Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS, Uri.parse("package:$packageName"))
        )
        for (intent in attempts) {
            try {
                startActivity(intent)
                return
            } catch (_: Exception) {
            }
        }
    }

    // Two gentle pulses. Amplitude is 1-255: raise the 60s if you can't feel it, lower them if too strong.
    private fun softBuzz() {
        val vib: Vibrator = if (Build.VERSION.SDK_INT >= 31) {
            (getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as VibratorManager).defaultVibrator
        } else {
            @Suppress("DEPRECATION")
            getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
        }
        if (!vib.hasVibrator()) return
        val timings = longArrayOf(0, 80, 180, 80)
        val amplitudes = intArrayOf(0, 60, 0, 60)
        if (Build.VERSION.SDK_INT >= 26) {
            val effect = if (vib.hasAmplitudeControl())
                VibrationEffect.createWaveform(timings, amplitudes, -1)
            else
                VibrationEffect.createWaveform(timings, -1)
            vib.vibrate(effect)
        } else {
            @Suppress("DEPRECATION")
            vib.vibrate(timings, -1)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "hasUsageAccess" -> result.success(hasUsageAccess())
                    "openUsageSettings" -> {
                        startActivity(Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS))
                        result.success(null)
                    }
                    "hasOverlayPermission" -> result.success(Settings.canDrawOverlays(this))
                    "openOverlaySettings" -> {
                        startActivity(
                            Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION, Uri.parse("package:$packageName"))
                        )
                        result.success(null)
                    }
                    "getRecentEvents" -> result.success(getRecentEvents())
                    "requestNotificationPermission" -> {
                        if (Build.VERSION.SDK_INT >= 33) {
                            requestPermissions(arrayOf(Manifest.permission.POST_NOTIFICATIONS), 1001)
                        }
                        result.success(null)
                    }
                    "startTracker" -> {
                        ContextCompat.startForegroundService(this, Intent(this, TrackerService::class.java))
                        result.success(null)
                    }
                    "stopTracker" -> {
                        stopService(Intent(this, TrackerService::class.java))
                        result.success(null)
                    }
                    "getPendingAlert" -> {
                        result.success(pendingAlert)
                        pendingAlert = null
                    }
                    "getPendingIntercept" -> {
                        result.success(pendingIntercept)
                        pendingIntercept = null
                    }
                    "interceptDone" -> {
                        // The user answered the card: "back", "pass" or "left".
                        val action = call.argument<String>("action") ?: "left"
                        val minutes = call.argument<Int>("minutes") ?: 0
                        val reason = call.argument<String>("reason")
                        InterceptBridge.complete(action, minutes, reason)
                        when (action) {
                            "back" -> goHome()                // leave the guarded app
                            "pass" -> moveTaskToBack(true)    // show the guarded app again
                        }
                        result.success(null)
                    }
                    "dial" -> {
                        // Opens the phone app with the number filled in. The user presses call.
                        val number = call.argument<String>("number") ?: ""
                        startActivity(
                            Intent(Intent.ACTION_DIAL, Uri.parse("tel:$number"))
                                .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        )
                        result.success(null)
                    }
                    "getInstalledApps" -> {
                        val launcher = Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_LAUNCHER)
                        val apps = packageManager.queryIntentActivities(launcher, 0)
                            .map {
                                mapOf(
                                    "pkg" to it.activityInfo.packageName,
                                    "name" to it.loadLabel(packageManager).toString()
                                )
                            }
                            .filter { it["pkg"] != packageName }
                            .distinctBy { it["pkg"] }
                            .sortedBy { it["name"]!!.lowercase() }
                        result.success(apps)
                    }
                    "softBuzz" -> {
                        softBuzz()
                        result.success(null)
                    }
                    "hasNotificationPermission" -> result.success(
                        NotificationManagerCompat.from(this).areNotificationsEnabled()
                    )
                    "openNotificationSettings" -> {
                        val i = if (Build.VERSION.SDK_INT >= 26) {
                            Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS)
                                .putExtra(Settings.EXTRA_APP_PACKAGE, packageName)
                        } else {
                            Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS, Uri.parse("package:$packageName"))
                        }
                        startActivity(i)
                        result.success(null)
                    }
                    "isXiaomi" -> result.success(isXiaomi())
                    "hasBackgroundStartPermission" -> result.success(backgroundStartAllowed())
                    "openBackgroundStartSettings" -> {
                        openXiaomiPermissions()
                        result.success(null)
                    }
                    "interceptShown" -> {
                        Log.d("Tomarin", "Flutter card reported in")
                        InterceptBridge.cardShown = true
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun hasUsageAccess(): Boolean {
        val appOps = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = appOps.checkOpNoThrow(
            AppOpsManager.OPSTR_GET_USAGE_STATS, Process.myUid(), packageName
        )
        return mode == AppOpsManager.MODE_ALLOWED
    }

    // Returns "time  package" lines for apps that came to the foreground in the last hour.
    private fun getRecentEvents(): List<String> {
        val usm = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val now = System.currentTimeMillis()
        val events = usm.queryEvents(now - 60 * 60 * 1000, now)
        val event = UsageEvents.Event()
        val fmt = SimpleDateFormat("HH:mm:ss", Locale.getDefault())
        val lines = mutableListOf<String>()
        while (events.hasNextEvent()) {
            events.getNextEvent(event)
            if (event.eventType == UsageEvents.Event.MOVE_TO_FOREGROUND) {
                lines.add("${fmt.format(Date(event.timeStamp))}  ${event.packageName}")
            }
        }
        return lines.reversed() // newest first
    }
}