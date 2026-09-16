// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feedback_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FeedbackResponse _$FeedbackResponseFromJson(Map<String, dynamic> json) =>
    FeedbackResponse(
      success: json['success'] as bool,
      message: json['message'] as String?,
      feedbackId: (json['feedback_id'] as num?)?.toInt(),
      evaluation: json['evaluation'] == null
          ? null
          : FeedbackEvaluation.fromJson(
              json['evaluation'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$FeedbackResponseToJson(FeedbackResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'feedback_id': instance.feedbackId,
      'evaluation': instance.evaluation,
    };

FeedbackEvaluation _$FeedbackEvaluationFromJson(Map<String, dynamic> json) =>
    FeedbackEvaluation(
      isValid: json['is_valid'] as bool?,
      isDuplicate: json['is_duplicate'] as bool?,
      category: json['category'] as String?,
      priority: json['priority'] as String?,
      summary: json['summary'] as String?,
      willReceiveReward: json['will_receive_reward'] as bool?,
    );

Map<String, dynamic> _$FeedbackEvaluationToJson(FeedbackEvaluation instance) =>
    <String, dynamic>{
      'is_valid': instance.isValid,
      'is_duplicate': instance.isDuplicate,
      'category': instance.category,
      'priority': instance.priority,
      'summary': instance.summary,
      'will_receive_reward': instance.willReceiveReward,
    };
