import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/localized_names.dart';
import '../../../l10n/app_localizations.dart';

class PrayerListTile extends StatelessWidget {
  final String prayerKey;
  final String time;
  final bool isActive;
  final bool isNext;

  const PrayerListTile({
    super.key,
    required this.prayerKey,
    required this.time,
    this.isActive = false,
    this.isNext = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 55,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      decoration: BoxDecoration(
        color: isActive
            ? AppTheme.accentOrange.withValues(alpha: 0.85)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(25),
        border: isNext
            ? Border.all(color: AppTheme.accentOrange, width: 1.5)
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Text(
              prayerName(AppLocalizations.of(context), prayerKey),
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            Text(
              _formatTime(time),
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: isActive ? AppTheme.darkGreen : Colors.white,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(String t) {
    // "HH:mm" → "HH : mm"
    if (t.contains(':')) {
      final parts = t.split(':');
      if (parts.length == 2) return '${parts[0]} : ${parts[1]}';
    }
    return t;
  }

}
