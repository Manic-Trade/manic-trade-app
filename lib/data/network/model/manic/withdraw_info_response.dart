import 'package:json_annotation/json_annotation.dart';

part 'withdraw_info_response.g.dart';

@JsonSerializable()
class WithdrawInfoResponse {
  @JsonKey(name: 'fee_payer')
  final String feePayer;
  @JsonKey(name: 'token_mint')
  final String tokenMint;
  final int decimals;
  @JsonKey(name: 'is_token_2022')
  final bool isToken2022;
  @JsonKey(name: 'withdraw_fee_receiver')
  final String withdrawFeeReceiver;
  @JsonKey(name: 'withdraw_fee_amount')
  final String withdrawFeeAmount;
  @JsonKey(name: 'withdraw_min_amount')
  final String withdrawMinAmount;

  const WithdrawInfoResponse({
    required this.feePayer,
    required this.tokenMint,
    required this.decimals,
    required this.isToken2022,
    required this.withdrawFeeReceiver,
    required this.withdrawFeeAmount,
    required this.withdrawMinAmount,
  });

  factory WithdrawInfoResponse.fromJson(Map<String, dynamic> json) =>
      _$WithdrawInfoResponseFromJson(json);

  Map<String, dynamic> toJson() => _$WithdrawInfoResponseToJson(this);
}

