import 'dart:async';

import 'package:deriv_chart/deriv_chart.dart';
import 'package:finality/common/utils/value_listenable_removable.dart';
import 'package:finality/core/logger.dart';
import 'package:finality/core/state/ui_state.dart';
import 'package:finality/data/drift/entities/options_trading_pair.dart';
import 'package:finality/di/injector.dart';
import 'package:finality/domain/options/entities/time_bar.dart';
import 'package:finality/features/highlow/config/high_low_settings_store.dart';
import 'package:finality/features/highlow/utils/timebar_converter.dart';
import 'package:finality/features/highlow/viewmodel/candle_data_synchronizer.dart';
import 'package:finality/features/highlow/viewmodel/selected_trading_pair_vm.dart';
import 'package:finality/services/app_lifecycle_service.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:store_scope/store_scope.dart';

/// deriv_chart K线数据 ViewModel
/// 职责：管理时间周期切换、K 线数据同步
final derivChartCandlesVMProvider = ViewModelProvider(
  (space) => DerivChartCandlesVM(
    selectedPairVM: space.bind(selectedTradingPairVMProvider),
    settingsStore: injector(),
    lifecycleService: injector(),
  ),
);

class DerivChartCandlesVM extends ViewModel {
  final SelectedTradingPairVM _selectedPairVM;
  final HighLowSettingsStore _settingsStore;
  final AppLifecycleService _lifecycleService;

  DerivChartCandlesVM({
    required SelectedTradingPairVM selectedPairVM,
    required HighLowSettingsStore settingsStore,
    required AppLifecycleService lifecycleService,
  })  : _selectedPairVM = selectedPairVM,
        _settingsStore = settingsStore,
        _lifecycleService = lifecycleService,
        currentTimeBar = ValueNotifier(settingsStore.getHighLowTimeBar());

  /// 后台超过该阈值时，回前台会触发强制刷新（重建 socket + 重拉 HTTP），
  /// 用于规避 iOS/Android 长时间后台后出现的僵尸 socket
  static const Duration _forceRefreshThreshold = Duration(seconds: 15);

  StreamSubscription<void>? _backgroundedSub;
  StreamSubscription<void>? _resumedSub;
  DateTime? _backgroundedAt;

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

  /// 上一次的 feedId，用于判断是否需要重建 synchronizer
  String? _previousPairFeedId;

  @override
  void init() {
    super.init();
    _selectedPairVM.currentPair.listen((pair) {
      _onPairChanged(pair);
    }, immediate: true);
    _backgroundedSub = _lifecycleService.onBackgrounded.listen((_) {
      _backgroundedAt ??= DateTime.now();
    });
    _resumedSub = _lifecycleService.onResumed.listen((_) {
      final backgroundedAt = _backgroundedAt;
      _backgroundedAt = null;
      if (backgroundedAt == null) return;
      final elapsed = DateTime.now().difference(backgroundedAt);
      if (elapsed < _forceRefreshThreshold) return;
      logger.d(
        'DerivChartCandlesVM: 后台 ${elapsed.inSeconds}s，触发强制刷新',
      );
      refreshData(forceReconnect: true);
    });
  }

  void _onPairChanged(OptionsTradingPair? pair) {
    if (pair != null) {
      // 只有 feedId 变化时才重建 synchronizer（避免刷新 schedule 时重置图表）
      if (_previousPairFeedId != pair.feedId) {
        _createAndStartSynchronizer(pair);
      }
      _previousPairFeedId = pair.feedId;
    } else {
      _previousPairFeedId = null;
      _synchronizer?.dispose();
      _resetState();
    }
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

  /// 切换 K 线图展示的时间周期（如 1s, 5s, 1m）
  void switchKlineTimeBar(TimeBar newTimebar) {
    if (currentTimeBar.value != newTimebar) {
      currentTimeBar.value = newTimebar;
      _settingsStore.setHighLowTimeBar(newTimebar);
      var pair = _selectedPairVM.currentPair.value;
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
  ///
  /// [forceReconnect] 详见 [CandleDataSynchronizer.refreshData]。用户下拉刷新
  /// 默认走 false；仅生命周期/僵尸连接兜底等场景传 true
  Future<void> refreshData({bool forceReconnect = false}) async {
    await _synchronizer?.refreshData(forceReconnect: forceReconnect);
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
    _backgroundedSub?.cancel();
    _backgroundedSub = null;
    _resumedSub?.cancel();
    _resumedSub = null;
    _synchronizer?.dispose();
    currentTimeBar.dispose();
    _candlesSubject.close();
    currentPrice.dispose();
    lastBeat.dispose();
    initialDataState.dispose();
    historyDataState.dispose();
    super.dispose();
  }
}
