import 'package:finality/core/logger.dart';
import 'package:finality/core/state/ui_state.dart';
import 'package:finality/data/network/manic_trade_data_source.dart';
import 'package:finality/data/network/model/manic/position_history_item.dart';
import 'package:finality/di/injector.dart';
import 'package:flutter/foundation.dart';
import 'package:store_scope/store_scope.dart';

final tradingHistoryRecentVMProvider =
    ViewModelProvider<TradingHistoryRecentVM>((space) {
  return TradingHistoryRecentVM(injector());
});

class TradingHistoryRecentVM extends ViewModel {
  TradingHistoryRecentVM(this._dataSource);

  final ManicTradeDataSource _dataSource;

  /// 加载状态
  final recentHistoryState =
      ValueNotifier<UiState<List<PositionHistoryItem>>>(UiState.initial());

  @override
  void init() {
    super.init();
    loadRecentHistory(false);
  }

  /// 加载最近 5 条交易历史
  Future<void> loadRecentHistory(bool isRefresh) async {
    if (!isRefresh) {
      recentHistoryState.value = Loading();
    }
    try {
      final response = await _dataSource.getPositionHistory(
        page: 1,
        limit: 20,
      );
      // 只取已结算的记录
      var list = response.nodes.where((e) => e.isSettled).take(5).toList();
      recentHistoryState.value = Success(list);
    } catch (e, stackTrace) {
      logger.e(e, stackTrace: stackTrace);
      if (!isRefresh) {
        recentHistoryState.value =
            Failure(e, retry: () => loadRecentHistory(isRefresh));
      }
    }
  }

  Future<void> refreshRecentHistory() async {
    loadRecentHistory(true);
  }

  @override
  void dispose() {
    recentHistoryState.dispose();
    super.dispose();
  }
}
