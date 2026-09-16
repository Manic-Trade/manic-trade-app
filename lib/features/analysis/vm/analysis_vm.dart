import 'dart:async';

import 'package:finality/core/logger.dart';
import 'package:finality/core/state/ui_state.dart';
import 'package:finality/data/drift/entities/options_trading_pair.dart';
import 'package:finality/data/network/manic_trade_data_source.dart';
import 'package:finality/data/network/model/manic/pnl_overview_response.dart';
import 'package:finality/di/injector.dart';
import 'package:finality/features/analysis/models/analysis_filter.dart';
import 'package:finality/features/analysis/models/analysis_vo.dart';
import 'package:finality/features/analysis/vm/today_win_rate_vm.dart';
import 'package:flutter/foundation.dart';
import 'package:store_scope/store_scope.dart';

final analysisVMProvider = ViewModelProvider<AnalysisVM>((space) {
  return AnalysisVM(injector(), space.bind(todayWinRateVMProvider));
});

class AnalysisVM extends ViewModel {
  final ManicTradeDataSource _dataSource;
  final TodayWinRateVM _todayWinRateVM;

  AnalysisVM(this._dataSource, this._todayWinRateVM);

  // ===== 筛选状态 =====

  /// 当前选中的资产 (null = All Assets)
  final ValueNotifier<OptionsTradingPair?> selectedPair = ValueNotifier(null);

  /// 当前选中的模式
  final ValueNotifier<ModeFilter> selectedMode = ValueNotifier(ModeFilter.all);

  /// 当前选中的时间范围
  final ValueNotifier<TimeRange> selectedTimeRange =
      ValueNotifier(TimeRange.today);

  // ===== 筛选变更事件流 =====
  final StreamController<void> _filterChangedController =
      StreamController.broadcast();

  Stream<void> get filterChanged => _filterChangedController.stream;

  // ===== 数据状态 =====
  final ValueNotifier<UiState<PnlOverviewResponse>> _dataState =
      ValueNotifier(UiState.initial());

  ValueListenable<UiState<PnlOverviewResponse>> get dataState => _dataState;

  // ===== Today 数据，转发 TodayWinRateVM =====
  ValueListenable<UiState<WinRateVO>> get todayWinRateState =>
      _todayWinRateVM.todayWinRateState;

  /// 判断当前筛选条件是否与 TodayWinRateVM 的请求参数一致
  bool get _isTodayFilter =>
      selectedTimeRange.value == TimeRange.today &&
      selectedPair.value == null &&
      selectedMode.value == ModeFilter.all;

  /// 当前筛选条件下的胜率数据
  WinRateVO get winRateVO {
    final data = _dataState.value.value;
    return data != null ? WinRateVO.fromResponse(data) : WinRateVO.empty();
  }

  /// 每日活动数据（已转为日历网格）
  List<DailyActivityVO> get activityList {
    final data = _dataState.value.value;
    if (data == null) return [];
    return data.dailyActivities
        .map((e) => DailyActivityVO.fromApiItem(e))
        .toList();
  }

  /// 用户等级
  UserTier get userTier {
    final data = _dataState.value.value;
    return data != null ? UserTier.fromBool(data.isPremium) : UserTier.basic;
  }

  /// 充值门槛
  double get premiumThreshold {
    return _dataState.value.value?.premiumThreshold ?? 5000;
  }

  @override
  void init() {
    super.init();

    // 监听 TodayWinRateVM，条件匹配时同步数据到 dataState
    _todayWinRateVM.todayWinRateResponseState.addListener(_onTodayDataChanged);

    // 筛选变化时通知 UI 触发下拉刷新
    selectedPair.addListener(_onFilterChanged);
    selectedMode.addListener(_onFilterChanged);
    selectedTimeRange.addListener(_onFilterChanged);

    _fetchData(false);
  }

  @override
  void dispose() {
    _todayWinRateVM.todayWinRateResponseState
        .removeListener(_onTodayDataChanged);
    selectedPair.removeListener(_onFilterChanged);
    selectedMode.removeListener(_onFilterChanged);
    selectedTimeRange.removeListener(_onFilterChanged);
    _filterChangedController.close();
    super.dispose();
  }

  /// TodayWinRateVM 数据变化时，如果条件匹配则同步到 dataState
  void _onTodayDataChanged() {
    if (_isTodayFilter) {
      var valueOrFallback =
          _todayWinRateVM.todayWinRateResponseState.value.valueOrFallback;
      if (valueOrFallback == null) {
        _dataState.value = _todayWinRateVM.todayWinRateResponseState.value;
      } else {
        _dataState.value = UiState.success(valueOrFallback);
      }
    }
  }

  void _onFilterChanged() {
    if (_filterChangedController.isClosed) return;
    _filterChangedController.add(null);
  }

  void updatePair(OptionsTradingPair? pair) {
    selectedPair.value = pair;
  }

  void updateMode(ModeFilter mode) {
    selectedMode.value = mode;
  }

  void updateTimeRange(TimeRange timeRange) {
    selectedTimeRange.value = timeRange;
  }

  void initOrRefresh() {
    if (!_dataState.value.isLoading) {
      refresh();
    }
  }

  Future<void> refresh() async {
    if (_isTodayFilter) {
      // 条件匹配时只刷新 TodayWinRateVM，监听会自动同步 dataState
      if (_todayWinRateVM.todayWinRateResponseState.value.valueOrFallback !=
          null) {
        _todayWinRateVM.refresh();
      } else {
        await _todayWinRateVM.refresh();
      }
    } else {
      await _fetchData(true);
    }
  }

  Future<void> _fetchData(bool isRefresh) async {
    // 条件匹配时直接用 TodayWinRateVM 的数据
    if (_isTodayFilter) {
      _dataState.value = _todayWinRateVM.todayWinRateResponseState.value;
      return;
    }

    if (!_dataState.value.isSuccess) {
      _dataState.value = _dataState.value.toLoading();
    }
    try {
      final asset = selectedPair.value?.baseAsset;
      final mode = selectedMode.value;
      final timeRange = selectedTimeRange.value;

      final response = await _dataSource.getPnlOverview(
        timeRange: timeRange.value,
        asset: asset,
        mode: mode == ModeFilter.all ? null : mode.value,
      );
      _dataState.value = UiState.success(response);
    } catch (e, stackTrace) {
      logger.e(e, stackTrace: stackTrace);
      if (!_dataState.value.isSuccess) {
        _dataState.value =
            UiState.failure(e, retry: () => _fetchData(isRefresh));
      }
    }
  }
}
