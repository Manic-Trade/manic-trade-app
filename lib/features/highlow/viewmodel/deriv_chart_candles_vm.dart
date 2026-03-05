import 'dart:async';

import 'package:deriv_chart/deriv_chart.dart';
import 'package:finality/common/utils/value_listenable_removable.dart';
import 'package:finality/core/state/ui_state.dart';
import 'package:finality/data/drift/options_database.dart';
import 'package:finality/di/injector.dart';
import 'package:finality/domain/options/entities/options_trading_pair_identify.dart';
import 'package:finality/domain/options/entities/time_bar.dart';
import 'package:finality/domain/options/options_trading_pair_selector.dart';
import 'package:finality/features/highlow/config/high_low_settings_store.dart';
import 'package:finality/features/highlow/utils/timebar_converter.dart';
import 'package:finality/features/highlow/viewmodel/candle_data_synchronizer.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:store_scope/store_scope.dart';

/// deriv_chart K线数据 ViewModel
/// 职责：管理资产切换、时间周期切换、持有状态数据
final derivChartCandlesVMProvider = ViewModelProvider.withArgument(
  (space, OptionsTradingPair? pair) => DerivChartCandlesVM(
    initialPair: pair,
    pairSelector: injector(),
    settingsStore: injector(),
  ),
);

class DerivChartCandlesVM extends ViewModel {
  final OptionsTradingPairSelector _pairSelector;
  final HighLowSettingsStore _settingsStore;

  DerivChartCandlesVM({
    OptionsTradingPair? initialPair,
    required OptionsTradingPairSelector pairSelector,
    required HighLowSettingsStore settingsStore,
  })  : _pairSelector = pairSelector,
        _settingsStore = settingsStore,
        currentPair = ValueNotifier(initialPair),
        currentTimeBar = ValueNotifier(settingsStore.getHighLowTimeBar());

  /// 当前资产
  final ValueNotifier<OptionsTradingPair?> currentPair;

  /// 当前时间周期
  final ValueNotifier<TimeBar> currentTimeBar;

  /// 当前同步器
  CandleDataSynchronizer? _synchronizer;

  // ========== 状态数据 ==========

  /// K线数据变化流
  final _candlesSubject = BehaviorSubject<List<Candle>>();
  Stream<List<Candle>> get candlesStream => _candlesSubject.stream;

  final ValueNotifier<bool> hasCandles = ValueNotifier(false);

  /// 当前价格
  final ValueNotifier<double?> currentPrice = ValueNotifier(null);

  /// 最后心跳时间戳
  final ValueNotifier<int?> lastBeat = ValueNotifier(null);

  /// 初始数据加载状态
  final ValueNotifier<UiState<bool>> initialDataState =
      ValueNotifier(UiState.initial());

  /// 历史数据加载状态
  final ValueNotifier<UiState<void>> historyDataState =
      ValueNotifier(UiState.initial());

  /// 是否已经没有更多历史数据了
  final ValueNotifier<bool> noMoreHistoryNotifier = ValueNotifier(false);

  /// 时间粒度（毫秒）
  int get granularityMs =>
      TimeBarConverter.toSecondsOrThrow(currentTimeBar.value) * 1000;

  /// 是否实时数据
  ValueNotifier<bool> isLiveNotifier = ValueNotifier(false);

  /// 是否已暂停
  bool get isPaused => _synchronizer?.isPaused ?? false;

  StreamSubscription? _selectedTradingPairSubscription;

  /// 交易时间表倒计时定时器
  Timer? _tradingScheduleTimer;

  ValueNotifier<bool> canTradeNotifier = ValueNotifier(true);

  @override
  void init() {
    super.init();
    currentPair.listen((pair) {
      onTradingPairChanged(pair);
    }, immediate: true);
  }

  void onTradingPairChanged(OptionsTradingPair? pair) {
    if (pair != null) {
      canTradeNotifier.value = pair.isActive;
      _createAndStartSynchronizer(pair);
      startListenTradingSchedule(pair);
    } else {
      canTradeNotifier.value = false;
      stopListenTradingSchedule();
      if (_synchronizer != null) {
        _synchronizer!.dispose();
        _resetState();
      }
      //如果当前没有交易对，则一直监听本地所有交易对变化，直到选择一个为止
      startListenSelectedPair();
    }
  }

  void startListenTradingSchedule(OptionsTradingPair pair) {
    // 先停止之前的定时器
    stopListenTradingSchedule();
    if (!pair.isActive) {
      final timeSeconds = pair.tradingSchedule?.nextOpenTime;
      if (timeSeconds != null) {
        final nowSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;

        // 如果已经开盘，直接设置为可交易，不需要倒计时
        if (timeSeconds <= nowSeconds) {
          return;
        }

        // 还没开盘，设置为不可交易，并开启倒计时
        canTradeNotifier.value = false;
        final durationSeconds = timeSeconds - nowSeconds;
        _tradingScheduleTimer = Timer(
          Duration(seconds: durationSeconds),
          () {
            _tradingScheduleTimer = null;
            canTradeNotifier.value = true;
          },
        );
      }
    }
  }

  void stopListenTradingSchedule() {
    _tradingScheduleTimer?.cancel();
    _tradingScheduleTimer = null;
  }

  void startListenSelectedPair() {
    _selectedTradingPairSubscription?.cancel();
    _selectedTradingPairSubscription =
        _pairSelector.streamSelectedTradingPair().listen((pair) {
      if (pair != null) {
        currentPair.value = pair;
        _selectedTradingPairSubscription?.cancel();
        _selectedTradingPairSubscription = null;
      }
    });
    addCloseable(() {
      _selectedTradingPairSubscription?.cancel();
    });
  }

  void _resetState() {
    _candlesSubject.value = [];
    hasCandles.value = false;
    currentPrice.value = null;
    lastBeat.value = null;
    initialDataState.value = UiState.initial();
    historyDataState.value = UiState.initial();
  }

  /// 创建并启动同步器
  void _createAndStartSynchronizer(OptionsTradingPair pair) {
    _synchronizer?.dispose();

    // 重置状态
    _resetState();

    _synchronizer = CandleDataSynchronizer(
      asset: pair.baseAsset,
      timeBar: currentTimeBar.value,
      httpDataSource: injector(),
      priceStreamManager: injector(),
    );

    _synchronizer!.start(
      onCandlesChanged: (candles) {
        _candlesSubject.value = candles;
        hasCandles.value = candles.isNotEmpty;
      },
      onPriceChanged: (price, timestamp) {
        currentPrice.value = price;
        lastBeat.value = timestamp;
      },
      onInitialLoadStateChanged: (state) {
        initialDataState.value = state;
      },
      onHistoryLoadStateChanged: (state) {
        historyDataState.value = state;
      },
      onIsLiveChanged: (isLive) {
        isLiveNotifier.value = isLive;
      },
      onNoMoreHistoryChanged: (noMoreHistory) {
        noMoreHistoryNotifier.value = noMoreHistory;
      },
    );
  }

  /// 切换资产
  void switchAsset(OptionsTradingPair newPair) {
    if (currentPair.value != newPair) {
      //保存最后一次选中的交易对
      _pairSelector.setSelectedPairId(OptionsTradingPairIdentify(
        feedId: newPair.feedId,
        baseAsset: newPair.baseAsset,
      ));
      currentPair.value = newPair; //notifiy listener 后自动触发onTradingPairChanged
    }
  }

  /// 切换 K 线图展示的时间周期（如 1s, 5s, 1m）
  void switchKlineTimeBar(TimeBar newTimebar) {
    if (currentTimeBar.value != newTimebar) {
      currentTimeBar.value = newTimebar;
      _settingsStore.setHighLowTimeBar(newTimebar);
      var pair = currentPair.value;
      if (pair != null) {
        _createAndStartSynchronizer(pair);
      }
    }
  }

  /// 加载历史K线数据
  Future<void> loadHistoryCandles() async {
    await _synchronizer?.loadHistory();
  }

  /// 刷新数据
  Future<void> refreshData() async {
    await _synchronizer?.refreshData();
  }

  /// 暂停数据监听
  Future<void> pause() async {
    await _synchronizer?.pause();
  }

  /// 恢复数据监听
  Future<void> resume() async {
    await _synchronizer?.resume();
  }

  @override
  void dispose() {
    stopListenTradingSchedule();
    _synchronizer?.dispose();
    currentPair.dispose();
    currentTimeBar.dispose();
    _candlesSubject.close();
    currentPrice.dispose();
    lastBeat.dispose();
    initialDataState.dispose();
    historyDataState.dispose();
    super.dispose();
  }
}
