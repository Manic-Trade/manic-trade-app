import 'package:json_annotation/json_annotation.dart';

part 'premium_activity_response.g.dart';

/// Premium 分析 - 活动热力图数据
/// GET /users/pnl/premium/activity
@JsonSerializable()
class PremiumActivityResponse {
  @JsonKey(name: 'heatmap', defaultValue: [])
  final List<HeatmapDay> heatmap;

  @JsonKey(name: 'longest_win_streak', defaultValue: 0)
  final int longestWinStreak;

  @JsonKey(name: 'best_trading_day')
  final BestTradingDay? bestTradingDay;

  @JsonKey(name: 'daily_average', defaultValue: 0)
  final double dailyAverage;

  const PremiumActivityResponse({
    required this.heatmap,
    required this.longestWinStreak,
    this.bestTradingDay,
    required this.dailyAverage,
  });

  factory PremiumActivityResponse.fromJson(Map<String, dynamic> json) =>
      _$PremiumActivityResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PremiumActivityResponseToJson(this);
}

/// 热力图每日数据
@JsonSerializable()
class HeatmapDay {
  @JsonKey(name: 'date', defaultValue: '')
  final String date;

  @JsonKey(name: 'has_activity', defaultValue: false)
  final bool hasActivity;

  @JsonKey(name: 'trade_count', defaultValue: 0)
  final int tradeCount;

  @JsonKey(name: 'wins', defaultValue: 0)
  final int wins;

  @JsonKey(name: 'win_rate')
  final double? winRate;

  @JsonKey(name: 'volume', defaultValue: 0)
  final double volume;

  @JsonKey(name: 'net_pnl', defaultValue: 0)
  final double netPnl;

  const HeatmapDay({
    required this.date,
    required this.hasActivity,
    required this.tradeCount,
    required this.wins,
    this.winRate,
    required this.volume,
    required this.netPnl,
  });

  factory HeatmapDay.fromJson(Map<String, dynamic> json) =>
      _$HeatmapDayFromJson(json);

  Map<String, dynamic> toJson() => _$HeatmapDayToJson(this);
}

/// 最佳交易日
@JsonSerializable()
class BestTradingDay {
  @JsonKey(name: 'date', defaultValue: '')
  final String date;

  @JsonKey(name: 'pnl', defaultValue: 0)
  final double pnl;

  const BestTradingDay({
    required this.date,
    required this.pnl,
  });

  factory BestTradingDay.fromJson(Map<String, dynamic> json) =>
      _$BestTradingDayFromJson(json);

  Map<String, dynamic> toJson() => _$BestTradingDayToJson(this);
}
