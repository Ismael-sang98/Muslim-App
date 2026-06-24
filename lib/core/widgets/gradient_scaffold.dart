import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GradientScaffold extends StatelessWidget {
  final Widget body;
  final bool extendBodyBehindHeader;

  const GradientScaffold({
    super.key,
    required this.body,
    this.extendBodyBehindHeader = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: isDark ? AppTheme.darkGradient : AppTheme.mainGradient,
        ),
        child: body,
      ),
    );
  }
}
