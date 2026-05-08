// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'withdraw_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WithdrawItem _$WithdrawItemFromJson(Map<String, dynamic> json) => WithdrawItem(
      id: (json['id'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      fromAddress: json['from_address'] as String,
      toAddress: json['to_address'] as String,
      amount: (json['amount'] as num).toInt(),
      uiAmount: json['ui_amount'] as String,
      status: json['status'] as String,
      signature: json['signature'] as String?,
      errorMessage: json['error_message'] as String?,
    );

Map<String, dynamic> _$WithdrawItemToJson(WithdrawItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'from_address': instance.fromAddress,
      'to_address': instance.toAddress,
      'amount': instance.amount,
      'ui_amount': instance.uiAmount,
      'status': instance.status,
      'signature': instance.signature,
      'error_message': instance.errorMessage,
    };
