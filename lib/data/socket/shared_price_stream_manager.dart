import 'dart:async';

import 'package:finality/common/utils/value_listenable_removable.dart';
import 'package:finality/core/logger.dart';
import 'package:finality/data/socket/manic_socket_client.dart';
import 'package:finality/domain/options/entities/time_bar.dart';
import 'package:finality/features/highlow/config/high_low_settings_store.dart';
import 'package:finality/features/highlow/utils/timebar_converter.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

/// 共享价格流管理器
/// 管理多个 asset 的 socket 连接，支持引用计数和自动释放
class SharedPriceStreamManager {
  final HighLowSettingsStore _settingsStore;
  final String _baseUrl;

  /// 连接池，key = asset
  final Map<String, _ManagedConnection> _pool = {};

  SharedPriceStreamManager({
    required HighLowSettingsStore settingsStore,
    required String baseUrl,
  })  : _settingsStore = settingsStore,
        _baseUrl = baseUrl;

  /// 订阅某个 asset 的实时价格
  ///
  /// [asset] 资产标识
  /// [timeBar] 可选，不传则用 HighLowSettingsStore 的默认值；
  ///           传了且和现有连接不同，会触发重连
  PriceSubscription subscribe(String asset, {TimeBar? timeBar}) {
    final requestedTimeBar = timeBar ?? _settingsStore.getHighLowTimeBar();
    final timeframe = TimeBarConverter.toSecondsOrThrow(requestedTimeBar);

    var connection = _pool[asset];

    if (connection == null) {
      // 无连接，创建新的
      connection = _ManagedConnection(
        asset: asset,
        timeframe: timeframe,
        baseUrl: _baseUrl,
      );
      _pool[asset] = connection;
      connection.connect();
      logger.d(
        'SharedPriceStreamManager: 创建新连接 asset=$asset, '
        'timeframe=$timeframe',
      );
    } else if (connection.timeframe != timeframe) {
      // 有连接但 timeframe 不同，重连
      logger.d(
        'SharedPriceStreamManager: 切换 timeframe asset=$asset, '
        '${connection.timeframe} → $timeframe',
      );
      connection.switchTimeframe(timeframe);
    }

    // 引用计数 +1
    connection.retain();

    final subscription = PriceSubscription._(
      priceStream: connection.priceSubject.stream,
      isConnected: connection.isConnected,
      reconnectStream: connection.reconnectStream,
      connectReady: connection.connectReady,
      onDispose: () {
        connection!.release();
        if (connection.refCount <= 0) {
          // 启动延迟释放
          connection.scheduleRelease(() {
            if (connection!.refCount <= 0) {
              logger.d(
                'SharedPriceStreamManager: 释放连接 asset=$asset',
              );
              connection.dispose();
              _pool.remove(asset);
            }
          });
        }
      },
    );

    return subscription;
  }

  void dispose() {
    for (final connection in _pool.values) {
      connection.dispose();
    }
    _pool.clear();
  }
}

/// 订阅句柄，每个消费者持有一个
class PriceSubscription {
  /// 价格数据流
  final Stream<ManicPriceData> priceStream;

  /// 连接是否在线
  final ValueListenable<bool> isConnected;

  /// 重连事件流（给 CandleDataSynchronizer 做断层检测）
  final Stream<void> reconnectStream;

  /// 等待 socket 连接就绪，返回连接建立的时间戳（毫秒）
  /// 如果已连接则立即返回，否则阻塞直到连接成功
  final Future<int> connectReady;

  final VoidCallback _onDispose;
  bool _isDisposed = false;

  PriceSubscription._({
    required this.priceStream,
    required this.isConnected,
    required this.reconnectStream,
    required this.connectReady,
    required VoidCallback onDispose,
  }) : _onDispose = onDispose;

  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    _onDispose();
  }
}

/// 内部类：管理单个 asset 的 socket 连接
class _ManagedConnection {
  final String asset;
  final String _baseUrl;
  int _timeframe;
  ManicSocketClient? _socketClient;

  /// 广播价格数据（BehaviorSubject 保留最新值）
  final BehaviorSubject<ManicPriceData> priceSubject =
      BehaviorSubject<ManicPriceData>();

  final ValueNotifier<bool> isConnected = ValueNotifier(false);

  /// 重连事件流
  final StreamController<void> _reconnectController =
      StreamController<void>.broadcast();
  Stream<void> get reconnectStream => _reconnectController.stream;

  /// 连接就绪 Completer，完成时返回连接建立时间戳（毫秒）
  Completer<int> _connectCompleter = Completer<int>();
  Future<int> get connectReady => _connectCompleter.future;

  int _refCount = 0;
  Timer? _releaseTimer;

  StreamSubscription? _priceSubscription;
  StreamSubscription? _reconnectSubscription;
  Removable? _isConnectedRemovable;

  static const _gracePeriod = Duration(seconds: 5);

  _ManagedConnection({
    required this.asset,
    required int timeframe,
    required String baseUrl,
  })  : _timeframe = timeframe,
        _baseUrl = baseUrl;

  int get timeframe => _timeframe;
  int get refCount => _refCount;

  void retain() {
    _refCount++;
    _releaseTimer?.cancel();
    _releaseTimer = null;
  }

  void release() {
    _refCount--;
  }

  void scheduleRelease(VoidCallback onRelease) {
    _releaseTimer?.cancel();
    _releaseTimer = Timer(_gracePeriod, onRelease);
  }

  /// 连接 socket
  void connect() {
    _socketClient = ManicSocketClient(baseUrl: _baseUrl);
    _socketClient!.connect(asset: asset, timeframe: _timeframe);

    _listenToSocketClient(_socketClient!);
  }

  /// 切换 timeframe：建新连接 → 新连接收到第一条数据后切流 → 释放旧连接
  void switchTimeframe(int newTimeframe) {
    _timeframe = newTimeframe;
    _connectCompleter = Completer<int>();

    final oldClient = _socketClient;

    // 先取消对旧 client 的监听
    _cancelSocketListeners();

    // 创建新 client 并连接
    final newClient = ManicSocketClient(baseUrl: _baseUrl);
    _socketClient = newClient;

    newClient.connect(asset: asset, timeframe: newTimeframe);
    _listenToSocketClient(newClient);

    // 等新连接收到第一条数据后，释放旧连接
    late StreamSubscription firstDataSub;
    firstDataSub = newClient.priceStream.take(1).listen((_) {
      oldClient?.dispose();
      firstDataSub.cancel();
    });

    // 超时保护：如果 10 秒内新连接没数据，也释放旧连接
    Timer(const Duration(seconds: 10), () {
      firstDataSub.cancel();
      oldClient?.dispose();
    });
  }

  void _listenToSocketClient(ManicSocketClient client) {
    _priceSubscription = client.priceStream.listen((data) {
      priceSubject.add(data);
    });

    _isConnectedRemovable = client.isConnected.listen((connected) {
      isConnected.value = connected;
      if (connected) {
        if (!_connectCompleter.isCompleted) {
          _connectCompleter.complete(DateTime.now().millisecondsSinceEpoch);
        }
      } else if (_connectCompleter.isCompleted) {
        // socket 断开后重置 completer，确保下次 subscribe() 拿到的
        // connectReady 会正确等待重连，而不是立刻返回旧时间戳
        _connectCompleter = Completer<int>();
      }
    }, immediate: true);

    _reconnectSubscription = client.reconnectStream.listen((_) {
      _reconnectController.add(null);
    });
  }

  void _cancelSocketListeners() {
    _priceSubscription?.cancel();
    _priceSubscription = null;
    _isConnectedRemovable?.remove();
    _isConnectedRemovable = null;
    _reconnectSubscription?.cancel();
    _reconnectSubscription = null;
  }

  void dispose() {
    _releaseTimer?.cancel();
    _releaseTimer = null;
    _cancelSocketListeners();
    _socketClient?.dispose();
    _socketClient = null;
    priceSubject.close();
    isConnected.dispose();
    _reconnectController.close();
  }
}
