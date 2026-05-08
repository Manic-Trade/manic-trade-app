// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'submit_close_position_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubmitClosePositionResponse _$SubmitClosePositionResponseFromJson(
        Map<String, dynamic> json) =>
    SubmitClosePositionResponse(
      txHash: json['tx_hash'] as String,
      positionId: json['position_id'] as String,
      asset: json['asset'] as String,
    );

Map<String, dynamic> _$SubmitClosePositionResponseToJson(
        SubmitClosePositionResponse instance) =>
    <String, dynamic>{
      'tx_hash': instance.txHash,
      'position_id': instance.positionId,
      'asset': instance.asset,
    };
