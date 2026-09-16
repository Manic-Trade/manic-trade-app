import 'package:json_annotation/json_annotation.dart';

part 'referral_info_response.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class ReferralInfoResponse {
  final String wallet;
  final bool twitterBound;
  final String? inviteCode;
  final int totalInvites;

  /// VIP 等级：0 = Basic，1 = VIP 1。旧后端未下发时回落为 0。
  @JsonKey(defaultValue: 0)
  final int vipLevel;

  /// VIP 1 有效邀请数（绑 X + 完成首笔交易的被邀请人数）。AI Campaign S3 后端新增。
  /// 与 `totalInvites`（注册即计数，含 pending）不同，此字段才是 VIP 解锁的权威计数。
  /// 旧后端不返回时为 null，消费处需回退到 `totalInvites`。
  @JsonKey(name: 'effective_invites')
  final int? effectiveInvites;

  /// 用户累计充值金额（USD，已换算）。VIP 1 解锁另一条路径：累计充值 ≥ $5,000。
  /// 后端于 AI Campaign S3 新增，旧后端可能不返回此字段，消费处需回退到 0。
  final double? totalDeposit;

  const ReferralInfoResponse({
    required this.wallet,
    required this.twitterBound,
    this.inviteCode,
    required this.totalInvites,
    this.vipLevel = 0,
    this.effectiveInvites,
    this.totalDeposit,
  });

  factory ReferralInfoResponse.fromJson(Map<String, dynamic> json) =>
      _$ReferralInfoResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ReferralInfoResponseToJson(this);
}
