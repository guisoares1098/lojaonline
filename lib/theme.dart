import 'package:flutter/material.dart';

/// Paleta de cores e tema central do aplicativo.
class AppColors {
  static const Color primary = Color(0xFF075EDB);
  static const Color primaryDark = Color(0xFF0A2E66);
  static const Color success = Color(0xFF2EAD55);
  static const Color warning = Color(0xFFE53935);
  static const Color background = Color(0xFFF7F9FC);
  static const Color surfaceTint = Color(0xFFEAF4FF);
}

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      centerTitle: false,
    ),
  );
}
