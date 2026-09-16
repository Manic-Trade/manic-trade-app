/// Premium 计算结果
class PremiumResult {
  /// 基础数字价格（ATM，barrier = spot 时的概率）
  final double baseDigitalPrice;

  /// 目标数字价格（调整后的概率）
  final double targetDigitalPrice;

  /// 障碍价格（Entry Price）
  final double barrierPrice;

  /// 价差（基点）
  final int strikePricePctDiffBps;

  const PremiumResult({
    required this.baseDigitalPrice,
    required this.targetDigitalPrice,
    required this.barrierPrice,
    required this.strikePricePctDiffBps,
  });

  /// 零值
  static const zero = PremiumResult(
    baseDigitalPrice: 0,
    targetDigitalPrice: 0,
    barrierPrice: 0,
    strikePricePctDiffBps: 0,
  );

  /// 是否为有效值
  bool get isValid => barrierPrice > 0;

  // ========== 基于 baseDigitalPrice 的计算（payoutMultiplier = 1.0 时使用）==========

  /// 基础实际赔率倍数（= 1 / baseDigitalPrice）
  double get baseActualMultiplier =>
      baseDigitalPrice > 0 ? 1 / baseDigitalPrice : 0;

  /// 基础收益率百分比（= (baseActualMultiplier - 1) * 100）
  double get baseEarningsPercent => (baseActualMultiplier - 1) * 100;

  /// 基础胜率百分比（= baseDigitalPrice * 100）
  double get baseWinProbabilityPercent => baseDigitalPrice * 100;

  /// 计算基础收益金额
  double baseEarnings(double amount) => amount * (baseActualMultiplier - 1);

  /// 计算基础总收益（本金 + 收益）
  double baseTotalPayout(double amount) => amount * baseActualMultiplier;

  // ========== 基于 targetDigitalPrice 的计算（payoutMultiplier != 1.0 时使用）==========

  /// 目标实际赔率倍数（= 1 / targetDigitalPrice）
  double get targetActualMultiplier =>
      targetDigitalPrice > 0 ? 1 / targetDigitalPrice : 0;

  /// 目标收益率百分比（= (targetActualMultiplier - 1) * 100）
  double get targetEarningsPercent => (targetActualMultiplier - 1) * 100;

  /// 目标胜率百分比（= targetDigitalPrice * 100）
  double get targetWinProbabilityPercent => targetDigitalPrice * 100;

  /// 计算目标收益金额
  double targetEarnings(double amount) => amount * (targetActualMultiplier - 1);

  /// 计算目标总收益（本金 + 收益）
  double targetTotalPayout(double amount) => amount * targetActualMultiplier;

  @override
  String toString() {
    return 'PremiumResult(baseDigitalPrice: $baseDigitalPrice, '
        'targetDigitalPrice: $targetDigitalPrice, '
        'barrierPrice: $barrierPrice, '
        'strikePricePctDiffBps: $strikePricePctDiffBps)';
  }
}
