import 'dart:async';
import 'dart:convert';

import 'package:finality/core/logger.dart';
import 'package:finality/data/socket/manic/game_status.dart';
import 'package:finality/services/app_lifecycle_service.dart';
import 'package:flutter/foundation.dart';
import 'package:web_socket_client/web_socket_client.dart';

export 'package:finality/data/socket/manic/game_status.dart';

/// Game Status WebSocket 客户端，用于接收用户仓位状态事件
class GameStatusSocketClient {
  GameStatusSocketClient({
    required this.baseUrl,
    AppLifecycleService? lifecycleService,
  }) : _lifecycleService = lifecycleService {
    // 回前台僵尸兜底：游戏状态消息稀疏（仅开仓/结算），无法用"窗口内无消息"
    // 作为活性判据。这里改为按后台时长判定：后台超过阈值就直接强制重连
    _backgroundedSub = _lifecycleService?.onBackgrounded
        .listen((_) => _backgroundedAt ??= DateTime.now());
    _resumedSub = _lifecycleService?.onResumed.listen((_) {
      final backgroundedAt = _backgroundedAt;
      _backgroundedAt = null;
      if (_currentAddress == null) return;
      // 权威源直接读 _socket.connection.state，绕开 isConnected.value
      // 这个 ValueNotifier 只是事件回调的快照，事件丢失/冻结时会过期
      final state = _socket?.connection.state;
      final isHealthy = state is Connected || state is Reconnected;
      if (!isHealthy) {
        logger.d(
          'GameStatusSocketClient: 回前台底层状态=$state，立即强制重连',
        );
        forceReconnect();
        return;
      }
      // 底层报告在线：可能是真在线，也可能是僵尸。用后台时长作为僵尸风险判据
      if (backgroundedAt == null) return;
      final elapsed = DateTime.now().difference(backgroundedAt);
      if (elapsed < _forceReconnectThreshold) return;
      logger.d(
        'GameStatusSocketClient: 后台 ${elapsed.inSeconds}s，强制重连规避僵尸',
      );
      forceReconnect();
    });
  }

  final String baseUrl;
  final AppLifecycleService? _lifecycleService;
  StreamSubscription<void>? _backgroundedSub;
  StreamSubscription<void>? _resumedSub;
  DateTime? _backgroundedAt;

  WebSocket? _socket;
  StreamSubscription? _messageSubscription;
  StreamSubscription? _connectionSubscription;

  final ValueNotifier<bool> isConnected = ValueNotifier(false);

  /// 是否正在执行强制重连（防止并发触发）
  bool _isReconnecting = false;

  bool _disposed = false;

  /// 后台超过该阈值时，回前台直接强制重连
  static const _forceReconnectThreshold = Duration(seconds: 15);

  // 当前订阅的用户地址
  String? _currentAddress;

  // 游戏状态事件流
  final StreamController<GameStatusEvent> _eventController =
      StreamController<GameStatusEvent>.broadcast();

  // 原始消息流（用于调试）
  final StreamController<String> _rawMessageController =
      StreamController<String>.broadcast();

  /// 游戏状态事件流
  Stream<GameStatusEvent> get eventStream => _eventController.stream;

  /// 原始消息流
  Stream<String> get rawMessageStream => _rawMessageController.stream;

  /// 当前订阅的用户地址
  String? get currentAddress => _currentAddress;

  /// 构建 WebSocket URL
  Uri _buildUri(String address) {
    // 将 https 替换为 wss
    final wsBaseUrl = baseUrl
        .replaceFirst('https://', 'wss://')
        .replaceFirst('http://', 'ws://');
    return Uri.parse('$wsBaseUrl/users/game-status?address=$address');
  }

  /// 连接到 WebSocket
  Future<void> connect({
    required String address,
  }) async {
    // 权威源读 _socket.connection.state，避免依赖 isConnected.value 的回调快照
    // 防止僵尸连接场景下误判"已连接"而短路
    final state = _socket?.connection.state;
    final isHealthy = state is Connected || state is Reconnected;
    if (isHealthy && isConnected.value && _currentAddress == address) {
      logger.d('GameStatusSocketClient: 已连接到相同的地址');
      return;
    }

    // 已有 socket（无论是否健康）都先断开，避免资源泄漏
    if (_socket != null) {
      await disconnect();
    }

    _currentAddress = address;

    final uri = _buildUri(address);
    logger.d('GameStatusSocketClient: 正在连接到 $uri');

    // 使用 BinaryExponentialBackoff 策略进行自动重连
    _socket = WebSocket(
      uri,
      backoff: BinaryExponentialBackoff(
        initial: const Duration(seconds: 1),
        maximumStep: 5,
      ),
      pingInterval: const Duration(seconds: 8),
      timeout: const Duration(seconds: 30),
    );

    // 监听连接状态
    _connectionSubscription = _socket!.connection.listen((state) {
      logger.d('GameStatusSocketClient: 连接状态变化 -> $state');

      if (state is Connected || state is Reconnected) {
        isConnected.value = true;
      } else if (state is Disconnected) {
        isConnected.value = false;
        if (state.error != null) {
          logger.e('GameStatusSocketClient: 连接断开，错误: ${state.error}');
        }
      } else if (state is Reconnecting) {
        isConnected.value = false;
        logger.d('GameStatusSocketClient: 正在重连...');
      }
    });

    // 监听消息
    _messageSubscription = _socket!.messages.listen(_onMessage);
  }

  /// 处理接收到的消息
  void _onMessage(dynamic data) {
    if (data is String) {
      _rawMessageController.add(data);

      try {
        final json = jsonDecode(data);
        if (json is Map<String, dynamic>) {
          final event = GameStatusEvent.fromJson(json);
          _eventController.add(event);
          logger.d('GameStatusSocketClient: 收到事件 flag=${event.flag}');
        }
      } catch (e) {
        logger.w('GameStatusSocketClient: 解析消息失败: $data, error: $e');
      }
    } else if (data is List<int>) {
      // 将字节数组转换为 UTF-8 字符串
      final stringData = utf8.decode(data);

      // 递归调用处理转换后的字符串
      _onMessage(stringData);
    } else {
      logger.d('GameStatusSocketClient: 收到未知类型消息: ${data.runtimeType}');
    }
  }

  /// 发送消息
  void send(dynamic data) {
    final socket = _socket;
    final state = socket?.connection.state;
    final isHealthy = state is Connected || state is Reconnected;
    if (socket != null && isHealthy) {
      socket.send(data);
    } else {
      logger.w('GameStatusSocketClient: 未连接，无法发送消息');
    }
  }

  /// 切换用户地址
  Future<void> switchAddress(String address) async {
    await connect(address: address);
  }

  /// 强制重连：先断开再用当前 address 重新连接
  /// 用于僵尸连接场景，绕过 connect() 的已连接短路
  Future<void> forceReconnect() async {
    if (_disposed || _isReconnecting) return;
    // disconnect() 内部会把 _currentAddress 置 null，必须先保存
    final address = _currentAddress;
    if (address == null) return;
    _isReconnecting = true;
    try {
      logger.d('GameStatusSocketClient: 强制重连 address=$address');
      await disconnect();
      if (_disposed) return;
      await connect(address: address);
    } finally {
      _isReconnecting = false;
    }
  }

  /// 断开连接
  Future<void> disconnect() async {
    await _messageSubscription?.cancel();
    _messageSubscription = null;

    await _connectionSubscription?.cancel();
    _connectionSubscription = null;

    _socket?.close();
    _socket = null;

    isConnected.value = false;
    _currentAddress = null;
    logger.d('GameStatusSocketClient: 已断开连接');
  }

  /// 销毁客户端
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    _backgroundedSub?.cancel();
    _backgroundedSub = null;
    _resumedSub?.cancel();
    _resumedSub = null;
    await disconnect();
    await _eventController.close();
    await _rawMessageController.close();
    isConnected.dispose();
    logger.d('GameStatusSocketClient: 已销毁');
  }
}
