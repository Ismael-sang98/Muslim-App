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

  // Couleur unique par prière
  static const _colors = {
    'imsak': Color(0xFF5E81F4),
    'gunes': Color(0xFFFF9000),
    'ogle': Color(0xFF00BCD4),
    'ikindi': Color(0xFF4CAF50),
    'aksam': Color(0xFFE91E63),
    'yatsi': Color(0xFF9C27B0),
  };

  // Icône Material par prière
  static const _icons = {
    'imsak': Icons.brightness_3_rounded,
    'gunes': Icons.wb_sunny_rounded,
    'ogle': Icons.light_mode_rounded,
    'ikindi': Icons.wb_cloudy_outlined,
    'aksam': Icons.wb_twilight_rounded,
    'yatsi': Icons.nights_stay_rounded,
  };

  static const _names = {
    'imsak': 'İmsak',
    'gunes': 'Güneş',
    'ogle': 'Öğle',
    'ikindi': 'İkindi',
    'aksam': 'Akşam',
    'yatsi': 'Yatsı',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final isEnabled = settings.notificationsActives[prayerKey] ?? false;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = _colors[prayerKey] ?? AppTheme.primaryGreen;
    final iconData = _icons[prayerKey] ?? Icons.notifications_outlined;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          // Icon bubble
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: isEnabled
                  ? color.withValues(alpha: isDark ? 0.22 : 0.13)
                  : isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.grey.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              iconData,
              color: isEnabled
                  ? color
                  : isDark
                      ? Colors.white30
                      : Colors.grey.shade400,
              size: 20,
            ),
          ),

          const SizedBox(width: 12),

          // Name + time
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _names[prayerKey] ?? prayerKey,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.92),
                  ),
                ),
                if (todayTime != null)
                  Text(
                    todayTime!,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: isDark
                          ? Colors.white38
                          : AppTheme.darkGreen.withValues(alpha: 0.45),
                    ),
                  ),
              ],
            ),
          ),

          // Switch avec couleur par prière
          Theme(
            data: Theme.of(context).copyWith(
              switchTheme: SwitchThemeData(
                thumbColor: WidgetStateProperty.resolveWith(
                  (s) => s.contains(WidgetState.selected) ? color : null,
                ),
                trackColor: WidgetStateProperty.resolveWith(
                  (s) => s.contains(WidgetState.selected)
                      ? color.withValues(alpha: 0.35)
                      : null,
                ),
              ),
            ),
            child: Switch(
              value: isEnabled,
              onChanged: (value) async {
                ref
                    .read(settingsProvider.notifier)
                    .toggleNotification(prayerKey, value);
                final updated = ref.read(settingsProvider);
                final ps = ref.read(prayerDataProvider(updated.villeId));
                if (ps is PrayerDataLoaded) {
                  await NotificationService.scheduleMonthlyPrayers(
                    horaires: ps.horaires,
                    notificationsActives: updated.notificationsActives,
                    minutesAvantRappel: updated.minutesAvantRappel,
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
