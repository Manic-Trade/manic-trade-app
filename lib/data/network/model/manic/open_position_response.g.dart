// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'open_position_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OpenPositionResponse _$OpenPositionResponseFromJson(
        Map<String, dynamic> json) =>
    OpenPositionResponse(
      json['signed_tx'] as String,
    );

Map<String, dynamic> _$OpenPositionResponseToJson(
        OpenPositionResponse instance) =>
    <String, dynamic>{
      'signed_tx': instance.signedTx,
    };
