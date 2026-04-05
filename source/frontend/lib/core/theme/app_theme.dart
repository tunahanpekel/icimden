// lib/core/theme/app_theme.dart
//
// İçimden Design System — Warm Emotional / Dark with terracotta accents
// Dark background + warm terracotta/peach primary colors

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // ─── Brand Palette ────────────────────────────────────────────────────────
  // Backgrounds (deep purple-dark)
  static const Color bgDeep        = Color(0xFF1A1028);
  static const Color bgMid         = Color(0xFF241535);
  static const Color bgSurface     = Color(0xFF2E1C42);
  static const Color bgBorder      = Color(0xFF3D2A55);

  // Primary (Terracotta/Warm)
  static const Color primary       = Color(0xFFE8735A);
  static const Color primaryDark   = Color(0xFFC55A43);

  // Accent
  static const Color accent        = Color(0xFFF5A97F); // Peach
  static const Color accentPurple  = Color(0xFFB97FE8); // Lavender
  static const Color accentBlue    = Color(0xFF7FA8E8); // Soft blue

  // Mood Colors
  static const Color moodTired     = Color(0xFF8BA7C7);
  static const Color moodAnxious   = Color(0xFFC4A4E8);
  static const Color moodHappy     = Color(0xFFF5C97F);
  static const Color moodSad       = Color(0xFF7DABC4);
  static const Color moodMotivated = Color(0xFFE87A5A);

  // Text
  static const Color textPrimary   = Color(0xFFF5EEF8);
  static const Color textSecondary = Color(0xFFA68CC4);
  static const Color textHint      = Color(0xFF6B4F8A);

  // Semantic
  static const Color success       = Color(0xFF7DD9A4);
  static const Color warning       = Color(0xFFF5C97F);
  static const Color error         = Color(0xFFE88A8A);

  // ─── Gradients ────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFE8735A), Color(0xFFC55A43)],
  );

  static const LinearGradient bgGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1A1028), Color(0xFF241535)],
  );

  static const LinearGradient warmGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE8735A), Color(0xFFF5A97F)],
  );

  // ─── Typography ───────────────────────────────────────────────────────────
  static TextStyle get displayLarge  => GoogleFonts.inter(fontSize: 40, fontWeight: FontWeight.w700, color: textPrimary,   letterSpacing: -1.0, height: 1.1);
  static TextStyle get displayMedium => GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w700, color: textPrimary,   letterSpacing: -0.5, height: 1.15);
  static TextStyle get headlineLarge => GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w600, color: textPrimary,   letterSpacing: -0.3, height: 1.2);
  static TextStyle get headlineMedium=> GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: textPrimary,   height: 1.3);
  static TextStyle get titleLarge    => GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w600, color: textPrimary,   height: 1.35);
  static TextStyle get titleMedium   => GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500, color: textPrimary,   height: 1.4);
  static TextStyle get bodyLarge     => GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400, color: textPrimary,   height: 1.6);
  static TextStyle get bodyMedium    => GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: textSecondary, height: 1.5);
  static TextStyle get labelLarge    => GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: textPrimary,   letterSpacing: 0.2);
  static TextStyle get labelMedium   => GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: textSecondary, letterSpacing: 0.3);
  static TextStyle get labelSmall    => GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: textHint,      letterSpacing: 0.5);

  // Message text — special style for AI message display
  static TextStyle get messageText   => GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w400, color: textPrimary,   height: 1.75, letterSpacing: 0.1);

  // ─── ThemeData ────────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgDeep,

      colorScheme: const ColorScheme.dark(
        primary:                  primary,
        primaryContainer:         Color(0xFF3A1A10),
        onPrimary:                textPrimary,
        secondary:                accent,
        secondaryContainer:       Color(0xFF3A2510),
        onSecondary:              bgDeep,
        tertiary:                 accentPurple,
        tertiaryContainer:        Color(0xFF2A1A3A),
        onTertiary:               bgDeep,
        surface:                  bgMid,
        surfaceContainerHighest:  bgSurface,
        onSurface:                textPrimary,
        onSurfaceVariant:         textSecondary,
        outline:                  bgBorder,
        error:                    error,
        onError:                  bgDeep,
        // ignore: deprecated_member_use
        background:               bgDeep,
      ),

      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge:   displayLarge,
        displayMedium:  displayMedium,
        headlineLarge:  headlineLarge,
        headlineMedium: headlineMedium,
        titleLarge:     titleLarge,
        titleMedium:    titleMedium,
        bodyLarge:      bodyLarge,
        bodyMedium:     bodyMedium,
        labelLarge:     labelLarge,
        labelMedium:    labelMedium,
        labelSmall:     labelSmall,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: headlineMedium,
        iconTheme: const IconThemeData(color: textPrimary),
      ),

      cardTheme: CardThemeData(
        color: bgMid,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: bgBorder, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: labelLarge.copyWith(fontSize: 16),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: const BorderSide(color: bgBorder, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: labelLarge,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bgSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border:         OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: bgBorder)),
        enabledBorder:  OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: bgBorder)),
        focusedBorder:  OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: primary, width: 1.5)),
        labelStyle: bodyMedium,
        hintStyle:  labelMedium,
      ),

      dividerTheme: const DividerThemeData(color: bgBorder, thickness: 1, space: 1),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: bgMid,
        selectedItemColor: primary,
        unselectedItemColor: textHint,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: bgSurface,
        contentTextStyle: bodyMedium.copyWith(color: textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: bgMid,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: bgBorder),
        ),
        titleTextStyle:   headlineMedium,
        contentTextStyle: bodyMedium,
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: bgMid,
        modalBackgroundColor: bgMid,
        showDragHandle: true,
        dragHandleColor: bgBorder,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: bgBorder,
        circularTrackColor: bgBorder,
      ),

      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.iOS:     CupertinoPageTransitionsBuilder(),
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
    );
  }

  // ─── Mood helpers ─────────────────────────────────────────────────────────

  static Color moodColor(String mood) {
    return switch (mood) {
      'tired'     => moodTired,
      'anxious'   => moodAnxious,
      'happy'     => moodHappy,
      'sad'       => moodSad,
      'motivated' => moodMotivated,
      _           => primary,
    };
  }

  static String moodEmoji(String mood) {
    return switch (mood) {
      'tired'     => '🌙',
      'anxious'   => '🌀',
      'happy'     => '☀️',
      'sad'       => '🌧️',
      'motivated' => '🔥',
      _           => '💫',
    };
  }
}
