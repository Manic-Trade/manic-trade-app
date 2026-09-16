// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'referral_invitees_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReferralInviteesResponse _$ReferralInviteesResponseFromJson(
        Map<String, dynamic> json) =>
    ReferralInviteesResponse(
      inviterWallet: json['inviter_wallet'] as String,
      total: (json['total'] as num).toInt(),
      invitees: (json['invitees'] as List<dynamic>)
          .map((e) => ReferralInvitee.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ReferralInviteesResponseToJson(
        ReferralInviteesResponse instance) =>
    <String, dynamic>{
      'inviter_wallet': instance.inviterWallet,
      'total': instance.total,
      'invitees': instance.invitees,
    };

ReferralInvitee _$ReferralInviteeFromJson(Map<String, dynamic> json) =>
    ReferralInvitee(
      inviteeWallet: json['invitee_wallet'] as String,
      registTime: json['regist_time'] as String,
      twitterCompleted: json['twitter_completed'] as bool,
      firstTradeAmount: json['first_trade_amount'] as num,
      userStatus: json['user_status'] as String,
      rewardStatus: json['reward_status'] as String,
    );

Map<String, dynamic> _$ReferralInviteeToJson(ReferralInvitee instance) =>
    <String, dynamic>{
      'invitee_wallet': instance.inviteeWallet,
      'regist_time': instance.registTime,
      'twitter_completed': instance.twitterCompleted,
      'first_trade_amount': instance.firstTradeAmount,
      'user_status': instance.userStatus,
      'reward_status': instance.rewardStatus,
    };
