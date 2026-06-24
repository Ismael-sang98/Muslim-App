import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/hive/models/horaires_jour_model.dart';
import '../../../core/theme/app_theme.dart';

class DayDetailSheet extends StatelessWidget {
  final HorairesJourModel horaires;

  const DayDetailSheet({super.key, required this.horaires});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.92,
      minChildSize: 0.4,
      expand: false,
      builder: (_, controller) {
        return Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: Column(
                children: [
                  Text(
                    _formatDate(horaires.date),
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  if (horaires.dateHijri.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      horaires.dateHijri,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppTheme.accentOrange,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Divider(color: Colors.white.withValues(alpha: 0.15)),
            Expanded(
              child: ListView.builder(
                controller: controller,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                itemCount: HorairesJourModel.prayerKeys.length,
                itemBuilder: (ctx, i) {
                  final key = HorairesJourModel.prayerKeys[i];
                  return _PrayerPillRow(
                    prayerKey: key,
                    time: horaires.timeForPrayer(key),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(String date) {
    // 'YYYY-MM-DD' → 'DD.MM.YYYY'
    final parts = date.split('-');
    if (parts.length == 3) return '${parts[2]}.${parts[1]}.${parts[0]}';
    return date;
  }
}

class _PrayerPillRow extends StatelessWidget {
  final String prayerKey;
  final String time;

  const _PrayerPillRow({required this.prayerKey, required this.time});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Text(_icon(prayerKey), style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              _name(prayerKey),
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
          ),
          Text(
            time,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
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

  String _icon(String key) {
    const icons = {
      'imsak': '🌙',
      'gunes': '🌅',
      'ogle': '☀️',
      'ikindi': '🌤️',
      'aksam': '🌇',
      'yatsi': '🌃',
    };
    return icons[key] ?? '🕌';
  }
}
