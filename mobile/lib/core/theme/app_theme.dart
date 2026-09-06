import 'package:flutter/material.dart';

// All the colors used in the app live here.
// If we ever want to change the purple shade, we only edit this one file.
class AppColors {
  static const primaryPurple = Color(0xFF7C4DFF);
  static const darkPurple = Color(0xFF5E35B1);
  static const lightPurple = Color(0xFFEDE7F6);
  static const background = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF202124);
  static const textSecondary = Color(0xFF6B7280);
  static const success = Color(0xFF2E7D32);
  static const error = Color(0xFFC62828);
}

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.background,

    // This tells every button, checkbox, etc. what "purple" means in this app.
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryPurple,
      primary: AppColors.primaryPurple,
      secondary: AppColors.lightPurple,
      error: AppColors.error,
    ),

    textTheme: const TextTheme(
      // Big numbers, like the balance on the dashboard
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      // Section titles, like "Recent transactions"
      titleMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      // Normal text
      bodyMedium: TextStyle(
        fontSize: 14,
        color: AppColors.textPrimary,
      ),
      // Smaller, greyed out text, like dates or hints
      bodySmall: TextStyle(
        fontSize: 12,
        color: AppColors.textSecondary,
      ),
    ),

    // Rounded cards everywhere, matches the spec's "rounded cards" requirement
    cardTheme: CardThemeData(
      color: AppColors.lightPurple,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),

    // Rounded buttons everywhere
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryPurple,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),

    // Input fields (email, password, amount, etc.)
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.lightPurple,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
  );
}