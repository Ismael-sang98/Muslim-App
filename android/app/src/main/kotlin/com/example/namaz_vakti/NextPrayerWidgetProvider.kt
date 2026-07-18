package com.example.namaz_vakti

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

/**
 * Small home-screen widget showing the next prayer (name + time + city).
 * Values are written from Flutter via the home_widget plugin; this provider
 * only renders whatever strings are stored.
 */
class NextPrayerWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        // Recompute the next prayer from the six saved times so the widget
        // stays correct at each system refresh, even while the app is closed.
        val nextKey = WidgetPrayers.nextKey(widgetData)
        val name = widgetData.getString("p_${nextKey}_name", "—")
        val time = widgetData.getString("p_${nextKey}_time", "--:--")

        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.next_prayer_widget).apply {
                setTextViewText(
                    R.id.w_label,
                    widgetData.getString("next_label", "Sonraki Namaz")
                )
                setTextViewText(R.id.w_name, name)
                setTextViewText(R.id.w_time, time)
                setTextViewText(R.id.w_city, widgetData.getString("city", ""))

                // Tap anywhere → open the app
                val pendingIntent = HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java
                )
                setOnClickPendingIntent(R.id.w_root, pendingIntent)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
