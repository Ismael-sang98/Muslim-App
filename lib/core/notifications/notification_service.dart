import 'dart:developer' as developer;
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../hive/hive_service.dart';
import '../hive/models/horaires_jour_model.dart';
import '../utils/localized_names.dart';
import '../../l10n/app_localizations.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'prayer_channel';
  static const String _channelName = 'Namaz Bildirimleri';

  static const String _persistentChannelId = 'prayer_persistent';
  static const String _persistentChannelName = 'Sonraki Namaz';
  static const int _persistentId = 999999;

  static const _batteryChannel = MethodChannel('namaz_vakti/battery');

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

    // Crée les canaux Android explicitement dès le démarrage
    // → visibles dans Paramètres > Notifications dès le premier lancement
    if (Platform.isAndroid) {
      final impl = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await impl?.createNotificationChannel(
        const AndroidNotificationChannel(
          _channelId,
          _channelName,
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
        ),
      );
      await impl?.createNotificationChannel(
        const AndroidNotificationChannel(
          _persistentChannelId,
          _persistentChannelName,
          importance: Importance.low,
          playSound: false,
          enableVibration: false,
        ),
      );
    }
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

  static Future<bool> isIgnoringBatteryOptimizations() async {
    if (!Platform.isAndroid) return true;
    try {
      return await _batteryChannel.invokeMethod<bool>(
            'isIgnoringBatteryOptimizations',
          ) ??
          false;
    } catch (_) {
      return false;
    }
  }

  static Future<void> requestBatteryOptimizationExemption() async {
    if (!Platform.isAndroid) return;
    try {
      await _batteryChannel.invokeMethod('requestIgnoreBatteryOptimizations');
    } catch (e) {
      developer.log(
        'Battery optimization request failed',
        error: e,
        name: 'NotificationService',
      );
    }
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

    int scheduled = 0;
    int failed = 0;

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
            scheduled++;
          } catch (e) {
            failed++;
            developer.log(
              'Reminder failed: $prayerKey ${jour.date}',
              error: e,
              name: 'NotificationService',
            );
          }
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
            scheduled++;
          } catch (e) {
            failed++;
            developer.log(
              'At-time failed: $prayerKey ${jour.date}',
              error: e,
              name: 'NotificationService',
            );
          }
        }
      }
    }

    developer.log(
      'Scheduling done — ok: $scheduled, errors: $failed, exactAlarms: $canExact',
      name: 'NotificationService',
    );

    // Re-show persistent notification after cancelAll()
    await updatePersistentNotification(horaires);
  }

  /// Localizations resolved from the persisted app language (no BuildContext
  /// is available when notifications are scheduled in the background).
  static AppLocalizations get _l10n {
    final lang = HiveService.getOrCreateSettings().langue;
    return lookupAppLocalizations(Locale(lang));
  }

  static String _buildAtTimeTitle(String prayerKey) {
    final l10n = _l10n;
    return l10n.notifAtTimeTitle(prayerName(l10n, prayerKey));
  }

  static String _buildAtTimeBody(String prayerKey) {
    final l10n = _l10n;
    return l10n.notifAtTimeBody(prayerName(l10n, prayerKey));
  }

  static String _buildTitle(String prayerKey) {
    final l10n = _l10n;
    return l10n.notifReminderTitle(prayerName(l10n, prayerKey));
  }

  static String _buildBody(String prayerKey, int minutes) {
    final l10n = _l10n;
    return l10n.notifReminderBody(prayerName(l10n, prayerKey), minutes);
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

    final l10n = _l10n;

    await _plugin.show(
      _persistentId,
      '🕌 ${prayerName(l10n, nextKey)} — $nextTime',
      l10n.nextPrayer,
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
