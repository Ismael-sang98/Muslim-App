import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Shared organic, blur-free backdrop used across the whole app: a deep-green
/// canvas with several bold, overlapping green blobs (deep → vivid → sage) that
/// melt into each other. This variation is what makes the frosted [GlassCard]s
/// on top actually read as glass.
///
/// No gold here — gold stays an accent on text/borders/icons only. No
/// BackdropFilter in this layer (plain radial gradients) so it paints cheaply;
/// only the cards above do real blurring. Place it as `Positioned.fill` behind
/// the page content, inside a `Stack`.
class BlobBackground extends StatelessWidget {
  const BlobBackground({super.key});

  // Deep forest green — a dark shade of the palette's darkGreen (same hue).
  static const Color _deep = Color(0xFF0C2A19);

  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child: Stack(
        children: [
          // Deep-green canvas covering the scaffold gradient.
          Positioned.fill(child: ColoredBox(color: _deep)),

          // Vivid green — top-left
          Positioned(
            top: -70,
            left: -100,
            child: _Blob(color: AppTheme.primaryGreen, size: 380, opacity: 0.50),
          ),
          // Sage (light green) — right / middle
          Positioned(
            top: 170,
            right: -80,
            child: _Blob(color: AppTheme.lightGreen, size: 320, opacity: 0.42),
          ),
          // Deep green — bottom (depth)
          Positioned(
            bottom: -130,
            left: -40,
            child: _Blob(color: AppTheme.darkGreen, size: 400, opacity: 0.50),
          ),
          // Vivid green accent — bottom-left
          Positioned(
            bottom: 40,
            left: -90,
            child: _Blob(color: AppTheme.primaryGreen, size: 280, opacity: 0.30),
          ),
        ],
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  final Color color;
  final double size;
  final double opacity;
  const _Blob({required this.color, required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: opacity),
            color.withValues(alpha: opacity * 0.35),
            color.withValues(alpha: 0),
          ],
          stops: const [0.0, 0.55, 1.0],
        ),
      ),
    );
  }
}
