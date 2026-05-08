class SettleTimeUtils {
  /// Batch 下单兜底 buffer：lastBeat 与服务端 server_now 之间存在网络延迟 δ，
  /// 服务端校验 `end_time - server_now ≥ 60s`，若 lastBeat 落在整分钟附近，
  /// 不加 buffer 会出现 settle - lastBeat = 60，δ > 0 即被判 too close。
  static const int _safetyBufferSeconds = 3;

  /// 计算下一个可用的结算时间（向上取整到下一个整分钟）
  ///
  /// 参数：
  /// - lastBeatSecond：上次心跳的时间戳（秒）
  /// - seconds：持仓时长（秒）
  ///
  /// 返回：
  /// - 下一个可用的结算时间（DateTime）
  ///
  /// 逻辑：先加上持仓时长 + buffer，然后向上取整到下一个整分钟。
  /// buffer 用于规避 server_now > lastBeat 时被服务端判 `end_time too close`。
  /// 例如：当前时间 14:35:30，m1(1分钟) -> 14:35:30 + 65s = 14:36:35 -> 向上取整到 14:37:00
  /// 例如：当前时间 14:35:30，m2(2分钟) -> 14:35:30 + 125s = 14:37:35 -> 向上取整到 14:38:00
  /// 例如：当前时间 14:35:30，m3(3分钟) -> 14:35:30 + 185s = 14:38:35 -> 向上取整到 14:39:00
  static DateTime calculateSettleTimeBySeconds(
      int lastBeatSecond, int seconds) {
    final totalSeconds = lastBeatSecond + seconds + _safetyBufferSeconds;
    final minutes = (totalSeconds / 60).ceil();
    final roundedSeconds = minutes * 60;
    return DateTime.fromMillisecondsSinceEpoch(roundedSeconds * 1000);
  }

  /// 格式化结算时间
  ///
  /// 参数：
  /// - settleTime：结算时间（DateTime）
  ///
  /// 返回：
  /// - 格式化后的结算时间（String）
  ///
  /// 例如：14:35:30 -> 14:35
  static String formatSettleTime(DateTime settleTime) {
    return '${settleTime.hour.toString().padLeft(2, '0')}:${settleTime.minute.toString().padLeft(2, '0')}';
  }
}
