import 'package:flutter/material.dart';

/// 文本颜色主题扩展类
/// 用于定义应用中不同层级的文本颜色，包括正常状态和反色状态
class TextColorTheme extends ThemeExtension<TextColorTheme> {
  /// 主要文本颜色
  final Color textColorPrimary;

  /// 次要文本颜色
  final Color textColorSecondary;

  /// 第三级文本颜色
  final Color textColorTertiary;

  /// 第四级文本颜色
  final Color textColorQuaternary;

  /// 辅助文本颜色
  final Color textColorHelper;

  /// 反色主要文本颜色（用于深色背景）
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
