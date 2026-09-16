import 'package:finality/domain/options/entities/time_bar.dart';

/// TimeBar 和 Timeframe（秒）之间的转换工具
class TimeBarConverter {
  TimeBarConverter._();

  /// TimeBar 到 Timeframe（秒）的映射
  static const Map<TimeBar, int> _timeBarToSeconds = {
    TimeBar.s1: 1,
    TimeBar.s5: 5,
    TimeBar.s15: 15,
    TimeBar.s30: 30,
    TimeBar.m1: 60,
    TimeBar.m5: 300,
    TimeBar.m15: 900,
    TimeBar.m30: 1800,
    TimeBar.H1: 3600,
    TimeBar.H3: 10800,
    TimeBar.H12: 43200,
    TimeBar.D1: 86400,
  };

  /// Timeframe（秒）到 TimeBar 的映射
  static final Map<int, TimeBar> _secondsToTimeBar = {
    for (final entry in _timeBarToSeconds.entries) entry.value: entry.key,
  };

  /// 将 TimeBar 转换为 Timeframe（秒）
  /// 如果不支持的 TimeBar，返回 null
  static int? toSeconds(TimeBar timeBar) {
    return _timeBarToSeconds[timeBar];
  }

  /// 将 TimeBar 转换为 Timeframe（秒）
  /// 如果不支持的 TimeBar，抛出异常
  static int toSecondsOrThrow(TimeBar timeBar) {
    final seconds = _timeBarToSeconds[timeBar];
    if (seconds == null) {
      throw UnimplementedError('Unsupported TimeBar: $timeBar');
    }
    return seconds;
  }

  /// 将 Timeframe（秒）转换为 TimeBar
  /// 如果不支持的 Timeframe，返回 null
  static TimeBar? toTimeBar(int seconds) {
    return _secondsToTimeBar[seconds];
  }

  /// 将 Timeframe（秒）转换为 TimeBar
  /// 如果不支持的 Timeframe，抛出异常
  static TimeBar toTimeBarOrThrow(int seconds) {
    final timeBar = _secondsToTimeBar[seconds];
    if (timeBar == null) {
      throw UnimplementedError('Unsupported timeframe: $seconds seconds');
    }
    return timeBar;
  }

  /// 检查 TimeBar 是否支持
  static bool isSupported(TimeBar timeBar) {
    return _timeBarToSeconds.containsKey(timeBar);
  }

  /// 检查 Timeframe（秒）是否支持
  static bool isSecondsSupported(int seconds) {
    return _secondsToTimeBar.containsKey(seconds);
  }

  /// 获取所有支持的 TimeBar 列表
  static List<TimeBar> get supportedTimeBars => _timeBarToSeconds.keys.toList();

  /// 获取所有支持的 Timeframe（秒）列表
  static List<int> get supportedSeconds => _secondsToTimeBar.keys.toList();
}
