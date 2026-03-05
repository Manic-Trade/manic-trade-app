// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'open_position_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OpenPositionMode _$OpenPositionModeFromJson(Map<String, dynamic> json) =>
    OpenPositionMode(
      type: json['type'] as String,
      duration: (json['duration'] as num).toInt(),
      endTime: (json['end_time'] as num).toInt(),
    );

Map<String, dynamic> _$OpenPositionModeToJson(OpenPositionMode instance) =>
    <String, dynamic>{
      'type': instance.type,
      'duration': instance.duration,
      'end_time': instance.endTime,
    };

OpenPositionRequest _$OpenPositionRequestFromJson(Map<String, dynamic> json) =>
    OpenPositionRequest(
      amount: (json['amount'] as num).toInt(),
      asset: json['asset'] as String,
      side: json['side'] as String,
      mint: (json['mint'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      strikePricePctDiffBps: (json['strike_price_pct_diff_bps'] as num).toInt(),
      mode: OpenPositionMode.fromJson(json['mode'] as Map<String, dynamic>),
      targetMultiplier: (json['target_multiplier'] as num?)?.toDouble() ?? 1,
      positionId: json['position_id'] as String?,
    );

Map<String, dynamic> _$OpenPositionRequestToJson(
        OpenPositionRequest instance) =>
    <String, dynamic>{
      'amount': instance.amount,
      'asset': instance.asset,
      'side': instance.side,
      'mint': instance.mint,
      'strike_price_pct_diff_bps': instance.strikePricePctDiffBps,
      'mode': instance.mode,
      'target_multiplier': instance.targetMultiplier,
      'position_id': instance.positionId,
    };
