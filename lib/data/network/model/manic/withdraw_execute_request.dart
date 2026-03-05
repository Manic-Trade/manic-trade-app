import 'package:json_annotation/json_annotation.dart';

part 'withdraw_execute_request.g.dart';

@JsonSerializable()
class WithdrawExecuteRequest {
  final String transaction;
  final String to;
  final String amount;

  const WithdrawExecuteRequest({
    required this.transaction,
    required this.to,
    required this.amount,
  });

  factory WithdrawExecuteRequest.fromJson(Map<String, dynamic> json) =>
      _$WithdrawExecuteRequestFromJson(json);

  Map<String, dynamic> toJson() => _$WithdrawExecuteRequestToJson(this);
}

