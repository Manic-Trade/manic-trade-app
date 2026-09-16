import 'package:json_annotation/json_annotation.dart';

part 'challenge_response.g.dart';

@JsonSerializable()
class ChallengeResponse {
  final String message;

  const ChallengeResponse({required this.message});

  factory ChallengeResponse.fromJson(Map<String, dynamic> json) =>
      _$ChallengeResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ChallengeResponseToJson(this);
}
