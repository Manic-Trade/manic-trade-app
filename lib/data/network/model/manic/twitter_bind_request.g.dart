// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'twitter_bind_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TwitterBindRequest _$TwitterBindRequestFromJson(Map<String, dynamic> json) =>
    TwitterBindRequest(
      userId: json['user_id'] as String,
      subOrgId: json['sub_org_id'] as String,
      wallet: json['wallet'] as String,
      twitterId: json['twitter_id'] as String,
      twitterUsername: json['twitter_username'] as String?,
      avatarUrl: json['avatar_url'] as String?,
    );

Map<String, dynamic> _$TwitterBindRequestToJson(TwitterBindRequest instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'sub_org_id': instance.subOrgId,
      'wallet': instance.wallet,
      'twitter_id': instance.twitterId,
      'twitter_username': instance.twitterUsername,
      'avatar_url': instance.avatarUrl,
    };
