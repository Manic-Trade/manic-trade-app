import 'package:json_annotation/json_annotation.dart';

part 'options_trading_schedule.g.dart';

@JsonSerializable()
class OptionsTradingSchedule {
  final String timezone;
  final String currentStatus;
  final String regularHours;
  final int? nextCloseTime;
  final int? nextOpenTime;
  final bool isHoliday;

  const OptionsTradingSchedule({
    required this.timezone,
    required this.currentStatus,
    required this.regularHours,
    this.nextCloseTime,
    this.nextOpenTime,
    required this.isHoliday,
  });

  bool get isClosed => !isOpen;

  bool get isOpen => currentStatus == 'open';

  factory OptionsTradingSchedule.fromJson(Map<String, dynamic> json) =>
      _$OptionsTradingScheduleFromJson(json);

  Map<String, dynamic> toJson() => _$OptionsTradingScheduleToJson(this);

  OptionsTradingSchedule copyWith({
    int? nextOpenTime,
    int? nextCloseTime,
    String? timezone,
    String? currentStatus,
    String? regularHours,
    bool? isHoliday,
  }) =>
      OptionsTradingSchedule(
        timezone: timezone ?? this.timezone,
        currentStatus: currentStatus ?? this.currentStatus,
        regularHours: regularHours ?? this.regularHours,
        nextCloseTime: nextCloseTime ?? this.nextCloseTime,
        nextOpenTime: nextOpenTime ?? this.nextOpenTime,
        isHoliday: isHoliday ?? this.isHoliday,
      );
}
