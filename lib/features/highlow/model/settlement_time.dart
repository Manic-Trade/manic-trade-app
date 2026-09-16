import 'package:intl/intl.dart';

class SettlementTime {
  final String? id;
  final DateTime? _settleTime;
  final int? _durationSeconds;

  SettlementTime._({DateTime? settleTime, int? durationSeconds, this.id})
      : _durationSeconds = durationSeconds,
        _settleTime = settleTime;

  factory SettlementTime.fromDurationSeconds(int durationSeconds, {String? id}) {
    return SettlementTime._(durationSeconds: durationSeconds, id: id);
  }

  factory SettlementTime.fromSettleTime(DateTime settleTime, {String? id}) {
    return SettlementTime._(settleTime: settleTime, id: id);
  }

  int get epoch {
    if (_settleTime != null) {
      return _settleTime.millisecondsSinceEpoch;
    } else {
      return DateTime.now()
          .add(Duration(seconds: _durationSeconds!))
          .millisecondsSinceEpoch;
    }
  }

  bool isFixedDuration() {
    return _settleTime == null;
  }

  Duration differenceToNow() {
    if (isFixedDuration()) {
      return Duration(seconds: _durationSeconds!);
    } else {
      return _settleTime!.difference(DateTime.now());
    }
  }

  String entryCountdownText() {
    if (isFixedDuration()) {
      return '${_durationSeconds! ~/ 60}:${(_durationSeconds % 60).toString().padLeft(2, '0')}';
    } else {
      Duration difference = _settleTime!.difference(DateTime.now());
      // 如果当前时间已经等于或超过 _settleTime，显示 0:00
      if (difference.isNegative || difference == Duration.zero) {
        return '0:00';
      }
      return '${difference.inMinutes}:${(difference.inSeconds % 60).toString().padLeft(2, '0')}';
    }
  }

  String settlementTimeText() {
    if (isFixedDuration()) {
      DateTime settlementTime = DateTime.fromMillisecondsSinceEpoch(epoch);
      return _settlementTimeFormat.format(settlementTime);
    } else {
      return _settlementTimeFormat.format(_settleTime!);
    }
  }

  static final DateFormat _settlementTimeFormat = DateFormat('HH:mm:ss');
}
