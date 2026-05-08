// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prepare_close_position_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PrepareClosePositionResponse _$PrepareClosePositionResponseFromJson(
        Map<String, dynamic> json) =>
    PrepareClosePositionResponse(
      requestId: json['request_id'] as String,
      unsignedTx: json['unsigned_tx'] as String,
      positionId: json['position_id'] as String,
      asset: json['asset'] as String,
      expiresIn: (json['expires_in'] as num).toInt(),
    );

Map<String, dynamic> _$PrepareClosePositionResponseToJson(
        PrepareClosePositionResponse instance) =>
    <String, dynamic>{
      'request_id': instance.requestId,
      'unsigned_tx': instance.unsignedTx,
      'position_id': instance.positionId,
      'asset': instance.asset,
      'expires_in': instance.expiresIn,
    };
