// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'twitter_follow_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TwitterFollowResponse _$TwitterFollowResponseFromJson(
        Map<String, dynamic> json) =>
    TwitterFollowResponse(
      success: json['success'] as bool,
      twitterId: json['twitter_id'] as String,
      twitterUsername: json['twitter_username'] as String,
      canTrade: json['can_trade'] as bool,
    );

Map<String, dynamic> _$TwitterFollowResponseToJson(
        TwitterFollowResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'twitter_id': instance.twitterId,
      'twitter_username': instance.twitterUsername,
      'can_trade': instance.canTrade,
    };
