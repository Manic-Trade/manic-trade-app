// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transfer_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransferToAgentRequest _$TransferToAgentRequestFromJson(
        Map<String, dynamic> json) =>
    TransferToAgentRequest(
      amount: json['amount'] as String,
      transaction: json['transaction'] as String?,
    );

Map<String, dynamic> _$TransferToAgentRequestToJson(
        TransferToAgentRequest instance) =>
    <String, dynamic>{
      'amount': instance.amount,
      'transaction': instance.transaction,
    };

TransferFromAgentRequest _$TransferFromAgentRequestFromJson(
        Map<String, dynamic> json) =>
    TransferFromAgentRequest(
      amount: json['amount'] as String,
    );

Map<String, dynamic> _$TransferFromAgentRequestToJson(
        TransferFromAgentRequest instance) =>
    <String, dynamic>{
      'amount': instance.amount,
    };
