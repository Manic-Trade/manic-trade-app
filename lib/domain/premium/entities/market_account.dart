

/// Solana 上的 MarketAccount 数据模型
/// 包含二元期权定价所需的所有参数
class MarketAccount {
  /// 操作员公钥
  final String operator;

  /// 后台授权公钥
  final String backAuthority;

  /// PDA bump
  final int bump;

  /// 最小结算延迟（秒）
  final int minSettleDelayEpochsSecs;

  /// 最大结算延迟（秒）
  final int maxSettleDelayEpochsSecs;

  /// 提前平仓最小延迟（开仓后至少等待多少秒才能平仓）
  final int closePositionMinDelaySecs;

  /// 提前平仓截止时间（到期前至少多少秒必须平仓）
  final int closePositionBeforeSettleSecs;

  /// 手续费（基点）
  final int feeBps;

  /// 最小质押金额
  final BigInt minStake;

  /// 最大质押金额
  final BigInt maxStake;

  /// 最小保费（基点）
  final int minPremiumBps;

  /// 提前平仓扣除费用（基点）
  final int deductedFeeBps;

  /// Call 期权的 Lambda 参数（< 1.0，如 0.999）
  final double callLambda;

  /// Put 期权的 Lambda 参数（> 1.0，如 1.001）
  final double putLambda;

  /// Vega 缓冲值，用于价差定价（如 0.05）
  final double vegaBuffer;

  /// Pyth 价格源 ID（32字节）
  final List<int> feedId;

  /// 价格过期时间（秒）
  final int stalenessMaxSec;

  /// 价格指数
  final int priceExponent;

  /// 最后记录的价格
  double lastPrice;

  /// 最后时间戳（Unix 秒）
  int lastTs;

  /// Call 方向的 EWMA 方差（IV² = callSigma2）
  double callSigma2;

  /// Put 方向的 EWMA 方差（IV² = putSigma2）
  double putSigma2;

  /// 最小方差下限
  final double minSigma2;

  /// 最大方差上限
  final double maxSigma2;

  /// EWMA 半衰期（秒）
  final int halfLifeSecs;

  /// 金库公钥
  final String vault;

  /// 资金池公钥
  final String pool;

  /// 国库公钥
  final String treasury;

  /// 杠杆缓冲 - 最大缓冲倍数（如 100 表示 100x）
  final int maxBufferMultiplier;

  /// 杠杆缓冲 - 缓冲百分比（如 500 表示最大杠杆时 5.0x 蜡烛变化）
  final int bufferPercent;

  /// 杠杆缓冲 - 最近一小时最大蜡烛变化（基点）
  final int highestCandleChangeBps;

  /// 是否暂停
  final bool paused;

  MarketAccount({
    required this.operator,
    required this.backAuthority,
    required this.bump,
    required this.minSettleDelayEpochsSecs,
    required this.maxSettleDelayEpochsSecs,
    required this.closePositionMinDelaySecs,
    required this.closePositionBeforeSettleSecs,
    required this.feeBps,
    required this.minStake,
    required this.maxStake,
    required this.minPremiumBps,
    required this.deductedFeeBps,
    required this.callLambda,
    required this.putLambda,
    required this.vegaBuffer,
    required this.feedId,
    required this.stalenessMaxSec,
    required this.priceExponent,
    required this.lastPrice,
    required this.lastTs,
    required this.callSigma2,
    required this.putSigma2,
    required this.minSigma2,
    required this.maxSigma2,
    required this.halfLifeSecs,
    required this.vault,
    required this.pool,
    required this.treasury,
    required this.maxBufferMultiplier,
    required this.bufferPercent,
    required this.highestCandleChangeBps,
    required this.paused,
  });

  /// 克隆（用于模拟计算，避免修改原始数据）
  MarketAccount clone() {
    return MarketAccount(
      operator: operator,
      backAuthority: backAuthority,
      bump: bump,
      minSettleDelayEpochsSecs: minSettleDelayEpochsSecs,
      maxSettleDelayEpochsSecs: maxSettleDelayEpochsSecs,
      closePositionMinDelaySecs: closePositionMinDelaySecs,
      closePositionBeforeSettleSecs: closePositionBeforeSettleSecs,
      feeBps: feeBps,
      minStake: minStake,
      maxStake: maxStake,
      minPremiumBps: minPremiumBps,
      deductedFeeBps: deductedFeeBps,
      callLambda: callLambda,
      putLambda: putLambda,
      vegaBuffer: vegaBuffer,
      feedId: List.from(feedId),
      stalenessMaxSec: stalenessMaxSec,
      priceExponent: priceExponent,
      lastPrice: lastPrice,
      lastTs: lastTs,
      callSigma2: callSigma2,
      putSigma2: putSigma2,
      minSigma2: minSigma2,
      maxSigma2: maxSigma2,
      halfLifeSecs: halfLifeSecs,
      vault: vault,
      pool: pool,
      treasury: treasury,
      maxBufferMultiplier: maxBufferMultiplier,
      bufferPercent: bufferPercent,
      highestCandleChangeBps: highestCandleChangeBps,
      paused: paused,
    );
  }

  @override
  String toString() {
    return 'MarketAccount(callLambda: $callLambda, putLambda: $putLambda, '
        'vegaBuffer: $vegaBuffer, callSigma2: $callSigma2, putSigma2: $putSigma2, lastPrice: $lastPrice)';
  }
}
