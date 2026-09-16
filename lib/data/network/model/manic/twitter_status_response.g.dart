// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'twitter_status_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TwitterStatusResponse _$TwitterStatusResponseFromJson(
        Map<String, dynamic> json) =>
    TwitterStatusResponse(
      wallet: json['wallet'] as String,
      twitterUrl: json['twitter_url'] as String,
      twitterStatus: json['twitter_status'] as bool,
      twitterName: json['twitter_name'] as String?,
    );

Map<String, dynamic> _$TwitterStatusResponseToJson(
        TwitterStatusResponse instance) =>
    <String, dynamic>{
      'wallet': instance.wallet,
      'twitter_url': instance.twitterUrl,
      'twitter_status': instance.twitterStatus,
      'twitter_name': instance.twitterName,
    };
