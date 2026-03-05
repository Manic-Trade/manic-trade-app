import 'package:collection/collection.dart';
import 'package:finality/common/constants/blockchain.dart';
import 'package:finality/data/network/manic_auth_data_source.dart';
import 'package:finality/domain/auth/auth_result.dart';
import 'package:finality/domain/auth/turnkey/turnkey_auth_use_case.dart';
import 'package:finality/domain/auth/wallet_auth_store.dart';
import 'package:finality/domain/wallet/entities/unified_wallet_accounts.dart';
import 'package:finality/services/turnkey/turnkey_manager.dart';
import 'package:turnkey_sdk_flutter/turnkey_sdk_flutter.dart';

class WalletAuthManager {
  final TurnkeyAuthUseCase _turnkeyAuthUseCase;

  final WalletAuthStore _storage;
  final TurnkeyManager _turnkeyManager;

  WalletAuthManager(this._storage,
      ManicAuthDataSource manicAuthDataSource, this._turnkeyManager)
      : _turnkeyAuthUseCase = TurnkeyAuthUseCase(manicAuthDataSource, _turnkeyManager);

  /// 登录 Turnkey 钱包
  Future<AuthResult> loginTurnkeyWallet(
      v1WalletAccount turnkeySolanaAccount) async {
    final accessToken = await getAccessToken(turnkeySolanaAccount.walletId);

    if (accessToken == null) {
      final authResult =
          await _turnkeyAuthUseCase.execute(turnkeySolanaAccount);
      await _storage.saveCredentials(
          turnkeySolanaAccount.walletId, authResult.token);
      return authResult;
    } else {
      return AuthResult(token: accessToken);
    }
  }

  Future<AuthResult> loginByWalletAccounts(
      UnifiedWalletAccounts walletAccounts) async {
    await _turnkeyManager.ensureInitialized();
    var turnkeySolanaAccount = walletAccounts.accounts
        .firstWhereOrNull(
          (a) => a.networkCode == NetworkCodes.solana && a.keyIndex == 0,
        )
        ?.turnkeyAccount;
    if (turnkeySolanaAccount == null) {
      throw Exception("Solana account not found in database");
    }
    var v1walletAccount = _turnkeyManager.wallets
        ?.firstWhereOrNull(
          (w) => w.id == turnkeySolanaAccount.walletId,
        )
        ?.accounts
        .firstWhereOrNull(
          (a) => a.address == turnkeySolanaAccount.address,
        );
    if (v1walletAccount == null) {
      throw Exception("Solana account not found in turnkey wallet");
    }
    return await loginTurnkeyWallet(v1walletAccount);
  }

  Future<String?> getAccessToken(String walletId) async {
    return await _storage.getAccessToken(walletId.toString());
  }

  Future<void> logoutWallet(String walletId) async {
    await _storage.removeCredentials(walletId.toString());
  }

  Future<bool> isWalletLoggedIn(String walletId) async {
    return await _storage.hasCredentials(walletId.toString());
  }

  Future<void> logoutAllWallets() async {
    await _storage.removeAllCredentials();
  }
}
