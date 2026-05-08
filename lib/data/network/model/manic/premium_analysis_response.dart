import 'package:json_annotation/json_annotation.dart';

part 'premium_analysis_response.g.dart';

/// Premium 分析 - 行为维度数据
/// GET /users/pnl/premium/analysis
@JsonSerializable()
class PremiumAnalysisResponse {
  @JsonKey(name: 'direction', defaultValue: [])
  final List<DirectionItem> direction;

  /// 持仓时长效率（仅 Individual 模式有数据）
  @JsonKey(name: 'duration')
  final List<DurationItem>? duration;

  @JsonKey(name: 'hourly', defaultValue: [])
  final List<TimeSlotItem> hourly;

  @JsonKey(name: 'weekday', defaultValue: [])
  final List<TimeSlotItem> weekday;

  @JsonKey(name: 'assets', defaultValue: [])
  final List<AssetBreakdownItem> assets;

  @JsonKey(name: 'modes', defaultValue: [])
  final List<ModeEfficiencyItem> modes;

  /// AI 生成的模式对比洞察
  @JsonKey(name: 'mode_insight')
  final String? modeInsight;

  const PremiumAnalysisResponse({
    required this.direction,
    this.duration,
    required this.hourly,
    required this.weekday,
    required this.assets,
    required this.modes,
    this.modeInsight,
  });

  factory PremiumAnalysisResponse.fromJson(Map<String, dynamic> json) =>
      _$PremiumAnalysisResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PremiumAnalysisResponseToJson(this);
}

/// 方向偏好（Higher / Lower）
@JsonSerializable()
class DirectionItem {
  @JsonKey(name: 'side', defaultValue: '')
  final String side;

  @JsonKey(name: 'trade_count', defaultValue: 0)
  final int tradeCount;

  @JsonKey(name: 'wins', defaultValue: 0)
  final int wins;

  @JsonKey(name: 'win_rate', defaultValue: 0)
  final double winRate;

  @JsonKey(name: 'volume', defaultValue: 0)
  final double volume;

  @JsonKey(name: 'net_pnl', defaultValue: 0)
  final double netPnl;

  const DirectionItem({
    required this.side,
    required this.tradeCount,
    required this.wins,
    required this.winRate,
    required this.volume,
    required this.netPnl,
  });

  factory DirectionItem.fromJson(Map<String, dynamic> json) =>
      _$DirectionItemFromJson(json);

  Map<String, dynamic> toJson() => _$DirectionItemToJson(this);
}

/// 持仓时长效率
@JsonSerializable()
class DurationItem {
  @JsonKey(name: 'duration_seconds', defaultValue: 0)
  final int durationSeconds;

  @JsonKey(name: 'label', defaultValue: '')
  final String label;

  @JsonKey(name: 'trade_count', defaultValue: 0)
  final int tradeCount;

  @JsonKey(name: 'wins', defaultValue: 0)
  final int wins;

  @JsonKey(name: 'win_rate', defaultValue: 0)
  final double winRate;

  const DurationItem({
    required this.durationSeconds,
    required this.label,
    required this.tradeCount,
    required this.wins,
    required this.winRate,
  });

  factory DurationItem.fromJson(Map<String, dynamic> json) =>
      _$DurationItemFromJson(json);

  Map<String, dynamic> toJson() => _$DurationItemToJson(this);
}

/// 时间段数据（小时 / 星期）
@JsonSerializable()
class TimeSlotItem {
  @JsonKey(name: 'slot', defaultValue: 0)
  final int slot;

  @JsonKey(name: 'label', defaultValue: '')
  final String label;

  @JsonKey(name: 'trade_count', defaultValue: 0)
  final int tradeCount;

  @JsonKey(name: 'wins', defaultValue: 0)
  final int wins;

  @JsonKey(name: 'win_rate', defaultValue: 0)
  final double winRate;

  const TimeSlotItem({
    required this.slot,
    required this.label,
    required this.tradeCount,
    required this.wins,
    required this.winRate,
  });

  factory TimeSlotItem.fromJson(Map<String, dynamic> json) =>
      _$TimeSlotItemFromJson(json);

  Map<String, dynamic> toJson() => _$TimeSlotItemToJson(this);
}

/// 资产分布
@JsonSerializable()
class AssetBreakdownItem {
  @JsonKey(name: 'feed_id', defaultValue: '')
  final String feedId;

  @JsonKey(name: 'asset', defaultValue: '')
  final String asset;

  @JsonKey(name: 'trade_count', defaultValue: 0)
  final int tradeCount;

  @JsonKey(name: 'wins', defaultValue: 0)
  final int wins;

  @JsonKey(name: 'win_rate', defaultValue: 0)
  final double winRate;

  @JsonKey(name: 'volume', defaultValue: 0)
  final double volume;

  @JsonKey(name: 'net_pnl', defaultValue: 0)
  final double netPnl;

  const AssetBreakdownItem({
    required this.feedId,
    required this.asset,
    required this.tradeCount,
    required this.wins,
    required this.winRate,
    required this.volume,
    required this.netPnl,
  });

  /// 占比（需在 VO 层根据总交易量计算）
  factory AssetBreakdownItem.fromJson(Map<String, dynamic> json) =>
      _$AssetBreakdownItemFromJson(json);

  Map<String, dynamic> toJson() => _$AssetBreakdownItemToJson(this);
}

/// 模式效率（Individual / Unified）
@JsonSerializable()
class ModeEfficiencyItem {
  @JsonKey(name: 'mode', defaultValue: '')
  final String mode;

  @JsonKey(name: 'label', defaultValue: '')
  final String label;

  @JsonKey(name: 'trade_count', defaultValue: 0)
  final int tradeCount;

  @JsonKey(name: 'wins', defaultValue: 0)
  final int wins;

  @JsonKey(name: 'win_rate', defaultValue: 0)
  final double winRate;

  @JsonKey(name: 'volume', defaultValue: 0)
  final double volume;

  @JsonKey(name: 'net_pnl', defaultValue: 0)
  final double netPnl;

  const ModeEfficiencyItem({
    required this.mode,
    required this.label,
    required this.tradeCount,
    required this.wins,
    required this.winRate,
    required this.volume,
    required this.netPnl,
  });

  factory ModeEfficiencyItem.fromJson(Map<String, dynamic> json) =>
      _$ModeEfficiencyItemFromJson(json);

  Map<String, dynamic> toJson() => _$ModeEfficiencyItemToJson(this);
}
