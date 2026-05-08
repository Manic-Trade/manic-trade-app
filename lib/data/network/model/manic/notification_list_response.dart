import 'package:finality/data/network/model/manic/notification_message.dart';

/// 通知列表接口返回体
/// API 返回字段名为 messages（非 PagedResponse 的 nodes），故单独定义
class NotificationListResponse {
  final List<NotificationMessage> messages;
  final int total;

  const NotificationListResponse({
    required this.messages,
    required this.total,
  });

  factory NotificationListResponse.fromJson(Map<String, dynamic> json) {
    return NotificationListResponse(
      messages: (json['messages'] as List<dynamic>?)
              ?.map((e) =>
                  NotificationMessage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      total: (json['total'] as num).toInt(),
    );
  }
}
