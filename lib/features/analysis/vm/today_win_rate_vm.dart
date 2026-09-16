import 'dart:async';

import 'package:finality/core/logger.dart';
import 'package:finality/core/state/ui_state.dart';
import 'package:finality/data/network/manic_trade_data_source.dart';
import 'package:finality/data/network/model/manic/pnl_overview_response.dart';
import 'package:finality/di/injector.dart';
import 'package:finality/features/positions/vm/opened_positions_vm.dart';
import 'package:finality/features/analysis/models/analysis_filter.dart';
import 'package:finality/features/analysis/models/analysis_vo.dart';
import 'package:flutter/foundation.dart';
import 'package:store_scope/store_scope.dart';

final todayWinRateVMProvider = ViewModelProvider<TodayWinRateVM>((space) {
  return TodayWinRateVM(
    injector(),
    space.bind(openedPositionsVMProvider).onPositionSettled,
  );
});

class TodayWinRateVM extends ViewModel {
  final ManicTradeDataSource _dataSource;
  final Stream<String> _onPositionSettled;

  TodayWinRateVM(this._dataSource, this._onPositionSettled);

  // ===== 刷新标记 =====
  bool _needsRefresh = false;
  StreamSubscription<String>? _settledSubscription;

  // ===== 数据状态 =====
  final ValueNotifier<UiState<PnlOverviewResponse>> _todayWinRateResponseState =
      ValueNotifier(UiState.initial());

  ValueListenable<UiState<PnlOverviewResponse>> get todayWinRateResponseState =>
      _todayWinRateResponseState;

  // ===== Today 数据（不受筛选条件影响，供 AccountWinRateCard 使用）=====
  final ValueNotifier<UiState<WinRateVO>> _todayWinRateState =
      ValueNotifier(UiState.initial());

  ValueListenable<UiState<WinRateVO>> get todayWinRateState =>
      _todayWinRateState;

  /// 每日活动数据（已转为日历网格）
  // List<DailyActivityVO> get activityList {
  //   final data = _todayWinRateResponseState.value.value;
  //   if (data == null) return [];
  //   return data.dailyActivities
  //       .map((e) => DailyActivityVO.fromApiItem(e))
  //       .toList();
  // }

  // /// 用户等级
  // UserTier get userTier {
  //   final data = _todayWinRateResponseState.value.value;
  //   return data != null ? UserTier.fromBool(data.isPremium) : UserTier.basic;
  // }

  @override
  void init() {
    super.init();
    _fetchTodayData(false);
    _settledSubscription = _onPositionSettled.listen((_) {
      _needsRefresh = true;
    });
  }

  /// 页面可见时调用，检查是否有待刷新的数据
  void refreshIfNeeded() {
    if (_needsRefresh) {
      _needsRefresh = false;
      _fetchTodayData(true);
    }
  }

  Future<void> refresh() async {
    await _fetchTodayData(true);
  }

  @override
  void dispose() {
    _settledSubscription?.cancel();
    super.dispose();
  }

  /// 获取 today 数据（不受筛选条件影响）
  Future<void> _fetchTodayData(bool isRefresh) async {
    if (_todayWinRateResponseState.value.isLoading) {
      return;
    }
    _todayWinRateResponseState.value =
        _todayWinRateResponseState.value.toLoading();
    _todayWinRateState.value = _todayWinRateState.value.toLoading();

    try {
      final response = await _dataSource.getPnlOverview(
        timeRange: TimeRange.today.value,
      );

      // 更新状态
      _todayWinRateState.value =
          UiState.success(WinRateVO.fromResponse(response));
      _todayWinRateResponseState.value = UiState.success(response);
    } catch (e, stackTrace) {
      logger.e(e, stackTrace: stackTrace);

      _todayWinRateResponseState.value = _todayWinRateResponseState.value
          .toFailure(e, retry: () => _fetchTodayData(isRefresh));
      _todayWinRateState.value = _todayWinRateState.value
          .toFailure(e, retry: () => _fetchTodayData(isRefresh));
    }
  }
}
