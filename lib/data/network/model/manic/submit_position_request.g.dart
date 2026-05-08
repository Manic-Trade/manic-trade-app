// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'submit_position_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubmitPositionRequest _$SubmitPositionRequestFromJson(
        Map<String, dynamic> json) =>
    SubmitPositionRequest(
      requestId: json['request_id'] as String,
      userSignature: json['user_signature'] as String,
    );

Map<String, dynamic> _$SubmitPositionRequestToJson(
        SubmitPositionRequest instance) =>
    <String, dynamic>{
      'request_id': instance.requestId,
      'user_signature': instance.userSignature,
    };
