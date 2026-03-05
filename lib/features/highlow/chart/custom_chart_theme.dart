import 'package:deriv_chart/deriv_chart.dart';
import 'package:finality/theme/attrs/clash_display_font.dart';
import 'package:finality/theme/attrs/text_color_theme.dart';
import 'package:finality/theme/color_schemes.g.dart';
import 'package:flutter/material.dart';

class CustomChartDarkTheme extends ChartDefaultDarkTheme {
  final ColorScheme colorScheme;
  final TextColorTheme textColorTheme;
  final bool showGrid;

  CustomChartDarkTheme({
    this.colorScheme = darkColorScheme,
    this.textColorTheme = darkTextColorTheme,
    this.showGrid = true,
  });

  @override
  Color get backgroundColor => colorScheme.surface;

  @override
  TextStyle get gridTextStyle => TextStyle(
        fontFeatures: <FontFeature>[
          FontFeature.liningFigures(),
          FontFeature.tabularFigures(),
        ],
        fontFamily: ClashDisplayFont.fontFamily,
        fontSize: 10,
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.w500,
        height: 1,
      );

  @override
  Color get gridLineColor =>
      showGrid ? colorScheme.outlineVariant : Colors.transparent;

  @override
  Color get gridTextColor => textColorTheme.textColorHelper;

  @override
  GridStyle get gridStyle => GridStyle(
        gridLineColor: gridLineColor,
        lineThickness: 0.5,
        xLabelStyle: textStyle(textStyle: gridTextStyle, color: gridTextColor),
        yLabelStyle: textStyle(textStyle: gridTextStyle, color: gridTextColor),
      );
}

class CustomChartLightTheme extends ChartDefaultLightTheme {
  final ColorScheme colorScheme;
  final TextColorTheme textColorTheme;
  final bool showGrid;

  CustomChartLightTheme({
    this.colorScheme = lightColorScheme,
    this.textColorTheme = lightTextColorTheme,
    this.showGrid = true,
  });

  @override
  Color get backgroundColor => colorScheme.surface;

  @override
  TextStyle get gridTextStyle => TextStyle(
        fontFeatures: <FontFeature>[
          FontFeature.liningFigures(),
          FontFeature.tabularFigures(),
        ],
        fontFamily: ClashDisplayFont.fontFamily,
        fontSize: 10,
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.w500,
        height: 1,
      );

  @override
  Color get gridLineColor =>
      showGrid ? colorScheme.outlineVariant : Colors.transparent;

  @override
  Color get gridTextColor => textColorTheme.textColorHelper;

  @override
  GridStyle get gridStyle => GridStyle(
        gridLineColor: gridLineColor,
        lineThickness: 0.5,
        xLabelStyle: textStyle(textStyle: gridTextStyle, color: gridTextColor),
        yLabelStyle: textStyle(textStyle: gridTextStyle, color: gridTextColor),
      );
}

ChartTheme getCustomChartTheme(BuildContext context, {bool showGrid = true}) {
  final colorScheme = Theme.of(context).colorScheme;
  final textColorTheme = context.textColorTheme;
  return Theme.of(context).brightness == Brightness.dark
      ? CustomChartDarkTheme(
          colorScheme: colorScheme,
          textColorTheme: textColorTheme,
          showGrid: showGrid,
        )
      : CustomChartLightTheme(
          colorScheme: colorScheme,
          textColorTheme: textColorTheme,
          showGrid: showGrid,
        );
}
