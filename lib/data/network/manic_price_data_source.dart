import 'package:dio/dio.dart';
import 'package:finality/data/network/manic_price_service.dart';
import 'package:finality/data/network/model/manic/candle_response.dart';
import 'package:finality/data/network/model/manic/market_account_response.dart';
import 'package:finality/data/network/model/manic/trading_pair_item_response.dart';

class ManicPriceDataSource {
  final ManicPriceService _service;

  ManicPriceDataSource(this._service);

  /// 获取历史价格
  Future<CandleResponse> getHistoricPrice(
      String asset, int duration, int timeframe,
      {CancelToken? cancelToken, int? endTime}) {
    return _service.getHistoricPrice(
        cancelToken, asset, duration, timeframe, endTime);
  }

  /// 获取交易对列表
  Future<List<TradingPairItemResponse>> getTradingPairs() {
    return _service.getTradingPairs();
  }

  /// 获取资产账户信息
  Future<MarketAccountResponse> getAssetMarketAccount(String asset,
      {CancelToken? cancelToken}) async {
    final response = await _service.getAssetMarketAccount(asset, cancelToken);
    return response.marketAccountInfo;
  }

}
