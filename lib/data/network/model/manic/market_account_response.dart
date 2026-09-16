import 'package:json_annotation/json_annotation.dart';

part 'market_account_response.g.dart';

@JsonSerializable()
class MarketAccountResponse {
  final String operator;
  @JsonKey(name: 'back_authority')
  final String backAuthority;
  final int bump;
  @JsonKey(name: 'min_settle_delay_epochs_secs')
  final int minSettleDelayEpochsSecs;
  @JsonKey(name: 'max_settle_delay_epochs_secs')
  final int maxSettleDelayEpochsSecs;
  @JsonKey(name: 'fee_bps')
  final int feeBps;
  @JsonKey(name: 'min_stake')
  final int minStake;
  @JsonKey(name: 'max_stake')
  final int maxStake;
  @JsonKey(name: 'min_premium_bps')
  final int minPremiumBps;
  @JsonKey(name: 'call_lambda')
  final double callLambda;
  @JsonKey(name: 'put_lambda')
  final double putLambda;
  @JsonKey(name: 'vega_buffer')
  final double vegaBuffer;
  @JsonKey(name: 'feed_id')
  final String feedId;
  @JsonKey(name: 'staleness_max_sec')
  final int stalenessMaxSec;
  @JsonKey(name: 'price_exponent')
  final int priceExponent;
  @JsonKey(name: 'last_price')
  final double lastPrice;
  @JsonKey(name: 'last_ts')
  final int lastTs;
  @JsonKey(name: 'call_sigma2', defaultValue: 0.0)
  final double callSigma2;
  @JsonKey(name: 'put_sigma2', defaultValue: 0.0)
  final double putSigma2;
  @JsonKey(name: 'min_sigma2', defaultValue: 0.0)
  final double minSigma2;
  @JsonKey(name: 'max_sigma2', defaultValue: 0.0)
  final double maxSigma2;
  @JsonKey(name: 'half_life_secs')
  final int halfLifeSecs;
  final String vault;
  final String pool;
  final String treasury;
  final bool paused;
  @JsonKey(name: 'close_position_min_delay_secs', defaultValue: 0)
  final int closePositionMinDelaySecs;
  @JsonKey(name: 'close_position_before_settle_secs', defaultValue: 0)
  final int closePositionBeforeSettleSecs;
  @JsonKey(name: 'deducted_fee_bps', defaultValue: 0)
  final int deductedFeeBps;
  @JsonKey(name: 'max_buffer_multiplier', defaultValue: 0)
  final int maxBufferMultiplier;
  @JsonKey(name: 'buffer_percent', defaultValue: 0)
  final int bufferPercent;
  @JsonKey(name: 'highest_candle_change_bps', defaultValue: 0)
  final int highestCandleChangeBps;
  const MarketAccountResponse({
    required this.operator,
    required this.backAuthority,
    required this.bump,
    required this.minSettleDelayEpochsSecs,
    required this.maxSettleDelayEpochsSecs,
    required this.feeBps,
    required this.minStake,
    required this.maxStake,
    required this.minPremiumBps,
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
    required this.paused,
    required this.closePositionMinDelaySecs,
    required this.closePositionBeforeSettleSecs,
    required this.deductedFeeBps,
    required this.maxBufferMultiplier,
    required this.bufferPercent,
    required this.highestCandleChangeBps,
  });

  factory MarketAccountResponse.fromJson(Map<String, dynamic> json) =>
      _$MarketAccountResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MarketAccountResponseToJson(this);
}
