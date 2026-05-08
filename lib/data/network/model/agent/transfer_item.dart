import 'package:json_annotation/json_annotation.dart';

part 'transfer_item.g.dart';

@JsonSerializable()
class TransferItem {
  final int id;
  /// "to_agent" 或 "from_agent"
  final String direction;
  /// Decimal string
  final String amount;
  @JsonKey(name: 'tx_hash')
  final String? txHash;
  /// "pending" | "confirmed" | "failed"
  final String status;
  /// Unix 时间戳（秒）
  @JsonKey(name: 'created_at')
  final int createdAt;


  bool get isToAgent => direction == 'to_agent';
  bool get isFromAgent => direction == 'from_agent';

  const TransferItem({
    required this.id,
    required this.direction,
    required this.amount,
    this.txHash,
    required this.status,
    required this.createdAt,
  });

  factory TransferItem.fromJson(Map<String, dynamic> json) =>
      _$TransferItemFromJson(json);

  Map<String, dynamic> toJson() => _$TransferItemToJson(this);
}
