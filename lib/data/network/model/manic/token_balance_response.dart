import 'package:json_annotation/json_annotation.dart';

part 'token_balance_response.g.dart';

@JsonSerializable()
class TokenBalanceResponse {
  @JsonKey(name: 'balance', defaultValue: '0')
  final String balance;
  @JsonKey(name: 'ui_balance', defaultValue: '0')
  final String uiBalance;
  @JsonKey(name: 'decimals', defaultValue: 6)
  final int decimals;
  @JsonKey(name: 'token_mint', defaultValue: '')
  final String tokenMint;
  @JsonKey(name: 'wallet', defaultValue: '')
  final String wallet;
  @JsonKey(name: 'native_balance', defaultValue: 0)
  final int nativeBalance;
  @JsonKey(name: 'native_ui_balance', defaultValue: '0')
  final String nativeUiBalance;

  const TokenBalanceResponse({
    required this.balance,
    required this.uiBalance,
    required this.decimals,
    required this.tokenMint,
    required this.wallet,
    required this.nativeBalance,
    required this.nativeUiBalance,
  });

  factory TokenBalanceResponse.fromJson(Map<String, dynamic> json) =>
      _$TokenBalanceResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TokenBalanceResponseToJson(this);
}

