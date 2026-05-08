import 'dart:async';

import 'package:finality/common/utils/value_listenable_removable.dart';
import 'package:finality/core/logger.dart';
import 'package:finality/data/socket/manic_socket_client.dart';
import 'package:finality/domain/options/entities/time_bar.dart';
import 'package:finality/features/highlow/config/high_low_settings_store.dart';
import 'package:finality/features/highlow/utils/timebar_converter.dart';
import 'package:finality/services/app_lifecycle_service.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

/// 共享价格流管理器
/// 管理多个 asset 的 socket 连接，支持引用计数和自动释放
class SharedPriceStreamManager {
  final HighLowSettingsStore _settingsStore;
  final String _baseUrl;
  final AppLifecycleService? _lifecycleService;
  StreamSubscription<void>? _resumeSub;

  /// 连接池，key = asset
  final Map<String, _ManagedConnection> _pool = {};

  SharedPriceStreamManager({
    required HighLowSettingsStore settingsStore,
    required String baseUrl,
    AppLifecycleService? lifecycleService,
  })  : _settingsStore = settingsStore,
        _baseUrl = baseUrl,
        _lifecycleService = lifecycleService {
    // onResumed 对池中每个活跃连接做一次轻量探测：
    // 若在 probeWindow 内没有任何消息/状态变化，判定僵尸连接并强制重连
    _resumeSub = _lifecycleService?.onResumed.listen((_) {
      for (final conn in _pool.values) {
        conn.probeOnResume();
      }
    });
  }

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
        'SharedPrice[$asset] 创建新连接 timeframe=$timeframe',
      );
    } else if (connection.timeframe != timeframe) {
      // 有连接但 timeframe 不同，切换
      logger.d(
        'SharedPrice[$asset] 切换 timeframe '
        '${connection.timeframe} → $timeframe'
        '${connection.refCount <= 0 ? '（复用待释放连接）' : ''}',
      );
      connection.switchTimeframe(timeframe);
    } else {
      logger.d(
        'SharedPrice[$asset] 命中现有连接 timeframe=$timeframe'
        '${connection.refCount <= 0 ? '（复用待释放连接）' : ''}',
      );
    }

    // 引用计数 +1
    connection.retain();

    final subscription = PriceSubscription._(
      priceStream: connection.priceSubject.stream,
      isConnected: connection.isConnected,
      reconnectStream: connection.reconnectStream,
      connectReadyGetter: () => connection!.connectReady,
      requestReconnect: () async {
        if (connection!.isDisposed) return;
        await connection.reconnect();
      },
      onDispose: () {
        // 防护：connection 可能已被 pool 回收并销毁（快速切换 asset 场景）
        if (connection!.isDisposed) {
          logger.d('SharedPrice[$asset] onDispose 跳过：连接已销毁');
          return;
        }
        logger.d('SharedPrice[$asset] PriceSubscription disposed');
        connection.release();
        if (connection.refCount <= 0) {
          // 启动延迟释放
          connection.scheduleRelease(() {
            if (connection!.isDisposed) return;
            if (connection.refCount <= 0) {
              logger.d(
                'SharedPrice[$asset] 延迟释放到期，回收连接',
              );
              connection.dispose();
              _pool.remove(asset);
            } else {
              logger.d(
                'SharedPrice[$asset] 延迟释放取消：refCount=${connection.refCount}',
              );
            }
          });
        }
      },
    );

    return subscription;
  }

  void dispose() {
    _resumeSub?.cancel();
    _resumeSub = null;
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
  ///
  /// 这是一个 getter，每次访问都会获取最新的 Future，
  /// 避免 Completer 被重建后旧 Future 悬空
  Future<int> get connectReady => _connectReadyGetter();
  final Future<int> Function() _connectReadyGetter;

  /// 请求强制重连底层 socket。
  /// 用于业务层显式判定当前连接不可信（如僵尸连接）时触发重建，
  /// 不改变 refCount，也不影响其他订阅者的订阅句柄
  ///
  /// 返回的 Future 在旧连接已 disconnect、新 WebSocket 已创建时完成；
  /// 新连接握手本身是异步的，调用方如需等待握手完成请结合 [connectReady]
  Future<void> requestReconnect() => _requestReconnect();
  final Future<void> Function() _requestReconnect;

  final VoidCallback _onDispose;
  bool _isDisposed = false;

  PriceSubscription._({
    required this.priceStream,
    required this.isConnected,
    required this.reconnectStream,
    required Future<int> Function() connectReadyGetter,
    required Future<void> Function() requestReconnect,
    required VoidCallback onDispose,
  })  : _connectReadyGetter = connectReadyGetter,
        _requestReconnect = requestReconnect,
        _onDispose = onDispose;

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
  bool _isDisposed = false;

  /// switchTimeframe 期间等待新连接首条数据的监听
  StreamSubscription? _switchFirstDataSub;

  /// switchTimeframe 的超时保护 Timer
  Timer? _switchTimeoutTimer;

  /// switchTimeframe 期间累积的待释放旧 client，key 为 timeframe，
  /// 等新连接收到首条数据或超时后统一 dispose，
  /// 切回相同 timeframe 时可从中复用，避免重建连接
  final Map<int, ManicSocketClient> _pendingOldClients = {};

  StreamSubscription? _priceSubscription;
  StreamSubscription? _reconnectSubscription;
  Removable? _isConnectedRemovable;

  /// onResume 探测 Timer
  Timer? _probeTimer;

  /// 是否正在执行强制重连（防止并发触发）
  bool _isReconnecting = false;

  static const _gracePeriod = Duration(seconds: 5);

  /// onResume 探测窗口：窗口内若没有任何新消息且状态未变，判定僵尸连接
  static const _probeWindow = Duration(seconds: 8);

  _ManagedConnection({
    required this.asset,
    required int timeframe,
    required String baseUrl,
  })  : _timeframe = timeframe,
        _baseUrl = baseUrl;

  int get timeframe => _timeframe;
  int get refCount => _refCount;
  bool get isDisposed => _isDisposed;

  String get _tag => 'SharedPrice[$asset]';

  void retain() {
    _refCount++;
    _releaseTimer?.cancel();
    if (_releaseTimer != null) {
      logger.d('$_tag retain refCount=$_refCount，取消延迟释放');
      _releaseTimer = null;
    } else {
      logger.d('$_tag retain refCount=$_refCount');
    }
  }

  void release() {
    assert(_refCount > 0, 'release() called when refCount is already 0');
    _refCount = (_refCount - 1).clamp(0, _refCount);
    logger.d('$_tag release refCount=$_refCount');
  }

  void scheduleRelease(VoidCallback onRelease) {
    _releaseTimer?.cancel();
    _releaseTimer = Timer(_gracePeriod, onRelease);
    logger.d('$_tag 启动延迟释放 (${_gracePeriod.inSeconds}s)');
  }

  /// 连接 socket
  void connect() {
    logger.d('$_tag 建立 socket 连接 timeframe=$_timeframe');
    _socketClient = ManicSocketClient(baseUrl: _baseUrl);
    _socketClient!.connect(asset: asset, timeframe: _timeframe);

    _listenToSocketClient(_socketClient!);
  }

  /// 切换 timeframe：优先复用待释放队列中的旧连接，否则建新连接
  void switchTimeframe(int newTimeframe) {
    final oldTimeframe = _timeframe;
    _timeframe = newTimeframe;

    // 取消上一轮 switchTimeframe 遗留的监听和 Timer
    _cancelSwitchCleanup();

    // 将旧 Completer 链接到新 Completer，确保正在 await 旧 Future 的调用方
    // 不会因为 Completer 被替换而永远挂起
    final oldCompleter = _connectCompleter;
    _connectCompleter = Completer<int>();
    if (!oldCompleter.isCompleted) {
      _connectCompleter.future.then(
        (value) {
          if (!oldCompleter.isCompleted) oldCompleter.complete(value);
        },
        onError: (error) {
          if (!oldCompleter.isCompleted) oldCompleter.completeError(error);
        },
      );
    }

    final oldClient = _socketClient;

    // 先取消对旧 client 的监听
    _cancelSocketListeners();

    // 旧 client 加入待释放队列
    if (oldClient != null) {
      _pendingOldClients[oldTimeframe] = oldClient;
    }

    // 尝试从待释放队列中复用目标 timeframe 的 client
    final reusableClient = _pendingOldClients.remove(newTimeframe);

    final ManicSocketClient activeClient;
    if (reusableClient != null) {
      // 复用旧连接
      logger.d(
        '$_tag 复用待释放连接 timeframe=$newTimeframe，'
        '剩余待释放=${_pendingOldClients.length}',
      );
      activeClient = reusableClient;
    } else {
      // 创建新连接
      logger.d('$_tag 新建连接 timeframe=$newTimeframe，'
          '待释放=${_pendingOldClients.length}');
      activeClient = ManicSocketClient(baseUrl: _baseUrl);
      activeClient.connect(asset: asset, timeframe: newTimeframe);
    }

    _socketClient = activeClient;
    _listenToSocketClient(activeClient);

    // 等活跃连接收到首条数据后，释放队列中所有旧连接
    _switchFirstDataSub = activeClient.priceStream.take(1).listen((_) {
      _disposePendingOldClients();
      _switchFirstDataSub?.cancel();
      _switchFirstDataSub = null;
      _switchTimeoutTimer?.cancel();
      _switchTimeoutTimer = null;
    });

    // 超时保护：如果 10 秒内没收到数据，也释放旧连接
    _switchTimeoutTimer = Timer(const Duration(seconds: 10), () {
      _disposePendingOldClients();
      _switchFirstDataSub?.cancel();
      _switchFirstDataSub = null;
      _switchTimeoutTimer = null;
    });
  }

  /// 取消 switchTimeframe 遗留的监听和 Timer（不释放旧 client）
  void _cancelSwitchCleanup() {
    _switchFirstDataSub?.cancel();
    _switchFirstDataSub = null;
    _switchTimeoutTimer?.cancel();
    _switchTimeoutTimer = null;
    // 切换期间底层 client 会换，此时老 probe 的快照与新 client 无关，直接取消
    _probeTimer?.cancel();
    _probeTimer = null;
  }

  /// 统一释放所有累积的旧 client
  void _disposePendingOldClients() {
    if (_pendingOldClients.isEmpty) return;
    logger.d('$_tag 统一释放 ${_pendingOldClients.length} 个旧连接');
    for (final client in _pendingOldClients.values) {
      client.dispose();
    }
    _pendingOldClients.clear();
  }

  void _listenToSocketClient(ManicSocketClient client) {
    _priceSubscription = client.priceStream.listen((data) {
      if (_isDisposed || priceSubject.isClosed) return;
      priceSubject.add(data);
    });

    _isConnectedRemovable = client.isConnected.listen((connected) {
      if (_isDisposed) return;
      isConnected.value = connected;
      if (connected) {
        if (!_connectCompleter.isCompleted) {
          logger.d('$_tag connectReady 完成');
          _connectCompleter.complete(DateTime.now().millisecondsSinceEpoch);
        }
      } else if (_connectCompleter.isCompleted) {
        // socket 断开后重置 completer，确保下次 subscribe() 拿到的
        // connectReady 会正确等待重连，而不是立刻返回旧时间戳
        logger.d('$_tag 连接断开，重置 connectReady');
        _connectCompleter = Completer<int>();
      }
    }, immediate: true);

    _reconnectSubscription = client.reconnectStream.listen((_) {
      if (!_reconnectController.isClosed) {
        _reconnectController.add(null);
      }
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

  /// 强制重连底层 socket（复用现有的 asset/timeframe、订阅句柄、refCount）
  ///
  /// 触发链：ManicSocketClient.forceReconnect → disconnect 会让 isConnected
  /// 事件流走 false，经由 [_listenToSocketClient] 的监听把本 connection 的
  /// isConnected/connectCompleter 重置；connect 成功后再置 true 并完成 completer
  Future<void> reconnect() async {
    if (_isDisposed || _socketClient == null) return;
    if (_isReconnecting) {
      logger.d('$_tag 已在重连中，忽略重复请求');
      return;
    }
    _isReconnecting = true;
    _probeTimer?.cancel();
    _probeTimer = null;
    try {
      logger.d('$_tag 强制重连底层 socket');
      await _socketClient!.forceReconnect();
    } finally {
      _isReconnecting = false;
    }
  }

  /// 回前台时做一次轻量探测：在 [_probeWindow] 内若没有新消息且没有状态变化，
  /// 判定为僵尸连接，强制重连
  void probeOnResume() {
    if (_isDisposed) return;
    if (_isReconnecting) return;
    // 连接层自己已经知道断开了，交给 backoff 自行恢复
    if (!isConnected.value) return;
    final client = _socketClient;
    if (client == null) return;

    _probeTimer?.cancel();
    final snapshot = client.lastMessageAtMs;
    logger.d('$_tag onResume 启动探测 window=${_probeWindow.inSeconds}s '
        'lastMessageAt=$snapshot');
    _probeTimer = Timer(_probeWindow, () {
      _probeTimer = null;
      if (_isDisposed || _isReconnecting) return;
      // 探测期间已经断开，backoff 会处理
      if (!isConnected.value) return;
      final current = _socketClient?.lastMessageAtMs;
      if (current == snapshot) {
        logger.w('$_tag onResume 探测超时，疑似僵尸连接，强制重连');
        reconnect();
      } else {
        logger.d('$_tag onResume 探测正常 lastMessageAt=$current');
      }
    });
  }

  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    logger.d('$_tag 销毁连接 refCount=$_refCount');
    _releaseTimer?.cancel();
    _releaseTimer = null;
    _probeTimer?.cancel();
    _probeTimer = null;
    _cancelSwitchCleanup();
    _disposePendingOldClients();
    _cancelSocketListeners();
    _socketClient?.dispose();
    _socketClient = null;
    priceSubject.close();
    isConnected.dispose();
    _reconnectController.close();
  }
}
