import 'package:json_annotation/json_annotation.dart';

part 'agent_regenerate_key_response.g.dart';

@JsonSerializable()
class AgentRegenerateKeyResponse {
  @JsonKey(name: 'api_key')
  final String apiKey;
  @JsonKey(name: 'api_key_name')
  final String apiKeyName;

  const AgentRegenerateKeyResponse({
    required this.apiKey,
    required this.apiKeyName,
  });

  factory AgentRegenerateKeyResponse.fromJson(Map<String, dynamic> json) =>
      _$AgentRegenerateKeyResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AgentRegenerateKeyResponseToJson(this);
}
