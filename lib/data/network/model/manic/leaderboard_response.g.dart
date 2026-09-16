// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leaderboard_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LeaderboardResponse _$LeaderboardResponseFromJson(Map<String, dynamic> json) =>
    LeaderboardResponse(
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      totalParticipants: (json['total_participants'] as num).toInt(),
      data: (json['data'] as List<dynamic>)
          .map((e) =>
              LeaderboardEntryResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentUser: json['current_user'] == null
          ? null
          : LeaderboardEntryResponse.fromJson(
              json['current_user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$LeaderboardResponseToJson(
        LeaderboardResponse instance) =>
    <String, dynamic>{
      'start_time': instance.startTime,
      'end_time': instance.endTime,
      'total_participants': instance.totalParticipants,
      'data': instance.data,
      'current_user': instance.currentUser,
    };

LeaderboardEntryResponse _$LeaderboardEntryResponseFromJson(
        Map<String, dynamic> json) =>
    LeaderboardEntryResponse(
      rank: (json['rank'] as num).toInt(),
      wallet: json['wallet'] as String,
      totalRounds: (json['total_rounds'] as num).toInt(),
      winCount: (json['win_count'] as num).toInt(),
      totalProfit: (json['total_profit'] as num).toDouble(),
      prize: (json['prize'] as num).toDouble(),
      isAgent: json['is_agent'] as bool?,
      agentName: json['agent_name'] as String?,
      parentWallet: json['parent_wallet'] as String?,
      isAiAgent: json['is_ai_agent'] as bool?,
      aiAgent: json['ai_agent'] as bool?,
      isAgentCamel: json['isAgent'] as bool?,
    );

Map<String, dynamic> _$LeaderboardEntryResponseToJson(
        LeaderboardEntryResponse instance) =>
    <String, dynamic>{
      'rank': instance.rank,
      'wallet': instance.wallet,
      'total_rounds': instance.totalRounds,
      'win_count': instance.winCount,
      'total_profit': instance.totalProfit,
      'prize': instance.prize,
      'is_agent': instance.isAgent,
      'agent_name': instance.agentName,
      'parent_wallet': instance.parentWallet,
      'is_ai_agent': instance.isAiAgent,
      'ai_agent': instance.aiAgent,
      'isAgent': instance.isAgentCamel,
    };
