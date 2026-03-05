import 'package:json_annotation/json_annotation.dart';

part 'position_history_item.g.dart';

@JsonSerializable()
class PositionHistoryItem {
  @JsonKey(name: 'position_id')
  final String positionId;
  final String asset;
  final String? mode;
  final int amount;
  @JsonKey(name: 'ui_amount')
  final double uiAmount;
  @JsonKey(name: 'boundary_price')
  final double boundaryPrice;
  @JsonKey(name: 'final_price')
  final double? finalPrice;
  final String side;
  final int payout;
  final String status;
  final String? result;
  @JsonKey(name: 'open_sig')
  final String? openSig;
  @JsonKey(name: 'result_sig')
  final String? resultSig;
  @JsonKey(name: 'start_time')
  final int startTime;
  @JsonKey(name: 'end_time')
  final int endTime;
  final int? profit;
  final int? profitPercent;
  final int? premiumAmount;
  @JsonKey(name: 'created_at')
  final int? createdAt;

  const PositionHistoryItem({
    required this.positionId,
    required this.asset,
    this.mode,
    required this.amount,
    required this.uiAmount,
    required this.boundaryPrice,
    this.finalPrice,
    required this.side,
    required this.payout,
    required this.status,
    this.result,
    this.openSig,
    this.resultSig,
    required this.startTime,
    required this.endTime,
    this.profit,
    this.profitPercent,
    this.premiumAmount,
    this.createdAt,
  });

  bool get isHigh => side == 'call';

  bool get isWin => result == 'Won';
  
  bool get isRefund => result == 'Refund';

  bool get isSettled => status == 'settled';

  /// 是否是定时器模式
  bool get isTimerMode => mode == "single";

  /// 是否是时钟模式
  bool get isClockMode => !isTimerMode;

  factory PositionHistoryItem.fromJson(Map<String, dynamic> json) =>
      _$PositionHistoryItemFromJson(json);

  Map<String, dynamic> toJson() => _$PositionHistoryItemToJson(this);
}
