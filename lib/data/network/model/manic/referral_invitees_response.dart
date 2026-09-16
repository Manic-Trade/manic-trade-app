import 'package:json_annotation/json_annotation.dart';

part 'referral_invitees_response.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class ReferralInviteesResponse {
  final String inviterWallet;
  final int total;
  final List<ReferralInvitee> invitees;

  const ReferralInviteesResponse({
    required this.inviterWallet,
    required this.total,
    required this.invitees,
  });

  factory ReferralInviteesResponse.fromJson(Map<String, dynamic> json) =>
      _$ReferralInviteesResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ReferralInviteesResponseToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ReferralInvitee {
  final String inviteeWallet;
  final String registTime;
  final bool twitterCompleted;
  final num firstTradeAmount;
  final String userStatus; // "inactive" | "active"
  final String rewardStatus; // "pending" | "completed" | "sent" | "failed"

  const ReferralInvitee({
    required this.inviteeWallet,
    required this.registTime,
    required this.twitterCompleted,
    required this.firstTradeAmount,
    required this.userStatus,
    required this.rewardStatus,
  });

  /// 是否已完成首笔交易
  bool get hasFirstTrade => firstTradeAmount > 0;

  /// 是否已获得奖励（completed 或 sent 都算）
  bool get isRewardEarned =>
      rewardStatus == 'completed' ||
      rewardStatus == 'sent' ||
      (twitterCompleted && hasFirstTrade);

  factory ReferralInvitee.fromJson(Map<String, dynamic> json) =>
      _$ReferralInviteeFromJson(json);

  Map<String, dynamic> toJson() => _$ReferralInviteeToJson(this);
}
