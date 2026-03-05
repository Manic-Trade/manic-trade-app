import 'dart:math';

import 'package:finality/domain/premium/entities/digital_params.dart';
import 'package:finality/domain/premium/entities/market_account.dart';
import 'package:finality/domain/premium/premium_calculator.dart';

/// 提前平仓估算结果
class ClosePositionEstimateResult {
  /// 是否可以平仓
  final bool canClose;

  /// 不能平仓的原因
  final String? error;

  /// 估算的平仓收益（lamports，扣费+封顶后）
  final double estimatedPayout;

  /// 理论价值（lamports，扣费前）
  final double theoreticalValue;

  /// 数字期权价格（0-1 概率值）
  final double digitalPrice;

  /// 剩余时间（秒）
  final int timeRemainingSeconds;

  /// 估算的平仓收益（USDC）
  double get estimatedPayoutUsdc => estimatedPayout / 1e6;

  const ClosePositionEstimateResult({
    required this.canClose,
    this.error,
    required this.estimatedPayout,
    required this.theoreticalValue,
    required this.digitalPrice,
    required this.timeRemainingSeconds,
  });

  static const zero = ClosePositionEstimateResult(
    canClose: false,
    estimatedPayout: 0,
    theoreticalValue: 0,
    digitalPrice: 0,
    timeRemainingSeconds: 0,
  );
}

/// 提前平仓估算器
///
/// 根据当前价格和 MarketAccount 数据实时计算 payoutAfterSell。
/// 算法与 Web 前端 estimateClosePositionPayout 一致。
class ClosePositionEstimator {
  static const double _secondsPerYear = 365 * 24 * 60 * 60;
  static const double _bpsDenominator = 10000;

  final PremiumCalculator _calculator;

  ClosePositionEstimator(this._calculator);

  /// 估算提前平仓收益
  ///
  /// [isHigh] true=CALL, false=PUT
  /// [winPayoutLamports] 最大赔付金额（lamports）
  /// [amountLamports] 原始保费（lamports）
  /// [boundaryPrice] 障碍/行权价格
  /// [startTime] 开仓时间（unix 秒）
  /// [endTime] 到期时间（unix 秒）
  /// [marketAccount] 链上 MarketAccount 数据
  /// [currentPrice] 当前现货价格
  /// [currentTimestamp] 当前时间戳（unix 秒），默认使用系统时间
  ClosePositionEstimateResult estimate({
    required bool isHigh,
    required int winPayoutLamports,
    required int amountLamports,
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
        error: 'Wait ${waitSeconds}s',
        estimatedPayout: 0,
        theoreticalValue: 0,
        digitalPrice: 0,
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
        digitalPrice: 0,
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
        digitalPrice: 0,
        timeRemainingSeconds: 0,
      );
    }

    // === Step 2: 获取 IV ===

    final sigma2 = isHigh ? marketAccount.callSigma2 : marketAccount.putSigma2;
    final currentIv = sqrt(max(sigma2, 0));

    // === Step 3: 计算剩余时间（年） ===

    final timeRemainingSeconds = endTime - now;
    final timeYears = timeRemainingSeconds / _secondsPerYear;

    // === Step 4: Black-Scholes 数字期权定价 ===

    final params = DigitalParams(
      spot: currentPrice,
      barrier: boundaryPrice,
      timeYears: timeYears,
      vegaBuffer: marketAccount.vegaBuffer,
      volatility: currentIv,
    );

    final double digitalPrice;
    if (isHigh) {
      digitalPrice =
          _calculator.digitalCallPrice(params, marketAccount.callLambda);
    } else {
      digitalPrice =
          _calculator.digitalPutPrice(params, marketAccount.putLambda);
    }

    // === Step 5: 理论价值 ===

    final theoreticalValue = winPayoutLamports * digitalPrice;

    // === Step 6: 扣除提前平仓手续费 ===

    final payoutRatio =
        (_bpsDenominator - marketAccount.deductedFeeBps) / _bpsDenominator;
    final payoutBeforeCap = theoreticalValue * payoutRatio;

    // === Step 7: 封顶于原始保费 ===
    // final estimatedPayout =
    //     min(payoutBeforeCap, amountLamports.toDouble());
    final estimatedPayout = payoutBeforeCap;

    return ClosePositionEstimateResult(
      canClose: true,
      estimatedPayout: estimatedPayout,
      theoreticalValue: theoreticalValue,
      digitalPrice: digitalPrice,
      timeRemainingSeconds: timeRemainingSeconds,
    );
  }
}
