import 'package:flutter/material.dart';

class TextColorTheme extends ThemeExtension<TextColorTheme> {
  final Color textColorPrimary;

  final Color textColorSecondary;

  final Color textColorTertiary;

  final Color textColorQuaternary;

  final Color textColorHelper;

  final Color textColorPrimaryInverse;

  const TextColorTheme({
    required this.textColorPrimary,
    required this.textColorSecondary,
    required this.textColorTertiary,
    required this.textColorQuaternary,
    required this.textColorHelper,
    required this.textColorPrimaryInverse,
  });

  @override
  ThemeExtension<TextColorTheme> copyWith() {
    return TextColorTheme(
      textColorPrimary: textColorPrimary,
      textColorSecondary: textColorSecondary,
      textColorTertiary: textColorTertiary,
      textColorQuaternary: textColorQuaternary,
      textColorHelper: textColorHelper,
      textColorPrimaryInverse: textColorPrimaryInverse,
    );
  }

  @override
  ThemeExtension<TextColorTheme> lerp(
      ThemeExtension<TextColorTheme>? other, double t) {
    if (other is! TextColorTheme) {
      return this;
    }
    return TextColorTheme(
      textColorPrimary:
          Color.lerp(textColorPrimary, other.textColorPrimary, t)!,
      textColorSecondary:
          Color.lerp(textColorSecondary, other.textColorSecondary, t)!,
      textColorTertiary:
          Color.lerp(textColorTertiary, other.textColorTertiary, t)!,
      textColorQuaternary:
          Color.lerp(textColorQuaternary, other.textColorQuaternary, t)!,
      textColorHelper: Color.lerp(textColorHelper, other.textColorHelper, t)!,
      textColorPrimaryInverse: Color.lerp(
          textColorPrimaryInverse, other.textColorPrimaryInverse, t)!,
    );
  }
}

extension TextColorThemeExtension on BuildContext {
  TextColorTheme get textColorTheme =>
      Theme.of(this).extension<TextColorTheme>()!;
}
