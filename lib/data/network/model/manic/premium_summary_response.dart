import 'package:json_annotation/json_annotation.dart';

part 'premium_summary_response.g.dart';

/// Premium 分析 - 摘要数据
/// GET /users/pnl/premium/summary
@JsonSerializable()
class PremiumSummaryResponse {
  @JsonKey(name: 'net_pnl', defaultValue: 0)
  final double netPnl;

  @JsonKey(name: 'pnl_percent', defaultValue: 0)
  final double pnlPercent;

  @JsonKey(name: 'win_rate', defaultValue: 0)
  final double winRate;

  @JsonKey(name: 'wins', defaultValue: 0)
  final int wins;

  @JsonKey(name: 'losses', defaultValue: 0)
  final int losses;

  @JsonKey(name: 'total_trades', defaultValue: 0)
  final int totalTrades;

  @JsonKey(name: 'total_volume', defaultValue: 0)
  final double totalVolume;

  @JsonKey(name: 'performance', defaultValue: [])
  final List<PerformancePoint> performance;

  @JsonKey(name: 'trade_tape', defaultValue: [])
  final List<TradeTapeItem> tradeTape;

  const PremiumSummaryResponse({
    required this.netPnl,
    required this.pnlPercent,
    required this.winRate,
    required this.wins,
    required this.losses,
    required this.totalTrades,
    required this.totalVolume,
    required this.performance,
    required this.tradeTape,
  });

  factory PremiumSummaryResponse.fromJson(Map<String, dynamic> json) =>
      _$PremiumSummaryResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PremiumSummaryResponseToJson(this);
}

/// 性能时序数据点
@JsonSerializable()
class PerformancePoint {
  @JsonKey(name: 'period', defaultValue: '')
  final String period;

  @JsonKey(name: 'net_pnl', defaultValue: 0)
  final double netPnl;

  @JsonKey(name: 'volume', defaultValue: 0)
  final double volume;

  const PerformancePoint({
    required this.period,
    required this.netPnl,
    required this.volume,
  });

  factory PerformancePoint.fromJson(Map<String, dynamic> json) =>
      _$PerformancePointFromJson(json);

  Map<String, dynamic> toJson() => _$PerformancePointToJson(this);
}

/// 最近交易记录
@JsonSerializable()
class TradeTapeItem {
  @JsonKey(name: 'asset', defaultValue: '')
  final String asset;

  @JsonKey(name: 'pnl_amount', defaultValue: 0)
  final double pnlAmount;

  @JsonKey(name: 'side')
  final String? side;

  const TradeTapeItem({
    required this.asset,
    required this.pnlAmount,
    this.side,
  });

  factory TradeTapeItem.fromJson(Map<String, dynamic> json) =>
      _$TradeTapeItemFromJson(json);

  Map<String, dynamic> toJson() => _$TradeTapeItemToJson(this);
}
