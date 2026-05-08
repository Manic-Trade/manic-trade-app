import 'package:json_annotation/json_annotation.dart';

part 'close_position_response.g.dart';

@JsonSerializable()
class ClosePositionResponse {
  @JsonKey(name: 'signed_tx')
  final String signedTx;

  ClosePositionResponse(this.signedTx);

  factory ClosePositionResponse.fromJson(Map<String, dynamic> json) =>
      _$ClosePositionResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ClosePositionResponseToJson(this);
}
