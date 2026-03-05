import 'dart:async';

import 'package:dio/dio.dart';
import 'package:finality/core/logger.dart';
import 'package:finality/di/injector.dart';
import 'package:finality/domain/auth/wallet_auth_manager.dart';
import 'package:finality/services/wallet/wallet_service.dart';
import 'package:synchronized/synchronized.dart';

class WalletAuthInterceptor extends Interceptor {
  final WalletAuthManager _walletAuthManager;
  Completer<String>? _loginCompleter;
  final _lock = Lock(); // 添加 synchronized 包的 Lock

  WalletAuthInterceptor(this._walletAuthManager);

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      await _addAuthHeader(options);
      handler.next(options);
    } catch (error, stackTrace) {
      logger.e("SiweAuthInterceptor", error: error, stackTrace: stackTrace);
      handler.reject(DioException(requestOptions: options, error: error));
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    logger.e("SiweAuthInterceptor", error: err);
    if (err.response?.statusCode == 401) {
      // 获取当前钱包
      if (injector.isRegistered<WalletService>()) {
        final walletService = injector<WalletService>();
        final currentWalletAccounts = walletService.walletAccounts.value;

        if (currentWalletAccounts != null) {
          // 清除 access token
          await _walletAuthManager
              .logoutWallet(currentWalletAccounts.wallet.id);
          // 重新添加认证头并重试请求
          final options = err.requestOptions;
          await _addAuthHeader(options);

          // 使用新的options重试请求
          final dio = Dio();
          final response = await dio.fetch(options);
          return handler.resolve(response);
        }
      }
    }
    handler.next(err);
  }

  Future<void> _addAuthHeader(RequestOptions options) async {
    if (!injector.isRegistered<WalletService>()) return;

    final walletService = injector<WalletService>();
    final walletAccounts = walletService.walletAccounts.value;
    if (walletAccounts == null) return;

    final walletId = walletAccounts.wallet.id;

    // 先尝试获取 token，这一步不需要加锁
    String? accessToken = await _walletAuthManager.isWalletLoggedIn(walletId)
        ? await _walletAuthManager.getAccessToken(walletId)
        : null;

    // 只有在需要登录时才加锁
    accessToken ??= await _lock.synchronized(() async {
      // 再次检查 token，因为可能在等待锁的过程中已经被其他请求获取了
      String? token = await _walletAuthManager.isWalletLoggedIn(walletId)
          ? await _walletAuthManager.getAccessToken(walletId)
          : null;
      if (token != null) return token;

      if (_loginCompleter != null) {
        return await _loginCompleter!.future;
      }

      _loginCompleter = Completer<String>();
      try {
        token =
            (await _walletAuthManager.loginByWalletAccounts(walletAccounts))
                .token;

        _loginCompleter!.complete(token);
        return token;
      } catch (e, stackTrace) {
        logger.e("_addAuthHeader", error: e, stackTrace: stackTrace);
        _loginCompleter!.completeError(e);
        rethrow;
      } finally {
        _loginCompleter = null;
      }
    });

    options.headers['Authorization'] = 'Bearer $accessToken';
  }
}
