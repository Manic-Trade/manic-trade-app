import 'package:dio/dio.dart';
import 'package:finality/data/network/model/manic/asset_market_account_response.dart';
import 'package:finality/data/network/model/manic/candle_response.dart';
import 'package:finality/data/network/model/manic/trading_pair_item_response.dart';
import 'package:retrofit/retrofit.dart';

part 'manic_price_service.g.dart';

@RestApi()
abstract class ManicPriceService {
  factory ManicPriceService(
    Dio dio, {
    String? baseUrl,
  }) =>
      _ManicPriceService(dio,
          baseUrl: baseUrl ?? 'https://bo-server-api-stg.manic.trade');

  /// 4. Charts: history price - 获取历史价格
  @GET('/charts/historic-price')
  Future<CandleResponse> getHistoricPrice(
    @CancelRequest() CancelToken? cancelToken,
    @Query('asset') String asset,
    @Query('duration') int duration,
    @Query('timeframe') int timeframe,
    @Query('end_time') int? endTime,
  );

  /// 17. Get trading pairs - 获取交易对列表
  @GET('/users/assets')
  Future<List<TradingPairItemResponse>> getTradingPairs();

  /// Get asset account - 获取资产账户信息
  @GET('/users/asset/account')
  Future<AssetMarketAccountResponse> getAssetMarketAccount(
    @Query('asset') String asset,
    @CancelRequest() CancelToken? cancelToken,
  );

 
}
