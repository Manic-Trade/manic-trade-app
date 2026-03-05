// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'withdraw_info_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WithdrawInfoResponse _$WithdrawInfoResponseFromJson(
        Map<String, dynamic> json) =>
    WithdrawInfoResponse(
      feePayer: json['fee_payer'] as String,
      tokenMint: json['token_mint'] as String,
      decimals: (json['decimals'] as num).toInt(),
      isToken2022: json['is_token_2022'] as bool,
      withdrawFeeReceiver: json['withdraw_fee_receiver'] as String,
      withdrawFeeAmount: json['withdraw_fee_amount'] as String,
      withdrawMinAmount: json['withdraw_min_amount'] as String,
    );

Map<String, dynamic> _$WithdrawInfoResponseToJson(
        WithdrawInfoResponse instance) =>
    <String, dynamic>{
      'fee_payer': instance.feePayer,
      'token_mint': instance.tokenMint,
      'decimals': instance.decimals,
      'is_token_2022': instance.isToken2022,
      'withdraw_fee_receiver': instance.withdrawFeeReceiver,
      'withdraw_fee_amount': instance.withdrawFeeAmount,
      'withdraw_min_amount': instance.withdrawMinAmount,
    };
