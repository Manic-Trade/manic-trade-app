import 'package:flutter/material.dart';

class AppTextThemes {
  const AppTextThemes._();


  static TextTheme apply(TextTheme textTheme, Color textColorPrimary) {
    return textTheme.copyWith(
     
      displayLarge: textTheme.displayLarge?.copyWith(
        color: textColorPrimary,
        fontSize: 57,
      ),

      displayMedium: textTheme.displayMedium?.copyWith(
        color: textColorPrimary,
        fontSize: 45,
      ),

      displaySmall: textTheme.displaySmall?.copyWith(
        color: textColorPrimary,
        fontSize: 36,
      ),

      headlineLarge: textTheme.headlineLarge?.copyWith(
        color: textColorPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 32,
      ),

      headlineMedium: textTheme.headlineMedium?.copyWith(
        color: textColorPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 28,
      ),

      headlineSmall: textTheme.headlineSmall?.copyWith(
        color: textColorPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 22,
      ),

      titleLarge: textTheme.titleLarge?.copyWith(
        color: textColorPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 20,
        height: 1.25,
        letterSpacing: 0,
      ),

      titleMedium: textTheme.titleMedium?.copyWith(
        color: textColorPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 18,
        height: 1,
        letterSpacing: 0,
      ),

      titleSmall: textTheme.titleSmall?.copyWith(
        color: textColorPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 16,
        height: 1,
        letterSpacing: 0.32,
      ),

      bodyLarge: textTheme.bodyLarge?.copyWith(
        color: textColorPrimary,
        fontWeight: FontWeight.w400,
        fontSize: 16,
        height: 1.25,
        letterSpacing: 0,
      ),

      bodyMedium: textTheme.bodyMedium?.copyWith(
          color: textColorPrimary,
          fontWeight: FontWeight.w400,
          fontSize: 14,
          height: 1.33,
          letterSpacing: 0.25),

      bodySmall: textTheme.bodySmall?.copyWith(
        color: textColorPrimary,
        fontWeight: FontWeight.w400,
        fontSize: 12,
        height: 1,
        letterSpacing: 0,
      ),

      labelLarge: textTheme.labelLarge?.copyWith(
        color: textColorPrimary,
        fontWeight: FontWeight.w500,
        fontSize: 16,
        height: 1,
        letterSpacing: 0,
      ),

      labelMedium: textTheme.labelMedium?.copyWith(
        color: textColorPrimary,
        fontWeight: FontWeight.w500,
        fontSize: 14,
        height: 1,
        letterSpacing: 0,
      ),
    
      labelSmall: textTheme.labelSmall?.copyWith(
        color: textColorPrimary,
        fontWeight: FontWeight.w500,
        fontSize: 12,
        height: 1.25,
        letterSpacing: 0,
      ),
    );
  }
}
