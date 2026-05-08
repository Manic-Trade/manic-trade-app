

import 'package:flutter/foundation.dart';

enum TimeUnit {
  /// 年
  year(Duration.microsecondsPerDay * 365),

  /// 月
  month(Duration.microsecondsPerDay * 30),

  /// 周
  week(Duration.microsecondsPerDay * 7),

  /// 天
  day(Duration.microsecondsPerDay),

  /// 小时
  hour(Duration.microsecondsPerHour),

  /// 分钟
  minute(Duration.microsecondsPerMinute),

  /// 秒
  second(Duration.microsecondsPerSecond),

  /// 毫秒
  millisecond(Duration.microsecondsPerMillisecond),

  /// 微秒
  microsecond(1);

  final int microseconds;
  const TimeUnit(this.microseconds);
}

/// 时间粒度，默认值1m
/// 如 [1m/3m/5m/15m/30m/1H/2H/4H]
/// 香港时间开盘价k线：[6H/12H/1D/2D/3D/1W/1M/3M]
/// UTC时间开盘价k线：[/6Hutc/12Hutc/1Dutc/2Dutc/3Dutc/1Wutc/1Mutc/3Mutc]
enum TimeBar {
  // time(1000, 'time'), // 暂不支持; v0.8.0支持
  s1('1s', 1, TimeUnit.second),
  s5('5s', 5, TimeUnit.second),
  s15('15s', 15, TimeUnit.second),
  s30('30s', 30, TimeUnit.second),
  m1('1m', 1, TimeUnit.minute),
  m3('3m', 3, TimeUnit.minute),
  m5('5m', 5, TimeUnit.minute),
  m15('15m', 15, TimeUnit.minute),
  m30('30m', 30, TimeUnit.minute),
  H1('1H', 1, TimeUnit.hour),
  H3('3H', 3, TimeUnit.hour),
  H2('2H', 2, TimeUnit.hour),
  H4('4H', 4, TimeUnit.hour),
  H6('6H', 6, TimeUnit.hour),
  H12('12H', 12, TimeUnit.hour),
  D1('1D', 1, TimeUnit.day),
  D2('2D', 2, TimeUnit.day),
  D3('3D', 3, TimeUnit.day),
  W1('1W', 7, TimeUnit.week),
  M1('1M', 1, TimeUnit.month),
  M3('3M', 3, TimeUnit.month),
  utc6H('6Hutc', 6, TimeUnit.hour),
  utc12H('12Hutc', 12, TimeUnit.hour),
  utc1D('1Dutc', 1, TimeUnit.day),
  utc2D('2Dutc', 2, TimeUnit.day),
  utc3D('3Dutc', 3, TimeUnit.day),
  utc1W('1Wutc', 7, TimeUnit.week),
  utc1M('1Mutc', 1, TimeUnit.month),
  utc3M('3Mutc', 3, TimeUnit.month);

  const TimeBar(this.bar, this.multiplier, this.unit);

  final String bar;
  final int multiplier;
  final TimeUnit unit;

  int get milliseconds => unit.microseconds ~/ 1000 * multiplier;

  bool get isUtc {
    return name.contains('utc') || bar.contains('utc');
  }

  @override
  String toString() => bar;

  static TimeBar? convert(String bar) {
    try {
      return TimeBar.values.firstWhere(
        (e) =>
            e.bar.toLowerCase() == bar.toLowerCase() ||
            e.name.toLowerCase() == bar.toLowerCase(),
      );
    } on Error catch (e, s) {
      debugPrintStack(stackTrace: s);
      return null;
    }
  }
}