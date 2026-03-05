import 'dart:async';

import 'package:finality/data/network/manic_trade_data_source.dart';
import 'package:finality/data/network/model/manic/position_history_item.dart';
import 'package:finality/di/injector.dart';
import 'package:store_scope/store_scope.dart';

final tradingHistoryVMProvider = ViewModelProvider<TradingHistoryVM>((space) {
  return TradingHistoryVM(injector());
});

/// 交易历史页面 ViewModel
/// 支持分页加载全部交易历史
class TradingHistoryVM extends ViewModel {
  TradingHistoryVM(this._dataSource);

  final ManicTradeDataSource _dataSource;

  static const int _pageSize = 15;

  int _page = 1;
  bool _hasMore = true;

  /// 是否还有更多数据
  bool get isTheEnd => !_hasMore;

  /// 刷新事件流，页面监听此流触发 loadInitial(true)
  final _refreshController = StreamController<void>.broadcast();

  Stream<void> get onRefresh => _refreshController.stream;

  /// 通知页面刷新数据
  void refresh() {
    _refreshController.add(null);
  }

  @override
  void dispose() {
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
    final response = await _dataSource.getPositionHistory(
      page: _page,
      limit: _pageSize,
    );
    if (response.nodes.length < _pageSize ||
        response.total <= _page * _pageSize) {
      _hasMore = false;
    }
    _page++;
    return response.nodes.where((e) => e.isSettled).toList();
  }
}
