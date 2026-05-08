import 'package:json_annotation/json_annotation.dart';

part 'agent_create_request.g.dart';

@JsonSerializable()
class AgentCreateRequest {
  @JsonKey(name: 'key_name')
  final String keyName;

  const AgentCreateRequest({required this.keyName});

  factory AgentCreateRequest.fromJson(Map<String, dynamic> json) =>
      _$AgentCreateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AgentCreateRequestToJson(this);
}
