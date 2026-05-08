import 'package:flutter/material.dart';

/// 应用自定义颜色主题扩展
/// 用于管理 ColorScheme 和 TextColorTheme 未覆盖的语义化颜色
class AppColorTheme extends ThemeExtension<AppColorTheme> {
  // ===== 交易相关颜色 =====
  /// 涨/买入颜色
  final Color bullish;

  /// 跌/卖出颜色
  final Color bearish;

  // ===== 特殊组件颜色 =====
  /// 拖拽条颜色
  final Color dragHandleColor;

  final Color bottomSheetTitle;
  final Color bottomSheetSubtitle;

  final Color cardSecondary;
  final Color lineSecondary;

  /// VIP 等级紫色，对齐 web 端 `--color-tertiary-purple` (#A855F7)
  final Color vipPurple;

  const AppColorTheme({
    required this.bullish,
    required this.bearish,
    required this.dragHandleColor,
    required this.bottomSheetTitle,
    required this.bottomSheetSubtitle,
    required this.cardSecondary,
    required this.lineSecondary,
    required this.vipPurple,
  });

  @override
  AppColorTheme copyWith({
    Color? bullish,
    Color? bearish,
    Color? dragHandleColor,
    Color? bottomSheetTitle,
    Color? bottomSheetSubtitle,
    Color? cardSecondary,
    Color? lineSecondary,
    Color? vipPurple,
  }) {
    return AppColorTheme(
      bullish: bullish ?? this.bullish,
      bearish: bearish ?? this.bearish,
      dragHandleColor: dragHandleColor ?? this.dragHandleColor,
      bottomSheetTitle: bottomSheetTitle ?? this.bottomSheetTitle,
      bottomSheetSubtitle: bottomSheetSubtitle ?? this.bottomSheetSubtitle,
      cardSecondary: cardSecondary ?? this.cardSecondary,
      lineSecondary: lineSecondary ?? this.lineSecondary,
      vipPurple: vipPurple ?? this.vipPurple,
    );
  }

  @override
  AppColorTheme lerp(ThemeExtension<AppColorTheme>? other, double t) {
    if (other is! AppColorTheme) return this;
    return AppColorTheme(
      bullish: Color.lerp(bullish, other.bullish, t)!,
      bearish: Color.lerp(bearish, other.bearish, t)!,
      dragHandleColor: Color.lerp(dragHandleColor, other.dragHandleColor, t)!,
      bottomSheetTitle:
          Color.lerp(bottomSheetTitle, other.bottomSheetTitle, t)!,
      bottomSheetSubtitle:
          Color.lerp(bottomSheetSubtitle, other.bottomSheetSubtitle, t)!,
      cardSecondary: Color.lerp(cardSecondary, other.cardSecondary, t)!,
      lineSecondary: Color.lerp(lineSecondary, other.lineSecondary, t)!,
      vipPurple: Color.lerp(vipPurple, other.vipPurple, t)!,
    );
  }
}

// 便捷扩展
extension AppColorThemeExtension on BuildContext {
  AppColorTheme get appColors => Theme.of(this).extension<AppColorTheme>()!;
}
