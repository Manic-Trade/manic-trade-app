// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'airdrop_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AirdropResponse _$AirdropResponseFromJson(Map<String, dynamic> json) =>
    AirdropResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
    );

Map<String, dynamic> _$AirdropResponseToJson(AirdropResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
    };
