import 'package:finality/domain/options/entities/time_bar.dart';
import 'package:finality/features/highlow/chart/options_chart_style.dart';
import 'package:finality/features/highlow/components/input_payout_multiplier_sheet.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HighLowSettingsStore {
  final SharedPreferencesWithCache _prefs;

  HighLowSettingsStore(this._prefs);

  static const String _keyHighLowTimeBar = "high_low_kline_time_bar";
  static const String _keyHighLowChartStyle = "high_low_chart_style";
  static const String _keyLineChartHasArea = "line_chart_has_area";

  static const String _keyHighLowMultiplierMode = "high_low_multiplier_mode";

  Future<void> seMultiplierMode(MultiplierMode mode) async {
    await _prefs.setInt(_keyHighLowMultiplierMode, mode.index);
  }

  MultiplierMode getMultiplierMode() {
    final index = _prefs.getInt(_keyHighLowMultiplierMode);
    if (index == null || index < 0 || index >= MultiplierMode.values.length) {
      return MultiplierMode.pro;
    }
    return MultiplierMode.values[index];
  }

  Future<void> setHighLowChartStyle(OptionsChartStyle chartStyle) async {
    await _prefs.setString(_keyHighLowChartStyle, chartStyle.name);
    if (chartStyle == OptionsChartStyle.area) {
      await setLineChartHasArea(true);
    } else if (chartStyle == OptionsChartStyle.line) {
      await setLineChartHasArea(false);
    }
  }

  OptionsChartStyle getHighLowChartStyle() {
    final chartStyleName = _prefs.getString(_keyHighLowChartStyle);
    if (chartStyleName != null) {
      var chartStyle = OptionsChartStyle.values
          .firstWhereOrNull((e) => e.name == chartStyleName);
      if (chartStyle != null) {
        return chartStyle;
      }
    }

    return OptionsChartStyle.area;
  }

  Future<void> setHighLowTimeBar(TimeBar timeBar) async {
    await _prefs.setString(_keyHighLowTimeBar, timeBar.name);
  }

  TimeBar getHighLowTimeBar() {
    final timeBarName = _prefs.getString(_keyHighLowTimeBar);
    var timeBar = timeBarName != null ? TimeBar.convert(timeBarName) : null;
    var localTimeBar = (timeBar ?? TimeBar.s5);
    return localTimeBar;
  }

  Future<void> setLineChartHasArea(bool hasArea) async {
    await _prefs.setBool(_keyLineChartHasArea, hasArea);
  }

  bool getLineChartHasArea() {
    return _prefs.getBool(_keyLineChartHasArea) ?? true;
  }

  static const List<TimeBar> allTimeBarList = [
    TimeBar.s1,
    TimeBar.s5,
    TimeBar.s15,
    TimeBar.s30,
    TimeBar.m1,
    TimeBar.m5,
    TimeBar.m15,
    TimeBar.m30,
    TimeBar.H1,
    TimeBar.H3,
    TimeBar.H12,
    TimeBar.D1,
  ];

  static const List<TimeBar> preferTimeBarList = [
    TimeBar.s1,
    TimeBar.s5,
    TimeBar.s15,
    TimeBar.s30,
    TimeBar.m1,
  ];
}
