import 'dart:async';

import 'package:finality/core/logger.dart';
import 'package:finality/core/state/ui_state.dart';
import 'package:finality/data/network/manic_trade_data_source.dart';
import 'package:finality/data/network/model/manic/position_history_item.dart';
import 'package:finality/di/injector.dart';
import 'package:finality/features/positions/vm/opened_positions_vm.dart';
import 'package:flutter/foundation.dart';
import 'package:store_scope/store_scope.dart';

final tradingHistoryRecentVMProvider =
    ViewModelProvider<TradingHistoryRecentVM>((ref) {
  return TradingHistoryRecentVM(
    injector(),
    ref.bind(openedPositionsVMProvider),
  );
});

class TradingHistoryRecentVM extends ViewModel {
  TradingHistoryRecentVM(this._dataSource, this._openedPositionsVM);

  final ManicTradeDataSource _dataSource;
  final OpenedPositionsVM _openedPositionsVM;

  /// 加载状态
  final recentHistoryState =
      ValueNotifier<UiState<List<PositionHistoryItem>>>(UiState.initial());

  /// 上一次观察到的未结算仓位 id 集合，用于检测"有仓位结算"
  Set<String> _lastOpenedIds = {};

  /// 批量结算时合并刷新的节流定时器
  Timer? _refreshThrottleTimer;
  static const _refreshThrottle = Duration(seconds: 1);

  @override
  void init() {
    super.init();
    _lastOpenedIds = _currentOpenedIds();
    _openedPositionsVM.openedPositions.addListener(_onOpenedPositionsChanged);
    _openedPositionsVM.setHistoryDetailFetcher(_fetchHistoryForReconcile);
    loadRecentHistory(false);
  }

  Set<String> _currentOpenedIds() {
    return _openedPositionsVM.openedPositions.value.map((p) => p.id).toSet();
  }

  /// 监听未结算列表变化：只要有 id 被移除（表示有仓位结算/平仓），就刷新历史
  void _onOpenedPositionsChanged() {
    final current = _currentOpenedIds();
    final removed = _lastOpenedIds.difference(current);
    _lastOpenedIds = current;
    if (removed.isNotEmpty) {
      _scheduleThrottledRefresh(removed);
    }
  }

  /// 批量结算时短时间内会触发多次，合并为一次刷新：
  /// 首次触发后启动 1s 定时器，期间的触发都被吞掉，定时器到点统一刷新
  /// 若被移除的 id 已全部在当前历史中，说明历史已是最新，跳过本次刷新
  void _scheduleThrottledRefresh(Set<String> removedIds) {
    if (_allRemovedIdsInCurrentHistory(removedIds)) return;
    if (_refreshThrottleTimer?.isActive ?? false) return;
    _refreshThrottleTimer = Timer(_refreshThrottle, () {
      if (disposed) return;
      refreshRecentHistory();
    });
  }

  /// 判断被移除的 id 是否都已存在于当前历史列表中
  /// 历史尚未加载（非 Success 态）时返回 false，让刷新照常进行
  bool _allRemovedIdsInCurrentHistory(Set<String> removedIds) {
    final state = recentHistoryState.value;
    if (state is! Success<List<PositionHistoryItem>>) return false;
    final historyIds = state.value.map((e) => e.positionId).toSet();
    return removedIds.every(historyIds.contains);
  }

  /// 加载最近 20 条交易历史，过滤掉仍在未结算列表中的记录
  Future<void> loadRecentHistory(bool isRefresh) async {
    if (!isRefresh) {
      recentHistoryState.value = Loading();
    }
    try {
      final response = await _dataSource.getPositionHistory(
        page: 1,
        limit: 20,
      );
      final openedIds = _currentOpenedIds();
      final list = response.nodes
          .where((e) => !openedIds.contains(e.positionId))
          .toList();
      if (!disposed) {
        recentHistoryState.value = Success(list);
      }
    } catch (e, stackTrace) {
      logger.e(e, stackTrace: stackTrace);
      if (!isRefresh && !disposed) {
        recentHistoryState.value =
            Failure(e, retry: () => loadRecentHistory(isRefresh));
      }
    }
  }

  Future<void> refreshRecentHistory() async {
    await loadRecentHistory(true);
  }

  /// 兜底对账时由 OpenedPositionsVM 调用：拉一次最近历史，更新自身状态并返回匹配 item
  /// 回调时 OpenedPositionsVM 还未移除 settled 仓位，因此过滤前先把这些 id 排除掉
  Future<Map<String, PositionHistoryItem>> _fetchHistoryForReconcile(
      List<String> ids) async {
    final response = await _dataSource.getPositionHistory(
      page: 1,
      limit: 20,
    );
    if (!disposed) {
      final aboutToSettle = ids.toSet();
      final activeOpenedIds = _currentOpenedIds().difference(aboutToSettle);
      final list = response.nodes
          .where((e) => !activeOpenedIds.contains(e.positionId))
          .toList();
      recentHistoryState.value = Success(list);
    }
    final idSet = ids.toSet();
    final result = <String, PositionHistoryItem>{};
    for (final item in response.nodes) {
      if (idSet.contains(item.positionId)) {
        result[item.positionId] = item;
      }
    }
    return result;
  }

  @override
  void dispose() {
    _refreshThrottleTimer?.cancel();
    _openedPositionsVM.setHistoryDetailFetcher(null);
    _openedPositionsVM.openedPositions.removeListener(_onOpenedPositionsChanged);
    recentHistoryState.dispose();
    super.dispose();
  }
}
