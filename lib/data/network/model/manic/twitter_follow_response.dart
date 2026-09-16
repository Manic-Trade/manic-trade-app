import 'package:json_annotation/json_annotation.dart';

part 'twitter_follow_response.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class TwitterFollowResponse {
  final bool success;
  final String twitterId;
  final String twitterUsername;
  final bool canTrade;

  const TwitterFollowResponse({
    required this.success,
    required this.twitterId,
    required this.twitterUsername,
    required this.canTrade,
  });

  factory TwitterFollowResponse.fromJson(Map<String, dynamic> json) =>
      _$TwitterFollowResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TwitterFollowResponseToJson(this);
}
