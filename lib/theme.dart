import 'package:flutter/material.dart';

class AppColors {
  // Background gradient (very dark with subtle blue tint at top)
  static const Color bgTop = Color(0xFF0B1420);
  static const Color bgBottom = Color(0xFF000000);

  // Cards
  static const Color card = Color(0xFF1A1F26);
  static const Color cardSoft = Color(0xFF202730);
  static const Color cardChip = Color(0xFF2A3340);

  // Brand
  static const Color ozonBlue = Color(0xFF005BFF);
  static const Color accentBlue = Color(0xFF1E88FF);

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF9AA3AE);
  static const Color textTertiary = Color(0xFF6E7682);

  // Banner gradient (premium / crown)
  static const Color premiumA = Color(0xFF1E3A8A);
  static const Color premiumB = Color(0xFF3B82F6);

  // Recommendation banner gradient
  static const Color recoA = Color(0xFF2D5BBF);
  static const Color recoB = Color(0xFFB7A7E8);

  static const Color divider = Color(0xFF1F242C);
}

ThemeData buildOzonTheme() {
  const baseFont = 'SF Pro Display';
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.black,
    primaryColor: AppColors.ozonBlue,
    splashColor: Colors.white10,
    highlightColor: Colors.white10,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.ozonBlue,
      secondary: AppColors.accentBlue,
      surface: AppColors.card,
    ),
    fontFamily: baseFont,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.textPrimary),
      bodyMedium: TextStyle(color: AppColors.textPrimary),
      titleLarge: TextStyle(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}
