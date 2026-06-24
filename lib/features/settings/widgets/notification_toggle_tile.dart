import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/notifications/notification_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../home/home_provider.dart';
import '../settings_provider.dart';

class NotificationToggleTile extends ConsumerWidget {
  final String prayerKey;
  final String? todayTime;

  const NotificationToggleTile({
    super.key,
    required this.prayerKey,
    this.todayTime,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final isEnabled = settings.notificationsActives[prayerKey] ?? false;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              // Colored dot indicator
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: isEnabled ? AppTheme.primaryGreen : Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 14),
              // Prayer name
              Text(
                _name(prayerKey),
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).textTheme.bodyMedium?.color ?? AppTheme.textDark,
                ),
              ),
              const Spacer(),
              // Time
              if (todayTime != null)
                Text(
                  todayTime!,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w300,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withValues(alpha: 0.45)
                        : AppTheme.darkGreen.withValues(alpha: 0.55),
                  ),
                ),
              const SizedBox(width: 10),
              // Toggle
              Switch(
                value: isEnabled,
                activeThumbColor: AppTheme.primaryGreen,
                onChanged: (value) async {
                  ref
                      .read(settingsProvider.notifier)
                      .toggleNotification(prayerKey, value);
                  final updated = ref.read(settingsProvider);
                  final villeId = updated.villeId;
                  final ps = ref.read(prayerDataProvider(villeId));
                  if (ps is PrayerDataLoaded) {
                    await NotificationService.scheduleMonthlyPrayers(
                      horaires: ps.horaires,
                      notificationsActives: updated.notificationsActives,
                      minutesAvantRappel: updated.minutesAvantRappel,
                    );
                  }
                },
              ),
            ],
          ),
        ),
        if (prayerKey != 'yatsi')
          Divider(
            height: 1,
            color: AppTheme.settingsBg.withValues(alpha: 0.5),
          ),
      ],
    );
  }

  String _name(String key) {
    const names = {
      'imsak': 'İmsak',
      'gunes': 'Güneş',
      'ogle': 'Öğle',
      'ikindi': 'İkindi',
      'aksam': 'Akşam',
      'yatsi': 'Yatsı',
    };
    return names[key] ?? key;
  }
}
