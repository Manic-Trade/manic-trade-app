// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transfer_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransferItem _$TransferItemFromJson(Map<String, dynamic> json) => TransferItem(
      id: (json['id'] as num).toInt(),
      direction: json['direction'] as String,
      amount: json['amount'] as String,
      txHash: json['tx_hash'] as String?,
      status: json['status'] as String,
      createdAt: (json['created_at'] as num).toInt(),
    );

Map<String, dynamic> _$TransferItemToJson(TransferItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'direction': instance.direction,
      'amount': instance.amount,
      'tx_hash': instance.txHash,
      'status': instance.status,
      'created_at': instance.createdAt,
    };
