import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/hive/models/horaires_jour_model.dart';
import '../../../core/theme/app_theme.dart';

class ProgressBarWidget extends StatefulWidget {
  final HorairesJourModel horaires;
  final String? currentPrayerKey;
  final String? nextPrayerKey;

  const ProgressBarWidget({
    super.key,
    required this.horaires,
    required this.currentPrayerKey,
    required this.nextPrayerKey,
  });

  @override
  State<ProgressBarWidget> createState() => _ProgressBarWidgetState();
}

class _ProgressBarWidgetState extends State<ProgressBarWidget>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  late AnimationController _glowCtrl;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.currentPrayerKey == null || widget.nextPrayerKey == null) {
      return const SizedBox.shrink();
    }

    final now = DateTime.now();
    final reference = DateTime(now.year, now.month, now.day);
    final currentDt =
        widget.horaires.timeAsDateTime(widget.currentPrayerKey!, reference);
    final nextDt =
        widget.horaires.timeAsDateTime(widget.nextPrayerKey!, reference);

    final totalSeconds = nextDt.difference(currentDt).inSeconds;
    final elapsedSeconds = now.difference(currentDt).inSeconds;
    final progress = totalSeconds > 0
        ? (elapsedSeconds / totalSeconds).clamp(0.0, 1.0)
        : 0.0;

    final remaining = nextDt.difference(now);
    final rh = remaining.inHours;
    final rm = remaining.inMinutes % 60;
    final rs = remaining.inSeconds % 60;
    final remainingStr = rh > 0
        ? '${rh}s ${rm.toString().padLeft(2, '0')}dk ${rs.toString().padLeft(2, '0')}sn'
        : '${rm}dk ${rs.toString().padLeft(2, '0')}sn';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Column(
          children: [
            // Labels
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _PrayerLabel(
                  name: _name(widget.currentPrayerKey!),
                  time: widget.horaires.timeForPrayer(widget.currentPrayerKey!),
                  align: CrossAxisAlignment.start,
                  color: AppTheme.primaryGreen,
                ),
                Text(
                  remainingStr,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.65),
                  ),
                ),
                _PrayerLabel(
                  name: _name(widget.nextPrayerKey!),
                  time: widget.horaires.timeForPrayer(widget.nextPrayerKey!),
                  align: CrossAxisAlignment.end,
                  color: AppTheme.accentOrange,
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Barre avec LayoutBuilder pour connaître la largeur exacte
            AnimatedBuilder(
              animation: _glowCtrl,
              builder: (context, _) {
                final glow = 0.4 + _glowCtrl.value * 0.6;
                return LayoutBuilder(
                  builder: (context, constraints) {
                    const barHeight = 8.0;
                    const dotSize = 16.0;
                    final totalWidth = constraints.maxWidth;
                    final fillWidth =
                        (totalWidth * progress).clamp(barHeight, totalWidth);
                    final dotLeft =
                        (fillWidth - dotSize / 2).clamp(0.0, totalWidth - dotSize);

                    return SizedBox(
                      height: dotSize,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // Track
                          Positioned(
                            left: 0,
                            right: 0,
                            top: (dotSize - barHeight) / 2,
                            height: barHeight,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(barHeight / 2),
                              ),
                            ),
                          ),

                          // Fill gradient
                          Positioned(
                            left: 0,
                            width: fillWidth,
                            top: (dotSize - barHeight) / 2,
                            height: barHeight,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(barHeight / 2),
                                gradient: const LinearGradient(
                                  colors: [
                                    AppTheme.primaryGreen,
                                    AppTheme.accentOrange,
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.accentOrange
                                        .withValues(alpha: 0.45 * glow),
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Dot lumineux
                          Positioned(
                            left: dotLeft,
                            top: 0,
                            width: dotSize,
                            height: dotSize,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.accentOrange
                                        .withValues(alpha: 0.85 * glow),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
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
}

class _PrayerLabel extends StatelessWidget {
  final String name;
  final String time;
  final CrossAxisAlignment align;
  final Color color;

  const _PrayerLabel({
    required this.name,
    required this.time,
    required this.align,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: align,
      children: [
        Text(
          name,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        Text(
          time,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w300,
            color: Colors.white.withValues(alpha: 0.55),
          ),
        ),
      ],
    );
  }
}
