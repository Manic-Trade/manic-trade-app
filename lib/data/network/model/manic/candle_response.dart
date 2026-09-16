import 'package:json_annotation/json_annotation.dart';

part 'candle_response.g.dart';

@JsonSerializable()
class CandleResponse {
  final List<CandleItem> candles;

  const CandleResponse({
    required this.candles,
  });

  factory CandleResponse.fromJson(Map<String, dynamic> json) =>
      _$CandleResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CandleResponseToJson(this);
}

@JsonSerializable()
class CandleItem {
  final String asset;
  @JsonKey(defaultValue: 0)
  final int timestamp;
  @JsonKey(defaultValue: 0.0)
  final double open;
  @JsonKey(defaultValue: 0.0)
  final double close;
  @JsonKey(defaultValue: 0.0)
  final double high;
  @JsonKey(defaultValue: 0.0)
  final double low;

  const CandleItem({
    required this.asset,
    required this.timestamp,
    required this.open,
    required this.close,
    required this.high,
    required this.low,
  });

  factory CandleItem.fromJson(Map<String, dynamic> json) =>
      _$CandleItemFromJson(json);

  Map<String, dynamic> toJson() => _$CandleItemToJson(this);
}

