import 'package:json_annotation/json_annotation.dart';

part 'prepare_close_position_response.g.dart';

/// POST /users/prepare-close-position 的响应
///
/// 服务端仅用 fee_payer 签名构建平仓交易，back_authority 不签。
@JsonSerializable()
class PrepareClosePositionResponse {
  @JsonKey(name: 'request_id')
  final String requestId;

  @JsonKey(name: 'unsigned_tx')
  final String unsignedTx;

  @JsonKey(name: 'position_id')
  final String positionId;

  final String asset;

  @JsonKey(name: 'expires_in')
  final int expiresIn;

  const PrepareClosePositionResponse({
    required this.requestId,
    required this.unsignedTx,
    required this.positionId,
    required this.asset,
    required this.expiresIn,
  });

  factory PrepareClosePositionResponse.fromJson(Map<String, dynamic> json) =>
      _$PrepareClosePositionResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PrepareClosePositionResponseToJson(this);
}
