/// Premium 计算的输入参数
class PremiumInput {
  /// 现货价格
  final double spotPrice;

  /// 持仓时长（秒）
  final int durationSecs;

  /// 赔付倍数（如 1.0, 2.0）
  final double payoutMultiplier;

  /// 计算时的时间戳（Unix 秒）
  final int timestamp;

  const PremiumInput({
    required this.spotPrice,
    required this.durationSecs,
    required this.payoutMultiplier,
    required this.timestamp,
  });

  /// 零值
  static const zero = PremiumInput(
    spotPrice: 0,
    durationSecs: 0,
    payoutMultiplier: 1,
    timestamp: 0,
  );

  /// 是否为有效值
  bool get isValid => spotPrice > 0 && durationSecs > 0;

  /// 创建当前时间戳的输入参数
  factory PremiumInput.now({
    required double spotPrice,
    required int durationSecs,
    required double payoutMultiplier,
  }) {
    return PremiumInput(
      spotPrice: spotPrice,
      durationSecs: durationSecs,
      payoutMultiplier: payoutMultiplier,
      timestamp: DateTime.now().millisecondsSinceEpoch ~/ 1000,
    );
  }

  /// 复制并修改部分参数
  PremiumInput copyWith({
    double? spotPrice,
    int? durationSecs,
    double? payoutMultiplier,
    int? timestamp,
  }) {
    return PremiumInput(
      spotPrice: spotPrice ?? this.spotPrice,
      durationSecs: durationSecs ?? this.durationSecs,
      payoutMultiplier: payoutMultiplier ?? this.payoutMultiplier,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  String toString() {
    return 'PremiumInput(spotPrice: $spotPrice, durationSecs: $durationSecs, '
        'payoutMultiplier: $payoutMultiplier, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PremiumInput &&
          runtimeType == other.runtimeType &&
          spotPrice == other.spotPrice &&
          durationSecs == other.durationSecs &&
          payoutMultiplier == other.payoutMultiplier &&
          timestamp == other.timestamp;

  @override
  int get hashCode =>
      spotPrice.hashCode ^
      durationSecs.hashCode ^
      payoutMultiplier.hashCode ^
      timestamp.hashCode;
}

