// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transfer_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransferResponse _$TransferResponseFromJson(Map<String, dynamic> json) =>
    TransferResponse(
      txHash: json['tx_hash'] as String,
      amount: json['amount'] as String,
      direction: json['direction'] as String,
    );

Map<String, dynamic> _$TransferResponseToJson(TransferResponse instance) =>
    <String, dynamic>{
      'tx_hash': instance.txHash,
      'amount': instance.amount,
      'direction': instance.direction,
    };
