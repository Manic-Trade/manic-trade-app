import 'package:finality/data/drift/turnkey_wallet_database.dart';
import 'package:finality/domain/wallet/entities/wallet_source.dart';

/// Unified account entity (Turnkey-only).
class UnifiedAccount {
  final String address;
  final String networkCode;
  final WalletSource source;
  final TurnkeyAccount? turnkeyAccount;
  final int keyIndex;

  UnifiedAccount({
    required this.address,
    required this.networkCode,
    required this.source,
    this.turnkeyAccount,
    required this.keyIndex,
  });

  String get walletId => turnkeyAccount!.walletId;

  String get path => turnkeyAccount!.derivationPath;

  String? get publicKey => turnkeyAccount?.publicKey;

  factory UnifiedAccount.fromTurnkey(TurnkeyAccount account) {
    return UnifiedAccount(
      address: account.address,
      networkCode: account.networkCode,
      source: WalletSource.turnkey,
      turnkeyAccount: account,
      keyIndex: account.keyIndex,
    );
  }
}
