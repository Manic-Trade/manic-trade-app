import 'package:json_annotation/json_annotation.dart';

part 'leaderboard_response.g.dart';

@JsonSerializable()
class LeaderboardResponse {
  @JsonKey(name: 'start_time')
  final String startTime;
  @JsonKey(name: 'end_time')
  final String endTime;
  @JsonKey(name: 'total_participants')
  final int totalParticipants;
  final List<LeaderboardEntryResponse> data;
  @JsonKey(name: 'current_user')
  final LeaderboardEntryResponse? currentUser;

  const LeaderboardResponse({
    required this.startTime,
    required this.endTime,
    required this.totalParticipants,
    required this.data,
    this.currentUser,
  });

  factory LeaderboardResponse.fromJson(Map<String, dynamic> json) =>
      _$LeaderboardResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LeaderboardResponseToJson(this);
}

@JsonSerializable()
class LeaderboardEntryResponse {
  final int rank;
  final String wallet;
  @JsonKey(name: 'total_rounds')
  final int totalRounds;
  @JsonKey(name: 'win_count')
  final int winCount;
  @JsonKey(name: 'total_profit')
  final double totalProfit;
  final double prize;

  /// 是否为 AI 交易 agent 钱包（AI Campaign S3 后端新增）。
  /// 旧后端兼容：兜底 `is_ai_agent` / `ai_agent` / `isAgent`，参见 [resolveIsAgent]。
  @JsonKey(name: 'is_agent')
  final bool? isAgent;

  /// agent 名称，仅 isAgent=true 时有意义。
  @JsonKey(name: 'agent_name')
  final String? agentName;

  /// agent 所属的真实用户钱包地址，用于判定 "Mine"。
  @JsonKey(name: 'parent_wallet')
  final String? parentWallet;

  /// @deprecated S2 旧字段名，留作 mock 兼容。
  @JsonKey(name: 'is_ai_agent')
  final bool? isAiAgent;

  /// @deprecated S2 旧字段名，留作 mock 兼容。
  @JsonKey(name: 'ai_agent')
  final bool? aiAgent;

  /// @deprecated S2 camelCase 旧字段名，留作 mock 兼容（对齐 web
  /// `resolveIsAgent` 的兜底链）。
  @JsonKey(name: 'isAgent')
  final bool? isAgentCamel;

  const LeaderboardEntryResponse({
    required this.rank,
    required this.wallet,
    required this.totalRounds,
    required this.winCount,
    required this.totalProfit,
    required this.prize,
    this.isAgent,
    this.agentName,
    this.parentWallet,
    this.isAiAgent,
    this.aiAgent,
    this.isAgentCamel,
  });

  /// 兜底解析 agent 标记，对齐 web `resolveIsAgent`：
  /// `is_agent → isAgent(camelCase) → is_ai_agent → ai_agent`。
  bool get resolveIsAgent =>
      isAgent ?? isAgentCamel ?? isAiAgent ?? aiAgent ?? false;

  factory LeaderboardEntryResponse.fromJson(Map<String, dynamic> json) =>
      _$LeaderboardEntryResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LeaderboardEntryResponseToJson(this);
}
