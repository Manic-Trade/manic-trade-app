import 'dart:async';

import 'package:finality/core/logger.dart';
import 'package:finality/data/network/manic_price_data_source.dart';
import 'package:finality/domain/premium/entities/market_account.dart';
import 'package:finality/domain/premium/mappers/market_account_mapper.dart';
import 'package:rxdart/rxdart.dart';

/// MarketAccount 实时数据管理器
///
/// 按 asset (如 "SOL", "BTC") 维度管理轮询：
/// - 有订阅者时自动启动轮询
/// - 无订阅者时自动停止轮询，保留最后一次缓存值
/// - 新订阅者立即收到缓存值
class RealtimeMarketAccountTransport {
  final ManicPriceDataSource _dataSource;
  final Duration _pollingInterval;

  final Map<String, _ManagedMarketAccount> _managed = {};

  RealtimeMarketAccountTransport(
    this._dataSource, {
    Duration pollingInterval = const Duration(seconds: 10),
  }) : _pollingInterval = pollingInterval;

  /// 订阅指定 asset 的 MarketAccount 实时数据流
  ///
  /// 返回的 Stream:
  /// - 如果有缓存值，立即发出
  /// - 之后每隔 [_pollingInterval] 发出最新值
  /// - 取消订阅后，如果没有其他订阅者，自动停止轮询
  Stream<MarketAccount> subscribe(String asset) {
    final managed = _managed.putIfAbsent(
      asset,
      () => _ManagedMarketAccount(asset: asset),
    );

    late final StreamController<MarketAccount> controller;
    late StreamSubscription<MarketAccount> innerSub;
    controller = StreamController<MarketAccount>(
      onListen: () {
        managed.retain(() => _startPolling(asset));
        innerSub = managed.subject.stream.listen(
          controller.add,
          onError: controller.addError,
        );
      },
      onCancel: () {
        innerSub.cancel();
        managed.release(() => _stopPolling(asset));
        controller.close();
      },
    );

    return controller.stream;
  }

  /// 获取缓存的最新值（不触发订阅）
  MarketAccount? getLastValue(String asset) {
    return _managed[asset]?.subject.valueOrNull;
  }

  void _startPolling(String asset) {
    logger.d('RealtimeMarketAccountTransport: start polling for $asset');
    final managed = _managed[asset];
    if (managed == null) return;

    // 立即拉取一次最新数据
    _fetchAndUpdate(asset);

    managed.timer?.cancel();
    managed.timer = Timer.periodic(_pollingInterval, (_) {
      _fetchAndUpdate(asset);
    });
  }

  void _stopPolling(String asset) {
    logger.d('RealtimeMarketAccountTransport: stop polling for $asset');
    final managed = _managed[asset];
    if (managed == null) return;
    managed.timer?.cancel();
    managed.timer = null;
  }

  Future<void> _fetchAndUpdate(String asset) async {
    final managed = _managed[asset];
    if (managed == null || managed.isFetching) return;

    managed.isFetching = true;
    try {
      final response = await _dataSource.getAssetMarketAccount(asset);
      final account = response.toMarketAccount();
      managed.subject.add(account);
    } catch (e) {
      logger.w(
        'RealtimeMarketAccountTransport: fetch failed for $asset',
        error: e,
      );
    } finally {
      managed.isFetching = false;
    }
  }

  void dispose() {
    for (final managed in _managed.values) {
      managed.timer?.cancel();
      if (!managed.subject.isClosed) {
        managed.subject.close();
      }
    }
    _managed.clear();
  }
}

class _ManagedMarketAccount {
  final String asset;
  final BehaviorSubject<MarketAccount> subject =
      BehaviorSubject<MarketAccount>();
  int _refCount = 0;
  Timer? timer;
  bool isFetching = false;

  _ManagedMarketAccount({required this.asset});

  void retain(void Function() onFirstSubscriber) {
    _refCount++;
    if (_refCount == 1) {
      onFirstSubscriber();
    }
  }

  void release(void Function() onLastUnsubscriber) {
    _refCount--;
    if (_refCount <= 0) {
      _refCount = 0;
      onLastUnsubscriber();
    }
  }
}
