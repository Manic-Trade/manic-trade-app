import 'package:json_annotation/json_annotation.dart';

part 'open_position_request.g.dart';

@JsonSerializable()
class OpenPositionMode {
  final String type;
  final int duration;
  @JsonKey(name: 'end_time')
  final int endTime;

  const OpenPositionMode({
    required this.type,
    required this.duration,
    required this.endTime,
  });

  factory OpenPositionMode.fromJson(Map<String, dynamic> json) =>
      _$OpenPositionModeFromJson(json);

  Map<String, dynamic> toJson() => _$OpenPositionModeToJson(this);
}

@JsonSerializable()
class OpenPositionRequest {
  final int amount;
  final String asset;
  final String side;
  final List<int> mint;
  @JsonKey(name: 'strike_price_pct_diff_bps')
  final int strikePricePctDiffBps;
  final OpenPositionMode mode;
  @JsonKey(name: 'target_multiplier')
  final double targetMultiplier;
  @JsonKey(name: 'position_id')
  final String? positionId;

  const OpenPositionRequest({
    required this.amount,
    required this.asset,
    required this.side,
    required this.mint,
    required this.strikePricePctDiffBps,
    required this.mode,
    this.targetMultiplier = 1,
    this.positionId,
  });

  factory OpenPositionRequest.fromJson(Map<String, dynamic> json) =>
      _$OpenPositionRequestFromJson(json);

  Map<String, dynamic> toJson() => _$OpenPositionRequestToJson(this);
}
