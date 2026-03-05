import 'package:json_annotation/json_annotation.dart';


part 'open_position_response.g.dart';


@JsonSerializable()
class OpenPositionResponse {
  @JsonKey(name: 'signed_tx')
  final String signedTx;

  OpenPositionResponse(this.signedTx);
  factory OpenPositionResponse.fromJson(Map<String, dynamic> json) =>
      _$OpenPositionResponseFromJson(json);

  Map<String, dynamic> toJson() => _$OpenPositionResponseToJson(this);

}
