import 'package:finality/data/network/model/manic/market_account_response.dart';
import 'package:json_annotation/json_annotation.dart';

part 'trading_pair_item_response.g.dart';

@JsonSerializable()
class TradingPairItemResponse {
  final String name;
  final String asset;
  @JsonKey(name: 'feed_id')
  final String feedId;
  final String label;
  final String icon;
  @JsonKey(name: 'base_asset')
  final String baseAsset;
  @JsonKey(name: 'base_currency')
  final String baseCurrency;
  @JsonKey(name: 'quote_currency')
  final String quoteCurrency;
  @JsonKey(name: 'pip_size')
  final int pipSize;
  final String type;
  @JsonKey(name: 'leverage_min')
  final int leverageMin;
  @JsonKey(name: 'leverage_max')
  final int leverageMax;
  @JsonKey(name: 'feed_account_info')
  final FeedAccountInfo feedAccountInfo;
  @JsonKey(name: 'market_account_info')
  final MarketAccountResponse marketAccountInfo;
  @JsonKey(name: 'price_info')
  final PriceInfo priceInfo;
  @JsonKey(name: 'can_trade')
  final bool canTrade;
  @JsonKey(name: 'trading_schedule')
  final TradingSchedule tradingSchedule;
  @JsonKey(name: 'call_payout')
  final double? callPayout;
  @JsonKey(name: 'put_payout')
  final double? putPayout;
  @JsonKey(name: 'is_pinned')
  final bool isPinned;
  final double? payout;

  const TradingPairItemResponse({
    required this.name,
    required this.asset,
    required this.feedId,
    required this.label,
    required this.icon,
    required this.baseAsset,
    required this.baseCurrency,
    required this.quoteCurrency,
    required this.pipSize,
    required this.type,
    required this.leverageMin,
    required this.leverageMax,
    required this.feedAccountInfo,
    required this.marketAccountInfo,
    required this.priceInfo,
    required this.canTrade,
    required this.tradingSchedule,
    this.callPayout,
    this.putPayout,
    required this.isPinned,
    this.payout,
  });

  double get payoutValue {
    var callPayoutTemp = callPayout ?? (payout ?? 0);
    var putPayoutTemp = putPayout ?? (payout ?? 0);
    return callPayoutTemp > putPayoutTemp ? callPayoutTemp : putPayoutTemp;
  }

  factory TradingPairItemResponse.fromJson(Map<String, dynamic> json) =>
      _$TradingPairItemResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TradingPairItemResponseToJson(this);
}

@JsonSerializable()
class FeedAccountInfo {
  final int price;
  final int conf;
  final int expo;
  @JsonKey(name: 'publish_time')
  final int publishTime;

  const FeedAccountInfo({
    required this.price,
    required this.conf,
    required this.expo,
    required this.publishTime,
  });

  factory FeedAccountInfo.fromJson(Map<String, dynamic> json) =>
      _$FeedAccountInfoFromJson(json);

  Map<String, dynamic> toJson() => _$FeedAccountInfoToJson(this);
}

@JsonSerializable()
class PriceInfo {
  final String price;
  @JsonKey(name: 'publish_time')
  final int publishTime;
  @JsonKey(name: 'is_active')
  final bool isActive;

  const PriceInfo({
    required this.price,
    required this.publishTime,
    required this.isActive,
  });

  factory PriceInfo.fromJson(Map<String, dynamic> json) =>
      _$PriceInfoFromJson(json);

  Map<String, dynamic> toJson() => _$PriceInfoToJson(this);
}

@JsonSerializable()
class TradingSchedule {
  final String timezone;
  @JsonKey(name: 'current_status')
  final String currentStatus;
  @JsonKey(name: 'regular_hours')
  final String regularHours;
  @JsonKey(name: 'next_close_time')
  final int? nextCloseTime;
  @JsonKey(name: 'next_open_time')
  final int? nextOpenTime;
  @JsonKey(name: 'is_holiday')
  final bool isHoliday;

  const TradingSchedule({
    required this.timezone,
    required this.currentStatus,
    required this.regularHours,
    this.nextCloseTime,
    this.nextOpenTime,
    required this.isHoliday,
  });

  factory TradingSchedule.fromJson(Map<String, dynamic> json) =>
      _$TradingScheduleFromJson(json);

  Map<String, dynamic> toJson() => _$TradingScheduleToJson(this);
}
