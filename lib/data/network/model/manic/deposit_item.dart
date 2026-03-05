import 'package:json_annotation/json_annotation.dart';

part 'deposit_item.g.dart';

@JsonSerializable()
class DepositItem {
  final int id;
  final String signature;
  @JsonKey(name: 'wallet_address')
  final String walletAddress;
  @JsonKey(name: 'from_address')
  final String fromAddress;
  final String amount;
  final int timestamp;

  const DepositItem({
    required this.id,
    required this.signature,
    required this.walletAddress,
    required this.fromAddress,
    required this.amount,
    required this.timestamp,
  });

  factory DepositItem.fromJson(Map<String, dynamic> json) =>
      _$DepositItemFromJson(json);

  Map<String, dynamic> toJson() => _$DepositItemToJson(this);
}

