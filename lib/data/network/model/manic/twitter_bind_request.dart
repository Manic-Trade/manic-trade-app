import 'package:json_annotation/json_annotation.dart';

part 'twitter_bind_request.g.dart';

/// `POST /users/twitter/bind` 请求体
///
/// 用于在 Turnkey X provider 已经绑定到当前 sub-org 之后，把 X 身份同步到后端
/// 用户记录。`twitter_id` 即 Turnkey X provider 的 `subject` 字段。
///
/// 后端 X squat-bind 加固后 `user_id` 必传：把 Turnkey provider 的查询限定到
/// 具体 user 而不是 org-level，否则会被 400 拒掉。
@JsonSerializable(fieldRename: FieldRename.snake)
class TwitterBindRequest {
  final String userId;
  final String subOrgId;
  final String wallet;
  final String twitterId;
  final String? twitterUsername;
  final String? avatarUrl;

  const TwitterBindRequest({
    required this.userId,
    required this.subOrgId,
    required this.wallet,
    required this.twitterId,
    this.twitterUsername,
    this.avatarUrl,
  });

  factory TwitterBindRequest.fromJson(Map<String, dynamic> json) =>
      _$TwitterBindRequestFromJson(json);

  Map<String, dynamic> toJson() => _$TwitterBindRequestToJson(this);
}
