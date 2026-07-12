import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Palette ──────────────────────────────────────────────────────────────────
  static const Color primaryGreen = Color(0xFF2EA85D);
  static const Color darkGreen = Color(0xFF124225);
  static const Color accentOrange = Color(0xFFFF9000);
  static const Color settingsBg = Color(0xFFD9D9D9);
  static const Color textDark = Color(0xFF1E1E1E);
  static const Color lightGreen = Color(0xFF56BC7C);
  static const Color lightWhite = Color(0xFFFFFFFF);

  // Legacy aliases used in a few widgets — kept for compatibility
  static const Color lightPrimary = primaryGreen;
  static const Color lightAccent = accentOrange;
  static const Color darkPrimary = primaryGreen;
  static const Color darkAccent = accentOrange;
  static const Color lightBackground = Color(0xFFD9D9D9);

  // ── Gradient ─────────────────────────────────────────────────────────────────
  static const LinearGradient mainGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primaryGreen, darkGreen],
  );

  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1A3025), Color(0xFF0A1510)],
  );

  // ── Light theme ───────────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: primaryGreen,
        secondary: accentOrange,
        surface: Colors.white,
        surfaceContainerHighest: settingsBg,
      ),
      scaffoldBackgroundColor: darkGreen,
      textTheme: _buildTextTheme(textDark, const Color(0xFF6C757D)),
      appBarTheme: AppBarTheme(
        backgroundColor: darkGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      cardTheme: const CardThemeData(
        color: Colors.white,
        elevation: 2,
        shadowColor: Color(0x1A000000),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: darkGreen,
        indicatorColor: accentOrange.withValues(alpha: 0.2),
        labelTextStyle: WidgetStateProperty.all(
          GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.white, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.white, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.white, width: 2),
        ),
        hintStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w100,
          color: Colors.white70,
          fontSize: 14,
        ),
        labelStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w500,
          color: Colors.white,
          fontSize: 14,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: darkGreen,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: settingsBg,
        selectedColor: primaryGreen.withValues(alpha: 0.15),
        labelStyle: GoogleFonts.poppins(fontSize: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? primaryGreen : Colors.grey,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? primaryGreen.withValues(alpha: 0.4)
              : Colors.grey.withValues(alpha: 0.3),
        ),
      ),
    );
  }

  // ── Dark theme ────────────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    const darkBg = Color(0xFF0D1117);
    const darkCard = Color(0xFF161B22);
    const darkText = Color(0xFFE6EDF3);

    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.dark(
        primary: primaryGreen,
        secondary: accentOrange,
        surface: darkCard,
        surfaceContainerHighest: darkBg,
      ),
      scaffoldBackgroundColor: darkBg,
      textTheme: _buildTextTheme(darkText, const Color(0xFF8B949E)),
      appBarTheme: AppBarTheme(
        backgroundColor: darkCard,
        foregroundColor: darkText,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          color: darkText,
          fontWeight: FontWeight.w500,
        ),
      ),
      cardTheme: const CardThemeData(
        color: darkCard,
        elevation: 2,
        shadowColor: Color(0x40000000),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: darkCard,
        indicatorColor: primaryGreen.withValues(alpha: 0.2),
        labelTextStyle: WidgetStateProperty.all(
          GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF30363D)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryGreen, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? primaryGreen : Colors.grey,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? primaryGreen.withValues(alpha: 0.4)
              : Colors.grey.withValues(alpha: 0.3),
        ),
      ),
    );
  }

  // ── Text theme ────────────────────────────────────────────────────────────────
  static TextTheme _buildTextTheme(Color primary, Color secondary) {
    return TextTheme(
      displayLarge: GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: primary,
      ),
      displayMedium: GoogleFonts.poppins(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: primary,
      ),
      headlineLarge: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: primary,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      titleLarge: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      titleMedium: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: primary,
      ),
      bodyLarge: GoogleFonts.poppins(fontSize: 16, color: primary),
      bodyMedium: GoogleFonts.poppins(fontSize: 14, color: primary),
      bodySmall: GoogleFonts.poppins(fontSize: 12, color: secondary),
      labelLarge: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      labelSmall: GoogleFonts.poppins(fontSize: 11, color: secondary),
    );
  }
}
