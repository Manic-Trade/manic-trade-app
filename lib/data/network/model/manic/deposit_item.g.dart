// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deposit_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DepositItem _$DepositItemFromJson(Map<String, dynamic> json) => DepositItem(
      id: (json['id'] as num).toInt(),
      signature: json['signature'] as String,
      walletAddress: json['wallet_address'] as String,
      fromAddress: json['from_address'] as String,
      amount: json['amount'] as String,
      timestamp: (json['timestamp'] as num).toInt(),
    );

Map<String, dynamic> _$DepositItemToJson(DepositItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'signature': instance.signature,
      'wallet_address': instance.walletAddress,
      'from_address': instance.fromAddress,
      'amount': instance.amount,
      'timestamp': instance.timestamp,
    };
