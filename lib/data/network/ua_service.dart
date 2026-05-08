import 'package:dio/dio.dart';
import 'package:finality/data/network/model/ua/ua_models.dart';
import 'package:retrofit/retrofit.dart';

part 'ua_service.g.dart';

@RestApi()
abstract class UAService {
  factory UAService(Dio dio, {String? baseUrl}) =>
      _UAService(dio, baseUrl: baseUrl ?? 'https://account-api-stg.manic.trade');

  /// GET /api/ua/account — 获取用户 UA 账户地址
  @GET('/api/ua/account')
  Future<UAAccountApiResponse> getAccount();

  /// GET /api/assets — 获取支持的链和 Token 列表（公开接口）
  @GET('/api/assets')
  Future<UAAssetsApiResponse> getAssets();

  /// GET /api/ua/balance — 获取 UA 余额
  @GET('/api/ua/balance')
  Future<UABalanceApiResponse> getBalance();

  /// GET /api/ua/solana/balance — 获取 Turnkey Solana USDC 余额（real account）
  @GET('/api/ua/solana/balance')
  Future<UASolanaBalanceApiResponse> getSolanaBalance();

  /// POST /api/ua/sweep — 执行 Sweep（将 UA 资产归集到 Turnkey Solana 钱包）
  @POST('/api/ua/sweep')
  Future<UASweepApiResponse> executeSweep(@Body() Map<String, dynamic> body);
}
