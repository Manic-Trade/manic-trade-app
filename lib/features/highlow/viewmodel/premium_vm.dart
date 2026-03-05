import 'dart:async';

import 'package:finality/core/logger.dart';
import 'package:finality/core/notifier/computed_notifier.dart';
import 'package:finality/data/drift/options_database.dart';
import 'package:finality/data/realtime/realtime_market_account_transport.dart';
import 'package:finality/di/injector.dart';
import 'package:finality/domain/premium/entities/premium_result_pair.dart';
import 'package:flutter/foundation.dart';
import 'package:store_scope/store_scope.dart';

import 'package:finality/domain/premium/premium_calculator.dart';
import 'package:finality/domain/premium/entities/market_account.dart';
import 'package:finality/domain/premium/entities/premium_input.dart';
import 'package:finality/domain/premium/entities/side.dart';

/// Premium ViewModel Provider
final premiumVMProvider = ViewModelProvider<PremiumVM>((ref) {
  return PremiumVM(
    injector<RealtimeMarketAccountTransport>(),
    PremiumCalculator(),
  );
});

/// Premium 计算 ViewModel
///
/// 职责：
/// 1. 管理 MarketAccount 数据
/// 2. 根据价格、倍数、时长计算 Premium
/// 3. 提供 Higher/Lower 的障碍价格和预期收益
class PremiumVM extends ViewModel {
  final RealtimeMarketAccountTransport _marketAccountTransport;
  final PremiumCalculator _calculator;

  PremiumVM(
    this._marketAccountTransport,
    this._calculator,
  );

  // ========== 状态数据 ==========
  final ValueNotifier<MarketAccount?> marketAccountNotifier =
      ValueNotifier(null);

  late final ValueListenable<({double min, double max})> stakeAmountRange =
      ComputedNotifier(source: marketAccountNotifier, compute: (account) {
        if (account == null) {
          return (min: 1.0, max: 100.0);
        }
        return (
          min: account.minStake.toDouble() / 1e6,
          max: account.maxStake.toDouble() / 1e6,
        );
      });

  /// Premium 计算结果
  final ValueNotifier<PremiumResultPair> premium =
      ValueNotifier(PremiumResultPair.zero);

  OptionsTradingPair? _currentTradingPair;

  /// MarketAccount 数据流订阅
  StreamSubscription<MarketAccount>? _marketAccountSubscription;

  void setTradingPair(OptionsTradingPair? tradingPair) {
    if (tradingPair == null) {
      _resetState();
      return;
    }

    if (_currentTradingPair == tradingPair) {
      return;
    }
    _currentTradingPair = tradingPair;
    _subscribeMarketAccount(tradingPair);
  }

  /// 订阅 MarketAccount 实时数据
  void _subscribeMarketAccount(OptionsTradingPair tradingPair) {
    // 取消旧订阅
    _marketAccountSubscription?.cancel();
    marketAccountNotifier.value = null;

    _marketAccountSubscription =
        _marketAccountTransport.subscribe(tradingPair.baseAsset).listen(
      (account) {
        // 确保 trading pair 没有变化才更新
        if (_currentTradingPair?.feedId == tradingPair.feedId) {
          marketAccountNotifier.value = account;
        }
      },
    );
  }

  void _resetState() {
    _currentTradingPair = null;
    _marketAccountSubscription?.cancel();
    _marketAccountSubscription = null;
    marketAccountNotifier.value = null;
    premium.value = PremiumResultPair.zero;
  }

  /// 计算 Premium
  ///
  /// [input] 计算输入参数
  void calculatePremiumWithInput(PremiumInput input) {
    final account = marketAccountNotifier.value;
    if (account == null || !input.isValid) {
      premium.value = PremiumResultPair.zero;
      return;
    }

    try {
      final higher = _calculator.calculateBarrierForMultiplier(
        spotPrice: input.spotPrice,
        side: Side.long,
        marketAccount: account,
        settleDelayEpochsSecs: input.durationSecs,
        targetMultiplier: input.payoutMultiplier,
        currentTimestamp: input.timestamp,
      );

      final lower = _calculator.calculateBarrierForMultiplier(
        spotPrice: input.spotPrice,
        side: Side.short,
        marketAccount: account,
        settleDelayEpochsSecs: input.durationSecs,
        targetMultiplier: input.payoutMultiplier,
        currentTimestamp: input.timestamp,
      );

      premium.value = PremiumResultPair(
        higher: higher,
        lower: lower,
        input: input,
      );
    } catch (e, stackTrace) {
      logger.e('PremiumVM: 计算 Premium 失败', error: e, stackTrace: stackTrace);
      premium.value = PremiumResultPair.zero;
    }
  }

  /// 计算 Premium（便捷方法）
  ///
  /// [spotPrice] 当前现货价格
  /// [durationSecs] 持仓时长（秒）
  /// [payoutMultiplier] 赔付倍数（如 2.0）
  /// [currentTimestamp] 当前时间戳（可选，默认使用当前时间）
  void calculatePremium({
    required double spotPrice,
    required int durationSecs,
    required double payoutMultiplier,
    int? currentTimestamp,
  }) {
    final input = PremiumInput(
      spotPrice: spotPrice,
      durationSecs: durationSecs,
      payoutMultiplier: payoutMultiplier,
      timestamp:
          currentTimestamp ?? DateTime.now().millisecondsSinceEpoch ~/ 1000,
    );
    calculatePremiumWithInput(input);
  }

  @override
  void dispose() {
    _marketAccountSubscription?.cancel();
    super.dispose();
  }
}
