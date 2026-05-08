import 'package:json_annotation/json_annotation.dart';

part 'agent_info_response.g.dart';

@JsonSerializable()
class AgentTradingStats {
  @JsonKey(name: 'total_trades', defaultValue: 0)
  final int totalTrades;
  @JsonKey(defaultValue: 0)
  final int wins;
  @JsonKey(defaultValue: 0)
  final int losses;

  /// 0–1, 例如 0.714 = 71.4%
  @JsonKey(name: 'win_rate', defaultValue: 0)
  final double winRate;

  /// USDC, 正数=盈利
  @JsonKey(name: 'net_pnl', defaultValue: 0)
  final double netPnl;

  /// 后端返回的 PnL 百分比, 例如 -100 表示 -100%
  @JsonKey(name: 'pnl_change_percent')
  final double? pnlChangePercent;

  /// USDC
  @JsonKey(name: 'total_volume', defaultValue: 0)
  final double totalVolume;

  const AgentTradingStats({
    required this.totalTrades,
    required this.wins,
    required this.losses,
    required this.winRate,
    required this.netPnl,
    this.pnlChangePercent,
    required this.totalVolume,
  });

  factory AgentTradingStats.fromJson(Map<String, dynamic> json) =>
      _$AgentTradingStatsFromJson(json);

  Map<String, dynamic> toJson() => _$AgentTradingStatsToJson(this);
}

/// Agent 代币信息
@JsonSerializable()
class AgentTokenInfo {
  @JsonKey(name: 'token_mint')
  final String tokenMint;
  @JsonKey(name: 'token_program')
  final String tokenProgram;
  final int decimals;

  const AgentTokenInfo({
    required this.tokenMint,
    required this.tokenProgram,
    required this.decimals,
  });

  factory AgentTokenInfo.fromJson(Map<String, dynamic> json) =>
      _$AgentTokenInfoFromJson(json);

  Map<String, dynamic> toJson() => _$AgentTokenInfoToJson(this);
}

@JsonSerializable()
class AgentInfoResponse {
  /// Agent 钱包地址
  final String? address;
  @JsonKey(name: 'api_key_name', defaultValue: '')
  final String apiKeyName;
  @JsonKey(name: 'api_key_prefix', defaultValue: '')
  final String apiKeyPrefix;

  /// 完整 API Key，可供复制（创建/重新生成时返回）
  @JsonKey(name: 'api_key_secret')
  final String? apiKeySecret;

  /// USDC 余额，decimal string，例如 "100.50"
  @JsonKey(defaultValue: '0')
  final String balance;

  /// false = key 已被删除
  @JsonKey(name: 'is_active', defaultValue: false)
  final bool isActive;

  /// RFC 3339 时间戳
  @JsonKey(name: 'created_at', defaultValue: '')
  final String createdAt;

  /// 代币信息（mint、program、decimals）
  final AgentTokenInfo? token;
  @JsonKey(name: 'trading_stats')
  final AgentTradingStats tradingStats;

  const AgentInfoResponse({
    this.address,
    required this.apiKeyName,
    required this.apiKeyPrefix,
    this.apiKeySecret,
    required this.balance,
    required this.isActive,
    required this.createdAt,
    this.token,
    required this.tradingStats,
  });

  bool get canAgentTrade => address != null;

  factory AgentInfoResponse.fromJson(Map<String, dynamic> json) =>
      _$AgentInfoResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AgentInfoResponseToJson(this);
}
