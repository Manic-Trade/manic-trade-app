import 'package:finality/domain/options/entities/opened_position.dart';
import 'package:finality/features/highlow/model/settled_position_event.dart';

/// Live Position Bar 中 item 的数据模型（密封类）
/// 每个子类只包含该状态需要的字段
sealed class LivePositionItemData {
  /// 唯一标识符
  final String id;

  /// 交易对基础资产（用于过滤，如 "BTC", "SOL"）
  final String baseAsset;

  const LivePositionItemData({
    required this.id,
    required this.baseAsset,
  });

  /// 下单时间戳（秒），用于排序
  int get startTime;

  /// 是否正在处理中
  bool get isProcessing => this is ProcessingItemData;

  /// 是否进行中
  bool get isActive => this is ActiveItemData;

  /// 是否已结算
  bool get isSettled => this is SettledItemData;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LivePositionItemData &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Processing 状态 - 处理中（发起开单请求，等待链上确认）
/// 只需要最少的字段用于显示
class ProcessingItemData extends LivePositionItemData {
  /// 是否看涨（用于可能的颜色显示）
  final bool isHigh;

  /// 下单金额
  final String amount;

  /// 本地下单时间戳（秒）
  @override
  final int startTime;

  const ProcessingItemData({
    required super.id,
    required super.baseAsset,
    required this.isHigh,
    required this.amount,
    required this.startTime,
  });
}

/// Active 状态 - 进行中（已开仓）
/// 需要倒计时、入场价等信息
class ActiveItemData extends LivePositionItemData {
  /// 是否看涨
  final bool isHigh;

  /// 入场价格
  final double entryPrice;
  final String entryPriceDisplay;

  /// 下单金额（显示用，如 "5.00"）
  final String amount;

  final String wonProfit; //获胜后的盈利金额
  final String lostLoss; //失败后的亏损金额

  // 开仓时间戳（秒）
  @override
  final int startTime;

  /// 结束时间戳（秒）
  final int endTime;

  /// 总时长（毫秒），通过 startTime 和 endTime 计算
  int get durationMs => (endTime - startTime) * 1000;

  const ActiveItemData({
    required super.id,
    required super.baseAsset,
    required this.isHigh,
    required this.entryPrice,
    required this.entryPriceDisplay,
    required this.amount,
    required this.wonProfit,
    required this.lostLoss,
    required this.startTime,
    required this.endTime,
  });

  /// 从 OpenedPosition 创建
  factory ActiveItemData.fromOpenedPosition(OpenedPosition position) {
    //   var wonProfit = position.winPayout - position.amount;
    return ActiveItemData(
      id: position.id,
      baseAsset: position.tradingPair.baseAsset,
      isHigh: position.isHigh,
      entryPrice: position.entryPrice,
      entryPriceDisplay:
          position.entryPrice.toStringAsFixed(position.tradingPair.pipSize),
      amount: position.amountDisplay,
      wonProfit: "+\$${position.winPayoutDisplay}",
      lostLoss: "+\$0.00",
      startTime: position.startTime,
      endTime: position.endTime,
    );
  }
}

/// Settled 状态 - 已结算（盈利或亏损）
class SettledItemData extends LivePositionItemData {
  /// 是否看涨
  final bool isHigh;

  /// 是否盈利
  final bool isWin;

  /// 盈亏文本（如 "+$133.08" 或 "-$5.00"）
  final String pnlText;

  /// 开仓时间戳（秒）
  @override
  final int startTime;

  const SettledItemData({
    required super.id,
    required super.baseAsset,
    required this.isHigh,
    required this.isWin,
    required this.pnlText,
    required this.startTime,
  });

  /// 从 SettledPositionEvent 创建
  factory SettledItemData.fromSettledEvent(SettledPositionEvent event) {
    final isWin = event.event.isWin;
    final pnlText = '+\$${event.pnl}';

    return SettledItemData(
      id: event.position.id,
      baseAsset: event.position.tradingPair.baseAsset,
      isHigh: event.position.isHigh,
      isWin: isWin,
      pnlText: pnlText,
      startTime: event.position.startTime,
    );
  }
}
