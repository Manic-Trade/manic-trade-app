import 'package:json_annotation/json_annotation.dart';

part 'user_txn_item.g.dart';

@JsonSerializable()
class UserTxnItem {
  final int? id;
  final String? signature;
  final String? walletAddress;
  final String? fromAddress;
  final String? toAddress;
  final String? amount;
  final int? timestamp;

  const UserTxnItem({
    this.id,
    this.signature,
    this.walletAddress,
    this.fromAddress,
    this.toAddress,
    this.amount,
    this.timestamp,
  });

  factory UserTxnItem.fromJson(Map<String, dynamic> json) =>
      _$UserTxnItemFromJson(json);

  Map<String, dynamic> toJson() => _$UserTxnItemToJson(this);
}

