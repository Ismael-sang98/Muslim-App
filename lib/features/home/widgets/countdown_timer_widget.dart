import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../home_provider.dart';
import '../../settings/settings_provider.dart';

class CountdownTimerWidget extends ConsumerStatefulWidget {
  const CountdownTimerWidget({super.key});

  @override
  ConsumerState<CountdownTimerWidget> createState() =>
      _CountdownTimerWidgetState();
}

class _CountdownTimerWidgetState extends ConsumerState<CountdownTimerWidget> {
  Timer? _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateCountdown();
    });
    _updateCountdown();
  }

  void _updateCountdown() {
    final villeId = ref.read(settingsProvider).villeId;
    final next = ref.read(nextPrayerProvider(villeId));

    if (next != null) {
      final remaining = next.remaining;
      if (remaining.isNegative) {
        ref.invalidate(nextPrayerProvider(villeId));
        ref.invalidate(currentPrayerProvider(villeId));
      } else {
        if (mounted) setState(() => _remaining = remaining);
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final next = ref.watch(nextPrayerProvider(settings.villeId));

    if (next == null) return const SizedBox.shrink();

    final h = _remaining.inHours;
    final m = _remaining.inMinutes % 60;
    final s = _remaining.inSeconds % 60;
    final timeStr =
        '${h.toString().padLeft(2, '0')} : ${m.toString().padLeft(2, '0')} : ${s.toString().padLeft(2, '0')}';

    return Center(
      child: Container(
        width: 180,
        height: 50,
        margin: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: const Color.fromARGB(66, 0, 0, 0),
          borderRadius: BorderRadius.circular(27.5),
          border: Border.all(
            color: AppTheme.accentOrange.withValues(alpha: 0.8),
            width: 1.5,
          ),
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, anim) =>
                FadeTransition(opacity: anim, child: child),
            child: Text(
              timeStr,
              key: ValueKey(timeStr),
              style: GoogleFonts.teko(
                fontSize: 30,
                fontWeight: FontWeight.w500,
                color: AppTheme.accentOrange,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
