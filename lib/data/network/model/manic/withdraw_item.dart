import 'package:json_annotation/json_annotation.dart';

part 'withdraw_item.g.dart';

@JsonSerializable()
class WithdrawItem {
  final int id;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  @JsonKey(name: 'from_address')
  final String fromAddress;
  @JsonKey(name: 'to_address')
  final String toAddress;
  final int amount;
  @JsonKey(name: 'ui_amount')
  final String uiAmount;
  @JsonKey(name: 'status')
  final String status;
  final String? signature;
  @JsonKey(name: 'error_message')
  final String? errorMessage;

  const WithdrawItem({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.fromAddress,
    required this.toAddress,
    required this.amount,
    required this.uiAmount,
    required this.status,
    this.signature,
    this.errorMessage,
  });

  factory WithdrawItem.fromJson(Map<String, dynamic> json) =>
      _$WithdrawItemFromJson(json);

  Map<String, dynamic> toJson() => _$WithdrawItemToJson(this);
}

