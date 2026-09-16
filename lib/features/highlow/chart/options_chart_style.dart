import 'package:finality/generated/assets.dart';
import 'package:flutter/material.dart';

enum OptionsChartStyle {
  /// 区域图 ,lineSeries hasArea = true
  area,

  /// 蜡烛图 , CandleSeries
  candles,

  /// 线图, LineSeries hasArea = false
  line;

  // // /// 空心蜡烛图 , CandleSeries
  // hollow,

  // /// OHLC 图 , OHLCSeries
  // ohlc;

  static List<OptionsChartStyle> get lineStyles => [area, line];

  bool get hasArea => this == area;

  bool get isCandles => this == candles;

  bool get isLine => lineStyles.contains(this);

  String get svgPath => switch (this) {
        area => Assets.svgsChartStyleArea,
        candles => Assets.svgsChartStyleCandles,
        line => Assets.svgsChartStyleLine,
        // hollow => Assets.svgsChartStyleHollow,
        // ohlc => Assets.svgsChartStyleOhlc,
      };

  String getLabel(BuildContext context) => switch (this) {
        area => 'Area',
        candles => 'Candles',
        line => 'Line',
        // hollow => 'Hollow',
        // ohlc => 'OHLC',
      };
}
