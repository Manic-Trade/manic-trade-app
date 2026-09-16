import 'package:deriv_chart/deriv_chart.dart';
import 'package:finality/theme/app_color_theme.dart';
import 'package:finality/theme/attrs/clash_display_font.dart';
import 'package:finality/theme/attrs/text_color_theme.dart';
import 'package:finality/theme/color_schemes.g.dart';
import 'package:flutter/material.dart';

class CustomChartDarkTheme extends ChartDefaultDarkTheme {
  final ColorScheme colorScheme;
  final TextColorTheme textColorTheme;
  final bool showGrid;
  final Color bullishColor;
  final Color bearishColor;

  CustomChartDarkTheme({
    this.colorScheme = darkColorScheme,
    this.textColorTheme = darkTextColorTheme,
    this.showGrid = true,
    required this.bullishColor,
    required this.bearishColor,
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

  // @override
  // CandleStyle get candleStyle => CandleStyle(
  //       candleBullishBodyColor: bullishColor,
  //       candleBearishBodyColor: bearishColor,
  //       candleBullishWickColor: bullishColor,
  //       candleBearishWickColor: bearishColor,
  //       neutralColor: base04Color,
  //     );

  @override
  MarkerStyle get markerStyle => MarkerStyle(
        upColor: bullishColor,
        downColor: bearishColor,
        upColorProminent: bullishColor,
        downColorProminent: bearishColor,
      );

  @override
  TextStyle get profitAndLossLabelTextStyle => super
      .profitAndLossLabelTextStyle
      .toClashDisplay(fontWeight: FontWeight.w500);

  @override
  Color get crosshairInformationBoxTextProfit => bullishColor;

  @override
  Color get crosshairInformationBoxTextLoss => bearishColor;

  @override
  Color get crosshairInformationBoxTextStatic => colorScheme.onPrimary;
  @override
  TextStyle get crosshairInformationBoxTitleStyle =>
      super.crosshairInformationBoxTitleStyle.toClashDisplay();
  @override
  TextStyle get crosshairInformationBoxQuoteStyle =>
      super.crosshairInformationBoxQuoteStyle.toClashDisplay();
  @override
  TextStyle get crosshairInformationBoxTimeLabelStyle =>
      super.crosshairInformationBoxTimeLabelStyle.toClashDisplay();
  @override
  TextStyle get crosshairAxisLabelStyle =>
      super.crosshairAxisLabelStyle.toClashDisplay();
}

class CustomChartLightTheme extends ChartDefaultLightTheme {
  final ColorScheme colorScheme;
  final TextColorTheme textColorTheme;
  final bool showGrid;
  final Color bullishColor;
  final Color bearishColor;

  CustomChartLightTheme({
    this.colorScheme = lightColorScheme,
    this.textColorTheme = lightTextColorTheme,
    this.showGrid = true,
    required this.bullishColor,
    required this.bearishColor,
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

  @override
  CandleStyle get candleStyle => CandleStyle(
        candleBullishBodyColor: bullishColor,
        candleBearishBodyColor: bearishColor,
        candleBullishWickColor: bullishColor,
        candleBearishWickColor: bearishColor,
        neutralColor: base04Color,
      );

  @override
  MarkerStyle get markerStyle => MarkerStyle(
        upColor: bullishColor,
        downColor: bearishColor,
        upColorProminent: bullishColor,
        downColorProminent: bearishColor,
      );

  @override
  TextStyle get profitAndLossLabelTextStyle => super
      .profitAndLossLabelTextStyle
      .toClashDisplay(fontWeight: FontWeight.w500);
}

ChartTheme getCustomChartTheme(BuildContext context, {bool showGrid = true}) {
  final colorScheme = Theme.of(context).colorScheme;
  final textColorTheme = context.textColorTheme;
  final appColors = context.appColors;
  return Theme.of(context).brightness == Brightness.dark
      ? CustomChartDarkTheme(
          colorScheme: colorScheme,
          textColorTheme: textColorTheme,
          showGrid: showGrid,
          bullishColor: appColors.bullish,
          bearishColor: appColors.bearish,
        )
      : CustomChartLightTheme(
          colorScheme: colorScheme,
          textColorTheme: textColorTheme,
          showGrid: showGrid,
          bullishColor: appColors.bullish,
          bearishColor: appColors.bearish,
        );
}
