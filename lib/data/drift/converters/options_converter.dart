import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:finality/data/drift/entities/options_trading_schedule.dart';

class TradingScheduleConverter extends TypeConverter<OptionsTradingSchedule?, String?> {
  const TradingScheduleConverter();
  @override
  OptionsTradingSchedule? fromSql(String? fromDb) {
    if (fromDb == null || fromDb.isEmpty) return null;
    try {
      return OptionsTradingSchedule.fromJson(jsonDecode(fromDb));
    } catch (e) {
      return null;
    }
  }

  @override
  String? toSql(OptionsTradingSchedule? value) {
    if (value == null) return null;
    try {
      return jsonEncode(value.toJson());
    } catch (e) {
      return null;
    }
  }
}
