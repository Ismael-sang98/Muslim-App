package com.example.namaz_vakti

import android.content.SharedPreferences
import java.util.Calendar

/**
 * Shared helper so both widgets can figure out the next prayer themselves at
 * each system refresh (~30 min) — no Flutter background execution required.
 * The app writes the six `p_<key>_time` values; this reads them.
 */
object WidgetPrayers {
    val keys = listOf("imsak", "gunes", "ogle", "ikindi", "aksam", "yatsi")

    /** Returns the key of the next upcoming prayer; after Yatsı → "imsak". */
    fun nextKey(data: SharedPreferences): String {
        val cal = Calendar.getInstance()
        val nowMinutes = cal.get(Calendar.HOUR_OF_DAY) * 60 + cal.get(Calendar.MINUTE)
        for (key in keys) {
            val minutes = toMinutes(data.getString("p_${key}_time", null)) ?: continue
            if (minutes > nowMinutes) return key
        }
        return "imsak"
    }

    private fun toMinutes(time: String?): Int? {
        if (time == null) return null
        val parts = time.split(":")
        if (parts.size < 2) return null
        val h = parts[0].toIntOrNull() ?: return null
        val m = parts[1].toIntOrNull() ?: return null
        return h * 60 + m
    }
}
