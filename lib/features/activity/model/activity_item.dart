import 'package:finality/data/network/model/manic/deposit_item.dart';
import 'package:finality/data/network/model/manic/position_history_item.dart';
import 'package:finality/data/network/model/manic/withdraw_item.dart';
import 'package:intl/intl.dart';

/// Activity 列表项类型
enum ActivityItemType {
  /// 开仓
  openPosition,

  /// 结算
  settlePosition,

  /// 充值
  deposit,

  /// 提现
  withdraw,
}

/// Activity 列表项基类
sealed class ActivityItem {
  /// 唯一ID
  String get id;

  /// 时间
  DateTime get time;

  /// 类型
  ActivityItemType get type;

  /// 判断是否同一天
  bool isSameDay(ActivityItem other) {
    return time.year == other.time.year &&
        time.month == other.time.month &&
        time.day == other.time.day;
  }
}

/// 开仓记录
class OpenPositionActivityItem extends ActivityItem {
  final PositionHistoryItem raw;

  OpenPositionActivityItem(this.raw);

  @override
  String get id => '${raw.positionId}_open';

  @override
  DateTime get time =>
      DateTime.fromMillisecondsSinceEpoch(raw.startTime * 1000).toLocal();

  @override
  ActivityItemType get type => ActivityItemType.openPosition;

  /// 资产名称
  String get asset => raw.asset.toUpperCase();

  /// 方向是否是看涨
  bool get isHigh => raw.side == 'call';

  /// 金额（UI 显示格式）
  String get amountDisplay =>
      '-\$${NumberFormat('#,##0.00').format(raw.uiAmount)}';
}

/// 结算记录
class SettlePositionActivityItem extends ActivityItem {
  final PositionHistoryItem raw;

  SettlePositionActivityItem(this.raw);

  @override
  String get id => '${raw.positionId}_settle';

  @override
  DateTime get time => DateTime.fromMillisecondsSinceEpoch(raw.endTime * 1000).toLocal();

  @override
  ActivityItemType get type => ActivityItemType.settlePosition;

  /// 资产名称
  String get asset => raw.asset.toUpperCase();

  /// 方向是否是看涨
  bool get isHigh => raw.side == 'call';

  /// 是否胜利
  bool get isWin => raw.result == 'Won';

  /// 派彩金额（微单位转 UI 格式）
  String get payoutDisplay {
    if (raw.payout == 0) {
      return '\$0';
    }

    final payoutAmount = raw.payout / 1000000;
    final prefix = payoutAmount > 0 ? '+' : '';
    return '$prefix\$${NumberFormat('#,##0.00').format(payoutAmount)}';
  }

  /// 派彩金额（用于判断正负）
  double get payoutAmount => raw.payout / 1000000;
}

/// 充值记录
class DepositActivityItem extends ActivityItem {
  final DepositItem raw;

  DepositActivityItem(this.raw);

  @override
  String get id => 'deposit_${raw.id}';

  @override
  DateTime get time =>
      DateTime.fromMillisecondsSinceEpoch(raw.timestamp * 1000).toLocal();

  @override
  ActivityItemType get type => ActivityItemType.deposit;

  /// 金额（UI 显示格式）
  String get amountDisplay => '+\$${raw.amount}';
}

/// 提现记录
class WithdrawActivityItem extends ActivityItem {
  final WithdrawItem raw;

  WithdrawActivityItem(this.raw);

  @override
  String get id => 'withdraw_${raw.id}';

  @override
  DateTime get time => raw.createdAt.toLocal();

  @override
  ActivityItemType get type => ActivityItemType.withdraw;

  /// 金额（UI 显示格式）
  String get amountDisplay => '-\$${raw.uiAmount}';
}
