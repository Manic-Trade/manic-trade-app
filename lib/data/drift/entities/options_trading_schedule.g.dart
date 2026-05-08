// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'options_trading_schedule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OptionsTradingSchedule _$OptionsTradingScheduleFromJson(
        Map<String, dynamic> json) =>
    OptionsTradingSchedule(
      timezone: json['timezone'] as String,
      currentStatus: json['currentStatus'] as String,
      regularHours: json['regularHours'] as String,
      nextCloseTime: (json['nextCloseTime'] as num?)?.toInt(),
      nextOpenTime: (json['nextOpenTime'] as num?)?.toInt(),
      isHoliday: json['isHoliday'] as bool,
    );

Map<String, dynamic> _$OptionsTradingScheduleToJson(
        OptionsTradingSchedule instance) =>
    <String, dynamic>{
      'timezone': instance.timezone,
      'currentStatus': instance.currentStatus,
      'regularHours': instance.regularHours,
      'nextCloseTime': instance.nextCloseTime,
      'nextOpenTime': instance.nextOpenTime,
      'isHoliday': instance.isHoliday,
    };
