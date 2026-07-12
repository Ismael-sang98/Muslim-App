import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/localized_names.dart';
import '../../../l10n/app_localizations.dart';
import '../home_provider.dart';

class NextPrayerCard extends StatefulWidget {
  final NextPrayerInfo nextPrayer;

  const NextPrayerCard({super.key, required this.nextPrayer});

  @override
  State<NextPrayerCard> createState() => _NextPrayerCardState();
}

class _NextPrayerCardState extends State<NextPrayerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowCtrl;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Label
        Text(
          AppLocalizations.of(context).nextPrayer.toUpperCase(),
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w300,
            color: Colors.white60,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 4),
        // Prayer name
        Text(
          prayerName(AppLocalizations.of(context), widget.nextPrayer.prayerKey),
          style: GoogleFonts.poppins(
            fontSize: 25,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 3),
        // Big time display with shimmer glow
        AnimatedBuilder(
          animation: _glowCtrl,
          builder: (_, _) {
            final opacity = 0.55 + _glowCtrl.value * 0.2;
            return FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                widget.nextPrayer.timeString.replaceAll(':', ' : '),
                style: GoogleFonts.teko(
                  fontSize: 150,
                  fontWeight: FontWeight.w800,
                  color: const Color.fromARGB(
                    255,
                    255,
                    255,
                    255,
                  ).withValues(alpha: opacity),
                  height: 1,
                  shadows: [
                    Shadow(
                      color: AppTheme.textDark.withValues(alpha: opacity * 1),
                      blurRadius: 2 + _glowCtrl.value * 5,
                    ),
                  ],
                ),
              ),
            );
          },
        ).animate().fadeIn(duration: 400.ms),
      ],
    );
  }

}
