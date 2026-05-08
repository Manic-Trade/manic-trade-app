// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'submit_close_position_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubmitClosePositionRequest _$SubmitClosePositionRequestFromJson(
        Map<String, dynamic> json) =>
    SubmitClosePositionRequest(
      requestId: json['request_id'] as String,
      userSignature: json['user_signature'] as String,
    );

Map<String, dynamic> _$SubmitClosePositionRequestToJson(
        SubmitClosePositionRequest instance) =>
    <String, dynamic>{
      'request_id': instance.requestId,
      'user_signature': instance.userSignature,
    };
