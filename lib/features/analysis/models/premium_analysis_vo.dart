import 'dart:math' as math;

import 'package:finality/data/network/model/manic/premium_activity_response.dart';
import 'package:finality/data/network/model/manic/premium_analysis_response.dart';
import 'package:finality/data/network/model/manic/premium_summary_response.dart';
import 'package:intl/intl.dart';

// ==================== OVERVIEW ====================

/// 色调
enum MetricTone { amber, green, red }

/// 摘要卡片 VO（Net P&L / Win Rate / Total Trades / Total Volume）
class SummaryMetricVO {
  final String label;
  final String value;
  final String subValue;
  final String caption;
  final MetricTone tone;

  const SummaryMetricVO({
    required this.label,
    required this.value,
    required this.subValue,
    required this.caption,
    required this.tone,
  });
}

/// 从 API 响应构建 4 张摘要卡片
class PremiumSummaryVO {
  final SummaryMetricVO netPnl;
  final SummaryMetricVO winRate;
  final SummaryMetricVO totalTrades;
  final SummaryMetricVO totalVolume;

  /// HeroWinRateCard 绘制 24 段进度条需要
  final int wins;
  final int losses;

  const PremiumSummaryVO({
    required this.netPnl,
    required this.winRate,
    required this.totalTrades,
    required this.totalVolume,
    required this.wins,
    required this.losses,
  });

  List<SummaryMetricVO> get asList => [netPnl, totalTrades, totalVolume];

  factory PremiumSummaryVO.fromResponse(PremiumSummaryResponse s) {
    final pnlTone = s.netPnl >= 0 ? MetricTone.green : MetricTone.red;
    final invested = s.totalVolume > 0 ? s.totalVolume : 1.0;

    return PremiumSummaryVO(
      wins: s.wins,
      losses: s.losses,
      netPnl: SummaryMetricVO(
        label: 'Net P&L',
        value: _formatSignedDollar(s.netPnl, compact: true),
        subValue: '${s.pnlPercent.abs().toStringAsFixed(1)}%',
        caption: '${_formatDollar(invested, compact: true)} invested',
        tone: pnlTone,
      ),
      winRate: SummaryMetricVO(
        label: 'Win Rate',
        value: '${s.winRate.round()}%',
        subValue: '${s.wins}W / ${s.losses}L',
        caption: 'Shareable card available',
        tone: MetricTone.amber,
      ),
      totalTrades: SummaryMetricVO(
        label: 'Total Trades',
        value: _formatNumber(s.totalTrades),
        subValue: '${s.wins}W / ${s.losses}L',
        caption: 'Execution count',
        tone: MetricTone.amber,
      ),
      totalVolume: SummaryMetricVO(
        label: 'Total Volume',
        value: _formatDollar(s.totalVolume, compact: true),
        subValue: 'Total Turnover',
        caption: 'Turnover across filtered sessions',
        tone: MetricTone.amber,
      ),
    );
  }
}

/// 性能时序点 VO
class PerformancePointVO {
  final String label;
  final double pnl;
  final double volume;

  const PerformancePointVO({
    required this.label,
    required this.pnl,
    required this.volume,
  });

  static List<PerformancePointVO> fromResponse(PremiumSummaryResponse s) {
    return s.performance
        .map((p) => PerformancePointVO(
              label: p.period,
              pnl: p.netPnl,
              volume: p.volume,
            ))
        .toList();
  }
}

/// Trade Tape 单条 VO
class TradeTapeVO {
  final String asset;
  final String mode; // "Higher" / "Lower"
  final double pnl;

  const TradeTapeVO({
    required this.asset,
    required this.mode,
    required this.pnl,
  });

  bool get isWin => pnl >= 0;

  static List<TradeTapeVO> fromResponse(PremiumSummaryResponse s) {
    return s.tradeTape
        .map((t) => TradeTapeVO(
              asset: t.asset,
              mode: _sideLabel(t.side ?? 'call'),
              pnl: t.pnlAmount,
            ))
        .toList();
  }
}

// ==================== BEHAVIOR ====================

/// 方向偏好 / 模式效率通用 VO
class BiasMetricVO {
  final String key;
  final String label;
  final int winRate;
  final int trades;
  final double volume;
  final double netPnl;
  final bool highlight;

  const BiasMetricVO({
    required this.key,
    required this.label,
    required this.winRate,
    required this.trades,
    required this.volume,
    required this.netPnl,
    this.highlight = false,
  });

  /// 从方向数据构建
  static List<BiasMetricVO> fromDirection(PremiumAnalysisResponse a) {
    if (a.direction.isEmpty) return [];
    final maxWr = a.direction.map((d) => d.winRate).reduce(math.max);
    return a.direction
        .map((d) => BiasMetricVO(
              key: d.side,
              label: _sideLabel(d.side),
              winRate: d.winRate.round(),
              trades: d.tradeCount,
              volume: d.volume,
              netPnl: d.netPnl,
              highlight: d.winRate == maxWr,
            ))
        .toList();
  }

  /// 从模式数据构建
  static List<BiasMetricVO> fromModes(PremiumAnalysisResponse a) {
    if (a.modes.isEmpty) return [];
    final maxWr = a.modes.map((m) => m.winRate).reduce(math.max);
    return a.modes
        .map((m) => BiasMetricVO(
              key: m.mode,
              label: m.label,
              winRate: m.winRate.round(),
              trades: m.tradeCount,
              volume: m.volume,
              netPnl: m.netPnl,
              highlight: m.winRate == maxWr,
            ))
        .toList();
  }
}

/// 效率数据点 VO（Duration / Hourly / Weekday 通用）
class EfficiencyPointVO {
  final String label;
  final int value; // 胜率百分比
  final int trades;

  const EfficiencyPointVO({
    required this.label,
    required this.value,
    required this.trades,
  });

  /// 持仓时长效率，固定 6 个桶
  static List<EfficiencyPointVO> fromDuration(PremiumAnalysisResponse a) {
    const buckets = ['30s', '1m', '2m', '3m', '4m', '5m'];
    final apiMap = {
      for (final d in a.duration ?? <DurationItem>[]) d.label: d,
    };
    return buckets
        .map((label) => EfficiencyPointVO(
              label: label,
              value: apiMap[label]?.winRate.round() ?? 0,
              trades: apiMap[label]?.tradeCount ?? 0,
            ))
        .toList();
  }

  /// 24 小时性能
  static List<EfficiencyPointVO> fromHourly(PremiumAnalysisResponse a) {
    final apiMap = {
      for (final h in a.hourly)
        h.label.replaceAll(':00', '').padLeft(2, '0'): h,
    };
    return List.generate(
      24,
      (i) {
        final label = i.toString().padLeft(2, '0');
        final h = apiMap[label];
        return EfficiencyPointVO(
          label: label,
          value: h?.winRate.round() ?? 0,
          trades: h?.tradeCount ?? 0,
        );
      },
    );
  }

  /// 星期性能
  static List<EfficiencyPointVO> fromWeekday(PremiumAnalysisResponse a) {
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final apiMap = {
      for (final w in a.weekday) w.label: w,
    };
    return labels
        .map((label) => EfficiencyPointVO(
              label: label,
              value: apiMap[label]?.winRate.round() ?? 0,
              trades: apiMap[label]?.tradeCount ?? 0,
            ))
        .toList();
  }
}

// ==================== EXPOSURE ====================

/// 资产分布 VO
class AssetBreakdownVO {
  final String asset;
  final int share; // 占比百分比
  final int trades;
  final double volume;
  final double netPnl;
  final int winRate;

  const AssetBreakdownVO({
    required this.asset,
    required this.share,
    required this.trades,
    required this.volume,
    required this.netPnl,
    required this.winRate,
  });

  static List<AssetBreakdownVO> fromResponse(PremiumAnalysisResponse a) {
    final totalVolume =
        a.assets.fold<double>(0, (sum, x) => sum + x.volume).clamp(1.0, double.infinity);

    final rows = a.assets
        .map((x) => AssetBreakdownVO(
              asset: x.asset,
              share: ((x.volume / totalVolume) * 100).round(),
              trades: x.tradeCount,
              volume: x.volume,
              netPnl: x.netPnl,
              winRate: x.winRate.round(),
            ))
        .toList();

    // 修正四舍五入误差，确保总和为 100%
    if (rows.isNotEmpty) {
      final shareSum = rows.fold<int>(0, (s, r) => s + r.share);
      if (shareSum != 100) {
        final first = rows.first;
        rows[0] = AssetBreakdownVO(
          asset: first.asset,
          share: first.share + (100 - shareSum),
          trades: first.trades,
          volume: first.volume,
          netPnl: first.netPnl,
          winRate: first.winRate,
        );
      }
    }
    return rows;
  }
}

// ==================== RHYTHM ====================

/// 热力图每日 VO
class PremiumDailyActivityVO {
  final String date;
  final int day;
  final bool hasActivity;
  final bool isWin;
  final int percentage;
  final int trades;
  final double volume;
  final double netPnl;
  final double intensity;

  const PremiumDailyActivityVO({
    required this.date,
    required this.day,
    required this.hasActivity,
    required this.isWin,
    required this.percentage,
    required this.trades,
    required this.volume,
    required this.netPnl,
    required this.intensity,
  });

  static List<PremiumDailyActivityVO> fromResponse(PremiumActivityResponse act) {
    return act.heatmap.map((h) {
      final pct = h.winRate?.round() ?? 0;
      final decisiveness = (pct - 50).abs() / 50.0;
      final intensity =
          h.hasActivity ? math.pow(decisiveness, 0.7).toDouble().clamp(0.0, 1.0) : 0.0;
      final day = DateTime.tryParse(h.date)?.day ?? 0;

      return PremiumDailyActivityVO(
        date: h.date,
        day: day,
        hasActivity: h.hasActivity,
        isWin: h.hasActivity && h.winRate != null && h.winRate! >= 50,
        percentage: pct,
        trades: h.tradeCount,
        volume: h.volume,
        netPnl: h.netPnl,
        intensity: intensity,
      );
    }).toList();
  }
}

/// Rhythm 统计块 VO
class RhythmStatsVO {
  final int longestWinStreak;
  final String? bestTradingDayLabel;
  final double? bestTradingDayPnl;
  final String dailyAverage;

  const RhythmStatsVO({
    required this.longestWinStreak,
    this.bestTradingDayLabel,
    this.bestTradingDayPnl,
    required this.dailyAverage,
  });

  factory RhythmStatsVO.fromResponse(PremiumActivityResponse act) {
    String? dayLabel;
    if (act.bestTradingDay != null) {
      final date = DateTime.tryParse(act.bestTradingDay!.date);
      dayLabel = date != null ? DateFormat('MMM d').format(date) : act.bestTradingDay!.date;
    }
    return RhythmStatsVO(
      longestWinStreak: act.longestWinStreak,
      bestTradingDayLabel: dayLabel,
      bestTradingDayPnl: act.bestTradingDay?.pnl,
      dailyAverage: act.dailyAverage.toStringAsFixed(1),
    );
  }
}

// ==================== INSIGHTS ====================

/// 洞察卡片 VO
class InsightMetricVO {
  final String label;
  final String value;
  final String helper;
  final MetricTone tone;

  const InsightMetricVO({
    required this.label,
    required this.value,
    required this.helper,
    required this.tone,
  });

  static List<InsightMetricVO> build({
    required PremiumActivityResponse activity,
    required List<BiasMetricVO> directionalBias,
    required List<BiasMetricVO> modeEfficiency,
    required String? modeInsight,
  }) {
    final insights = <InsightMetricVO>[];

    final bestDir = directionalBias.isNotEmpty
        ? directionalBias.reduce((a, b) => a.winRate > b.winRate ? a : b)
        : null;
    final bestMode = modeEfficiency.isNotEmpty
        ? modeEfficiency.reduce((a, b) => a.winRate > b.winRate ? a : b)
        : null;
    final worstMode = modeEfficiency.isNotEmpty
        ? modeEfficiency.reduce((a, b) => a.winRate < b.winRate ? a : b)
        : null;

    insights.add(InsightMetricVO(
      label: 'Longest Win Streak',
      value: '${activity.longestWinStreak} trades',
      helper: bestDir != null
          ? 'Your edge peaks with ${bestDir.label} trades. Stay consistent to extend streaks.'
          : 'Keep trading to build your streak.',
      tone: MetricTone.green,
    ));

    if (activity.bestTradingDay != null) {
      final date = DateTime.tryParse(activity.bestTradingDay!.date);
      final dateLabel = date != null ? DateFormat('MMM d').format(date) : '';
      insights.add(InsightMetricVO(
        label: 'Best Trading Day',
        value: '$dateLabel · ${_formatSignedDollar(activity.bestTradingDay!.pnl, compact: true)}',
        helper: bestMode != null
            ? '${bestMode.label} mode drove your best day with ${bestMode.winRate}% win rate.'
            : 'Great performance on your top day.',
        tone: MetricTone.amber,
      ));
    }

    if (modeInsight != null &&
        bestMode != null &&
        worstMode != null &&
        bestMode.key != worstMode.key) {
      insights.add(InsightMetricVO(
        label: 'Mode Insight',
        value: '${bestMode.label} +${bestMode.winRate - worstMode.winRate}% edge',
        helper: modeInsight,
        tone: MetricTone.amber,
      ));
    }

    return insights;
  }
}

// ==================== 聚合 VO ====================

/// Premium 分析完整数据 VO，聚合所有模块
class PremiumAnalysisData {
  final PremiumSummaryVO summary;
  final List<PerformancePointVO> performancePoints;
  final List<TradeTapeVO> tradeTape;
  final List<BiasMetricVO> directionalBias;
  final List<EfficiencyPointVO> durationEfficiency;
  final List<EfficiencyPointVO> hourlyPerformance;
  final List<EfficiencyPointVO> weekdayPerformance;
  final List<AssetBreakdownVO> assetBreakdown;
  final List<BiasMetricVO> modeEfficiency;
  final List<PremiumDailyActivityVO> activity;
  final RhythmStatsVO rhythmStats;
  final List<InsightMetricVO> insights;

  const PremiumAnalysisData({
    required this.summary,
    required this.performancePoints,
    required this.tradeTape,
    required this.directionalBias,
    required this.durationEfficiency,
    required this.hourlyPerformance,
    required this.weekdayPerformance,
    required this.assetBreakdown,
    required this.modeEfficiency,
    required this.activity,
    required this.rhythmStats,
    required this.insights,
  });

  factory PremiumAnalysisData.from({
    required PremiumSummaryResponse summaryResp,
    required PremiumAnalysisResponse analysisResp,
    required PremiumActivityResponse activityResp,
  }) {
    final directionalBias = BiasMetricVO.fromDirection(analysisResp);
    final modeEfficiency = BiasMetricVO.fromModes(analysisResp);

    return PremiumAnalysisData(
      summary: PremiumSummaryVO.fromResponse(summaryResp),
      performancePoints: PerformancePointVO.fromResponse(summaryResp),
      tradeTape: TradeTapeVO.fromResponse(summaryResp),
      directionalBias: directionalBias,
      durationEfficiency: EfficiencyPointVO.fromDuration(analysisResp),
      hourlyPerformance: EfficiencyPointVO.fromHourly(analysisResp),
      weekdayPerformance: EfficiencyPointVO.fromWeekday(analysisResp),
      assetBreakdown: AssetBreakdownVO.fromResponse(analysisResp),
      modeEfficiency: modeEfficiency,
      activity: PremiumDailyActivityVO.fromResponse(activityResp),
      rhythmStats: RhythmStatsVO.fromResponse(activityResp),
      insights: InsightMetricVO.build(
        activity: activityResp,
        directionalBias: directionalBias,
        modeEfficiency: modeEfficiency,
        modeInsight: analysisResp.modeInsight,
      ),
    );
  }
}

// ==================== 工具函数 ====================

final _currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
final _compactFormat = NumberFormat.compactCurrency(symbol: '\$', decimalDigits: 1);
final _numberFormat = NumberFormat('#,###');

String _formatDollar(double value, {bool compact = false}) {
  if (compact && value.abs() >= 1000) {
    return _compactFormat.format(value);
  }
  return _currencyFormat.format(value);
}

String _formatSignedDollar(double value, {bool compact = false}) {
  final sign = value >= 0 ? '+' : '-';
  return '$sign${_formatDollar(value.abs(), compact: compact)}';
}

String _formatNumber(int value) {
  return _numberFormat.format(value);
}

String _sideLabel(String side) {
  if (side == 'call' || side == 'higher') return 'Higher';
  return 'Lower';
}
