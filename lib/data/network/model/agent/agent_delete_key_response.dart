import 'package:json_annotation/json_annotation.dart';

part 'agent_delete_key_response.g.dart';

@JsonSerializable()
class AgentDeleteKeyResponse {
  @JsonKey(defaultValue: false)
  final bool success;

  const AgentDeleteKeyResponse({required this.success});

  factory AgentDeleteKeyResponse.fromJson(Map<String, dynamic> json) =>
      _$AgentDeleteKeyResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AgentDeleteKeyResponseToJson(this);
}
