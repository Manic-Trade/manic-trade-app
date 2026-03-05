import 'dart:math';

import 'entities/bs_params.dart';
import 'entities/digital_params.dart';
import 'entities/market_account.dart';
import 'entities/premium_result.dart';
import 'entities/side.dart';

/// # Black-Scholes Digital Option Pricing Engine
///
/// Computes barrier prices and premiums for binary (digital) options using a
/// **normalized call/put spread** approximation of the Black-Scholes model.
///
/// ## Why Client-Side Pricing?
///
/// The on-chain Anchor smart contract uses the same pricing formula to
/// determine the barrier price at settlement. By running identical math on
/// the client, we can show the user **exactly** what barrier price they'll
/// get before submitting the transaction — no surprises.
///
/// ## Pricing Model
///
/// A digital call option pays 1 if `S > K` at expiry, 0 otherwise.
/// We approximate this discontinuous payoff using a tight call spread:
///
/// ```
/// DigitalCall ≈ (C(K₁) - C(K₂)) / (K₂ - K₁)
///
/// where K₁ = barrier × λ,  K₂ = barrier
///       λ < 1 (spread width parameter from the market account)
/// ```
///
/// A **vega buffer** is applied to the volatility for each leg of the spread
/// to account for the discrete nature of blockchain settlement (the spread
/// must be wide enough to be robust against small price movements during the
/// settlement window).
///
/// ## Key Parameters (from on-chain MarketAccount)
///
/// - `callSigma2` / `putSigma2` — EWMA implied volatility² per side
/// - `callLambda` / `putLambda` — Strike spread width multiplier
/// - `vegaBuffer` — Volatility cushion for spread robustness
/// - `bufferPercent`, `highestCandleChangeBps` — Leverage-based barrier buffer
///
/// ## References
///
/// - Black, F. & Scholes, M. (1973). "The Pricing of Options and Corporate
///   Liabilities." Journal of Political Economy.
/// - On-chain implementation: `bo-sc-sdk/idl/bo_sc.json` (Anchor IDL)
class PremiumCalculator {
  static const double _secondsPerYear = 365 * 24 * 60 * 60;
  static const double _pi = 3.14159265358979323846264338327950288;
  static const double _bpsDenominator = 10000;

  /// 计算指定倍数的障碍价格
  ///
  /// [spotPrice] 当前现货价格
  /// [side] 交易方向（long/short）
  /// [marketAccount] 市场账户数据
  /// [settleDelayEpochsSecs] 结算延迟时间（秒）
  /// [targetMultiplier] 目标赔付倍数（如 2.0）
  /// [currentTimestamp] 当前时间戳（可选，默认使用系统时间）
  PremiumResult calculateBarrierForMultiplier({
    required double spotPrice,
    required Side side,
    required MarketAccount marketAccount,
    required int settleDelayEpochsSecs,
    required double targetMultiplier,
    int? currentTimestamp,
  }) {
    if (targetMultiplier < 1.0) {
      throw ArgumentError('targetMultiplier must be >= 1.0');
    }

    if (spotPrice <= 0) {
      return PremiumResult.zero;
    }

    // 直接使用当前 sigma2 计算 IV（与合约保持一致）
    final sigma2 = side == Side.long
        ? marketAccount.callSigma2
        : marketAccount.putSigma2;
    final iv = sqrt(max(sigma2, 0));
    final timeYears = settleDelayEpochsSecs / _secondsPerYear;

    // 获取 ATM 基础数字价格（barrier = spot）
    final baseParams = DigitalParams(
      spot: spotPrice,
      barrier: spotPrice,
      timeYears: timeYears,
      vegaBuffer: marketAccount.vegaBuffer,
      volatility: iv,
    );

    final lambda =
        side == Side.long ? marketAccount.callLambda : marketAccount.putLambda;

    final basePrice = side == Side.long
        ? digitalCallPrice(baseParams, lambda)
        : digitalPutPrice(baseParams, lambda);

    // 如果倍数为 1，返回 ATM 值
    if (targetMultiplier == 1) {
      return PremiumResult(
        baseDigitalPrice: basePrice,
        targetDigitalPrice: basePrice,
        barrierPrice: baseParams.barrier,
        strikePricePctDiffBps: 0,
      );
    }

    // 从倍数计算目标数字价格（基于收益率的计算方式）
    final baseReturn = 1 / basePrice - 1;
    final targetReturn = baseReturn * targetMultiplier;
    final targetDigitalPrice = 1 / (targetReturn + 1);

    // 使用二分法求解障碍价格
    final solverParams = baseParams.copyWith();

    final boundaryBuffer =
        _getBufferBps(marketAccount, targetMultiplier);

    double barrierPrice;
    if (side == Side.long) {
      barrierPrice = _solveBarrierForCall(solverParams, lambda, targetDigitalPrice) *
          (boundaryBuffer + _bpsDenominator) /
          _bpsDenominator;
    } else {
      barrierPrice = _solveBarrierForPut(solverParams, lambda, targetDigitalPrice) *
          (_bpsDenominator - boundaryBuffer) /
          _bpsDenominator;
    }

    // 计算价差（基点）
    final strikePricePctDiffBps =
        ((barrierPrice - spotPrice) / spotPrice) * _bpsDenominator;

    return PremiumResult(
      baseDigitalPrice: basePrice,
      targetDigitalPrice: targetDigitalPrice,
      barrierPrice: barrierPrice,
      strikePricePctDiffBps: strikePricePctDiffBps.round(),
    );
  }

  // ==========================================================================
  // Black-Scholes Core Functions
  // ==========================================================================

  /// Cumulative standard normal distribution function (Hastings approximation).
  ///
  /// Uses a 5th-degree polynomial approximation with maximum error < 7.5e-8.
  /// This avoids the need for `dart:math`'s `erf` (which doesn't exist) or
  /// expensive numerical integration.
  double normalCDF(double x) {
    const a1 = 0.319381530;
    const a2 = -0.356563782;
    const a3 = 1.781477937;
    const a4 = -1.821255978;
    const a5 = 1.330274429;
    const p = 0.2316419;

    final pdfCoefficient = 1 / sqrt(2 * _pi);
    final z = x.abs();
    final t = 1.0 / (1.0 + p * z);
    final poly = ((((a5 * t + a4) * t + a3) * t + a2) * t + a1) * t;
    final pdf = pdfCoefficient * exp(-0.5 * z * z);
    final cdf = 1.0 - pdf * poly;

    return x >= 0.0 ? cdf : 1.0 - cdf;
  }

  /// Clamps volatility to a minimum to avoid division by zero in B-S formula.
  double clampSigma(double x) => max(x, 1e-9);

  /// Computes the Black-Scholes d₁ and d₂ parameters.
  ///
  /// ```
  /// d₁ = [ln(S/K) + ½σ²T] / (σ√T)
  /// d₂ = d₁ - σ√T
  /// ```
  (double d1, double d2) calculateD1D2(BSParams params) {
    final sqrtT = sqrt(params.timeYears);
    final sigmaT = params.volatility * sqrtT;
    final d1 =
        (log(params.spot / params.strike) + 0.5 * sigmaT * sigmaT) / sigmaT;
    final d2 = d1 - sigmaT;
    return (d1, d2);
  }

  /// Standard Black-Scholes European call price: `C = S·N(d₁) - K·N(d₂)`
  double blackScholesCall(BSParams params) {
    if (params.volatility <= 0 || params.timeYears <= 0) {
      return max(params.spot - params.strike, 0);
    }
    final (d1, d2) = calculateD1D2(params);
    return params.spot * normalCDF(d1) - params.strike * normalCDF(d2);
  }

  /// Standard Black-Scholes European put price: `P = K·N(-d₂) - S·N(-d₁)`
  double blackScholesPut(BSParams params) {
    if (params.volatility <= 0 || params.timeYears <= 0) {
      return max(params.strike - params.spot, 0);
    }
    final (d1, d2) = calculateD1D2(params);
    return params.strike * normalCDF(-d2) - params.spot * normalCDF(-d1);
  }

  /// Digital call price via **normalized call spread** approximation.
  ///
  /// Instead of taking the limit of a call spread (which is numerically
  /// unstable), we use a finite spread width controlled by `callLambda`:
  ///
  /// ```
  /// DigitalCall ≈ [C(K×λ, σ+buf) - C(K, σ-buf)] / (K - K×λ)
  /// ```
  ///
  /// The vega buffer (`σ ± buf`) creates a volatility smile that makes the
  /// spread price more robust against IV changes during settlement.
  double digitalCallPrice(DigitalParams params, double callLambda) {
    final k1 = params.barrier * callLambda;
    final k2 = params.barrier;
    final width = k2 - k1;

    final sigmaTight = clampSigma(params.volatility + params.vegaBuffer);
    final sigmaLoose = clampSigma(params.volatility - params.vegaBuffer);

    final c1 = blackScholesCall(BSParams(
      spot: params.spot,
      strike: k1,
      volatility: sigmaTight,
      timeYears: params.timeYears,
    ));

    final c2 = blackScholesCall(BSParams(
      spot: params.spot,
      strike: k2,
      volatility: sigmaLoose,
      timeYears: params.timeYears,
    ));

    return max((c1 - c2) / width, 0);
  }

  /// Digital put price via **normalized put spread** approximation.
  ///
  /// Mirror of `digitalCallPrice` — uses `P(K, σ-buf) - P(K×λ, σ+buf)`.
  double digitalPutPrice(DigitalParams params, double putLambda) {
    final k1 = params.barrier;
    final k2 = params.barrier * putLambda;
    final width = k2 - k1;

    final sigmaTight = clampSigma(params.volatility + params.vegaBuffer);
    final sigmaLoose = clampSigma(params.volatility - params.vegaBuffer);

    final p1 = blackScholesPut(BSParams(
      spot: params.spot,
      strike: k1,
      volatility: sigmaLoose,
      timeYears: params.timeYears,
    ));

    final p2 = blackScholesPut(BSParams(
      spot: params.spot,
      strike: k2,
      volatility: sigmaTight,
      timeYears: params.timeYears,
    ));

    return max((p2 - p1) / width, 0);
  }

  /// Solves for the barrier price where `digitalCallPrice == targetPrice`
  /// using the **bisection method** (100 iterations, tolerance 1e-8).
  ///
  /// WHY bisection over Newton-Raphson: The digital price function is not
  /// continuously differentiable at certain barrier values due to the spread
  /// approximation, making gradient-based methods unreliable.
  double _solveBarrierForCall(
    DigitalParams params,
    double lambda,
    double targetPrice,
  ) {
    var low = params.barrier;
    var high = params.barrier * 5.0;

    for (var i = 0; i < 100; i++) {
      final mid = (low + high) / 2;
      params.barrier = mid;
      // 与合约一致，使用固定 0.999
      final price = digitalCallPrice(params, 0.999);
      final diff = price - targetPrice;

      if (diff.abs() < 1e-8) return mid;

      if (diff > 0) {
        low = mid;
      } else {
        high = mid;
      }
    }
    return 0;
  }

  /// Solves for the put barrier price. Same bisection approach as call side.
  double _solveBarrierForPut(
    DigitalParams params,
    double lambda,
    double targetPrice,
  ) {
    var low = params.barrier * 0.1;
    var high = params.barrier;

    for (var i = 0; i < 100; i++) {
      final mid = (low + high) / 2;
      params.barrier = mid;
      final price = digitalPutPrice(params, lambda);
      final diff = price - targetPrice;

      if (diff.abs() < 1e-5) return mid;

      if (diff > 0) {
        high = mid;
      } else {
        low = mid;
      }
    }
    return 0;
  }

  /// Computes the leverage-based barrier buffer in basis points.
  ///
  /// Higher leverage multipliers push the barrier further from spot, making
  /// the option cheaper but harder to win. The buffer is linearly interpolated
  /// between 0 and `maxBufferMultiplier`, then capped.
  int _getBufferBps(MarketAccount marketAccount, double multiplier) {
    if (marketAccount.maxBufferMultiplier == 0) {
      return 0;
    }

    // 线性计算: buffer = multiplier * bufferPercent * highestCandleChangeBps / (maxBufferMultiplier * 100)
    final bufferBps = (multiplier *
            marketAccount.bufferPercent *
            marketAccount.highestCandleChangeBps) ~/
        (marketAccount.maxBufferMultiplier * 100);

    // 上限: bufferPercent * highestCandleChangeBps / 100
    final maxBuffer =
        (marketAccount.bufferPercent * marketAccount.highestCandleChangeBps) ~/
            100;

    return bufferBps < maxBuffer ? bufferBps : maxBuffer;
  }
}

