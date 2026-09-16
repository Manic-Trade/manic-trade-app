// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_txn_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserTxnItem _$UserTxnItemFromJson(Map<String, dynamic> json) => UserTxnItem(
      id: (json['id'] as num?)?.toInt(),
      signature: json['signature'] as String?,
      walletAddress: json['walletAddress'] as String?,
      fromAddress: json['fromAddress'] as String?,
      toAddress: json['toAddress'] as String?,
      amount: json['amount'] as String?,
      timestamp: (json['timestamp'] as num?)?.toInt(),
    );

Map<String, dynamic> _$UserTxnItemToJson(UserTxnItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'signature': instance.signature,
      'walletAddress': instance.walletAddress,
      'fromAddress': instance.fromAddress,
      'toAddress': instance.toAddress,
      'amount': instance.amount,
      'timestamp': instance.timestamp,
    };
