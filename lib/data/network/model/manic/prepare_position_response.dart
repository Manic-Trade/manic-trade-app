import 'package:json_annotation/json_annotation.dart';

part 'prepare_position_response.g.dart';

/// POST /users/prepare-position 的响应
///
/// 服务端仅用 fee_payer 签名构建交易，back_authority 不签。
/// 客户端需在 [expiresIn] 秒内用 [requestId] 调 /users/submit-position
/// 完成用户签名的回传，否则该请求会在服务端被 GETDEL 或因超过时间窗口而拒绝。
@JsonSerializable()
class PreparePositionResponse {
  @JsonKey(name: 'request_id')
  final String requestId;

  /// 未完成签名的交易（hex 编码）。fee_payer 已签，user 和 back_authority 未签。
  @JsonKey(name: 'unsigned_tx')
  final String unsignedTx;

  final int amount;

  /// "call" | "put"
  final String side;

  /// 资产 snake_case 名，如 "btc"
  final String asset;

  @JsonKey(name: 'position_mode')
  final String positionMode;

  /// boundary price
  final int price;

  @JsonKey(name: 'position_id')
  final String positionId;

  @JsonKey(name: 'price_exponent')
  final int priceExponent;

  /// 服务端允许 submit 的最大秒数（当前固定 5）
  @JsonKey(name: 'expires_in')
  final int expiresIn;

  const PreparePositionResponse({
    required this.requestId,
    required this.unsignedTx,
    required this.amount,
    required this.side,
    required this.asset,
    required this.positionMode,
    required this.price,
    required this.positionId,
    required this.priceExponent,
    required this.expiresIn,
  });

  factory PreparePositionResponse.fromJson(Map<String, dynamic> json) =>
      _$PreparePositionResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PreparePositionResponseToJson(this);
}
