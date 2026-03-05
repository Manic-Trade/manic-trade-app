import 'dart:async';
import 'package:flutter/foundation.dart';

/// 倒计时 ValueNotifier
/// 传入结束时间戳（秒），自动计算剩余秒数
class CountdownNotifier extends ValueNotifier<int> {
  /// 结束时间戳（秒）
  final int endTime;

  Timer? _timer;

  /// 创建倒计时通知器
  /// [endTime] 结束时间戳（秒）
  CountdownNotifier(this.endTime) : super(0) {
    _updateRemaining();
    _startTimer();
  }

  /// 开始倒计时定时器
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateRemaining();
    });
  }

  /// 更新剩余时间
  void _updateRemaining() {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final remaining = endTime - now;
    value = remaining > 0 ? remaining : 0;

    // 如果倒计时结束，取消定时器
    if (remaining <= 0) {
      _timer?.cancel();
    }
  }

  /// 格式化为 MM:SS 格式
  String get formattedTime {
    if (value <= 0) return '00:00';
    final minutes = value ~/ 60;
    final seconds = value % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// 是否紧急（剩余时间 ≤ 5 秒）
  bool get isUrgent => value <= 5 && value > 0;

  /// 是否已结束
  bool get isExpired => value <= 0;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
