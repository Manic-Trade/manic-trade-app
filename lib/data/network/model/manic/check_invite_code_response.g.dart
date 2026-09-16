// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'check_invite_code_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CheckInviteCodeResponse _$CheckInviteCodeResponseFromJson(
        Map<String, dynamic> json) =>
    CheckInviteCodeResponse(
      valid: json['valid'] as bool,
      code: json['code'] as String,
    );

Map<String, dynamic> _$CheckInviteCodeResponseToJson(
        CheckInviteCodeResponse instance) =>
    <String, dynamic>{
      'valid': instance.valid,
      'code': instance.code,
    };
