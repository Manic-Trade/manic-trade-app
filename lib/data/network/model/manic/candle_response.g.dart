// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'candle_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CandleResponse _$CandleResponseFromJson(Map<String, dynamic> json) =>
    CandleResponse(
      candles: (json['candles'] as List<dynamic>)
          .map((e) => CandleItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CandleResponseToJson(CandleResponse instance) =>
    <String, dynamic>{
      'candles': instance.candles,
    };

CandleItem _$CandleItemFromJson(Map<String, dynamic> json) => CandleItem(
      asset: json['asset'] as String,
      timestamp: (json['timestamp'] as num?)?.toInt() ?? 0,
      open: (json['open'] as num?)?.toDouble() ?? 0.0,
      close: (json['close'] as num?)?.toDouble() ?? 0.0,
      high: (json['high'] as num?)?.toDouble() ?? 0.0,
      low: (json['low'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$CandleItemToJson(CandleItem instance) =>
    <String, dynamic>{
      'asset': instance.asset,
      'timestamp': instance.timestamp,
      'open': instance.open,
      'close': instance.close,
      'high': instance.high,
      'low': instance.low,
    };
