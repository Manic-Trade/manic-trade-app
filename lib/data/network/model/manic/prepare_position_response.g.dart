// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prepare_position_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PreparePositionResponse _$PreparePositionResponseFromJson(
        Map<String, dynamic> json) =>
    PreparePositionResponse(
      requestId: json['request_id'] as String,
      unsignedTx: json['unsigned_tx'] as String,
      amount: (json['amount'] as num).toInt(),
      side: json['side'] as String,
      asset: json['asset'] as String,
      positionMode: json['position_mode'] as String,
      price: (json['price'] as num).toInt(),
      positionId: json['position_id'] as String,
      priceExponent: (json['price_exponent'] as num).toInt(),
      expiresIn: (json['expires_in'] as num).toInt(),
    );

Map<String, dynamic> _$PreparePositionResponseToJson(
        PreparePositionResponse instance) =>
    <String, dynamic>{
      'request_id': instance.requestId,
      'unsigned_tx': instance.unsignedTx,
      'amount': instance.amount,
      'side': instance.side,
      'asset': instance.asset,
      'position_mode': instance.positionMode,
      'price': instance.price,
      'position_id': instance.positionId,
      'price_exponent': instance.priceExponent,
      'expires_in': instance.expiresIn,
    };
