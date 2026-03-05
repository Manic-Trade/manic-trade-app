import 'package:flutter/material.dart';

class AppColorTheme extends ThemeExtension<AppColorTheme> {
  final Color bullish;
  final Color bearish;
  
  final Color dragHandleColor;

  final Color bottomSheetTitle;
  final Color bottomSheetSubtitle;
 

  const AppColorTheme({
    required this.bullish,
    required this.bearish,
    required this.dragHandleColor,
    required this.bottomSheetTitle,
    required this.bottomSheetSubtitle,
  });

  @override
  AppColorTheme copyWith({
    Color? bullish,
    Color? bearish,
    Color? dragHandleColor,
    Color? bottomSheetTitle,
    Color? bottomSheetSubtitle,
  }) {
    return AppColorTheme(
      bullish: bullish ?? this.bullish,
      bearish: bearish ?? this.bearish,
      dragHandleColor: dragHandleColor ?? this.dragHandleColor,
      bottomSheetTitle: bottomSheetTitle ?? this.bottomSheetTitle,
      bottomSheetSubtitle: bottomSheetSubtitle ?? this.bottomSheetSubtitle,
    );
  }

  @override
  AppColorTheme lerp(ThemeExtension<AppColorTheme>? other, double t) {
    if (other is! AppColorTheme) return this;
    return AppColorTheme(
      bullish: Color.lerp(bullish, other.bullish, t)!,
      bearish: Color.lerp(bearish, other.bearish, t)!,
      dragHandleColor: Color.lerp(dragHandleColor, other.dragHandleColor, t)!,
      bottomSheetTitle: Color.lerp(bottomSheetTitle, other.bottomSheetTitle, t)!,
      bottomSheetSubtitle: Color.lerp(bottomSheetSubtitle, other.bottomSheetSubtitle, t)!,
    );
  }
}

extension AppColorThemeExtension on BuildContext {
  AppColorTheme get appColors => Theme.of(this).extension<AppColorTheme>()!;
}