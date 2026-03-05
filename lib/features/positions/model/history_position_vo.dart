import 'package:finality/common/constants/currencies.dart';
import 'package:finality/common/utils/decimal_format.dart';
import 'package:finality/data/drift/options_database.dart';
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
  final bool isWin; //是否赢了
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
      payoutDisplay: '+00000.00',
      isWin: true,
      isRefund: false,
      settleTxHash:
          '0x8a1234567890abcdef1234567890abcdef1234567890abcdef1234567890a29c1',
    );
  }

  /// 持续时间（秒）
  int get duration => endTime - startTime;

  /// 格式化的持续时间（如 "30 sec", "2 min", "1 hr"）
  String get durationDisplay {
    if (duration < 60) {
      return '$duration sec';
    } else if (duration < 3600) {
      final minutes = duration ~/ 60;
      return '$minutes min';
    } else if (duration < 86400) {
      final hours = duration ~/ 3600;
      return '$hours hr';
    } else {
      final days = duration ~/ 86400;
      return '$days day${days > 1 ? 's' : ''}';
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

  /// 金额展示（带符号和格式化）
  String get amountDisplay => amount.formatWithDecimals(2).withUsdSymbol();

  /// Entry/Close Price 展示
  String getEntryClosePriceDisplay(int pipSize) {
    final entryPriceStr = entryPrice.formatWithDecimals(pipSize).withUsdSymbol();
    final closePriceStr =
        (finalPrice ?? 0).formatWithDecimals(pipSize).withUsdSymbol();
    return '$entryPriceStr/$closePriceStr';
  }
}
