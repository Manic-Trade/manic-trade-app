import 'dart:async';
import 'dart:convert';

import 'package:finality/core/logger.dart';
import 'package:finality/data/socket/manic/game_status.dart';
import 'package:flutter/foundation.dart';
import 'package:web_socket_client/web_socket_client.dart';

export 'package:finality/data/socket/manic/game_status.dart';

/// Game Status WebSocket 客户端，用于接收用户仓位状态事件
class GameStatusSocketClient {
  GameStatusSocketClient({
    required this.baseUrl,
  });

  final String baseUrl;

  WebSocket? _socket;
  StreamSubscription? _messageSubscription;
  StreamSubscription? _connectionSubscription;

  final ValueNotifier<bool> isConnected = ValueNotifier(false);

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
    // 如果已连接且参数相同，直接返回
    if (isConnected.value && _currentAddress == address) {
      logger.d('GameStatusSocketClient: 已连接到相同的地址');
      return;
    }

    // 如果已连接但参数不同，先断开
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
      pingInterval: const Duration(seconds: 10),
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
    if (_socket != null && isConnected.value) {
      _socket!.send(data);
    } else {
      logger.w('GameStatusSocketClient: 未连接，无法发送消息');
    }
  }

  /// 切换用户地址
  Future<void> switchAddress(String address) async {
    await connect(address: address);
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
    await disconnect();
    await _eventController.close();
    await _rawMessageController.close();
    isConnected.dispose();
    logger.d('GameStatusSocketClient: 已销毁');
  }
}
