import 'package:deriv_chart/deriv_chart.dart';
import 'package:finality/common/utils/color_scheme_extensions.dart';
import 'package:finality/domain/options/entities/time_bar.dart';
import 'package:finality/features/highlow/chart/options_chart_style.dart';
import 'package:finality/features/highlow/model/settlement_time.dart';
import 'package:finality/theme/attrs/text_color_theme.dart';
import 'package:flutter/material.dart';

/// 图表配置构建器
/// 负责构建图表的各种配置（轴配置、底层配置等）
class ChartConfigBuilder {
  const ChartConfigBuilder();

  /// 构建图表轴配置
  ChartAxisConfig buildChartAxisConfig({
    required Candle lastCandle,
    required TimeBar currentTimeBar,
  }) {
    double intervalWidth = 7;
    if (currentTimeBar == TimeBar.s1) {
      intervalWidth = 3;
    } else if (currentTimeBar == TimeBar.s5) {
      intervalWidth = 5;
    }
    return ChartAxisConfig(
      defaultIntervalWidth: intervalWidth,
      maxCurrentTickOffset: 180,
      initialCurrentTickOffset: 100,
    );
  }

  /// 构建图表底层配置（结算区域背景）
  ChartLowLayerConfig? buildChartLowLayerConfig({
    required BuildContext context,
    required List<Candle> candles,
    required bool canTrade,
    SettlementTime? settlementTime,
    required bool showSettlementLine,
    required bool showCurrentEpochLine,
  }) {
    if (!canTrade || settlementTime == null) return null;

    var showBackground = showSettlementLine && showCurrentEpochLine;
    return ChartLowLayerConfig(
      startEpoch: candles.last.currentEpoch,
      endEpoch: settlementTime.epoch,
      patternConfig: showBackground
          ? LowLayerPatternConfig(
              patternColor: context.colorScheme.outlineVariant,
              patternSpacing: 8,
            )
          : null,
      startLineConfig: showCurrentEpochLine
          ? LowLayerLineConfig(
              color: context.textColorTheme.textColorPrimary
                  .withValues(alpha: 0.5),
              isDashed: true,
              dashWidth: 2,
              dashSpace: 2,
            )
          : null,
    );
  }

  /// 获取数据序列（线图或蜡烛图）
  DataSeries<Tick> getDataSeries({
    required BuildContext context,
    required List<Candle> candles,
    required OptionsChartStyle chartStyle,
  }) {
    switch (chartStyle) {
      case OptionsChartStyle.line:
        return _buildLineSeries(context, candles, false);
      case OptionsChartStyle.candles:
        return CandleSeries(candles);
      case OptionsChartStyle.area:
        return _buildLineSeries(context, candles, true);
    }
  }

  /// 构建线图序列
  LineSeries _buildLineSeries(
      BuildContext context, List<Candle> candles, bool hasArea) {
    return LineSeries(
      candles,
      style: LineStyle(
        color: context.colorScheme.primary,
        hasArea: hasArea,
        areaGradientColors: (
          start: const Color(0xFF7C2707),
          end: const Color(0x0018120D),
        ),
        markerRadius: 4,
        thickness: 1.5,
      ),
    );
  }
}
