import 'package:deriv_chart/deriv_chart.dart';
import 'package:finality/common/utils/color_scheme_extensions.dart';
import 'package:finality/features/highlow/chart/options_chart_style.dart';
import 'package:finality/features/highlow/model/settlement_time.dart';
import 'package:finality/domain/premium/entities/premium_result_pair.dart';
import 'package:finality/theme/app_color_theme.dart';
import 'package:finality/theme/attrs/clash_display_font.dart';
import 'package:finality/theme/attrs/text_color_theme.dart';
import 'package:flutter/material.dart';

/// 图表注解构建器
/// 负责构建图表上的各种注解（价格指示器、结算时间线等）
class ChartAnnotationBuilder {
  const ChartAnnotationBuilder({
    required this.pipSize,
    required this.granularityMs,
    this.showCountdown = true,
    this.showLongEntryPrice = true,
    this.showShortEntryPrice = true,
    this.showSettlementLine = true,
    this.showCurrentEpochLine = true,
    this.entryPriceYAxisAdaptive = true,
    this.settlementXAxisAdaptive = true,
    this.latestPriceLineFullScreen = true,
  });

  final int pipSize;
  final int granularityMs;

  /// 显示倒计时
  final bool showCountdown;

  /// 显示看多入场价
  final bool showLongEntryPrice;

  /// 显示看空入场价
  final bool showShortEntryPrice;

  /// 显示 Settlement 线
  final bool showSettlementLine;

  /// 显示当前时间线
  final bool showCurrentEpochLine;

  /// 入场价 Y 轴自适应
  final bool entryPriceYAxisAdaptive;

  /// Settlement 线 X 轴自适应
  final bool settlementXAxisAdaptive;

  /// 全屏价格线
  final bool latestPriceLineFullScreen;

  /// 构建所有注解
  List<ChartAnnotation<ChartObject>>? buildAnnotations({
    required BuildContext context,
    required List<Candle> candles,
    required OptionsChartStyle chartStyle,
    required bool canTrade,
    PremiumResultPair? premium,
    SettlementTime? settlementTime,
  }) {
    if (candles.isEmpty) {
      return null;
    }

    final chartAnnotations = <ChartAnnotation<ChartObject>>[];

    // 添加入场价格线
    _addPremiumBarriers(
      context: context,
      chartAnnotations: chartAnnotations,
      canTrade: canTrade,
      premium: premium,
    );

    // 添加结算时间线
    _addSettlementTimeBarrier(
      context: context,
      chartAnnotations: chartAnnotations,
      canTrade: canTrade,
      settlementTime: settlementTime,
    );
    chartAnnotations.addAll(
        _buildTickIndicator(context, candles.last, chartStyle, canTrade));

    return chartAnnotations;
  }

  /// 构建价格指示器
  List<ChartAnnotation> _buildTickIndicator(
    BuildContext context,
    Candle lastCandle,
    OptionsChartStyle chartStyle,
    bool canTrade,
  ) {
    final tickTextStyle = TextStyle(
      color: context.colorScheme.onPrimary,
      fontSize: 10,
      height: 1,
      fontFamily: ClashDisplayFont.fontFamily,
      fontWeight: FontWeight.w600,
      fontFeatures: const <FontFeature>[
        FontFeature.liningFigures(),
        FontFeature.tabularFigures(),
      ],
    );
    final closeString = lastCandle.close.toStringAsFixed(pipSize);

    HorizontalBarrier tickIndicator;
    if (chartStyle.isLine) {
      tickIndicator = TickIndicator(
        lastCandle,
        longLine: latestPriceLineFullScreen,
        style: HorizontalBarrierStyle(
          rightMargin: 0,
          color: context.colorScheme.primary,
          labelHeight: 24,
          labelWidth: closeString.length * 6.8 + 6 * 2,
          labelShape: LabelShape.rectangle,
          hasBlinkingDot: chartStyle.isLine,
          hasArrow: false,
          lineColor: context.colorScheme.primary.withValues(alpha: 0.5),
          isDashed: true,
          labelShapeBackgroundColor: context.colorScheme.primary,
          textStyle: tickTextStyle,
        ),
        visibility: HorizontalBarrierVisibility.keepBarrierLabelVisible,
      );
    } else {
      final isUp = lastCandle.close > lastCandle.open;
      final color =
          isUp ? context.appColors.bullish : context.appColors.bearish;
      tickIndicator = CandleIndicator(
        lastCandle,
        showTimer: canTrade && showCountdown,
        longLine: latestPriceLineFullScreen,
        timerTextStyle: tickTextStyle.copyWith(
            fontWeight: FontWeight.w500,
            color: context.textColorTheme.textColorSecondary),
        style: HorizontalBarrierStyle(
          rightMargin: 0,
          color: color,
          labelHeight: 24,
          labelWidth: closeString.length * 6.8 + 6 * 2,
          labelShape: LabelShape.rectangle,
          hasBlinkingDot: chartStyle.isLine,
          hasArrow: false,
          lineColor: color.withValues(alpha: 0.5),
          isDashed: true,
          labelPadding: 0,
          labelShapeBackgroundColor: color,
          secondaryBackgroundColor: context.colorScheme.surfaceContainerHighest,
          textStyle: tickTextStyle,
        ),
        visibility: HorizontalBarrierVisibility.keepBarrierLabelVisible,
        granularity: granularityMs,
        serverTime:
            DateTime.fromMillisecondsSinceEpoch(lastCandle.currentEpoch),
      );
    }

    return [tickIndicator];
  }

  /// 添加入场价格线（Higher/Lower 入场点）
  void _addPremiumBarriers({
    required BuildContext context,
    required List<ChartAnnotation<ChartObject>> chartAnnotations,
    required bool canTrade,
    PremiumResultPair? premium,
  }) {
    if (!canTrade ||
        premium == null ||
        premium.input == null ||
        premium.input!.payoutMultiplier <= 1) {
      return;
    }

    // 如果两个入场价都不显示，直接返回
    if (!showLongEntryPrice && !showShortEntryPrice) {
      return;
    }

    final spotPrice = premium.input!.spotPrice;
    final tickTextStyle = TextStyle(
      color: context.colorScheme.onPrimary,
      fontSize: 10,
      height: 1,
      fontFamily: ClashDisplayFont.fontFamily,
      fontWeight: FontWeight.w600,
      fontFeatures: const <FontFeature>[
        FontFeature.liningFigures(),
        FontFeature.tabularFigures(),
      ],
    );

    final entryPriceVisibility = entryPriceYAxisAdaptive
        ? HorizontalBarrierVisibility.forceToStayOnRange
        : HorizontalBarrierVisibility.keepBarrierLabelVisible;

    // Higher 入场价格线
    if (showLongEntryPrice) {
      final entryHigherPrice = premium.higher.barrierPrice;
      if (entryHigherPrice != spotPrice) {
        chartAnnotations.add(HorizontalBarrier(
          entryHigherPrice,
          title: 'Entry higher',
          style: HorizontalBarrierStyle(
            rightMargin: 0,
            labelPadding: 8,
            textStyle: tickTextStyle,
            color: Colors.green,
            isDashed: true,
            labelShapeBackgroundColor: Colors.green,
            lineColor: Colors.green,
          ),
          visibility: entryPriceVisibility,
        ));
      }
    }

    // Lower 入场价格线
    if (showShortEntryPrice) {
      final entryLowerPrice = premium.lower.barrierPrice;
      if (entryLowerPrice != spotPrice) {
        chartAnnotations.add(HorizontalBarrier(
          entryLowerPrice,
          title: 'Entry lower',
          style: HorizontalBarrierStyle(
            rightMargin: 0,
            labelPadding: 8,
            textStyle: tickTextStyle,
            color: Colors.red,
            isDashed: true,
            labelShapeBackgroundColor: Colors.red,
            lineColor: Colors.red,
          ),
          visibility: entryPriceVisibility,
        ));
      }
    }
  }

  /// 添加结算时间垂直线
  void _addSettlementTimeBarrier({
    required BuildContext context,
    required List<ChartAnnotation<ChartObject>> chartAnnotations,
    required bool canTrade,
    SettlementTime? settlementTime,
  }) {
    if (!canTrade || settlementTime == null || !showSettlementLine) {
      return;
    }

    final settlementVisibility = settlementXAxisAdaptive
        ? VerticalBarrierVisibility.fitIfPossible
        : VerticalBarrierVisibility.normal;

    chartAnnotations.add(VerticalBarrier(
      settlementTime.epoch,
      longLine: true,
      visibility: settlementVisibility,
      style: VerticalBarrierStyle(
        color: context.textColorTheme.textColorPrimary.withValues(alpha: 0.5),
        isDashed: true,
        dashWidth: 2,
        dashSpace: 2,
        labelPosition: VerticalBarrierLabelPosition.rightTop,
      ),
      id: settlementTime.id,
    ));
  }
}
