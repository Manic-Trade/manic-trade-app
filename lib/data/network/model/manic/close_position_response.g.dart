// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'close_position_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClosePositionResponse _$ClosePositionResponseFromJson(
        Map<String, dynamic> json) =>
    ClosePositionResponse(
      json['signed_tx'] as String,
    );

Map<String, dynamic> _$ClosePositionResponseToJson(
        ClosePositionResponse instance) =>
    <String, dynamic>{
      'signed_tx': instance.signedTx,
    };
