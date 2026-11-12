package com.example.detox_pet

/**
 * The Flutter card lives in MainActivity, but the decision logic lives in TrackerService.
 * Both run in the same app process, so this tiny object passes the user's answer across.
 */
object InterceptBridge {
    /** Set by TrackerService when it opens the card. Called once with "back", "pass" or "left" (and the reason, for a pass). */
    @Volatile
    var onResult: ((String, Int, String?) -> Unit)? = null

    fun complete(action: String, minutes: Int, reason: String?) {
        val callback = onResult
        onResult = null
        callback?.invoke(action, minutes, reason)
    }
}