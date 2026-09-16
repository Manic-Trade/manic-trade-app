// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trading_pair_item_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TradingPairItemResponse _$TradingPairItemResponseFromJson(
        Map<String, dynamic> json) =>
    TradingPairItemResponse(
      name: json['name'] as String,
      asset: json['asset'] as String,
      feedId: json['feed_id'] as String,
      label: json['label'] as String,
      icon: json['icon'] as String,
      baseAsset: json['base_asset'] as String,
      baseCurrency: json['base_currency'] as String,
      quoteCurrency: json['quote_currency'] as String,
      pipSize: (json['pip_size'] as num).toInt(),
      type: json['type'] as String,
      leverageMin: (json['leverage_min'] as num).toInt(),
      leverageMax: (json['leverage_max'] as num).toInt(),
      feedAccountInfo: FeedAccountInfo.fromJson(
          json['feed_account_info'] as Map<String, dynamic>),
      marketAccountInfo: MarketAccountResponse.fromJson(
          json['market_account_info'] as Map<String, dynamic>),
      priceInfo: PriceInfo.fromJson(json['price_info'] as Map<String, dynamic>),
      canTrade: json['can_trade'] as bool,
      tradingSchedule: TradingSchedule.fromJson(
          json['trading_schedule'] as Map<String, dynamic>),
      callPayout: (json['call_payout'] as num?)?.toDouble(),
      putPayout: (json['put_payout'] as num?)?.toDouble(),
      isPinned: json['is_pinned'] as bool,
      payout: (json['payout'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$TradingPairItemResponseToJson(
        TradingPairItemResponse instance) =>
    <String, dynamic>{
      'name': instance.name,
      'asset': instance.asset,
      'feed_id': instance.feedId,
      'label': instance.label,
      'icon': instance.icon,
      'base_asset': instance.baseAsset,
      'base_currency': instance.baseCurrency,
      'quote_currency': instance.quoteCurrency,
      'pip_size': instance.pipSize,
      'type': instance.type,
      'leverage_min': instance.leverageMin,
      'leverage_max': instance.leverageMax,
      'feed_account_info': instance.feedAccountInfo,
      'market_account_info': instance.marketAccountInfo,
      'price_info': instance.priceInfo,
      'can_trade': instance.canTrade,
      'trading_schedule': instance.tradingSchedule,
      'call_payout': instance.callPayout,
      'put_payout': instance.putPayout,
      'is_pinned': instance.isPinned,
      'payout': instance.payout,
    };

FeedAccountInfo _$FeedAccountInfoFromJson(Map<String, dynamic> json) =>
    FeedAccountInfo(
      price: (json['price'] as num).toInt(),
      conf: (json['conf'] as num).toInt(),
      expo: (json['expo'] as num).toInt(),
      publishTime: (json['publish_time'] as num).toInt(),
    );

Map<String, dynamic> _$FeedAccountInfoToJson(FeedAccountInfo instance) =>
    <String, dynamic>{
      'price': instance.price,
      'conf': instance.conf,
      'expo': instance.expo,
      'publish_time': instance.publishTime,
    };

PriceInfo _$PriceInfoFromJson(Map<String, dynamic> json) => PriceInfo(
      price: json['price'] as String,
      publishTime: (json['publish_time'] as num).toInt(),
      isActive: json['is_active'] as bool,
    );

Map<String, dynamic> _$PriceInfoToJson(PriceInfo instance) => <String, dynamic>{
      'price': instance.price,
      'publish_time': instance.publishTime,
      'is_active': instance.isActive,
    };

TradingSchedule _$TradingScheduleFromJson(Map<String, dynamic> json) =>
    TradingSchedule(
      timezone: json['timezone'] as String,
      currentStatus: json['current_status'] as String,
      regularHours: json['regular_hours'] as String,
      nextCloseTime: (json['next_close_time'] as num?)?.toInt(),
      nextOpenTime: (json['next_open_time'] as num?)?.toInt(),
      isHoliday: json['is_holiday'] as bool,
    );

Map<String, dynamic> _$TradingScheduleToJson(TradingSchedule instance) =>
    <String, dynamic>{
      'timezone': instance.timezone,
      'current_status': instance.currentStatus,
      'regular_hours': instance.regularHours,
      'next_close_time': instance.nextCloseTime,
      'next_open_time': instance.nextOpenTime,
      'is_holiday': instance.isHoliday,
    };
