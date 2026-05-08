import 'package:json_annotation/json_annotation.dart';

part 'withdraw_execute_response.g.dart';

@JsonSerializable()
class WithdrawExecuteResponse {
  final String signature;
  final String? amount;
  final String? from;
  final String? to;

  const WithdrawExecuteResponse({
    required this.signature,
    this.amount,
    this.from,
    this.to,
  });

  factory WithdrawExecuteResponse.fromJson(Map<String, dynamic> json) =>
      _$WithdrawExecuteResponseFromJson(json);

  Map<String, dynamic> toJson() => _$WithdrawExecuteResponseToJson(this);
}

