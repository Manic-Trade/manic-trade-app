import 'package:json_annotation/json_annotation.dart';

part 'twitter_status_response.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class TwitterStatusResponse {
  final String wallet;
  final String twitterUrl;
  final bool twitterStatus;
  final String? twitterName;

  const TwitterStatusResponse({
    required this.wallet,
    required this.twitterUrl,
    required this.twitterStatus,
    required this.twitterName,
  });

  factory TwitterStatusResponse.fromJson(Map<String, dynamic> json) =>
      _$TwitterStatusResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TwitterStatusResponseToJson(this);
}
