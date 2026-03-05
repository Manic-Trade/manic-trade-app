import 'package:flutter/material.dart';

class FontUtils {
  const FontUtils._();

  static TextStyle textStyle({
    required String fontFamily,
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<Shadow>? shadows,
    List<FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    return (textStyle ?? const TextStyle()).copyWith(
      fontFamily: fontFamily,
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
    );
  }

  static TextTheme textTheme(TextTheme textTheme, String fontFamily) {
    return TextTheme(
      displayLarge: textTheme.displayLarge?.copyWith(fontFamily: fontFamily),
      displayMedium: textTheme.displayMedium?.copyWith(fontFamily: fontFamily),
      displaySmall: textTheme.displaySmall?.copyWith(fontFamily: fontFamily),
      headlineLarge: textTheme.headlineLarge?.copyWith(fontFamily: fontFamily),
      headlineMedium:
          textTheme.headlineMedium?.copyWith(fontFamily: fontFamily),
      headlineSmall: textTheme.headlineSmall?.copyWith(fontFamily: fontFamily),
      titleLarge: textTheme.titleLarge?.copyWith(fontFamily: fontFamily),
      titleMedium: textTheme.titleMedium?.copyWith(fontFamily: fontFamily),
      titleSmall: textTheme.titleSmall?.copyWith(fontFamily: fontFamily),
      bodyLarge: textTheme.bodyLarge?.copyWith(fontFamily: fontFamily),
      bodyMedium: textTheme.bodyMedium?.copyWith(fontFamily: fontFamily),
      bodySmall: textTheme.bodySmall?.copyWith(fontFamily: fontFamily),
      labelLarge: textTheme.labelLarge?.copyWith(fontFamily: fontFamily),
      labelMedium: textTheme.labelMedium?.copyWith(fontFamily: fontFamily),
      labelSmall: textTheme.labelSmall?.copyWith(fontFamily: fontFamily),
    );
  }
}
