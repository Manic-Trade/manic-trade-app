// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'premium_analysis_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PremiumAnalysisResponse _$PremiumAnalysisResponseFromJson(
        Map<String, dynamic> json) =>
    PremiumAnalysisResponse(
      direction: (json['direction'] as List<dynamic>?)
              ?.map((e) => DirectionItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      duration: (json['duration'] as List<dynamic>?)
          ?.map((e) => DurationItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      hourly: (json['hourly'] as List<dynamic>?)
              ?.map((e) => TimeSlotItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      weekday: (json['weekday'] as List<dynamic>?)
              ?.map((e) => TimeSlotItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      assets: (json['assets'] as List<dynamic>?)
              ?.map(
                  (e) => AssetBreakdownItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      modes: (json['modes'] as List<dynamic>?)
              ?.map(
                  (e) => ModeEfficiencyItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      modeInsight: json['mode_insight'] as String?,
    );

Map<String, dynamic> _$PremiumAnalysisResponseToJson(
        PremiumAnalysisResponse instance) =>
    <String, dynamic>{
      'direction': instance.direction,
      'duration': instance.duration,
      'hourly': instance.hourly,
      'weekday': instance.weekday,
      'assets': instance.assets,
      'modes': instance.modes,
      'mode_insight': instance.modeInsight,
    };

DirectionItem _$DirectionItemFromJson(Map<String, dynamic> json) =>
    DirectionItem(
      side: json['side'] as String? ?? '',
      tradeCount: (json['trade_count'] as num?)?.toInt() ?? 0,
      wins: (json['wins'] as num?)?.toInt() ?? 0,
      winRate: (json['win_rate'] as num?)?.toDouble() ?? 0,
      volume: (json['volume'] as num?)?.toDouble() ?? 0,
      netPnl: (json['net_pnl'] as num?)?.toDouble() ?? 0,
    );

Map<String, dynamic> _$DirectionItemToJson(DirectionItem instance) =>
    <String, dynamic>{
      'side': instance.side,
      'trade_count': instance.tradeCount,
      'wins': instance.wins,
      'win_rate': instance.winRate,
      'volume': instance.volume,
      'net_pnl': instance.netPnl,
    };

DurationItem _$DurationItemFromJson(Map<String, dynamic> json) => DurationItem(
      durationSeconds: (json['duration_seconds'] as num?)?.toInt() ?? 0,
      label: json['label'] as String? ?? '',
      tradeCount: (json['trade_count'] as num?)?.toInt() ?? 0,
      wins: (json['wins'] as num?)?.toInt() ?? 0,
      winRate: (json['win_rate'] as num?)?.toDouble() ?? 0,
    );

Map<String, dynamic> _$DurationItemToJson(DurationItem instance) =>
    <String, dynamic>{
      'duration_seconds': instance.durationSeconds,
      'label': instance.label,
      'trade_count': instance.tradeCount,
      'wins': instance.wins,
      'win_rate': instance.winRate,
    };

TimeSlotItem _$TimeSlotItemFromJson(Map<String, dynamic> json) => TimeSlotItem(
      slot: (json['slot'] as num?)?.toInt() ?? 0,
      label: json['label'] as String? ?? '',
      tradeCount: (json['trade_count'] as num?)?.toInt() ?? 0,
      wins: (json['wins'] as num?)?.toInt() ?? 0,
      winRate: (json['win_rate'] as num?)?.toDouble() ?? 0,
    );

Map<String, dynamic> _$TimeSlotItemToJson(TimeSlotItem instance) =>
    <String, dynamic>{
      'slot': instance.slot,
      'label': instance.label,
      'trade_count': instance.tradeCount,
      'wins': instance.wins,
      'win_rate': instance.winRate,
    };

AssetBreakdownItem _$AssetBreakdownItemFromJson(Map<String, dynamic> json) =>
    AssetBreakdownItem(
      feedId: json['feed_id'] as String? ?? '',
      asset: json['asset'] as String? ?? '',
      tradeCount: (json['trade_count'] as num?)?.toInt() ?? 0,
      wins: (json['wins'] as num?)?.toInt() ?? 0,
      winRate: (json['win_rate'] as num?)?.toDouble() ?? 0,
      volume: (json['volume'] as num?)?.toDouble() ?? 0,
      netPnl: (json['net_pnl'] as num?)?.toDouble() ?? 0,
    );

Map<String, dynamic> _$AssetBreakdownItemToJson(AssetBreakdownItem instance) =>
    <String, dynamic>{
      'feed_id': instance.feedId,
      'asset': instance.asset,
      'trade_count': instance.tradeCount,
      'wins': instance.wins,
      'win_rate': instance.winRate,
      'volume': instance.volume,
      'net_pnl': instance.netPnl,
    };

ModeEfficiencyItem _$ModeEfficiencyItemFromJson(Map<String, dynamic> json) =>
    ModeEfficiencyItem(
      mode: json['mode'] as String? ?? '',
      label: json['label'] as String? ?? '',
      tradeCount: (json['trade_count'] as num?)?.toInt() ?? 0,
      wins: (json['wins'] as num?)?.toInt() ?? 0,
      winRate: (json['win_rate'] as num?)?.toDouble() ?? 0,
      volume: (json['volume'] as num?)?.toDouble() ?? 0,
      netPnl: (json['net_pnl'] as num?)?.toDouble() ?? 0,
    );

Map<String, dynamic> _$ModeEfficiencyItemToJson(ModeEfficiencyItem instance) =>
    <String, dynamic>{
      'mode': instance.mode,
      'label': instance.label,
      'trade_count': instance.tradeCount,
      'wins': instance.wins,
      'win_rate': instance.winRate,
      'volume': instance.volume,
      'net_pnl': instance.netPnl,
    };
