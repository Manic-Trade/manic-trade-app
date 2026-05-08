// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'twitter_bind_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TwitterBindResponse _$TwitterBindResponseFromJson(Map<String, dynamic> json) =>
    TwitterBindResponse(
      success: json['success'] as bool,
      canTrade: json['can_trade'] as bool,
    );

Map<String, dynamic> _$TwitterBindResponseToJson(
        TwitterBindResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'can_trade': instance.canTrade,
    };
