// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'check_user_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CheckUserResponse _$CheckUserResponseFromJson(Map<String, dynamic> json) =>
    CheckUserResponse(
      userActive: json['user_active'] as String,
      userCanTrade: json['user_can_trade'] as bool,
      userCreated: json['user_created'] as bool,
      userId: (json['user_id'] as num?)?.toInt(),
      validCode: json['valid_code'] as bool?,
    );

Map<String, dynamic> _$CheckUserResponseToJson(CheckUserResponse instance) =>
    <String, dynamic>{
      'user_active': instance.userActive,
      'user_can_trade': instance.userCanTrade,
      'user_created': instance.userCreated,
      'user_id': instance.userId,
      'valid_code': instance.validCode,
    };
