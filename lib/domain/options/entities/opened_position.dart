import 'package:equatable/equatable.dart';
import 'package:finality/common/utils/decimal_format.dart';
import 'package:finality/data/drift/options_database.dart';
import 'package:finality/data/network/model/manic/pending_position_item_response.dart';
import 'package:finality/data/socket/manic/game_status.dart';

class OpenedPosition extends Equatable {
  final String id;
  final bool isHigh;
  final int endTime;
  final int startTime;
  final double entryPrice; //入场价格
  final int winPayoutLamports; //预期收益（lamports），用于提前平仓计算
  final double winPayout; //预期收益（包含本金+收益）
  final String winPayoutDisplay; //预期收益展示字符串,不带货币单位，包含本金+收益
  /// 输了后的亏损
  final double lossPayout;

  /// 输了后的亏损展示字符串,不带货币单位
  final String lossPayoutDisplay;
  final int amountLamports; //开单金额（lamports），用于提前平仓计算
  final double amount; //开单金额
  final String amountDisplay; //开单金额展示字符串,不带货币单位
  final OptionsTradingPair tradingPair;

  /// 是否是定时器模式
  /// true为计时器模式(估计多少秒后结算,每次结算时间不一样)
  /// false为时钟模式（统一到一个时间点结算，多次结算会集中在同一个时间点结算）
  final bool isTimerMode;

  const OpenedPosition({
    required this.id,
    required this.isHigh,
    required this.endTime,
    required this.startTime,
    required this.entryPrice,
    required this.winPayoutLamports,
    required this.winPayout,
    required this.winPayoutDisplay,
    required this.lossPayout,
    required this.lossPayoutDisplay,
    required this.amountLamports,
    required this.amount,
    required this.amountDisplay,
    required this.tradingPair,
    required this.isTimerMode,
  });

  /// 从 API 响应的 PendingPositionItemResponse 创建
  factory OpenedPosition.fromPendingPositionItem(
      PendingPositionItemResponse item, OptionsTradingPair tradingPair) {
    //开单金额
    var amountLamports = item.premiumAmount;
    var amount = amountLamports / 1000000;
    var amountDisplay = amount.formatWithDecimals(2);

    //预期收益
    var winPayoutLamports = item.amount;
    var winPayout = winPayoutLamports / 1000000;
    var winPayoutDisplay = winPayout.formatWithDecimals(2);

    return OpenedPosition(
      id: item.id,
      isHigh: item.isHigher,
      endTime: item.endTime,
      startTime: item.startTime,
      entryPrice: item.boundaryPrice,
      amountLamports: amountLamports,
      amount: amount,
      amountDisplay: amountDisplay,
      winPayoutLamports: winPayoutLamports,
      winPayout: winPayout,
      winPayoutDisplay: winPayoutDisplay,
      lossPayout: 0,
      lossPayoutDisplay: "0.00",
      tradingPair: tradingPair,
      isTimerMode: item.isTimerMode,
    );
  }

  /// 从 Socket 推送的 open_position 事件创建
  factory OpenedPosition.fromSocketEvent(
      PositionEvent event, OptionsTradingPair tradingPair) {
    //开单金额
    var amountLamports = event.premiumAmount ?? 0;
    var amount = amountLamports / 1000000;
    var amountDisplay = amount.formatWithDecimals(2);

    //预期收益
    var winPayoutLamports = event.amount ?? 0;
    var winPayout = winPayoutLamports / 1000000;
    var winPayoutDisplay = winPayout.formatWithDecimals(2);

    return OpenedPosition(
      id: event.id,
      isHigh: event.isHigh,
      endTime: event.endTime ?? 0,
      startTime: event.startTime ?? 0,
      entryPrice: event.boundaryPrice,
      amountLamports: event.amount ?? 0,
      amount: amount,
      amountDisplay: amountDisplay,
      winPayoutLamports: winPayoutLamports,
      winPayout: winPayout,
      winPayoutDisplay: winPayoutDisplay,
      lossPayout: 0,
      lossPayoutDisplay: "0.00",
      tradingPair: tradingPair,
      isTimerMode: event.isTimerMode,
    );
  }

  /// 是否是时钟模式
  bool get isClockMode => !isTimerMode;

  @override
  List<Object?> get props =>
      [id, isHigh, endTime, startTime, entryPrice, amount, isTimerMode];
}
