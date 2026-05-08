import 'package:json_annotation/json_annotation.dart';

part 'submit_close_position_request.g.dart';

/// POST /users/submit-close-position 的请求体
@JsonSerializable()
class SubmitClosePositionRequest {
  @JsonKey(name: 'request_id')
  final String requestId;

  @JsonKey(name: 'user_signature')
  final String userSignature;

  const SubmitClosePositionRequest({
    required this.requestId,
    required this.userSignature,
  });

  factory SubmitClosePositionRequest.fromJson(Map<String, dynamic> json) =>
      _$SubmitClosePositionRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SubmitClosePositionRequestToJson(this);
}
