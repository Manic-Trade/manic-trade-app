import 'package:json_annotation/json_annotation.dart';

part 'pnl_overview_response.g.dart';

@JsonSerializable()
class PnlOverviewResponse {
  @JsonKey(name: 'is_premium', defaultValue: false)
  final bool isPremium;

  @JsonKey(name: 'total_deposits', defaultValue: 0)
  final double totalDeposits;

  @JsonKey(name: 'premium_threshold', defaultValue: 5000)
  final double premiumThreshold;

  @JsonKey(name: 'win_rate', defaultValue: 0)
  final double winRate;

  /// 胜率排名百分位（Outperforming X% of traders）
  @JsonKey(name: 'win_rate_percentile', defaultValue: 0)
  final double winRatePercentile;

  @JsonKey(name: 'wins', defaultValue: 0)
  final int wins;

  @JsonKey(name: 'losses', defaultValue: 0)
  final int losses;

  @JsonKey(name: 'total_trades', defaultValue: 0)
  final int totalTrades;

  @JsonKey(name: 'daily_activities', defaultValue: [])
  final List<DailyActivityItem> dailyActivities;

  const PnlOverviewResponse({
    required this.isPremium,
    required this.totalDeposits,
    required this.premiumThreshold,
    required this.winRate,
    required this.winRatePercentile,
    required this.wins,
    required this.losses,
    required this.totalTrades,
    required this.dailyActivities,
  });

  factory PnlOverviewResponse.fromJson(Map<String, dynamic> json) =>
      _$PnlOverviewResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PnlOverviewResponseToJson(this);
}

@JsonSerializable()
class DailyActivityItem {
  @JsonKey(name: 'date', defaultValue: '')
  final String date;

  @JsonKey(name: 'has_activity', defaultValue: false)
  final bool hasActivity;

  @JsonKey(name: 'win_rate')
  final double? winRate;

  @JsonKey(name: 'trade_count', defaultValue: 0)
  final int tradeCount;

  const DailyActivityItem({
    required this.date,
    required this.hasActivity,
    this.winRate,
    required this.tradeCount,
  });

  factory DailyActivityItem.fromJson(Map<String, dynamic> json) =>
      _$DailyActivityItemFromJson(json);

  Map<String, dynamic> toJson() => _$DailyActivityItemToJson(this);
}
