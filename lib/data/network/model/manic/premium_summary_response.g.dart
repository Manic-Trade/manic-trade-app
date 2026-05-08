// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'premium_summary_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PremiumSummaryResponse _$PremiumSummaryResponseFromJson(
        Map<String, dynamic> json) =>
    PremiumSummaryResponse(
      netPnl: (json['net_pnl'] as num?)?.toDouble() ?? 0,
      pnlPercent: (json['pnl_percent'] as num?)?.toDouble() ?? 0,
      winRate: (json['win_rate'] as num?)?.toDouble() ?? 0,
      wins: (json['wins'] as num?)?.toInt() ?? 0,
      losses: (json['losses'] as num?)?.toInt() ?? 0,
      totalTrades: (json['total_trades'] as num?)?.toInt() ?? 0,
      totalVolume: (json['total_volume'] as num?)?.toDouble() ?? 0,
      performance: (json['performance'] as List<dynamic>?)
              ?.map((e) => PerformancePoint.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      tradeTape: (json['trade_tape'] as List<dynamic>?)
              ?.map((e) => TradeTapeItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );

Map<String, dynamic> _$PremiumSummaryResponseToJson(
        PremiumSummaryResponse instance) =>
    <String, dynamic>{
      'net_pnl': instance.netPnl,
      'pnl_percent': instance.pnlPercent,
      'win_rate': instance.winRate,
      'wins': instance.wins,
      'losses': instance.losses,
      'total_trades': instance.totalTrades,
      'total_volume': instance.totalVolume,
      'performance': instance.performance,
      'trade_tape': instance.tradeTape,
    };

PerformancePoint _$PerformancePointFromJson(Map<String, dynamic> json) =>
    PerformancePoint(
      period: json['period'] as String? ?? '',
      netPnl: (json['net_pnl'] as num?)?.toDouble() ?? 0,
      volume: (json['volume'] as num?)?.toDouble() ?? 0,
    );

Map<String, dynamic> _$PerformancePointToJson(PerformancePoint instance) =>
    <String, dynamic>{
      'period': instance.period,
      'net_pnl': instance.netPnl,
      'volume': instance.volume,
    };

TradeTapeItem _$TradeTapeItemFromJson(Map<String, dynamic> json) =>
    TradeTapeItem(
      asset: json['asset'] as String? ?? '',
      pnlAmount: (json['pnl_amount'] as num?)?.toDouble() ?? 0,
      side: json['side'] as String?,
    );

Map<String, dynamic> _$TradeTapeItemToJson(TradeTapeItem instance) =>
    <String, dynamic>{
      'asset': instance.asset,
      'pnl_amount': instance.pnlAmount,
      'side': instance.side,
    };
