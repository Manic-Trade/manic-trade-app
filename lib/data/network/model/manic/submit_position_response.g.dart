// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'submit_position_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubmitPositionResponse _$SubmitPositionResponseFromJson(
        Map<String, dynamic> json) =>
    SubmitPositionResponse(
      txHash: json['tx_hash'] as String,
      positionId: json['position_id'] as String,
      asset: json['asset'] as String,
      side: json['side'] as String,
      positionMode: json['position_mode'] as String,
      price: (json['price'] as num).toInt(),
      priceExponent: (json['price_exponent'] as num).toInt(),
      amount: (json['amount'] as num).toInt(),
    );

Map<String, dynamic> _$SubmitPositionResponseToJson(
        SubmitPositionResponse instance) =>
    <String, dynamic>{
      'tx_hash': instance.txHash,
      'position_id': instance.positionId,
      'asset': instance.asset,
      'side': instance.side,
      'position_mode': instance.positionMode,
      'price': instance.price,
      'price_exponent': instance.priceExponent,
      'amount': instance.amount,
    };
