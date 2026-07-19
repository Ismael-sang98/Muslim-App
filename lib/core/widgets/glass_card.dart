import 'dart:ui';
import 'package:flutter/material.dart';

/// Reusable frosted-glass (glassmorphism) surface: real backdrop blur + a
/// low-opacity WHITE fill (no colour tint, so the blurred background stays
/// clearly visible through it) + a thin luminous rim + a soft shadow.
///
/// Gold is never used as a fill here — only borders/text/icons carry the gold
/// accent (passed via [borderColor]). Meant for fixed cards, never for the
/// scrolling background; each instance is a separate GPU pass.
class GlassCard extends StatelessWidget {
  final Widget child;
  final double radius;
  final double blur;
  final EdgeInsetsGeometry? padding;

  /// Rim colour; defaults to a soft white edge. Pass gold for the hero.
  final Color? borderColor;

  /// White translucency of the frost fill (0.15–0.20 keeps real transparency).
  final double fillOpacity;

  final List<BoxShadow>? shadow;

  const GlassCard({
    super.key,
    required this.child,
    this.radius = 22,
    this.blur = 18,
    this.padding,
    this.borderColor,
    this.fillOpacity = 0.16,
    this.shadow,
  });

  @override
  Widget build(BuildContext context) {
    final br = BorderRadius.circular(radius);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: br,
        boxShadow: shadow ??
            [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.20),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
      ),
      child: ClipRRect(
        borderRadius: br,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: br,
              // Pure white frost, slightly stronger at the top-left so the card
              // reads as glass without hiding the green blobs behind it.
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: fillOpacity),
                  Colors.white.withValues(alpha: fillOpacity * 0.6),
                ],
              ),
              border: Border.all(
                color: borderColor ?? Colors.white.withValues(alpha: 0.22),
                width: 1,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
