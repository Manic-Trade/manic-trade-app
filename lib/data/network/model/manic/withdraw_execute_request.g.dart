// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'withdraw_execute_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WithdrawExecuteRequest _$WithdrawExecuteRequestFromJson(
        Map<String, dynamic> json) =>
    WithdrawExecuteRequest(
      transaction: json['transaction'] as String,
      to: json['to'] as String,
      amount: json['amount'] as String,
    );

Map<String, dynamic> _$WithdrawExecuteRequestToJson(
        WithdrawExecuteRequest instance) =>
    <String, dynamic>{
      'transaction': instance.transaction,
      'to': instance.to,
      'amount': instance.amount,
    };
