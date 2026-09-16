// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationMessage _$NotificationMessageFromJson(Map<String, dynamic> json) =>
    NotificationMessage(
      messageTargetId: (json['message_target_id'] as num).toInt(),
      messageId: (json['message_id'] as num).toInt(),
      title: json['title'] as String,
      content: json['content'] as String,
      url: json['url'] as String?,
      bizType: json['biz_type'] as String?,
      scope: json['scope'] as String?,
      createdAt: (json['created_at'] as num).toInt(),
      readAt: (json['read_at'] as num?)?.toInt(),
      payload: json['payload'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$NotificationMessageToJson(
        NotificationMessage instance) =>
    <String, dynamic>{
      'message_target_id': instance.messageTargetId,
      'message_id': instance.messageId,
      'title': instance.title,
      'content': instance.content,
      'url': instance.url,
      'biz_type': instance.bizType,
      'scope': instance.scope,
      'created_at': instance.createdAt,
      'read_at': instance.readAt,
      'payload': instance.payload,
    };
