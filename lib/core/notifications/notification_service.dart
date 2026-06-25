import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../hive/models/horaires_jour_model.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'prayer_channel';
  static const String _channelName = 'Namaz Bildirimleri';

  static const String _persistentChannelId = 'prayer_persistent';
  static const String _persistentChannelName = 'Sonraki Namaz';
  static const int _persistentId = 999999;

  static Future<void> init() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );
  }

  static Future<bool> requestPermission() async {
    if (Platform.isIOS) {
      final impl = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      final granted = await impl?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    } else if (Platform.isAndroid) {
      final impl = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      final granted = await impl?.requestNotificationsPermission();
      return granted ?? false;
    }
    return false;
  }

  static Future<void> scheduleMonthlyPrayers({
    required List<HorairesJourModel> horaires,
    required Map<String, bool> notificationsActives,
    required int minutesAvantRappel,
  }) async {
    await _plugin.cancelAll();

    final istanbulTz = tz.getLocation('Europe/Istanbul');
    final nowTz = tz.TZDateTime.now(istanbulTz);
    final maxDays = Platform.isIOS ? 10 : 31;

    final canExact = await canScheduleExactAlarms();
    final scheduleMode = canExact
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;

    for (final jour in horaires) {
      final dateParts = jour.date.split('-');
      if (dateParts.length < 3) continue;
      final year = int.tryParse(dateParts[0]);
      final month = int.tryParse(dateParts[1]);
      final day = int.tryParse(dateParts[2]);
      if (year == null || month == null || day == null) continue;

      for (
        int prayerIndex = 0;
        prayerIndex < HorairesJourModel.prayerKeys.length;
        prayerIndex++
      ) {
        final prayerKey = HorairesJourModel.prayerKeys[prayerIndex];
        if (notificationsActives[prayerKey] != true) continue;

        final timeStr = jour.timeForPrayer(prayerKey);
        final timeParts = timeStr.split(':');
        if (timeParts.length < 2) continue;
        final hour = int.tryParse(timeParts[0]);
        final minute = int.tryParse(timeParts[1]);
        if (hour == null || minute == null) continue;

        final prayerTz = tz.TZDateTime(
          istanbulTz,
          year,
          month,
          day,
          hour,
          minute,
        );
        if (prayerTz.difference(nowTz).inDays >= maxDays) continue;

        final details = NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            importance: Importance.high,
            priority: Priority.high,
            playSound: true,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        );

        // IDs unique par année/mois/jour/prière — dernier chiffre 0=rappel 1=heure exacte
        final baseId =
            (year % 100) * 100000 + month * 10000 + day * 100 + prayerIndex * 10;

        // Reminder notification (X minutes before)
        final reminderTz = prayerTz.subtract(Duration(minutes: minutesAvantRappel));
        if (reminderTz.isAfter(nowTz)) {
          try {
            await _plugin.zonedSchedule(
              baseId,
              _buildTitle(prayerKey),
              _buildBody(prayerKey, minutesAvantRappel),
              reminderTz,
              details,
              androidScheduleMode: scheduleMode,
              uiLocalNotificationDateInterpretation:
                  UILocalNotificationDateInterpretation.absoluteTime,
            );
          } catch (_) {}
        }

        // At-time notification (exact prayer time)
        if (prayerTz.isAfter(nowTz)) {
          try {
            await _plugin.zonedSchedule(
              baseId + 1,
              _buildAtTimeTitle(prayerKey),
              _buildAtTimeBody(prayerKey),
              prayerTz,
              details,
              androidScheduleMode: scheduleMode,
              uiLocalNotificationDateInterpretation:
                  UILocalNotificationDateInterpretation.absoluteTime,
            );
          } catch (_) {}
        }
      }
    }

    // Re-show persistent notification after cancelAll()
    await updatePersistentNotification(horaires);
  }

  static String _buildAtTimeTitle(String prayerKey) {
    const names = {
      'imsak': 'İmsak',
      'gunes': 'Güneş',
      'ogle': 'Öğle',
      'ikindi': 'İkindi',
      'aksam': 'Akşam',
      'yatsi': 'Yatsı',
    };
    return '🕌 ${names[prayerKey] ?? prayerKey} Vakti Girdi';
  }

  static String _buildAtTimeBody(String prayerKey) {
    const names = {
      'imsak': 'İmsak',
      'gunes': 'Güneş',
      'ogle': 'Öğle',
      'ikindi': 'İkindi',
      'aksam': 'Akşam',
      'yatsi': 'Yatsı',
    };
    return '${names[prayerKey] ?? prayerKey} namazının vakti geldi';
  }

  static String _buildTitle(String prayerKey) {
    const names = {
      'imsak': 'İmsak',
      'gunes': 'Güneş',
      'ogle': 'Öğle',
      'ikindi': 'İkindi',
      'aksam': 'Akşam',
      'yatsi': 'Yatsı',
    };
    return '🕌 ${names[prayerKey] ?? prayerKey} Vakti';
  }

  static String _buildBody(String prayerKey, int minutes) {
    const names = {
      'imsak': 'İmsak',
      'gunes': 'Güneş',
      'ogle': 'Öğle',
      'ikindi': 'İkindi',
      'aksam': 'Akşam',
      'yatsi': 'Yatsı',
    };
    return '${names[prayerKey] ?? prayerKey} namazına $minutes dakika kaldı';
  }

  static Future<void> updatePersistentNotification(
      List<HorairesJourModel> horaires) async {
    if (!Platform.isAndroid) return;

    final now = DateTime.now();
    final todayStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    HorairesJourModel? today;
    try {
      today = horaires.firstWhere((h) => h.date == todayStr);
    } catch (_) {
      return;
    }

    final reference = DateTime(now.year, now.month, now.day);
    String? nextKey;
    String? nextTime;

    for (final key in HorairesJourModel.prayerKeys) {
      final dt = today.timeAsDateTime(key, reference);
      if (dt.isAfter(now)) {
        nextKey = key;
        nextTime = today.timeForPrayer(key);
        break;
      }
    }

    nextKey ??= 'imsak';
    nextTime ??= today.imsak;

    const names = {
      'imsak': 'İmsak',
      'gunes': 'Güneş',
      'ogle': 'Öğle',
      'ikindi': 'İkindi',
      'aksam': 'Akşam',
      'yatsi': 'Yatsı',
    };

    await _plugin.show(
      _persistentId,
      '🕌 ${names[nextKey] ?? nextKey} — $nextTime',
      'Bir sonraki namaz',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _persistentChannelId,
          _persistentChannelName,
          importance: Importance.low,
          priority: Priority.low,
          ongoing: true,
          autoCancel: false,
          showWhen: false,
          playSound: false,
          enableVibration: false,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }

  static Future<bool> canScheduleExactAlarms() async {
    if (!Platform.isAndroid) return true;
    final impl = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    return await impl?.canScheduleExactNotifications() ?? false;
  }

  static Future<void> requestExactAlarmPermission() async {
    if (!Platform.isAndroid) return;
    final impl = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await impl?.requestExactAlarmsPermission();
  }

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
