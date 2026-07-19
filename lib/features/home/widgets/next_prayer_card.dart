import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/localized_names.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../l10n/app_localizations.dart';
import '../../settings/settings_provider.dart';
import '../home_provider.dart';

/// Glassmorphism hero: a champagne frosted card with the next prayer name, its
/// time as the large figure, and a live countdown underneath in gold.
class NextPrayerCard extends ConsumerStatefulWidget {
  final NextPrayerInfo nextPrayer;

  const NextPrayerCard({super.key, required this.nextPrayer});

  @override
  ConsumerState<NextPrayerCard> createState() => _NextPrayerCardState();
}

class _NextPrayerCardState extends ConsumerState<NextPrayerCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glow;
  Timer? _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _glow = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _tick();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    final remaining = widget.nextPrayer.scheduledAt.difference(DateTime.now());
    if (remaining.isNegative) {
      final villeId = ref.read(settingsProvider).villeId;
      ref.invalidate(nextPrayerProvider(villeId));
      ref.invalidate(currentPrayerProvider(villeId));
      return;
    }
    if (mounted) setState(() => _remaining = remaining);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _glow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final name = prayerName(l10n, widget.nextPrayer.prayerKey);

    final h = _remaining.inHours;
    final m = _remaining.inMinutes % 60;
    final s = _remaining.inSeconds % 60;
    final remainingStr =
        '${h.toString().padLeft(2, '0')} : ${m.toString().padLeft(2, '0')} : ${s.toString().padLeft(2, '0')}';

    return GlassCard(
          //radius: 18,
          blur: 0,
          fillOpacity: 0,
          borderColor: AppTheme.accentOrange.withValues(alpha: 0),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          shadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 20,
              offset: const Offset(0, 14),
            ),
          ],
          child: Column(
            children: [
              // Label
              Text(
                l10n.nextPrayer.toUpperCase(),
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 3,
                  color: Colors.white.withValues(alpha: 0.55),
                ),
              ),
              const SizedBox(height: 10),
              // Prayer name (gold accent)
              Text(
                name,
                style: GoogleFonts.poppins(
                  fontSize: 25,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.accentOrange,
                ),
              ),
              const SizedBox(height: 6),
              // Big time with a soft gold glow
              AnimatedBuilder(
                animation: _glow,
                builder: (_, _) {
                  //final glow = reduceMotion ? 0.5 : 0.4 + _glow.value * 0.35;
                  return FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      widget.nextPrayer.timeString.replaceAll(':', ' : '),
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 96,
                        fontWeight: FontWeight.w600,
                        height: 1.0,
                        color: Colors.white.withValues(alpha: 0.92),
                        fontFeatures: const [FontFeature.tabularFigures()],
                        letterSpacing: -2,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              // Countdown in gold
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    remainingStr,
                    style: GoogleFonts.outfit(
                      fontSize: 35,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 2,
                      color: AppTheme.accentOrange,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.08, duration: 400.ms, curve: Curves.easeOut);
  }
}
