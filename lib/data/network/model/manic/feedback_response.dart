import 'package:json_annotation/json_annotation.dart';

part 'feedback_response.g.dart';

@JsonSerializable()
class FeedbackResponse {
  final bool success;
  final String? message;
  @JsonKey(name: 'feedback_id')
  final int? feedbackId;
  final FeedbackEvaluation? evaluation;

  const FeedbackResponse({
    required this.success,
    required this.message,
    required this.feedbackId,
    this.evaluation,
  });

  factory FeedbackResponse.fromJson(Map<String, dynamic> json) =>
      _$FeedbackResponseFromJson(json);

  Map<String, dynamic> toJson() => _$FeedbackResponseToJson(this);
}

@JsonSerializable()
class FeedbackEvaluation {
  @JsonKey(name: 'is_valid')
  final bool? isValid;
  @JsonKey(name: 'is_duplicate')
  final bool? isDuplicate;
  final String? category;
  final String? priority;
  final String? summary;
  @JsonKey(name: 'will_receive_reward')
  final bool? willReceiveReward;

  const FeedbackEvaluation({
    required this.isValid,
    required this.isDuplicate,
    required this.category,
    required this.priority,
    required this.summary,
    required this.willReceiveReward,
  });

  factory FeedbackEvaluation.fromJson(Map<String, dynamic> json) =>
      _$FeedbackEvaluationFromJson(json);

  Map<String, dynamic> toJson() => _$FeedbackEvaluationToJson(this);
}

