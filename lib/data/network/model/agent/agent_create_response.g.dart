// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'agent_create_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AgentCreateResponse _$AgentCreateResponseFromJson(Map<String, dynamic> json) =>
    AgentCreateResponse(
      agentAddress: json['agent_address'] as String,
      apiKey: json['api_key'] as String?,
      apiKeyName: json['api_key_name'] as String? ?? '',
      apiKeyPrefix: json['api_key_prefix'] as String? ?? '',
      isNew: json['is_new'] as bool? ?? false,
    );

Map<String, dynamic> _$AgentCreateResponseToJson(
        AgentCreateResponse instance) =>
    <String, dynamic>{
      'agent_address': instance.agentAddress,
      'api_key': instance.apiKey,
      'api_key_name': instance.apiKeyName,
      'api_key_prefix': instance.apiKeyPrefix,
      'is_new': instance.isNew,
    };
