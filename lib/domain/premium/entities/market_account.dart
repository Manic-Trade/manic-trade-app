

/// MarketAccount data model on Solana.
/// Contains all parameters required for options pricing.
class MarketAccount {
  /// Operator public key
  final String operator;

  /// Backend authority public key
  final String backAuthority;

  /// PDA bump
  final int bump;

  /// Minimum settlement delay (seconds)
  final int minSettleDelayEpochsSecs;

  /// Maximum settlement delay (seconds)
  final int maxSettleDelayEpochsSecs;

  /// Minimum delay for early close (seconds to wait after opening before closing)
  final int closePositionMinDelaySecs;

  /// Cutoff for early close (minimum seconds before expiry by which a position must be closed)
  final int closePositionBeforeSettleSecs;

  /// Trading fee (basis points)
  final int feeBps;

  /// Minimum stake amount
  final BigInt minStake;

  /// Maximum stake amount
  final BigInt maxStake;

  /// Minimum premium (basis points)
  final int minPremiumBps;

  /// Fee deducted for early close (basis points)
  final int deductedFeeBps;

  /// Lambda parameter for call options (< 1.0, e.g. 0.999)
  final double callLambda;

  /// Lambda parameter for put options (> 1.0, e.g. 1.001)
  final double putLambda;

  /// Vega buffer used for spread pricing (e.g. 0.05)
  final double vegaBuffer;

  /// Pyth price feed ID (32 bytes)
  final List<int> feedId;

  /// Maximum price staleness (seconds)
  final int stalenessMaxSec;

  /// Price exponent
  final int priceExponent;

  /// Last recorded price
  double lastPrice;

  /// Last timestamp (Unix seconds)
  int lastTs;

  /// EWMA variance for call side (IV² = callSigma2)
  double callSigma2;

  /// EWMA variance for put side (IV² = putSigma2)
  double putSigma2;

  /// Minimum variance floor
  final double minSigma2;

  /// Maximum variance cap
  final double maxSigma2;

  /// EWMA half-life (seconds)
  final int halfLifeSecs;

  /// Vault public key
  final String vault;

  /// Liquidity pool public key
  final String pool;

  /// Treasury public key
  final String treasury;

  /// Leverage buffer - maximum buffer multiplier (e.g. 100 means 100x)
  final int maxBufferMultiplier;

  /// Leverage buffer - buffer percentage (e.g. 500 means 5.0x candle move at max leverage)
  final int bufferPercent;

  /// Leverage buffer - maximum 1h candle change (basis points)
  final int highestCandleChangeBps;

  /// Whether the market is paused
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

  /// Clone this instance (used for simulation to avoid mutating original data)
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
