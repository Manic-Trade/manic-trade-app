// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_balance_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TokenBalanceResponse _$TokenBalanceResponseFromJson(
        Map<String, dynamic> json) =>
    TokenBalanceResponse(
      balance: json['balance'] as String? ?? '0',
      uiBalance: json['ui_balance'] as String? ?? '0',
      decimals: (json['decimals'] as num?)?.toInt() ?? 6,
      tokenMint: json['token_mint'] as String? ?? '',
      wallet: json['wallet'] as String? ?? '',
      nativeBalance: (json['native_balance'] as num?)?.toInt() ?? 0,
      nativeUiBalance: json['native_ui_balance'] as String? ?? '0',
    );

Map<String, dynamic> _$TokenBalanceResponseToJson(
        TokenBalanceResponse instance) =>
    <String, dynamic>{
      'balance': instance.balance,
      'ui_balance': instance.uiBalance,
      'decimals': instance.decimals,
      'token_mint': instance.tokenMint,
      'wallet': instance.wallet,
      'native_balance': instance.nativeBalance,
      'native_ui_balance': instance.nativeUiBalance,
    };
