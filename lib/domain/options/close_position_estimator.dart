import 'dart:math';

import 'package:finality/domain/premium/entities/market_account.dart';

/// 提前平仓估算结果
class ClosePositionEstimateResult {
  /// 是否可以平仓
  final bool canClose;

  /// 不能平仓的原因
  final String? error;

  /// 估算的平仓收益（lamports，扣费+封顶后）
  final int estimatedPayout;

  /// 理论价值（lamports，扣费前）
  final double theoreticalValue;

  /// 手续费（lamports）
  final int feeAmount;

  /// 池子收益 = premiumAmount - estimatedPayout
  final int profitForPool;

  /// 手续费比例（0-1）
  final double payoutRatio;

  /// 价格是否已越过边界（方向正确且移动超过阈值）
  final bool hasCrossedBoundary;

  /// 价格是否在错误方向
  final bool isWrongDirection;

  /// 价格移动进度 [-1.0, 1.0]，负值=错误方向，正值=正确方向
  final double progress;

  /// 剩余时间（秒）
  final int timeRemainingSeconds;

  /// 估算的平仓收益（USDC）
  double get estimatedPayoutUsdc => estimatedPayout / 1e6;

  const ClosePositionEstimateResult({
    required this.canClose,
    this.error,
    required this.estimatedPayout,
    required this.theoreticalValue,
    required this.feeAmount,
    required this.profitForPool,
    required this.payoutRatio,
    required this.hasCrossedBoundary,
    required this.isWrongDirection,
    required this.progress,
    required this.timeRemainingSeconds,
  });

  static const zero = ClosePositionEstimateResult(
    canClose: false,
    estimatedPayout: 0,
    theoreticalValue: 0,
    feeAmount: 0,
    profitForPool: 0,
    payoutRatio: 0,
    hasCrossedBoundary: false,
    isWrongDirection: false,
    progress: 0,
    timeRemainingSeconds: 0,
  );
}

/// 提前平仓估算器
///
/// 基于当前价格相对边界价格的偏移百分比计算 payoutAfterSell。
/// 算法与 Web 前端 estimateClosePositionPayout 及 Rust 合约一致。
class ClosePositionEstimator {
  static const double _closeBaseScale = 0.5;
  static const double _closePriceMovementMultiplier = 1000;
  static const int _minFeeDeduction = 1;
  static const int _bpsDenominator = 10000;

  /// 估算提前平仓收益
  ///
  /// [isHigh] true=CALL(Long)，false=PUT(Short)
  /// [premiumAmountLamports] 用户开仓支付的本金（lamports）
  /// [boundaryPrice] 行权/边界价格（开仓时的参考价）
  /// [startTime] 开仓时间（unix 秒）
  /// [endTime] 到期时间（unix 秒）
  /// [marketAccount] 链上 MarketAccount 数据
  /// [currentPrice] 当前现货价格
  /// [currentTimestamp] 当前时间戳（unix 秒），默认使用系统时间
  ClosePositionEstimateResult estimate({
    required bool isHigh,
    required int premiumAmountLamports,
    required double boundaryPrice,
    required int startTime,
    required int endTime,
    required MarketAccount marketAccount,
    required double currentPrice,
    int? currentTimestamp,
  }) {
    final now =
        currentTimestamp ?? DateTime.now().millisecondsSinceEpoch ~/ 1000;

    // === Step 1: 时间窗口验证 ===

    final minDelayAfterOpen = marketAccount.closePositionMinDelaySecs;
    final minCloseBeforeSettle = marketAccount.closePositionBeforeSettleSecs;
    final timeRemaining = endTime - now;

    // 开仓后必须等待至少 closePositionMinDelaySecs
    if (now < startTime + minDelayAfterOpen) {
      final waitSeconds = startTime + minDelayAfterOpen - now;
      return ClosePositionEstimateResult(
        canClose: false,
        error: 'Must wait ${waitSeconds}s',
        estimatedPayout: 0,
        theoreticalValue: 0,
        feeAmount: 0,
        profitForPool: 0,
        payoutRatio: 0,
        hasCrossedBoundary: false,
        isWrongDirection: false,
        progress: 0,
        timeRemainingSeconds: timeRemaining,
      );
    }

    // 到期前 closePositionBeforeSettleSecs 不能平仓
    if (now + minCloseBeforeSettle >= endTime) {
      return ClosePositionEstimateResult(
        canClose: false,
        error: 'Too late',
        estimatedPayout: 0,
        theoreticalValue: 0,
        feeAmount: 0,
        profitForPool: 0,
        payoutRatio: 0,
        hasCrossedBoundary: false,
        isWrongDirection: false,
        progress: 0,
        timeRemainingSeconds: timeRemaining,
      );
    }

    // 已到期
    if (now >= endTime) {
      return ClosePositionEstimateResult(
        canClose: false,
        error: 'Expired',
        estimatedPayout: 0,
        theoreticalValue: 0,
        feeAmount: 0,
        profitForPool: 0,
        payoutRatio: 0,
        hasCrossedBoundary: false,
        isWrongDirection: false,
        progress: 0,
        timeRemainingSeconds: 0,
      );
    }

    final timeRemainingSeconds = endTime - now;

    // === Step 2: 价格偏移计算 ===

    final double rawMovePct =
        boundaryPrice > 0 ? (currentPrice - boundaryPrice) / boundaryPrice : 0.0;

    // CALL(Long)：价格高于边界是正确方向；PUT(Short)：价格低于边界是正确方向（取反）
    final double movementPct = isHigh ? rawMovePct : -rawMovePct;

    final bool isWrongDirection = movementPct < 0;
    final bool hasCrossedBoundary =
        movementPct >= 1.0 / _closePriceMovementMultiplier;

    // === Step 3: Scale 计算（0.0 - 1.0） ===

    double scale;
    if (movementPct >= 0) {
      // 正确方向：scale 从 50% 线性升至 100%
      scale = _closeBaseScale +
          _closeBaseScale *
              (movementPct * _closePriceMovementMultiplier).clamp(0.0, 1.0);
    } else {
      // 错误方向：scale 从 50% 线性降至 0%
      scale = _closeBaseScale *
          (1.0 -
              (-movementPct * _closePriceMovementMultiplier).clamp(0.0, 1.0));
    }

    final double theoreticalValue = premiumAmountLamports * scale;

    // === Step 4: 扣除手续费，计算最终 Payout ===

    final int feeBps = marketAccount.deductedFeeBps;
    final int feeAmount =
        (premiumAmountLamports * feeBps / _bpsDenominator).floor();
    final int payout =
        (theoreticalValue * (_bpsDenominator - feeBps) / _bpsDenominator)
            .floor();
    final int maxAllowedPayout =
        premiumAmountLamports - max(feeAmount, _minFeeDeduction);
    final int estimatedPayout = min(payout, maxAllowedPayout);
    final int profitForPool = premiumAmountLamports - estimatedPayout;
    final double payoutRatio = (_bpsDenominator - feeBps) / _bpsDenominator;

    // Progress 指示器 [-1, 1]
    final double progress = movementPct >= 0
        ? (movementPct * _closePriceMovementMultiplier).clamp(0.0, 1.0)
        : -(-movementPct * _closePriceMovementMultiplier).clamp(0.0, 1.0);

    return ClosePositionEstimateResult(
      canClose: true,
      estimatedPayout: estimatedPayout,
      theoreticalValue: theoreticalValue,
      feeAmount: feeAmount,
      profitForPool: profitForPool,
      payoutRatio: payoutRatio,
      hasCrossedBoundary: hasCrossedBoundary,
      isWrongDirection: isWrongDirection,
      progress: progress,
      timeRemainingSeconds: timeRemainingSeconds,
    );
  }
}
