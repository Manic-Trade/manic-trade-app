import 'package:json_annotation/json_annotation.dart';

part 'check_user_response.g.dart';

@JsonSerializable()
class CheckUserResponse {
  @JsonKey(name: 'user_active')
  final String userActive; //active
  @JsonKey(name: 'user_can_trade')
  final bool userCanTrade;
  @JsonKey(name: 'user_created')
  final bool userCreated;
  @JsonKey(name: 'user_id')
  final int? userId;
  @JsonKey(name: 'valid_code')
  final bool? validCode;

  const CheckUserResponse({
    required this.userActive,
    required this.userCanTrade,
    required this.userCreated,
    required this.userId,
    required this.validCode,
  });

  factory CheckUserResponse.fromJson(Map<String, dynamic> json) =>
      _$CheckUserResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CheckUserResponseToJson(this);

  bool get isActive => userActive == 'active';
  bool get isInactive => userActive != 'active';

  bool get canLogin => isActive && userCanTrade;
}
