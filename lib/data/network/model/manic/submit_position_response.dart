import 'package:json_annotation/json_annotation.dart';

part 'submit_position_response.g.dart';

/// POST /users/submit-position 的响应
///
/// 服务端 send_and_confirm 上链完成后返回 [txHash]。
@JsonSerializable()
class SubmitPositionResponse {
  @JsonKey(name: 'tx_hash')
  final String txHash;

  @JsonKey(name: 'position_id')
  final String positionId;

  final String asset;

  /// "call" | "put"
  final String side;

  @JsonKey(name: 'position_mode')
  final String positionMode;

  final int price;

  @JsonKey(name: 'price_exponent')
  final int priceExponent;

  final int amount;

  const SubmitPositionResponse({
    required this.txHash,
    required this.positionId,
    required this.asset,
    required this.side,
    required this.positionMode,
    required this.price,
    required this.priceExponent,
    required this.amount,
  });

  factory SubmitPositionResponse.fromJson(Map<String, dynamic> json) =>
      _$SubmitPositionResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SubmitPositionResponseToJson(this);
}
