// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deposit_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DepositItem _$DepositItemFromJson(Map<String, dynamic> json) => DepositItem(
      fromAddress: json['from_address'] as String,
      destHash: json['dest_hash'] as String?,
      wallet: json['wallet'] as String,
      amount: json['amount'] as String,
      createdAt: (json['created_at'] as num).toInt(),
      explorerUrl: json['explorer_url'] as String?,
    );

Map<String, dynamic> _$DepositItemToJson(DepositItem instance) =>
    <String, dynamic>{
      'from_address': instance.fromAddress,
      'dest_hash': instance.destHash,
      'wallet': instance.wallet,
      'amount': instance.amount,
      'created_at': instance.createdAt,
      'explorer_url': instance.explorerUrl,
    };
