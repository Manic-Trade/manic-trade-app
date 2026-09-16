// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'premium_activity_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PremiumActivityResponse _$PremiumActivityResponseFromJson(
        Map<String, dynamic> json) =>
    PremiumActivityResponse(
      heatmap: (json['heatmap'] as List<dynamic>?)
              ?.map((e) => HeatmapDay.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      longestWinStreak: (json['longest_win_streak'] as num?)?.toInt() ?? 0,
      bestTradingDay: json['best_trading_day'] == null
          ? null
          : BestTradingDay.fromJson(
              json['best_trading_day'] as Map<String, dynamic>),
      dailyAverage: (json['daily_average'] as num?)?.toDouble() ?? 0,
    );

Map<String, dynamic> _$PremiumActivityResponseToJson(
        PremiumActivityResponse instance) =>
    <String, dynamic>{
      'heatmap': instance.heatmap,
      'longest_win_streak': instance.longestWinStreak,
      'best_trading_day': instance.bestTradingDay,
      'daily_average': instance.dailyAverage,
    };

HeatmapDay _$HeatmapDayFromJson(Map<String, dynamic> json) => HeatmapDay(
      date: json['date'] as String? ?? '',
      hasActivity: json['has_activity'] as bool? ?? false,
      tradeCount: (json['trade_count'] as num?)?.toInt() ?? 0,
      wins: (json['wins'] as num?)?.toInt() ?? 0,
      winRate: (json['win_rate'] as num?)?.toDouble(),
      volume: (json['volume'] as num?)?.toDouble() ?? 0,
      netPnl: (json['net_pnl'] as num?)?.toDouble() ?? 0,
    );

Map<String, dynamic> _$HeatmapDayToJson(HeatmapDay instance) =>
    <String, dynamic>{
      'date': instance.date,
      'has_activity': instance.hasActivity,
      'trade_count': instance.tradeCount,
      'wins': instance.wins,
      'win_rate': instance.winRate,
      'volume': instance.volume,
      'net_pnl': instance.netPnl,
    };

BestTradingDay _$BestTradingDayFromJson(Map<String, dynamic> json) =>
    BestTradingDay(
      date: json['date'] as String? ?? '',
      pnl: (json['pnl'] as num?)?.toDouble() ?? 0,
    );

Map<String, dynamic> _$BestTradingDayToJson(BestTradingDay instance) =>
    <String, dynamic>{
      'date': instance.date,
      'pnl': instance.pnl,
    };
