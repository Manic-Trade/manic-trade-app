import 'package:finality/data/network/model/ua/ua_models.dart';
import 'package:finality/data/network/ua_service.dart';

/// UA（Universal Account）API 数据源
/// 使用独立的 UAService 实例，Bearer Token 通过 WalletAuthInterceptor 注入
class UADataSource {
  final UAService _service;

  UADataSource(this._service);

  /// GET /api/ua/account — 获取用户 UA 账户地址
  Future<UAAccountData> getAccount() async =>
      (await _service.getAccount()).data;

  /// GET /api/assets — 获取支持的链和 Token 列表
  Future<List<UAChain>> getAssets() async =>
      (await _service.getAssets()).chains;

  /// GET /api/ua/balance — 获取 UA 余额
  Future<UABalanceData> getBalance() async =>
      (await _service.getBalance()).data;

  /// GET /api/ua/solana/balance — 获取 Turnkey Solana USDC 余额（real account）
  Future<UASolanaBalanceData> getSolanaBalance() async =>
      (await _service.getSolanaBalance()).data;

  /// POST /api/ua/sweep — 执行 Sweep（将 UA 资产归集到 Turnkey Solana 钱包）
  Future<UASweepData> executeSweep() async =>
      (await _service.executeSweep({})).data;
}
