import 'dart:math' as math;

import 'package:finality/data/network/model/manic/pnl_overview_response.dart';

/// 胜率数据 VO
class WinRateVO {
  final int winRate;
  final int winRatePercentile;
  final int wins;
  final int losses;
  final int totalTrades;

  const WinRateVO({
    required this.winRate,
    required this.winRatePercentile,
    required this.wins,
    required this.losses,
    required this.totalTrades,
  });

  /// 胜率条宽度比例 (0.0 ~ 1.0)，最小 0.22 保证可见
  double get winBarRatio {
    if (totalTrades == 0) return 0.5;
    final ratio = wins / totalTrades;
    return ratio.clamp(0.22, 0.88);
  }

  factory WinRateVO.fromResponse(PnlOverviewResponse resp) {
    return WinRateVO(
      winRate: resp.winRate.round(),
      winRatePercentile: resp.winRatePercentile.round(),
      wins: resp.wins,
      losses: resp.losses,
      totalTrades: resp.totalTrades,
    );
  }

  factory WinRateVO.empty() {
    return const WinRateVO(winRate: 0, winRatePercentile: 0, wins: 0, losses: 0, totalTrades: 0);
  }
}

/// 每日活动 VO
class DailyActivityVO {
  final String date;
  final int day;
  final bool hasActivity;
  final bool isWin;
  final int percentage;
  final int trades;

  /// 颜色强度 (0.0 ~ 1.0)，越接近 100% 或 0% 越强
  final double intensity;

  const DailyActivityVO({
    required this.date,
    required this.day,
    required this.hasActivity,
    required this.isWin,
    required this.percentage,
    required this.trades,
    required this.intensity,
  });

  factory DailyActivityVO.fromApiItem(DailyActivityItem item) {
    final winRate = item.winRate ?? 0;
    final pct = winRate.round();
    // 与 web 端一致：Math.pow(Math.abs(percentage - 50) / 50, 0.7)
    final decisiveness = (pct - 50).abs() / 50.0;
    final intensity =
        item.hasActivity ? math.pow(decisiveness, 0.7).toDouble().clamp(0.0, 1.0) : 0.0;
    final day = DateTime.tryParse(item.date)?.day ?? 0;

    return DailyActivityVO(
      date: item.date,
      day: day,
      hasActivity: item.hasActivity,
      isWin: item.hasActivity && pct >= 50,
      percentage: pct,
      trades: item.tradeCount,
      intensity: intensity,
    );
  }

  factory DailyActivityVO.empty(int day) {
    return DailyActivityVO(
      date: '',
      day: day,
      hasActivity: false,
      isWin: false,
      percentage: 0,
      trades: 0,
      intensity: 0,
    );
  }
}

/// 用户等级
enum UserTier {
  basic,
  premium;

  factory UserTier.fromBool(bool isPremium) =>
      isPremium ? UserTier.premium : UserTier.basic;
}
