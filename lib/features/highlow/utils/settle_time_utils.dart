class SettleTimeUtils {
  /// 计算下一个可用的结算时间（向上取整到下一个整分钟）
  ///
  /// 参数：
  /// - lastBeatSecond：上次心跳的时间戳（秒）
  /// - seconds：持仓时长（秒）
  ///
  /// 返回：
  /// - 下一个可用的结算时间（DateTime）
  ///
  /// 逻辑：先加上持仓时长，然后向上取整到下一个整分钟（或整分钟间隔）
  /// 例如：当前时间 14:35:30，m1(1分钟) -> 14:35:30 + 1分钟 = 14:36:30 -> 向上取整到 14:37:00
  /// 例如：当前时间 14:35:30，m2(2分钟) -> 14:35:30 + 2分钟 = 14:37:30 -> 向上取整到 14:38:00
  /// 例如：当前时间 14:35:30，m3(3分钟) -> 14:35:30 + 3分钟 = 14:38:30 -> 向上取整到 14:39:00
  static DateTime calculateSettleTimeBySeconds(
      int lastBeatSecond, int seconds) {
    final totalSeconds = lastBeatSecond + seconds;
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
