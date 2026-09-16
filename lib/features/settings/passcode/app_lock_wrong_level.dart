enum AppLockWrongLevel {
  none(0),
  minute_1(1000 * 60),
  minute_5(1000 * 60 * 5),
  hour_1(1000 * 60 * 60),
  hour_5(1000 * 60 * 60 * 5),
  day_1(1000 * 60 * 60 * 24);

  final int timeInterval;

  const AppLockWrongLevel(this.timeInterval);

  AppLockWrongLevel levelUp() {
    var upLevelOrdinal = index + 1;
    var values = AppLockWrongLevel.values;
    if (upLevelOrdinal < values.length) {
      return values[upLevelOrdinal];
    } else {
      return values.last;
    }
  }
}
