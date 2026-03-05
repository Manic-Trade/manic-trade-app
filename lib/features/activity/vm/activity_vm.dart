import 'package:finality/data/network/manic_trade_data_source.dart';
import 'package:finality/di/injector.dart';
import 'package:finality/features/activity/model/activity_item.dart';
import 'package:store_scope/store_scope.dart';

final activityVMProvider = ViewModelProvider<ActivityVM>((space) {
  return ActivityVM(injector());
});

/// Activity 页面数据源状态
class _DataSourceState {
  int page = 1;
  bool hasMore = true;
}

class ActivityVM extends ViewModel {
  final ManicTradeDataSource _dataSource;

  ActivityVM(this._dataSource);

  static const int _pageSize = 20;

  /// 三个数据源的分页状态
  final _positionState = _DataSourceState();
  final _depositState = _DataSourceState();
  final _withdrawState = _DataSourceState();

  /// 是否所有数据源都没有更多数据了
  bool get isTheEnd =>
      !_positionState.hasMore &&
      !_depositState.hasMore &&
      !_withdrawState.hasMore;

  /// 重置所有状态
  void _resetStates() {
    _positionState.page = 1;
    _positionState.hasMore = true;
    _depositState.page = 1;
    _depositState.hasMore = true;
    _withdrawState.page = 1;
    _withdrawState.hasMore = true;
  }

  /// 加载初始数据
  Future<List<ActivityItem>> loadInitial(bool isRefresh) async {
    if (isRefresh) {
      _resetStates();
    }
    return _loadFromAllSources();
  }

  /// 加载更多数据
  Future<List<ActivityItem>> loadMore() async {
    if (isTheEnd) return [];
    return _loadFromAllSources();
  }

  /// 从所有数据源加载数据
  Future<List<ActivityItem>> _loadFromAllSources() async {
    final List<ActivityItem> allItems = [];

    // 并行请求三个接口
    final results = await Future.wait([
      _loadPositionHistory(),
      _loadDeposits(),
      _loadWithdraws(),
    ]);

    for (final items in results) {
      allItems.addAll(items);
    }

    // 按时间降序排序
    allItems.sort((a, b) => b.time.compareTo(a.time));

    return allItems;
  }

  /// 加载交易历史
  Future<List<ActivityItem>> _loadPositionHistory() async {
    if (!_positionState.hasMore) return [];

    try {
      final response = await _dataSource.getPositionHistory(
        page: _positionState.page,
        limit: _pageSize,
      );

      // 更新分页状态
      if (response.nodes.length < _pageSize) {
        _positionState.hasMore = false;
      } else {
        _positionState.page++;
      }

      // 将每条交易记录拆分为开仓和结算两条
      final List<ActivityItem> items = [];
      for (final item in response.nodes) {
        items.add(OpenPositionActivityItem(item));
        if (item.isSettled) {
          items.add(SettlePositionActivityItem(item));
        }
      }
      return items;
    } catch (e) {
      _positionState.hasMore = false;
      return [];
    }
  }

  /// 加载充值历史
  Future<List<ActivityItem>> _loadDeposits() async {
    if (!_depositState.hasMore) return [];

    try {
      final response = await _dataSource.getDeposits(
        page: _depositState.page,
        limit: _pageSize,
      );

      // 更新分页状态
      if (response.nodes.length < _pageSize) {
        _depositState.hasMore = false;
      } else {
        _depositState.page++;
      }

      return response.nodes.map((e) => DepositActivityItem(e)).toList();
    } catch (e) {
      _depositState.hasMore = false;
      return [];
    }
  }

  /// 加载提现历史
  Future<List<ActivityItem>> _loadWithdraws() async {
    if (!_withdrawState.hasMore) return [];

    try {
      final response = await _dataSource.getWithdraws(
        page: _withdrawState.page,
        limit: _pageSize,
      );

      // 更新分页状态
      if (response.nodes.length < _pageSize) {
        _withdrawState.hasMore = false;
      } else {
        _withdrawState.page++;
      }

      return response.nodes.map((e) => WithdrawActivityItem(e)).toList();
    } catch (e) {
      _withdrawState.hasMore = false;
      return [];
    }
  }
}
