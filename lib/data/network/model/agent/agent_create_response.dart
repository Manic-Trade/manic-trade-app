import 'package:json_annotation/json_annotation.dart';

part 'agent_create_response.g.dart';

@JsonSerializable()
class AgentCreateResponse {
  @JsonKey(name: 'agent_address')
  final String agentAddress;
  /// 完整 API Key，仅首次创建时返回（is_new=true）
  @JsonKey(name: 'api_key')
  final String? apiKey;
  @JsonKey(name: 'api_key_name', defaultValue: '')
  final String apiKeyName;
  @JsonKey(name: 'api_key_prefix', defaultValue: '')
  final String apiKeyPrefix;
  @JsonKey(name: 'is_new', defaultValue: false)
  final bool isNew;

  const AgentCreateResponse({
    required this.agentAddress,
    this.apiKey,
    required this.apiKeyName,
    required this.apiKeyPrefix,
    required this.isNew,
  });

  factory AgentCreateResponse.fromJson(Map<String, dynamic> json) =>
      _$AgentCreateResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AgentCreateResponseToJson(this);
}
