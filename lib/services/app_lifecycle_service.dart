import 'dart:async';

import 'package:flutter/widgets.dart';

/// 应用生命周期服务：把 [WidgetsBindingObserver] 封装成可注入的单例，
/// 让业务层（ViewModel / Service）订阅 app 前后台切换事件时无需依赖 widget 框架。
class AppLifecycleService with WidgetsBindingObserver {
  AppLifecycleService() {
    WidgetsBinding.instance.addObserver(this);
    _current =
        WidgetsBinding.instance.lifecycleState ?? AppLifecycleState.resumed;
  }

  final StreamController<AppLifecycleState> _controller =
      StreamController<AppLifecycleState>.broadcast();

  late AppLifecycleState _current;

  /// 当前生命周期状态
  AppLifecycleState get currentState => _current;

  /// 生命周期状态变化事件流（仅在状态真正变化时发出）
  Stream<AppLifecycleState> get onStateChange => _controller.stream;

  /// 便捷：应用进入前台的事件流
  Stream<void> get onResumed =>
      onStateChange.where((s) => s == AppLifecycleState.resumed).map((_) {});

  /// 便捷：应用进入后台的事件流（paused / hidden / inactive / detached 统一为一个信号）
  Stream<void> get onBackgrounded =>
      onStateChange.where((s) => s != AppLifecycleState.resumed).map((_) {});

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 去重：部分平台/场景会重复回调同一状态
    if (_current == state) return;
    _current = state;
    _controller.add(state);
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.close();
  }
}
