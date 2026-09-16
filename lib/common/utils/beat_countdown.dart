import 'dart:async';

import 'package:flutter/foundation.dart';

/// 基于服务器 beat 校准的高精度倒计时
///
/// 原理（对齐 web 端）：
/// 1. 用服务器 beat 算出剩余整数秒作为锚点
/// 2. 仅当剩余整数秒变化时才重新校准（避免抖动）
/// 3. 用本地时钟的相对差值从锚点平滑递减（毫秒级精度）
///
/// 用法：
/// ```dart
/// final countdown = BeatCountdown(
///   endTime: position.endTime,
///   beat: beatNotifier,
/// )..start();
///
/// // 监听剩余毫秒数
/// ValueListenableBuilder(
///   valueListenable: countdown.remainingMs,
///   builder: (_, ms, __) => Text(ms.toString()),
/// );
///
/// // 用完记得 dispose
/// countdown.dispose();
/// ```
class BeatCountdown {
  /// 结束时间戳（秒）
  final int endTime;

  /// 服务器 beat 时间戳（秒），通过 ValueListenable 持续更新
  final ValueListenable<int?> beat;

  /// 剩余毫秒数（对外暴露的可监听值）
  final ValueNotifier<int> _remainingMs = ValueNotifier(0);

  /// 锚点：校准时的剩余秒数（整数）
  int _anchorRemainingSec = 0;

  /// 锚点：校准时的本地时间戳（毫秒）
  int _anchorLocalMs = 0;

  /// 上次校准的剩余秒数，只在整数变化时才重新校准
  int _lastRemainingSec = -1;

  Timer? _timer;

  BeatCountdown({
    required this.endTime,
    required this.beat,
  });

  /// 启动倒计时
  void start() {
    _calibrate();
    beat.addListener(_onBeatUpdated);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 30), (_) {
      _updateDisplay();
    });
    _updateDisplay();
  }

  /// beat 更新时，仅剩余秒数整数变化才重新校准
  void _onBeatUpdated() {
    final b = beat.value;
    if (b == null || b <= 0) return;
    final remainingSec = endTime - b;
    if (remainingSec != _lastRemainingSec) {
      _lastRemainingSec = remainingSec;
      _anchorRemainingSec = remainingSec > 0 ? remainingSec : 0;
      _anchorLocalMs = DateTime.now().millisecondsSinceEpoch;
    }
  }

  /// 初始校准，beat 为 0 时 fallback 到本地时间
  void _calibrate() {
    final b = beat.value;
    if (b != null && b > 0) {
      final remainingSec = endTime - b;
      _anchorRemainingSec = remainingSec > 0 ? remainingSec : 0;
      _lastRemainingSec = remainingSec;
    } else {
      final remainingMs =
          endTime * 1000 - DateTime.now().millisecondsSinceEpoch;
      _anchorRemainingSec = remainingMs > 0 ? (remainingMs / 1000).ceil() : 0;
      _lastRemainingSec = _anchorRemainingSec;
    }
    _anchorLocalMs = DateTime.now().millisecondsSinceEpoch;
  }

  /// 从锚点平滑递减
  void _updateDisplay() {
    final elapsed = DateTime.now().millisecondsSinceEpoch - _anchorLocalMs;
    final remaining = _anchorRemainingSec * 1000 - elapsed;
    _remainingMs.value = remaining > 0 ? remaining : 0;
    if (remaining <= 0) {
      _timer?.cancel();
    }
  }

  ValueListenable<int> get remainingMs => _remainingMs;

  void dispose() {
    beat.removeListener(_onBeatUpdated);
    _timer?.cancel();
    _remainingMs.dispose();
  }
}
