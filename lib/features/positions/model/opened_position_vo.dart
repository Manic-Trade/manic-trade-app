import 'package:finality/domain/options/entities/options_time_mode.dart';
import 'package:finality/domain/options/entities/opened_position.dart';

/// OpenPosition 视图对象
/// 用于在 UI 层展示持仓信息
class OpenedPositionVO {
  final String positionId;

  /// 基础资产（如 btc)
  final String baseAsset;

  // 交易对图片 URL
  final String pairImageUrl;

  // 交易对名称（如 BTC/USD）
  final String pairName;

  // 交易对价格小数位数
  final int pipSize;

  /// 模式显示（如 Individual）
  final String modeDisplay;

  /// 押注金额
  final double amount;

  /// 原始保费（lamports），用于提前平仓计算
  final int amountLamports;

  /// 是否看涨（true=看涨，false=看跌）
  final bool isHigh;

  /// 开始时间戳（秒）
  final int startTime;

  /// 结束时间戳（秒）
  final int endTime;

  /// 入场价格
  final double entryPrice;

    /// 预期收益（lamports），用于提前平仓计算
  final int winPayoutLamports;

  /// 赢了后的收益
  final double winPayout;

  /// 赢了后的收益展示字符串
  final String winPayoutDisplay;

  /// 输了后的亏损
  final double lossPayout;

  final String lossPayoutDisplay;


  const OpenedPositionVO({
    required this.positionId,
    required this.baseAsset,
    required this.pairImageUrl,
    required this.pairName,
    required this.pipSize,
    required this.modeDisplay,
    required this.amount,
    required this.isHigh,
    required this.startTime,
    required this.endTime,
    required this.entryPrice,
    required this.winPayout,
    required this.winPayoutDisplay,
    required this.lossPayout,
    required this.lossPayoutDisplay,
    required this.winPayoutLamports,
    required this.amountLamports,
  });

  /// 创建一个占位 VO，用于骨架图显示
  factory OpenedPositionVO.placeholder() {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return OpenedPositionVO(
      positionId: '123',
      baseAsset: 'btc',
      pairImageUrl: 'https://example.com/btc.png',
      pairName: '--- BTC/USD',
      pipSize: 2,
      modeDisplay: 'Individual',
      amount: 100,
      isHigh: true,
      startTime: now,
      endTime: now + 300, // 5分钟后
      entryPrice: 2500.0,
      winPayout: 240.0,
      winPayoutDisplay: '+\$240.00',
      lossPayout: 25.0,
      lossPayoutDisplay: '-\$25.00',
      winPayoutLamports: 0,
      amountLamports: 0,
    );
  }

  factory OpenedPositionVO.fromOpenedPosition(OpenedPosition openedPosition) {
    return OpenedPositionVO(
      positionId: openedPosition.id,
      baseAsset: openedPosition.tradingPair.baseAsset,
      pairImageUrl: openedPosition.tradingPair.iconUrl,
      pairName: openedPosition.tradingPair.pairName,
      pipSize: openedPosition.tradingPair.pipSize,
      modeDisplay: openedPosition.isTimerMode
          ? OptionsTimeMode.timer.label
          : OptionsTimeMode.clock.label,
      amount: openedPosition.amount,
      isHigh: openedPosition.isHigh,
      startTime: openedPosition.startTime,
      endTime: openedPosition.endTime,
      entryPrice: openedPosition.entryPrice,
      winPayout: openedPosition.winPayout,
      lossPayout: openedPosition.lossPayout,
      winPayoutDisplay: '+\$${openedPosition.winPayoutDisplay}',
      lossPayoutDisplay: '\$${openedPosition.lossPayoutDisplay}',
      winPayoutLamports: openedPosition.winPayoutLamports,
      amountLamports: openedPosition.amountLamports,
    );
  }
}
