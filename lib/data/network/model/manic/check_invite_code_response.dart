import 'package:json_annotation/json_annotation.dart';

part 'check_invite_code_response.g.dart';

@JsonSerializable()
class CheckInviteCodeResponse {
  final bool valid;
  final String code;

  const CheckInviteCodeResponse({required this.valid, required this.code});

  factory CheckInviteCodeResponse.fromJson(Map<String, dynamic> json) =>
      _$CheckInviteCodeResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CheckInviteCodeResponseToJson(this);
}
