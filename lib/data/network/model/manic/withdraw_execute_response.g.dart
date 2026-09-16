// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'withdraw_execute_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WithdrawExecuteResponse _$WithdrawExecuteResponseFromJson(
        Map<String, dynamic> json) =>
    WithdrawExecuteResponse(
      signature: json['signature'] as String,
      amount: json['amount'] as String?,
      from: json['from'] as String?,
      to: json['to'] as String?,
    );

Map<String, dynamic> _$WithdrawExecuteResponseToJson(
        WithdrawExecuteResponse instance) =>
    <String, dynamic>{
      'signature': instance.signature,
      'amount': instance.amount,
      'from': instance.from,
      'to': instance.to,
    };
