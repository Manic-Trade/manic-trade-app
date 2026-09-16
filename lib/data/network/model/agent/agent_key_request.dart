import 'package:json_annotation/json_annotation.dart';

part 'agent_key_request.g.dart';

/// regenerate-key 和 rename-key 共用的请求体
@JsonSerializable()
class AgentKeyRequest {
  @JsonKey(name: 'key_name')
  final String keyName;

  const AgentKeyRequest({required this.keyName});

  factory AgentKeyRequest.fromJson(Map<String, dynamic> json) =>
      _$AgentKeyRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AgentKeyRequestToJson(this);
}
