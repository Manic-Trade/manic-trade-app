import 'dart:async';

import 'package:finality/core/logger.dart';
import 'package:finality/core/state/ui_state.dart';
import 'package:finality/data/drift/entities/options_trading_pair.dart';
import 'package:finality/data/network/manic_trade_data_source.dart';
import 'package:finality/di/injector.dart';
import 'package:finality/features/analysis/models/analysis_filter.dart';
import 'package:finality/features/analysis/models/premium_analysis_vo.dart';
import 'package:flutter/foundation.dart';
import 'package:store_scope/store_scope.dart';

final premiumAnalysisVMProvider =
    ViewModelProvider<PremiumAnalysisVM>((space) {
  return PremiumAnalysisVM(injector());
});

/// Premium 模式分析页 ViewModel
/// 并行请求 3 个 API，合并为 PremiumAnalysisData
class PremiumAnalysisVM extends ViewModel {
  final ManicTradeDataSource _dataSource;

  PremiumAnalysisVM(this._dataSource);

  // ===== 筛选状态 =====
  final ValueNotifier<OptionsTradingPair?> selectedPair = ValueNotifier(null);
  final ValueNotifier<ModeFilter> selectedMode = ValueNotifier(ModeFilter.all);
  final ValueNotifier<TimeRange> selectedTimeRange =
      ValueNotifier(TimeRange.today);

  // ===== 筛选变更事件流 =====
  final StreamController<void> _filterChangedController =
      StreamController.broadcast();

  Stream<void> get filterChanged => _filterChangedController.stream;

  // ===== 数据状态 =====
  final ValueNotifier<UiState<PremiumAnalysisData>> _dataState =
      ValueNotifier(UiState.initial());

  ValueListenable<UiState<PremiumAnalysisData>> get dataState => _dataState;

  PremiumAnalysisData? get data => _dataState.value.value;

  @override
  void init() {
    super.init();
    selectedPair.addListener(_onFilterChanged);
    selectedMode.addListener(_onFilterChanged);
    selectedTimeRange.addListener(_onFilterChanged);
    _fetchData();
  }

  @override
  void dispose() {
    selectedPair.removeListener(_onFilterChanged);
    selectedMode.removeListener(_onFilterChanged);
    selectedTimeRange.removeListener(_onFilterChanged);
    _filterChangedController.close();
    super.dispose();
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
    await _fetchData();
  }

  Future<void> _fetchData() async {
    if (!_dataState.value.isSuccess) {
      _dataState.value = _dataState.value.toLoading();
    }
    try {
      final asset = selectedPair.value?.baseAsset;
      final mode = selectedMode.value;
      final timeRange = selectedTimeRange.value;
      final modeParam = mode == ModeFilter.all ? null : mode.value;

      // 并行请求 3 个 API
      final results = await Future.wait([
        _dataSource.getPremiumSummary(
          timeRange: timeRange.value,
          asset: asset,
          mode: modeParam,
        ),
        _dataSource.getPremiumAnalysis(
          timeRange: timeRange.value,
          asset: asset,
          mode: modeParam,
        ),
        _dataSource.getPremiumActivity(
          timeRange: timeRange.value,
          asset: asset,
          mode: modeParam,
        ),
      ]);

      final data = PremiumAnalysisData.from(
        summaryResp: results[0] as dynamic,
        analysisResp: results[1] as dynamic,
        activityResp: results[2] as dynamic,
      );

      _dataState.value = UiState.success(data);
    } catch (e, stackTrace) {
      logger.e(e, stackTrace: stackTrace);
      if (!_dataState.value.isSuccess) {
        _dataState.value = UiState.failure(e, retry: _fetchData);
      }
    }
  }
}
