package com.example.detox_pet

import android.util.Log

/**
 * The Flutter card lives in MainActivity, but the decision logic lives in TrackerService.
 * Both run in the same app process, so this small object passes messages across.
 */
object InterceptBridge {
    /** Set by TrackerService when it opens the card. Called once with "back", "pass" or "left". */
    @Volatile
    var onResult: ((String, Int, String?) -> Unit)? = null

    /** Set by TrackerService when it opens the card. Called when Flutter says the card is on screen. */
    @Volatile
    var onShown: (() -> Unit)? = null

    fun shown() {
        Log.d("Tomarin", "Bridge: card reported in (listener=${onShown != null})")
        onShown?.invoke()
    }

    fun complete(action: String, minutes: Int, reason: String?) {
        val callback = onResult
        Log.d("Tomarin", "Bridge: answer $action (listener=${callback != null})")
        onResult = null
        onShown = null
        callback?.invoke(action, minutes, reason)
    }
}