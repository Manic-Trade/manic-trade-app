import 'package:json_annotation/json_annotation.dart';

part 'deposit_item.g.dart';

@JsonSerializable()
class DepositItem {
  @JsonKey(name: 'from_address')
  final String fromAddress;
  @JsonKey(name: 'dest_hash')
  final String? destHash;
  final String wallet;
  final String amount;
  @JsonKey(name: 'created_at')
  final int createdAt;
  @JsonKey(name: 'explorer_url')
  final String? explorerUrl;

  const DepositItem({
    required this.fromAddress,
    this.destHash,
    required this.wallet,
    required this.amount,
    required this.createdAt,
    this.explorerUrl,
  });

  

  factory DepositItem.fromJson(Map<String, dynamic> json) =>
      _$DepositItemFromJson(json);

  Map<String, dynamic> toJson() => _$DepositItemToJson(this);
}

