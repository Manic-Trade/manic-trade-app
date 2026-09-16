import 'package:finality/common/constants/currencies.dart';
import 'package:finality/common/utils/decimal_format.dart';
import 'package:finality/data/drift/entities/options_trading_pair.dart';
import 'package:finality/data/network/model/manic/position_history_item.dart';
import 'package:finality/domain/options/entities/options_time_mode.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class HistoryPositionVO {
  final String positionId;
  final String baseAsset;
  final ValueListenable<OptionsTradingPair?> tradingPair;
  final String modeDisplay;
  final double amount;
  final bool isHigh;
  final int startTime; //开仓时间
  final int endTime; //平仓时间
  final double entryPrice; //开仓价格
  final double? finalPrice; //结算价格
  final double payout; //结算收益
  final String payoutDisplay; //收益展示字符串
  final bool? isWin; //是否赢了,如果是 pending 状态，则为 null,使用 isSettledWin 判断
  final bool isRefund; //是否中途平仓
  final String? settleTxHash;

  HistoryPositionVO(
      {required this.positionId,
      required this.baseAsset,
      required this.tradingPair,
      required this.modeDisplay,
      required this.amount,
      required this.isHigh,
      required this.startTime,
      required this.endTime,
      required this.entryPrice,
      required this.finalPrice,
      required this.payout,
      required this.payoutDisplay,
      required this.isWin,
      required this.isRefund,
      required this.settleTxHash}); //结算交易hash

  factory HistoryPositionVO.fromPositionHistoryItem(PositionHistoryItem item,
      ValueListenable<OptionsTradingPair?> tradingPair) {
    var amount = item.amount / 1000000;
    var payout = item.payout / 1000000;
    var profitable = payout > 0;
    var payoutDisplay = profitable
        ? '+${payout.formatWithDecimals(2).withUsdSymbol()}'
        : payout.formatWithDecimals(2).withUsdSymbol();
    return HistoryPositionVO(
      positionId: item.positionId,
      baseAsset: item.asset,
      tradingPair: tradingPair,
      modeDisplay: item.isTimerMode
          ? OptionsTimeMode.timer.label
          : OptionsTimeMode.clock.label,
      amount: amount,
      isHigh: item.isHigh,
      startTime: item.startTime,
      endTime: item.endTime,
      entryPrice: item.boundaryPrice,
      finalPrice: item.finalPrice,
      payout: payout,
      payoutDisplay: payoutDisplay,
      isWin: item.isWin,
      isRefund: item.isRefund,
      settleTxHash: item.resultSig,
    );
  }

  /// 创建占位符对象（用于骨架加载）
  factory HistoryPositionVO.placeholder() {
    return HistoryPositionVO(
      positionId: 'placeholder',
      baseAsset: 'BTCCCC',
      tradingPair: ValueNotifier(null),
      modeDisplay: 'Individual',
      amount: 25.0,
      isHigh: true,
      startTime: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      endTime: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      entryPrice: 2500.0,
      finalPrice: 2475.0,
      payout: 250.0,
      payoutDisplay: '+000000.00',
      isWin: true,
      isRefund: false,
      settleTxHash:
          '0x8a1234567890abcdef1234567890abcdef1234567890abcdef1234567890a29c1',
    );
  }

  bool get isSettledWin => isWin == true;

  /// 持续时间（秒）
  int get duration => endTime - startTime;

  /// 格式化的持续时间（如 "30 sec", "1 min 26 sec", "1 hr 1 min 14 sec"）
  String get durationDisplay {
    if (duration < 60) {
      return '$duration sec';
    } else if (duration < 3600) {
      final minutes = duration ~/ 60;
      final seconds = duration % 60;
      if (seconds == 0) return '$minutes min';
      return '$minutes min $seconds sec';
    } else if (duration < 86400) {
      final hours = duration ~/ 3600;
      final remaining = duration % 3600;
      final minutes = remaining ~/ 60;
      final seconds = remaining % 60;
      if (minutes == 0 && seconds == 0) return '$hours hr';
      if (seconds == 0) return '$hours hr $minutes min';
      if (minutes == 0) return '$hours hr $seconds sec';
      return '$hours hr $minutes min $seconds sec';
    } else {
      final days = duration ~/ 86400;
      return '$days day${days > 1 ? 's' : ''}';
    }
  }

  String get durationDisplayShort {
    if (duration < 60) {
      return '$duration s';
    } else if (duration < 3600) {
      final minutes = duration ~/ 60;
      final seconds = duration % 60;
      if (seconds == 0) return '$minutes m';
      return '$minutes m $seconds s';
    } else if (duration < 86400) {
      final hours = duration ~/ 3600;
      final remaining = duration % 3600;
      final minutes = remaining ~/ 60;
      final seconds = remaining % 60;
      if (minutes == 0 && seconds == 0) return '$hours h';
      if (seconds == 0) return '$hours h $minutes m';
      if (minutes == 0) return '$hours h $seconds s';
      return '$hours h $minutes m $seconds s';
    } else {
      final days = duration ~/ 86400;
      return '$days d';
    }
  }

  /// 格式化的结束时间（如 "12:28:50, Dec 16 2025"）
  String get endTimeDisplay {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(endTime * 1000);
    final timeFormat = DateFormat('HH:mm:ss');
    final dateFormat = DateFormat('MMM dd yyyy');
    return '${timeFormat.format(dateTime)}, ${dateFormat.format(dateTime)}';
  }

  /// 平仓类型（Manual 或 Auto）
  String get closeTypeDisplay => isRefund ? 'Manual' : 'Auto';

  /// 短地址（如 "0x8a...29c1"）
  String? get settleTxHashShort {
    if (settleTxHash == null || settleTxHash!.length < 10) return settleTxHash;
    return '${settleTxHash!.substring(0, 4)}...${settleTxHash!.substring(settleTxHash!.length - 4)}';
  }

  /// PNL（收益 - 本金）
  double get profit => payout - amount;

  /// PNL 百分比（取绝对值,显示需要自己加上 pnlSign
  int get pnlPercent => (profit / amount * 100).round().abs();

  /// PNL 符号（+ 或 -）
  String get pnlSign => profit >= 0 ? '+' : '-';

  /// PNL 展示（如 "+$12.50"）
  String get profitDisplay =>
      pnlSign + profit.abs().formatWithDecimals(2).withUsdSymbol();

  /// 金额展示（带符号和格式化）
  String get amountDisplay => amount.formatWithDecimals(2).withUsdSymbol();

  /// Entry/Close Price 展示
  String getEntryClosePriceDisplay(int pipSize) {
    final entryPriceStr =
        entryPrice.formatWithDecimals(pipSize).withUsdSymbol();
    final closePriceStr =
        (finalPrice ?? 0).formatWithDecimals(pipSize).withUsdSymbol();
    return '$entryPriceStr/$closePriceStr';
  }

  String getEntryPriceDisplay(int pipSize) {
    return entryPrice.formatWithDecimals(pipSize).withUsdSymbol();
  }

  String getClosePriceDisplay(int pipSize) {
    return (finalPrice ?? 0).formatWithDecimals(pipSize).withUsdSymbol();
  }
}
