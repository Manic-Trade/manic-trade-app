// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'close_position_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClosePositionRequest _$ClosePositionRequestFromJson(
        Map<String, dynamic> json) =>
    ClosePositionRequest(
      positionId: json['position_id'] as String,
      asset: json['asset'] as String,
      mint: (json['mint'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
    );

Map<String, dynamic> _$ClosePositionRequestToJson(
        ClosePositionRequest instance) =>
    <String, dynamic>{
      'position_id': instance.positionId,
      'asset': instance.asset,
      'mint': instance.mint,
    };
