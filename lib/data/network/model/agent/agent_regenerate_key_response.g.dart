// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'agent_regenerate_key_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AgentRegenerateKeyResponse _$AgentRegenerateKeyResponseFromJson(
        Map<String, dynamic> json) =>
    AgentRegenerateKeyResponse(
      apiKey: json['api_key'] as String,
      apiKeyName: json['api_key_name'] as String,
    );

Map<String, dynamic> _$AgentRegenerateKeyResponseToJson(
        AgentRegenerateKeyResponse instance) =>
    <String, dynamic>{
      'api_key': instance.apiKey,
      'api_key_name': instance.apiKeyName,
    };
