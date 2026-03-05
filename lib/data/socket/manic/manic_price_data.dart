/// 价格数据模型（K线推送数据）
/// 格式: {"beat":1765347200,"close":92591.82504265,"high":92591.82504265,"low":92591.82504265,"open":92591.82504265,"timeframe":5,"timestamp":1765347200,"unit_close":9259182504265}
class ManicPriceData {
  final int beat;
  final double open;
  final double high;
  final double low;
  final double close;
  final int timeframe;
  final int timestamp;

  ManicPriceData({
    required this.beat,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.timeframe,
    required this.timestamp,
  });

  factory ManicPriceData.fromJson(Map<String, dynamic> json) {
    return ManicPriceData(
      beat: json['beat'] as int? ?? 0,
      open: (json['open'] as num?)?.toDouble() ?? 0.0,
      high: (json['high'] as num?)?.toDouble() ?? 0.0,
      low: (json['low'] as num?)?.toDouble() ?? 0.0,
      close: (json['close'] as num?)?.toDouble() ?? 0.0,
      timeframe: json['timeframe'] as int? ?? 0,
      timestamp: json['timestamp'] as int? ?? 0,
    );
  }

  @override
  String toString() =>
      'ManicPriceData(timestamp: $timestamp, open: $open, high: $high, low: $low, close: $close, timeframe: $timeframe)';
}
