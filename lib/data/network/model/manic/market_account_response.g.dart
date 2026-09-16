// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'market_account_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MarketAccountResponse _$MarketAccountResponseFromJson(
        Map<String, dynamic> json) =>
    MarketAccountResponse(
      operator: json['operator'] as String,
      backAuthority: json['back_authority'] as String,
      bump: (json['bump'] as num).toInt(),
      minSettleDelayEpochsSecs:
          (json['min_settle_delay_epochs_secs'] as num).toInt(),
      maxSettleDelayEpochsSecs:
          (json['max_settle_delay_epochs_secs'] as num).toInt(),
      feeBps: (json['fee_bps'] as num).toInt(),
      minStake: (json['min_stake'] as num).toInt(),
      maxStake: (json['max_stake'] as num).toInt(),
      minPremiumBps: (json['min_premium_bps'] as num).toInt(),
      callLambda: (json['call_lambda'] as num).toDouble(),
      putLambda: (json['put_lambda'] as num).toDouble(),
      vegaBuffer: (json['vega_buffer'] as num).toDouble(),
      feedId: json['feed_id'] as String,
      stalenessMaxSec: (json['staleness_max_sec'] as num).toInt(),
      priceExponent: (json['price_exponent'] as num).toInt(),
      lastPrice: (json['last_price'] as num).toDouble(),
      lastTs: (json['last_ts'] as num).toInt(),
      callSigma2: (json['call_sigma2'] as num?)?.toDouble() ?? 0.0,
      putSigma2: (json['put_sigma2'] as num?)?.toDouble() ?? 0.0,
      minSigma2: (json['min_sigma2'] as num?)?.toDouble() ?? 0.0,
      maxSigma2: (json['max_sigma2'] as num?)?.toDouble() ?? 0.0,
      halfLifeSecs: (json['half_life_secs'] as num).toInt(),
      vault: json['vault'] as String,
      pool: json['pool'] as String,
      treasury: json['treasury'] as String,
      paused: json['paused'] as bool,
      closePositionMinDelaySecs:
          (json['close_position_min_delay_secs'] as num?)?.toInt() ?? 0,
      closePositionBeforeSettleSecs:
          (json['close_position_before_settle_secs'] as num?)?.toInt() ?? 0,
      deductedFeeBps: (json['deducted_fee_bps'] as num?)?.toInt() ?? 0,
      maxBufferMultiplier:
          (json['max_buffer_multiplier'] as num?)?.toInt() ?? 0,
      bufferPercent: (json['buffer_percent'] as num?)?.toInt() ?? 0,
      highestCandleChangeBps:
          (json['highest_candle_change_bps'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$MarketAccountResponseToJson(
        MarketAccountResponse instance) =>
    <String, dynamic>{
      'operator': instance.operator,
      'back_authority': instance.backAuthority,
      'bump': instance.bump,
      'min_settle_delay_epochs_secs': instance.minSettleDelayEpochsSecs,
      'max_settle_delay_epochs_secs': instance.maxSettleDelayEpochsSecs,
      'fee_bps': instance.feeBps,
      'min_stake': instance.minStake,
      'max_stake': instance.maxStake,
      'min_premium_bps': instance.minPremiumBps,
      'call_lambda': instance.callLambda,
      'put_lambda': instance.putLambda,
      'vega_buffer': instance.vegaBuffer,
      'feed_id': instance.feedId,
      'staleness_max_sec': instance.stalenessMaxSec,
      'price_exponent': instance.priceExponent,
      'last_price': instance.lastPrice,
      'last_ts': instance.lastTs,
      'call_sigma2': instance.callSigma2,
      'put_sigma2': instance.putSigma2,
      'min_sigma2': instance.minSigma2,
      'max_sigma2': instance.maxSigma2,
      'half_life_secs': instance.halfLifeSecs,
      'vault': instance.vault,
      'pool': instance.pool,
      'treasury': instance.treasury,
      'paused': instance.paused,
      'close_position_min_delay_secs': instance.closePositionMinDelaySecs,
      'close_position_before_settle_secs':
          instance.closePositionBeforeSettleSecs,
      'deducted_fee_bps': instance.deductedFeeBps,
      'max_buffer_multiplier': instance.maxBufferMultiplier,
      'buffer_percent': instance.bufferPercent,
      'highest_candle_change_bps': instance.highestCandleChangeBps,
    };
