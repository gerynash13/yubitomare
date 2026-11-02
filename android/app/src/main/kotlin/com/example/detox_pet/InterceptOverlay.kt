package com.example.detox_pet

import android.content.Context
import android.graphics.Color
import android.graphics.PixelFormat
import android.graphics.Typeface
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.view.Gravity
import android.view.View
import android.view.WindowManager
import android.widget.Button
import android.widget.LinearLayout
import android.widget.TextView

/**
 * A full-screen card drawn on top of whatever app is open.
 * Still plain native views: the art and the AI text come in a later step.
 */
class InterceptOverlay(private val context: Context) {

    private val wm = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager
    private val handler = Handler(Looper.getMainLooper())
    private var view: View? = null

    val isShowing: Boolean get() = view != null

    private fun dp(n: Int) = (n * context.resources.displayMetrics.density).toInt()

    /**
     * [options] are the pass lengths in minutes. An empty list means "locked":
     * only the back button is shown.
     */
    fun show(
        title: String,
        backLabel: String,
        options: List<Int>,
        optionLabel: (Int) -> String,          // e.g. "5 min"
        optionWaitLabel: (Int, Int) -> String, // e.g. "5 min (3)" while counting down
        waitSeconds: Int,
        onBack: () -> Unit,
        onPass: (Int) -> Unit
    ) {
        if (view != null) return // already showing

        val titleView = TextView(context).apply {
            text = title
            textSize = 26f
            setTextColor(Color.WHITE)
            typeface = Typeface.DEFAULT_BOLD
            gravity = Gravity.CENTER
        }

        val backBtn = Button(context).apply {
            text = backLabel
            setOnClickListener {
                hide()
                onBack()
            }
        }

        // One button per pass length. They start disabled and count down together.
        val passBtns = options.map { minutes ->
            Button(context).apply {
                isEnabled = false
                text = optionWaitLabel(minutes, waitSeconds)
                setOnClickListener {
                    hide()
                    onPass(minutes)
                }
            }
        }

        var left = waitSeconds
        val countdown = object : Runnable {
            override fun run() {
                left -= 1
                if (left > 0) {
                    options.forEachIndexed { i, m -> passBtns[i].text = optionWaitLabel(m, left) }
                    handler.postDelayed(this, 1000)
                } else {
                    options.forEachIndexed { i, m ->
                        passBtns[i].text = optionLabel(m)
                        passBtns[i].isEnabled = true
                    }
                }
            }
        }
        if (options.isNotEmpty()) handler.postDelayed(countdown, 1000)

        fun btnParams(topDp: Int) = LinearLayout.LayoutParams(
            LinearLayout.LayoutParams.MATCH_PARENT,
            LinearLayout.LayoutParams.WRAP_CONTENT
        ).apply { topMargin = dp(topDp) }

        val root = LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            setBackgroundColor(Color.argb(240, 20, 18, 26))
            setPadding(dp(32), dp(32), dp(32), dp(32))
            addView(titleView)
            addView(backBtn, btnParams(32))
            passBtns.forEach { addView(it, btnParams(12)) }
        }

        val type = if (Build.VERSION.SDK_INT >= 26) {
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
        } else {
            @Suppress("DEPRECATION")
            WindowManager.LayoutParams.TYPE_PHONE
        }
        val params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.MATCH_PARENT,
            type,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN,
            PixelFormat.TRANSLUCENT
        )

        try {
            wm.addView(root, params)
            view = root
        } catch (_: Exception) {
            // Permission missing or blocked by the phone: do nothing, never crash the service.
            handler.removeCallbacksAndMessages(null)
        }
    }

    fun hide() {
        handler.removeCallbacksAndMessages(null)
        view?.let {
            try {
                wm.removeView(it)
            } catch (_: Exception) {
            }
        }
        view = null
    }
}