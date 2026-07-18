import 'package:home_widget/home_widget.dart';

/// One prayer row pushed to the widgets.
typedef WidgetPrayer = ({String key, String name, String time});

/// Pushes prayer data to the native Android home-screen widgets.
///
/// The app only stores the six prayer times (+ labels/city/date); the native
/// widgets compute which one is "next" themselves on every refresh, so they
/// stay correct even while the app is closed.
class HomeWidgetService {
  static const String _nextPrayerWidget = 'NextPrayerWidgetProvider';
  static const String _prayerTimesWidget = 'PrayerTimesWidgetProvider';

  static Future<void> update({
    required List<WidgetPrayer> prayers,
    required String label,
    required String city,
    required String date,
  }) async {
    try {
      await HomeWidget.saveWidgetData<String>('next_label', label);
      await HomeWidget.saveWidgetData<String>('city', city);
      await HomeWidget.saveWidgetData<String>('date', date);
      for (final p in prayers) {
        await HomeWidget.saveWidgetData<String>('p_${p.key}_name', p.name);
        await HomeWidget.saveWidgetData<String>('p_${p.key}_time', p.time);
      }
      await HomeWidget.updateWidget(androidName: _nextPrayerWidget);
      await HomeWidget.updateWidget(androidName: _prayerTimesWidget);
    } catch (_) {
      // Widget not added / plugin unavailable — ignore silently.
    }
  }
}
