// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'agent_info_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AgentTradingStats _$AgentTradingStatsFromJson(Map<String, dynamic> json) =>
    AgentTradingStats(
      totalTrades: (json['total_trades'] as num?)?.toInt() ?? 0,
      wins: (json['wins'] as num?)?.toInt() ?? 0,
      losses: (json['losses'] as num?)?.toInt() ?? 0,
      winRate: (json['win_rate'] as num?)?.toDouble() ?? 0,
      netPnl: (json['net_pnl'] as num?)?.toDouble() ?? 0,
      pnlChangePercent: (json['pnl_change_percent'] as num?)?.toDouble(),
      totalVolume: (json['total_volume'] as num?)?.toDouble() ?? 0,
    );

Map<String, dynamic> _$AgentTradingStatsToJson(AgentTradingStats instance) =>
    <String, dynamic>{
      'total_trades': instance.totalTrades,
      'wins': instance.wins,
      'losses': instance.losses,
      'win_rate': instance.winRate,
      'net_pnl': instance.netPnl,
      'pnl_change_percent': instance.pnlChangePercent,
      'total_volume': instance.totalVolume,
    };

AgentTokenInfo _$AgentTokenInfoFromJson(Map<String, dynamic> json) =>
    AgentTokenInfo(
      tokenMint: json['token_mint'] as String,
      tokenProgram: json['token_program'] as String,
      decimals: (json['decimals'] as num).toInt(),
    );

Map<String, dynamic> _$AgentTokenInfoToJson(AgentTokenInfo instance) =>
    <String, dynamic>{
      'token_mint': instance.tokenMint,
      'token_program': instance.tokenProgram,
      'decimals': instance.decimals,
    };

AgentInfoResponse _$AgentInfoResponseFromJson(Map<String, dynamic> json) =>
    AgentInfoResponse(
      address: json['address'] as String?,
      apiKeyName: json['api_key_name'] as String? ?? '',
      apiKeyPrefix: json['api_key_prefix'] as String? ?? '',
      apiKeySecret: json['api_key_secret'] as String?,
      balance: json['balance'] as String? ?? '0',
      isActive: json['is_active'] as bool? ?? false,
      createdAt: json['created_at'] as String? ?? '',
      token: json['token'] == null
          ? null
          : AgentTokenInfo.fromJson(json['token'] as Map<String, dynamic>),
      tradingStats: AgentTradingStats.fromJson(
          json['trading_stats'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AgentInfoResponseToJson(AgentInfoResponse instance) =>
    <String, dynamic>{
      'address': instance.address,
      'api_key_name': instance.apiKeyName,
      'api_key_prefix': instance.apiKeyPrefix,
      'api_key_secret': instance.apiKeySecret,
      'balance': instance.balance,
      'is_active': instance.isActive,
      'created_at': instance.createdAt,
      'token': instance.token,
      'trading_stats': instance.tradingStats,
    };
