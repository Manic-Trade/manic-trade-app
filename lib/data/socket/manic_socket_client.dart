import 'dart:async';
import 'dart:convert';

import 'package:finality/core/logger.dart';
import 'package:finality/data/socket/manic/manic_price_data.dart';
import 'package:flutter/foundation.dart';
import 'package:web_socket_client/web_socket_client.dart';

export 'package:finality/data/socket/manic/manic_price_data.dart';

/// Manic WebSocket 客户端，用于获取实时价格数据
class ManicSocketClient {
  ManicSocketClient({
    required this.baseUrl,
    this.defaultTimeframe = 5,
  });

  final String baseUrl;
  final int defaultTimeframe;

  WebSocket? _socket;
  StreamSubscription? _messageSubscription;
  StreamSubscription? _connectionSubscription;

  final ValueNotifier<bool> isConnected = ValueNotifier(false);

  /// 断开重连事件流，当发生断开重连时会发出事件
  /// 用于通知外部数据可能存在断层，需要重新加载
  final StreamController<void> _reconnectController =
      StreamController<void>.broadcast();

  /// 断开重连事件流
  Stream<void> get reconnectStream => _reconnectController.stream;

  /// 记录是否发生过断开（用于检测重连后的断层）
  bool _hasDisconnected = false;

  bool _disposed = false;

  // 当前订阅的参数
  String? _currentAsset;
  int? _currentTimeframe;

  // 价格数据流
  final StreamController<ManicPriceData> _priceController =
      StreamController<ManicPriceData>.broadcast();

  // 原始消息流（用于调试）
  final StreamController<String> _rawMessageController =
      StreamController<String>.broadcast();

  /// 价格数据流
  Stream<ManicPriceData> get priceStream => _priceController.stream;

  /// 原始消息流
  Stream<String> get rawMessageStream => _rawMessageController.stream;

  /// 当前资产
  String? get currentAsset => _currentAsset;

  /// 当前时间周期
  int? get currentTimeframe => _currentTimeframe;

  /// 构建 WebSocket URL
  Uri _buildUri(String asset, int timeframe) {
    // 将 https 替换为 wss
    final wsBaseUrl = baseUrl
        .replaceFirst('https://', 'wss://')
        .replaceFirst('http://', 'ws://');
    return Uri.parse(
        '$wsBaseUrl/charts/price?asset=$asset&timeframe=$timeframe');
  }

  /// 连接到 WebSocket
  Future<void> connect({
    required String asset,
    int? timeframe,
  }) async {
    // 如果已连接且参数相同，直接返回
    if (isConnected.value &&
        _currentAsset == asset &&
        _currentTimeframe == (timeframe ?? defaultTimeframe)) {
      logger.d('ManicSocketClient: 已连接到相同的资产');
      return;
    }

    // 如果已连接但参数不同，先断开
    if (_socket != null) {
      await disconnect();
    }

    _currentAsset = asset;
    _currentTimeframe = timeframe ?? defaultTimeframe;

    final uri = _buildUri(asset, _currentTimeframe!);
    logger.d('ManicSocketClient: 正在连接到 $uri');

    // 使用 BinaryExponentialBackoff 策略进行自动重连
    _socket = WebSocket(
      uri,
      backoff: BinaryExponentialBackoff(
        initial: const Duration(seconds: 1),
        maximumStep: 5,
      ),
      timeout: const Duration(seconds: 30),
    );

    // 监听连接状态
    _connectionSubscription = _socket!.connection.listen((state) {
      logger.d('ManicSocketClient: 连接状态变化 -> $state');

      if (state is Connected) {
        isConnected.value = true;
        // 首次连接，重置断开标记
        _hasDisconnected = false;
      } else if (state is Reconnected) {
        isConnected.value = true;
        // 重连成功，如果之前断开过，发出重连事件通知数据可能有断层
        if (_hasDisconnected) {
          logger.d('ManicSocketClient: 重连成功，通知数据可能有断层');
          _reconnectController.add(null);
          _hasDisconnected = false;
        }
      } else if (state is Disconnected) {
        isConnected.value = false;
        _hasDisconnected = true;
        if (state.error != null) {
          logger.e('ManicSocketClient: 连接断开，错误: ${state.error}');
        }
      } else if (state is Reconnecting) {
        isConnected.value = false;
        _hasDisconnected = true;
        logger.d('ManicSocketClient: 正在重连...');
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
          final priceData = ManicPriceData.fromJson(json);
          _priceController.add(priceData);
          //logger.d('ManicSocketClient: 收到价格数据 $priceData');
        } else if (json is List) {
          // 如果是数组，处理每个元素
          for (final item in json) {
            if (item is Map<String, dynamic>) {
              final priceData = ManicPriceData.fromJson(item);
              _priceController.add(priceData);
            }
          }
        }
      } catch (e) {
        // logger.w('ManicSocketClient: 解析消息失败: $data, error: $e');
      }
    } else if (data is List<int>) {
      // 将字节数组转换为 UTF-8 字符串
      final stringData = utf8.decode(data);

      // 递归调用处理转换后的字符串
      _onMessage(stringData);
    } else {
      logger.d('ManicSocketClient: 收到未知类型消息: ${data.runtimeType}');
    }
  }

  /// 发送消息
  void send(dynamic data) {
    if (_socket != null && isConnected.value) {
      _socket!.send(data);
    } else {
      logger.w('ManicSocketClient: 未连接，无法发送消息');
    }
  }

  /// 切换资产
  Future<void> switchAsset(String asset, {int? timeframe}) async {
    await connect(asset: asset, timeframe: timeframe ?? _currentTimeframe);
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
    logger.d('ManicSocketClient: 已断开连接');
  }

  /// 销毁客户端
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    await disconnect();
    await _priceController.close();
    await _rawMessageController.close();
    await _reconnectController.close();
    isConnected.dispose();
    logger.d('ManicSocketClient: 已销毁');
  }
}
