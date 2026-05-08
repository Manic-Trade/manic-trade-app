import 'package:json_annotation/json_annotation.dart';

part 'submit_position_request.g.dart';

/// POST /users/submit-position 的请求体
///
/// [userSignature] 为 64 字节 Ed25519 签名的 hex 编码（128 字符）。
/// 服务端会按 [requestId] 取出 prepare 阶段保存的未签名交易，填入此签名，
/// 再由 back_authority 补签并广播。
@JsonSerializable()
class SubmitPositionRequest {
  @JsonKey(name: 'request_id')
  final String requestId;

  @JsonKey(name: 'user_signature')
  final String userSignature;

  const SubmitPositionRequest({
    required this.requestId,
    required this.userSignature,
  });

  factory SubmitPositionRequest.fromJson(Map<String, dynamic> json) =>
      _$SubmitPositionRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SubmitPositionRequestToJson(this);
}
