import 'package:json_annotation/json_annotation.dart';

part 'notification_message.g.dart';

/// 通知消息 API 数据模型
@JsonSerializable()
class NotificationMessage {
  @JsonKey(name: 'message_target_id')
  final int messageTargetId;

  @JsonKey(name: 'message_id')
  final int messageId;

  final String title;
  final String content;

  /// 图标 URL（可选，部分消息无图标）
  final String? url;

  /// 业务类型（如 tournament_loser, daily_draw_unlocked 等）
  @JsonKey(name: 'biz_type')
  final String? bizType;

  final String? scope;

  /// 创建时间（Unix 时间戳，秒）
  @JsonKey(name: 'created_at')
  final int createdAt;

  /// 已读时间（Unix 时间戳，秒），为 null 表示未读
  @JsonKey(name: 'read_at')
  final int? readAt;

  final Map<String, dynamic>? payload;

  const NotificationMessage({
    required this.messageTargetId,
    required this.messageId,
    required this.title,
    required this.content,
    this.url,
    this.bizType,
    this.scope,
    required this.createdAt,
    this.readAt,
    this.payload,
  });

  /// 是否已读
  bool get isRead => readAt != null;

  factory NotificationMessage.fromJson(Map<String, dynamic> json) =>
      _$NotificationMessageFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationMessageToJson(this);
}
