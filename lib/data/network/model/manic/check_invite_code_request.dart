class CheckInviteCodeRequest {
  final String inviteCode;

  const CheckInviteCodeRequest({required this.inviteCode});

  Map<String, dynamic> toJson() => {'code': inviteCode};
}