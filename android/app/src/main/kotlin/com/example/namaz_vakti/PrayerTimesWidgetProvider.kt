package com.example.namaz_vakti

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

/**
 * Large home-screen widget listing all six prayer times for the day, with the
 * next prayer highlighted. Values are written from Flutter via home_widget.
 */
class PrayerTimesWidgetProvider : HomeWidgetProvider() {

    private val orange = 0xFFFF9000.toInt()
    private val white = 0xFFFFFFFF.toInt()
    private val whiteDim = 0xB3FFFFFF.toInt()

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        val nameIds = mapOf(
            "imsak" to R.id.name_imsak, "gunes" to R.id.name_gunes,
            "ogle" to R.id.name_ogle, "ikindi" to R.id.name_ikindi,
            "aksam" to R.id.name_aksam, "yatsi" to R.id.name_yatsi
        )
        val timeIds = mapOf(
            "imsak" to R.id.time_imsak, "gunes" to R.id.time_gunes,
            "ogle" to R.id.time_ogle, "ikindi" to R.id.time_ikindi,
            "aksam" to R.id.time_aksam, "yatsi" to R.id.time_yatsi
        )

        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.prayer_times_widget)
            views.setTextViewText(R.id.pt_date, widgetData.getString("date", ""))
            views.setTextViewText(R.id.pt_city, widgetData.getString("city", ""))

            val next = WidgetPrayers.nextKey(widgetData)
            for (key in nameIds.keys) {
                val nameId = nameIds.getValue(key)
                val timeId = timeIds.getValue(key)
                views.setTextViewText(nameId, widgetData.getString("p_${key}_name", key))
                views.setTextViewText(timeId, widgetData.getString("p_${key}_time", "--:--"))
                val highlighted = key == next
                views.setTextColor(nameId, if (highlighted) orange else whiteDim)
                views.setTextColor(timeId, if (highlighted) orange else white)
            }

            views.setOnClickPendingIntent(
                R.id.pt_root,
                HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java)
            )
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
