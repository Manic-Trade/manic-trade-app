// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'referral_info_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReferralInfoResponse _$ReferralInfoResponseFromJson(
        Map<String, dynamic> json) =>
    ReferralInfoResponse(
      wallet: json['wallet'] as String,
      twitterBound: json['twitter_bound'] as bool,
      inviteCode: json['invite_code'] as String?,
      totalInvites: (json['total_invites'] as num).toInt(),
      vipLevel: (json['vip_level'] as num?)?.toInt() ?? 0,
      effectiveInvites: (json['effective_invites'] as num?)?.toInt(),
      totalDeposit: (json['total_deposit'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$ReferralInfoResponseToJson(
        ReferralInfoResponse instance) =>
    <String, dynamic>{
      'wallet': instance.wallet,
      'twitter_bound': instance.twitterBound,
      'invite_code': instance.inviteCode,
      'total_invites': instance.totalInvites,
      'vip_level': instance.vipLevel,
      'effective_invites': instance.effectiveInvites,
      'total_deposit': instance.totalDeposit,
    };
