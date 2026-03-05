import 'package:json_annotation/json_annotation.dart';

part 'airdrop_response.g.dart';

@JsonSerializable()
class AirdropResponse {
  final bool success;
  final String message;

  const AirdropResponse({
    required this.success,
    required this.message,
  });

  factory AirdropResponse.fromJson(Map<String, dynamic> json) =>
      _$AirdropResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AirdropResponseToJson(this);
}

