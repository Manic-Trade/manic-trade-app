import 'dart:async';

import 'package:finality/common/utils/value_listenable_removable.dart';
import 'package:finality/core/logger.dart';
import 'package:finality/data/drift/entities/options_trading_pair.dart';
import 'package:finality/di/injector.dart';
import 'package:finality/domain/options/entities/options_trading_pair_identify.dart';
import 'package:finality/domain/options/options_trading_pair_selector.dart';
import 'package:finality/features/highlow/trading_pairs/vm/options_trading_pairs_vm.dart';
import 'package:flutter/foundation.dart';
import 'package:store_scope/store_scope.dart';

/// 当前选中币对状态管理
/// 职责：管理当前选中的交易对、开关盘状态、交易时间表倒计时
final selectedTradingPairVMProvider = ViewModelProvider(
  (space) => SelectedTradingPairVM(
    pairSelector: injector(),
    tradingPairsVM: space.bind(optionsTradingPairsVMProvider),
  ),
);

class SelectedTradingPairVM extends ViewModel {
  final OptionsTradingPairSelector _pairSelector;
  final OptionsTradingPairsVM _tradingPairsVM;

  SelectedTradingPairVM({
    required OptionsTradingPairSelector pairSelector,
    required OptionsTradingPairsVM tradingPairsVM,
  })  : _pairSelector = pairSelector,
        _tradingPairsVM = tradingPairsVM;

  /// 当前选中的交易对
  final ValueNotifier<OptionsTradingPair?> currentPair = ValueNotifier(null);

  /// 当前交易对是否可交易（开盘状态）
  final ValueNotifier<bool> canTradeNotifier = ValueNotifier(true);

  StreamSubscription? _selectedTradingPairSubscription;

  /// 交易时间表倒计时定时器（关盘 / 开盘倒计时）
  Timer? _tradingScheduleTimer;

  /// 关盘前预检定时器（提前 1 分钟刷新确认）
  Timer? _preCloseTimer;

  @override
  void init() {
    super.init();
    var removable = currentPair.listen((pair) {
      _onTradingPairChanged(pair);
    });
    addCloseable(removable.remove);
    // 持续监听 DB 中当前选中交易对的变化
    // 任何地方调用 refreshTradingPairs() 存入 DB 后，变化会自动传播到 currentPair
    _startListenSelectedPair();
  }

  void _onTradingPairChanged(OptionsTradingPair? pair) {
    if (pair != null) {
      logger.d('[TradingPair] 币对变更: ${pair.toString()}');
      canTradeNotifier.value = pair.isActive;
      _startListenTradingSchedule(pair);
    } else {
      logger.d('[TradingPair] 币对变更: null');
      canTradeNotifier.value = false;
      _stopListenTradingSchedule();
    }
  }

  // ==================== 币对切换 ====================

  /// 切换资产
  void switchAsset(OptionsTradingPair newPair) {
    if (currentPair.value != newPair) {
      logger.d(
          '[TradingPair] 切换币对: ${currentPair.value?.baseAsset} → ${newPair.baseAsset}');
      // 保存最后一次选中的交易对
      _pairSelector.setSelectedPairId(OptionsTradingPairIdentify(
        feedId: newPair.feedId,
        baseAsset: newPair.baseAsset,
      ));
      currentPair.value = newPair;
    }
  }

  /// 持续监听 DB 中当前选中交易对的变化
  void _startListenSelectedPair() {
    _selectedTradingPairSubscription?.cancel();
    _selectedTradingPairSubscription =
        _pairSelector.streamSelectedTradingPair().listen((pair) {
      if (pair != null) {
        logger.d('[TradingPair] DB 推送更新: ${pair.baseAsset}'
            ' | isActive=${pair.isActive}');
        currentPair.value = pair;
      }
    });
    addCloseable(() {
      _selectedTradingPairSubscription?.cancel();
    });
  }

  // ==================== 交易时间表 ====================

  void _startListenTradingSchedule(OptionsTradingPair pair) {
    _stopListenTradingSchedule();

    final nowSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    if (!pair.isActive) {
      // === 关→开 路径 ===
      final nextOpenTime = pair.tradingSchedule?.nextOpenTime;
      if (nextOpenTime != null && nextOpenTime > nowSeconds) {
        final durationSeconds = nextOpenTime - nowSeconds;
        logger.d('[TradingPair] 市场关闭，${durationSeconds}s 后开盘');
        canTradeNotifier.value = false;
        _tradingScheduleTimer = Timer(
          Duration(seconds: durationSeconds),
          () {
            _tradingScheduleTimer = null;
            logger.d('[TradingPair] 开盘倒计时到，canTrade → true');
            canTradeNotifier.value = true;
            // 开盘后刷新交易对信息，获取新的 nextCloseTime
            refreshCurrentPairInfo();
          },
        );
      }
    } else {
      // === 开→关 路径 ===
      final nextCloseTime = pair.tradingSchedule?.nextCloseTime;
      if (nextCloseTime != null && nextCloseTime > nowSeconds) {
        // 关盘前 60 秒触发预检
        final preCloseTime = nextCloseTime - 60;
        if (preCloseTime > nowSeconds) {
          logger.d('[TradingPair] 市场开放，${preCloseTime - nowSeconds}s 后触发预检'
              '，${nextCloseTime - nowSeconds}s 后关盘');
          _preCloseTimer = Timer(
            Duration(seconds: preCloseTime - nowSeconds),
            () {
              _preCloseTimer = null;
              logger.d('[TradingPair] 预检定时器触发，开始刷新确认');
              _handlePreCloseCheck(nextCloseTime);
            },
          );
        } else {
          // 距离关盘 <= 60 秒，立即执行预检
          logger.d('[TradingPair] 距离关盘 <= 60s，立即预检');
          _handlePreCloseCheck(nextCloseTime);
        }
      }
    }
  }

  void _stopListenTradingSchedule() {
    _tradingScheduleTimer?.cancel();
    _tradingScheduleTimer = null;
    _preCloseTimer?.cancel();
    _preCloseTimer = null;
  }

  /// 关盘前预检：刷新交易对信息，确认是否仍然需要关盘
  Future<void> _handlePreCloseCheck(int scheduledCloseTime) async {
    final currentFeedId = currentPair.value?.feedId;
    if (currentFeedId == null) return;

    try {
      await _tradingPairsVM.refreshTradingPairs();
      final updatedPair = await _pairSelector.loadSelectedTradingPair();

      // 切换了币对，忽略
      if (updatedPair == null || updatedPair.feedId != currentFeedId) return;

      if (!updatedPair.isActive) {
        // API 已经标记关盘，直接更新（触发 _onTradingPairChanged → 走关→开路径）
        logger.d('[TradingPair] 预检结果: API 已标记关盘');
        currentPair.value = updatedPair;
      } else {
        final newCloseTime = updatedPair.tradingSchedule?.nextCloseTime;
        final nowSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;

        if (newCloseTime != null && newCloseTime > nowSeconds) {
          // 确认仍要关盘，设置最终关盘定时器
          logger.d('[TradingPair] 预检确认: ${newCloseTime - nowSeconds}s 后关盘');
          _tradingScheduleTimer = Timer(
            Duration(seconds: newCloseTime - nowSeconds),
            () {
              _tradingScheduleTimer = null;
              logger.d('[TradingPair] 关盘倒计时到，canTrade → false');
              canTradeNotifier.value = false;
              // 关盘后刷新，获取新的 nextOpenTime
              refreshCurrentPairInfo();
            },
          );
          // 同时更新 pair 引用（让 UI 拿到最新的 tradingSchedule）
          currentPair.value = updatedPair;
        } else if (newCloseTime != null) {
          // 关盘时间已过
          logger.d('[TradingPair] 预检结果: 关盘时间已过，立即关盘');
          canTradeNotifier.value = false;
          refreshCurrentPairInfo();
        } else {
          // 没有 closeTime 了（可能取消了关盘计划），更新 pair
          logger.d('[TradingPair] 预检结果: 无 closeTime，取消关盘计划');
          currentPair.value = updatedPair;
        }
      }
    } catch (e) {
      // 网络失败，保守处理：按原定时间关盘
      logger.e('_handlePreCloseCheck failed', error: e);
      final nowSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final remaining = scheduledCloseTime - nowSeconds;
      if (remaining > 0) {
        _tradingScheduleTimer = Timer(
          Duration(seconds: remaining),
          () {
            _tradingScheduleTimer = null;
            canTradeNotifier.value = false;
          },
        );
      } else {
        canTradeNotifier.value = false;
      }
    }
  }

  /// 从 API 刷新交易对信息
  /// 数据存入 DB 后，Drift stream 会自动推送更新到 currentPair
  Future<void> refreshCurrentPairInfo() async {
    try {
      await _tradingPairsVM.refreshTradingPairs();
    } catch (e) {
      logger.e('refreshCurrentPairInfo failed', error: e);
    }
  }

  @override
  void dispose() {
    _stopListenTradingSchedule();
    currentPair.dispose();
    super.dispose();
  }
}
