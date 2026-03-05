import 'package:finality/data/drift/entities/options_trading_schedule.dart';
import 'package:finality/data/drift/options_database.dart';
import 'package:finality/data/network/model/manic/trading_pair_item_response.dart';
import 'package:finality/domain/options/entities/options_trading_pair_tick.dart';

extension TradingPairMapper on TradingPairItemResponse {
  OptionsTradingPair toOptionsTradingPair() {
    return OptionsTradingPair(
      feedId: feedId,
      baseAsset: baseAsset,
      pairName: label,
      baseAssetName: baseCurrency,
      quoteAssetName: quoteCurrency,
      iconUrl: icon,
      type: type,
      isActive: canTrade,
      timestamp: priceInfo.publishTime,
      tradingSchedule: OptionsTradingSchedule(
        timezone: tradingSchedule.timezone,
        currentStatus: tradingSchedule.currentStatus,
        regularHours: tradingSchedule.regularHours,
        nextCloseTime: tradingSchedule.nextCloseTime,
        nextOpenTime: tradingSchedule.nextOpenTime,
        isHoliday: tradingSchedule.isHoliday,
      ),
      leverageMin: leverageMin,
      leverageMax: leverageMax,
      pipSize: pipSize,
      isPinned: isPinned,
    );
  }
}

extension TradingPairTickMapper on TradingPairItemResponse {
  OptionsTradingPairTick toOptionsTradingPairTick() {
    return OptionsTradingPairTick(
      feedId: feedId,
      baseAsset: baseAsset,
      payout: payoutValue,
      price: priceInfo.price,
      timestamp: priceInfo.publishTime,
    );
  }
}
