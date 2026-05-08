import 'package:json_annotation/json_annotation.dart';

part 'twitter_follow_request.g.dart';

@JsonSerializable()
class TwitterFollowRequest {
  final String code;
  final String state;

  const TwitterFollowRequest({
    required this.code,
    required this.state,
  });

  factory TwitterFollowRequest.fromJson(Map<String, dynamic> json) =>
      _$TwitterFollowRequestFromJson(json);

  Map<String, dynamic> toJson() => _$TwitterFollowRequestToJson(this);
}
