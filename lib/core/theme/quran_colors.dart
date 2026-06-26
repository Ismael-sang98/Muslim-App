import 'package:flutter/material.dart';
import 'app_theme.dart';

class QuranColors {
  QuranColors._();

  static Color bg(BuildContext ctx) => Theme.of(ctx).scaffoldBackgroundColor;

  static Color appBar(BuildContext ctx) =>
      Theme.of(ctx).appBarTheme.backgroundColor ?? AppTheme.darkGreen;

  static Color card(BuildContext ctx) => _dark(ctx)
      ? Colors.white.withValues(alpha: 0.05)
      : Colors.white.withValues(alpha: 0.08);

  static Color border(BuildContext ctx) => _dark(ctx)
      ? Colors.white.withValues(alpha: 0.07)
      : Colors.white.withValues(alpha: 0.1);

  static Color divider(BuildContext ctx) => _dark(ctx)
      ? Colors.white.withValues(alpha: 0.07)
      : Colors.white.withValues(alpha: 0.09);

  static Color searchFill(BuildContext ctx) => _dark(ctx)
      ? Colors.white.withValues(alpha: 0.06)
      : Colors.white.withValues(alpha: 0.1);

  static bool _dark(BuildContext ctx) =>
      Theme.of(ctx).brightness == Brightness.dark;
}
