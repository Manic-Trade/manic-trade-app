import 'package:json_annotation/json_annotation.dart';

part 'close_position_request.g.dart';

@JsonSerializable()
class ClosePositionRequest {
  @JsonKey(name: 'position_id')
  final String positionId;

  final String asset;

  final List<int> mint;

  const ClosePositionRequest({
    required this.positionId,
    required this.asset,
    required this.mint,
  });

  factory ClosePositionRequest.fromJson(Map<String, dynamic> json) =>
      _$ClosePositionRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ClosePositionRequestToJson(this);
}
