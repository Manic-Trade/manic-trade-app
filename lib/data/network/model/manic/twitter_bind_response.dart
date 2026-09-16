import 'package:json_annotation/json_annotation.dart';

part 'twitter_bind_response.g.dart';

/// `POST /users/twitter/bind` 响应
@JsonSerializable(fieldRename: FieldRename.snake)
class TwitterBindResponse {
  final bool success;
  final bool canTrade;

  const TwitterBindResponse({
    required this.success,
    required this.canTrade,
  });

  factory TwitterBindResponse.fromJson(Map<String, dynamic> json) =>
      _$TwitterBindResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TwitterBindResponseToJson(this);
}
