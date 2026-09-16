import 'package:json_annotation/json_annotation.dart';

part 'agent_rename_key_response.g.dart';

@JsonSerializable()
class AgentRenameKeyResponse {
  @JsonKey(name: 'api_key_name')
  final String apiKeyName;

  const AgentRenameKeyResponse({required this.apiKeyName});

  factory AgentRenameKeyResponse.fromJson(Map<String, dynamic> json) =>
      _$AgentRenameKeyResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AgentRenameKeyResponseToJson(this);
}
