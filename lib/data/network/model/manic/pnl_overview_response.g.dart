// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pnl_overview_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PnlOverviewResponse _$PnlOverviewResponseFromJson(Map<String, dynamic> json) =>
    PnlOverviewResponse(
      isPremium: json['is_premium'] as bool? ?? false,
      totalDeposits: (json['total_deposits'] as num?)?.toDouble() ?? 0,
      premiumThreshold: (json['premium_threshold'] as num?)?.toDouble() ?? 5000,
      winRate: (json['win_rate'] as num?)?.toDouble() ?? 0,
      winRatePercentile: (json['win_rate_percentile'] as num?)?.toDouble() ?? 0,
      wins: (json['wins'] as num?)?.toInt() ?? 0,
      losses: (json['losses'] as num?)?.toInt() ?? 0,
      totalTrades: (json['total_trades'] as num?)?.toInt() ?? 0,
      dailyActivities: (json['daily_activities'] as List<dynamic>?)
              ?.map(
                  (e) => DailyActivityItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );

Map<String, dynamic> _$PnlOverviewResponseToJson(
        PnlOverviewResponse instance) =>
    <String, dynamic>{
      'is_premium': instance.isPremium,
      'total_deposits': instance.totalDeposits,
      'premium_threshold': instance.premiumThreshold,
      'win_rate': instance.winRate,
      'win_rate_percentile': instance.winRatePercentile,
      'wins': instance.wins,
      'losses': instance.losses,
      'total_trades': instance.totalTrades,
      'daily_activities': instance.dailyActivities,
    };

DailyActivityItem _$DailyActivityItemFromJson(Map<String, dynamic> json) =>
    DailyActivityItem(
      date: json['date'] as String? ?? '',
      hasActivity: json['has_activity'] as bool? ?? false,
      winRate: (json['win_rate'] as num?)?.toDouble(),
      tradeCount: (json['trade_count'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$DailyActivityItemToJson(DailyActivityItem instance) =>
    <String, dynamic>{
      'date': instance.date,
      'has_activity': instance.hasActivity,
      'win_rate': instance.winRate,
      'trade_count': instance.tradeCount,
    };
