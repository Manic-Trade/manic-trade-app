import 'dart:async';

import 'package:finality/data/network/agent_data_source.dart';
import 'package:finality/data/network/manic_trade_data_source.dart';
import 'package:finality/data/network/model/manic/position_history_item.dart';
import 'package:finality/di/injector.dart';
import 'package:finality/features/positions/vm/opened_positions_vm.dart';
import 'package:store_scope/store_scope.dart';

final tradingHistoryVMProvider = ViewModelProvider<TradingHistoryVM>((ref) {
  return TradingHistoryVM(
    injector(),
    openedPositionsVM: ref.bind(openedPositionsVMProvider),
  );
});

final agentTradingHistoryVMProvider =
    ViewModelProvider<TradingHistoryVM>((ref) {
  return TradingHistoryVM(injector(), isAgent: true);
});

/// 交易历史页面 ViewModel
/// 支持分页加载全部交易历史
class TradingHistoryVM extends ViewModel {
  TradingHistoryVM(
    this._dataSource, {
    this.isAgent = false,
    this.openedPositionsVM,
  }) : _agentDataSource = isAgent ? injector<AgentDataSource>() : null;

  final ManicTradeDataSource _dataSource;
  final AgentDataSource? _agentDataSource;
  final bool isAgent;

  /// 非 agent 模式下用于过滤"仍在未结算列表"的记录；agent 模式为 null
  final OpenedPositionsVM? openedPositionsVM;

  static const int _pageSize = 15;

  int _page = 1;
  bool _hasMore = true;

  /// 是否还有更多数据
  bool get isTheEnd => !_hasMore;

  /// 刷新事件流，页面监听此流触发 loadInitial(true)
  final _refreshController = StreamController<void>.broadcast();

  Stream<void> get onRefresh => _refreshController.stream;

  /// 上一次观察到的未结算仓位 id 集合，用于检测"有仓位结算"
  Set<String> _lastOpenedIds = {};

  /// 批量结算时合并刷新的节流定时器
  Timer? _refreshThrottleTimer;
  static const _refreshThrottle = Duration(seconds: 1);

  @override
  void init() {
    super.init();
    final notifier = openedPositionsVM?.openedPositions;
    if (notifier != null) {
      _lastOpenedIds = notifier.value.map((p) => p.id).toSet();
      notifier.addListener(_onOpenedPositionsChanged);
    }
  }

  /// 监听未结算列表变化：有 id 被移除时（仓位结算/平仓）通知页面刷新
  void _onOpenedPositionsChanged() {
    final notifier = openedPositionsVM?.openedPositions;
    if (notifier == null) return;
    final current = notifier.value.map((p) => p.id).toSet();
    final removed = _lastOpenedIds.difference(current);
    _lastOpenedIds = current;
    if (removed.isNotEmpty) {
      _scheduleThrottledRefresh();
    }
  }

  /// 批量结算时短时间内会触发多次，合并为一次刷新：
  /// 首次触发后启动 1s 定时器，期间的触发都被吞掉，定时器到点统一刷新
  void _scheduleThrottledRefresh() {
    if (_refreshThrottleTimer?.isActive ?? false) return;
    _refreshThrottleTimer = Timer(_refreshThrottle, () {
      if (disposed) return;
      refresh();
    });
  }

  /// 通知页面刷新数据
  void refresh() {
    _refreshController.add(null);
  }

  @override
  void dispose() {
    _refreshThrottleTimer?.cancel();
    openedPositionsVM?.openedPositions.removeListener(_onOpenedPositionsChanged);
    _refreshController.close();
    super.dispose();
  }

  /// 重置分页状态
  void _resetState() {
    _page = 1;
    _hasMore = true;
  }

  /// 加载初始数据
  Future<List<PositionHistoryItem>> loadInitial(bool isRefresh) async {
    if (isRefresh) {
      _resetState();
    }
    return _fetchPage();
  }

  /// 加载更多数据
  Future<List<PositionHistoryItem>> loadMore() async {
    if (isTheEnd) return [];
    return _fetchPage();
  }

  Future<List<PositionHistoryItem>> _fetchPage() async {
    final response = isAgent
        ? await _agentDataSource!.getAgentPositionHistory(
            page: _page,
            limit: _pageSize,
          )
        : await _dataSource.getPositionHistory(
            page: _page,
            limit: _pageSize,
          );
    if (response.nodes.length < _pageSize ||
        response.total <= _page * _pageSize) {
      _hasMore = false;
    }
    _page++;
    if (isAgent) {
      // Agent 不区分已结算和未结算
      return response.nodes;
    }
    // 过滤掉仍在未结算列表中的记录（避免后端 status 尚未回写时误判为已结算）
    final openedIds = openedPositionsVM?.openedPositions.value
            .map((p) => p.id)
            .toSet() ??
        const <String>{};
    return response.nodes
        .where((e) => !openedIds.contains(e.positionId))
        .toList();
  }
}
