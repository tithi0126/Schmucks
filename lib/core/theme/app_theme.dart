import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: AppColors.forestGreen,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.forestGreen,
        primary: AppColors.forestGreen,
        secondary: AppColors.softPink,
        surface: AppColors.softPink,
      ),
      // Premium default typography fallback (Deep Green text on Soft Pink canvas)
      textTheme: GoogleFonts.playfairDisplayTextTheme().apply(
        bodyColor: AppColors.forestGreen,
        displayColor: AppColors.forestGreen,
      ),
      scaffoldBackgroundColor: AppColors.softPink,
    );
  }
}
