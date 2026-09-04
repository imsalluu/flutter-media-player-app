import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand & Palette Colors - Electric Indigo & Neon Cyan Cyber Aesthetic
  static const primaryIndigo = Color(0xFF6366F1); // Electric Indigo
  static const primaryViolet = Color(0xFF8B5CF6); // Cyber Violet
  static const primaryCyan = Color(0xFF06B6D4); // Neon Cyan
  static const primaryCoral = Color(0xFFFF3366); // Cyber Coral Red
  static const primaryEmerald = Color(0xFF10B981); // Emerald Wave
  static const primaryAmber = Color(0xFFF59E0B); // Amber Glow

  static const bgDark = Color(0xFF090A10); // Deep Obsidian Canvas
  static const cardDark = Color(0xFF131520); // Dark Slate Card
  static const cardBorderDark = Color(0xFF222638); // Fine Border
  static const surfaceDark = Color(0xFF1A1D2D);

  static const bgLight = Color(0xFFF6F8FC);
  static const cardLight = Color(0xFFFFFFFF);
  static const cardBorderLight = Color(0xFFE5E9F2);

  // Aurora Gradients
  static const primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryIndigo, primaryCyan],
  );

  static const violetCoralGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryViolet, primaryCoral],
  );

  static const emeraldCyanGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryEmerald, primaryCyan],
  );

  static const amberCoralGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryAmber, primaryCoral],
  );

  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.plusJakartaSansTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: bgLight,
      primaryColor: primaryIndigo,
      colorScheme: const ColorScheme.light(
        primary: primaryIndigo,
        secondary: primaryCyan,
        surface: cardLight,
        onSurface: Color(0xFF0F172A),
        surfaceContainerHighest: Color(0xFFEFF2F8),
      ),
      textTheme: baseTextTheme.copyWith(
        titleLarge: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)),
        titleMedium: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: const Color(0xFF0F172A)),
        bodyMedium: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w500, color: const Color(0xFF334155)),
        bodySmall: GoogleFonts.plusJakartaSans(color: const Color(0xFF64748B)),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: Color(0xFF0F172A)),
        titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
      ),
      iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
    );
  }

  static ThemeData get darkTheme {
    final baseTextTheme = GoogleFonts.plusJakartaSansTextTheme(ThemeData.dark().textTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgDark,
      primaryColor: primaryIndigo,
      colorScheme: const ColorScheme.dark(
        primary: primaryIndigo,
        secondary: primaryCyan,
        surface: cardDark,
        onSurface: Color(0xFFF8FAFC),
        surfaceContainerHighest: surfaceDark,
      ),
      textTheme: baseTextTheme.copyWith(
        titleLarge: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: Colors.white),
        titleMedium: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: Colors.white),
        bodyMedium: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w500, color: const Color(0xFFCBD5E1)),
        bodySmall: GoogleFonts.plusJakartaSans(color: const Color(0xFF94A3B8)),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    );
  }
}
