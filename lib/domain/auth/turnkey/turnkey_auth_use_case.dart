import 'package:convert/convert.dart';
import 'package:dio/dio.dart';
import 'package:finality/core/logger.dart';
import 'package:finality/data/network/manic_auth_data_source.dart';
import 'package:finality/domain/auth/auth_exceptions.dart';
import 'package:finality/domain/auth/auth_result.dart';
import 'package:finality/services/turnkey/turnkey_manager.dart';
import 'package:solana/base58.dart';
import 'package:turnkey_sdk_flutter/turnkey_sdk_flutter.dart';

class TurnkeyAuthUseCase {
  final ManicAuthDataSource _remote;
  final TurnkeyManager _turnkeyManager;

  TurnkeyAuthUseCase(this._remote, this._turnkeyManager);

  Future<AuthResult> execute(v1WalletAccount turnkeySolanaAccount) async {
    try {
      // 1. 获取 challenge message（含 nonce）
      final challenge =
          await _remote.getChallenge(turnkeySolanaAccount.address);
      final message = challenge.message;

      // 2. 使用 Turnkey 签名 challenge message
      final response = await _turnkeyManager.signMessage(
        walletAccount: turnkeySolanaAccount,
        message: message,
      );
      final rBytes = hex.decode(response.r);
      final sBytes = hex.decode(response.s);
      // Solana签名是64字节：r(32字节) + s(32字节)
      // v字段在Solana中不使用（那是以太坊签名用的）
      final signatureBytes = [...rBytes, ...sBytes];
      // 将签名编码为base58字符串
      final signedMessage = base58encode(signatureBytes);

      // 3. 使用签名后的 challenge 登录
      final signInResponse = await _remote.signIn(
          address: turnkeySolanaAccount.address,
          message: message,
          signedMessage: signedMessage);
      return AuthResult(token: signInResponse.token);
    } catch (error, stackTrace) {
      if (error is DioException) {
        var statusCode = error.response?.statusCode;
        if (statusCode == 404 || statusCode == 400) {
          throw UserNotFoundException(address: turnkeySolanaAccount.address);
        }
      }
      logger.e("TurnkeyAuthUseCase", error: error, stackTrace: stackTrace);
      rethrow;
    }
  }
}
