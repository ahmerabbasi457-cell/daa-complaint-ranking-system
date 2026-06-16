// lib/theme/app_theme.dart
// ─────────────────────────────────────────────────────────
// Central design system for the ComplaintRank app.
// Dark civic-tech aesthetic matching the web frontend.
// ─────────────────────────────────────────────────────────
 
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
 
class AppTheme {
  // ── Brand colours ──────────────────────────────────────
  static const Color bgVoid    = Color(0xFF080B12);
  static const Color bgBase    = Color(0xFF0D1117);
  static const Color bgSurface = Color(0xFF121921);
  static const Color bgCard    = Color(0xFF161D28);
  static const Color bgInput   = Color(0xFF1A2233);
  static const Color bgRaised  = Color(0xFF1C2535);
 
  static const Color accent    = Color(0xFF00D4AA);  // teal
  static const Color accentDim = Color(0x2200D4AA);
  static const Color accentGlow= Color(0x5500D4AA);
  static const Color accent2   = Color(0xFF3B82F6);  // blue
 
  static const Color amber     = Color(0xFFF59E0B);
  static const Color amberDim  = Color(0x1FF59E0B);
 
  static const Color text1     = Color(0xFFEEF2FF);
  static const Color text2     = Color(0xFF8899BB);
  static const Color text3     = Color(0xFF445577);
 
  static const Color urgencyHigh   = Color(0xFFEF4444);
  static const Color urgencyMedium = Color(0xFFF59E0B);
  static const Color urgencyLow    = Color(0xFF22C55E);
 
  static const Color borderColor   = Color(0xFF1E2D45);
  static const Color borderAccent  = Color(0x4400D4AA);
 
  static const Color spamColor    = Color(0xFFEF4444);
  static const Color clusterColor = Color(0xFF8B5CF6);
  static const Color rankGold     = Color(0xFFFBBF24);
  static const Color rankSilver   = Color(0xFF94A3B8);
  static const Color rankBronze   = Color(0xFFCD7C3D);
 
  // ── Typography ─────────────────────────────────────────
  static TextTheme get textTheme => GoogleFonts.outfitTextTheme().copyWith(
    displayLarge:  GoogleFonts.outfit(
      fontSize: 32, fontWeight: FontWeight.w800, color: text1, letterSpacing: -0.5),
    displayMedium: GoogleFonts.outfit(
      fontSize: 24, fontWeight: FontWeight.w700, color: text1),
    displaySmall:  GoogleFonts.outfit(
      fontSize: 20, fontWeight: FontWeight.w700, color: text1),
    headlineMedium:GoogleFonts.outfit(
      fontSize: 18, fontWeight: FontWeight.w700, color: text1),
    headlineSmall: GoogleFonts.outfit(
      fontSize: 16, fontWeight: FontWeight.w600, color: text1),
    titleLarge:    GoogleFonts.outfit(
      fontSize: 14, fontWeight: FontWeight.w600, color: text1),
    bodyLarge:     GoogleFonts.outfit(
      fontSize: 14, fontWeight: FontWeight.w400, color: text2),
    bodyMedium:    GoogleFonts.outfit(
      fontSize: 13, fontWeight: FontWeight.w400, color: text2),
    bodySmall:     GoogleFonts.dmMono(
      fontSize: 11, fontWeight: FontWeight.w400, color: text3),
    labelLarge:    GoogleFonts.outfit(
      fontSize: 13, fontWeight: FontWeight.w700, color: text1),
  );
 
  // ── Material Theme ─────────────────────────────────────
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bgBase,
    colorScheme: const ColorScheme.dark(
      primary:   accent,
      secondary: accent2,
      surface:   bgCard,
      error:     urgencyHigh,
    ),
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: bgSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.outfit(
        fontSize: 18, fontWeight: FontWeight.w800, color: text1),
      iconTheme: const IconThemeData(color: text2),
    ),
    cardTheme: CardThemeData(
      color: bgCard,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: borderColor, width: 1),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: bgInput,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: accent, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: urgencyHigh),
      ),
      hintStyle: GoogleFonts.outfit(color: text3, fontSize: 14),
      labelStyle: GoogleFonts.outfit(color: text2, fontSize: 13,
          fontWeight: FontWeight.w600),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accent,
        foregroundColor: bgBase,
        elevation: 0,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        textStyle: GoogleFonts.outfit(
          fontSize: 15, fontWeight: FontWeight.w700),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: accent,
        textStyle: GoogleFonts.outfit(
          fontSize: 13, fontWeight: FontWeight.w600),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: borderColor,
      thickness: 1,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: bgSurface,
      selectedItemColor: accent,
      unselectedItemColor: text3,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
  );
}
 
// ── Reusable gradient ───────────────────────────────────
const LinearGradient brandGradient = LinearGradient(
  colors: [AppTheme.accent, AppTheme.accent2],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);
 
const LinearGradient amberGradient = LinearGradient(
  colors: [AppTheme.amber, Color(0xFFFBBF24)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);