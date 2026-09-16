import 'package:json_annotation/json_annotation.dart';

part 'submit_close_position_response.g.dart';

/// POST /users/submit-close-position 的响应
@JsonSerializable()
class SubmitClosePositionResponse {
  @JsonKey(name: 'tx_hash')
  final String txHash;

  @JsonKey(name: 'position_id')
  final String positionId;

  final String asset;

  const SubmitClosePositionResponse({
    required this.txHash,
    required this.positionId,
    required this.asset,
  });

  factory SubmitClosePositionResponse.fromJson(Map<String, dynamic> json) =>
      _$SubmitClosePositionResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SubmitClosePositionResponseToJson(this);
}
