import 'package:finality/data/drift/turnkey_wallet_database.dart';
import 'package:finality/domain/wallet/entities/wallet_source.dart';

/// Turnkey-only wallet entity (Domain layer).
class UnifiedWallet {
  final TurnkeyWallet _turnkeyWallet;

  WalletSource get source => WalletSource.turnkey;

  String get id => _turnkeyWallet.id;

  String get name => _turnkeyWallet.name;

  String? get avatar => null;

  TurnkeyWallet get turnkeyWallet => _turnkeyWallet;

  bool get isTurnkeyWallet => true;

  UnifiedWallet._({required TurnkeyWallet turnkeyWallet})
      : _turnkeyWallet = turnkeyWallet;

  factory UnifiedWallet.fromTurnkey(TurnkeyWallet turnkeyWallet) {
    return UnifiedWallet._(turnkeyWallet: turnkeyWallet);
  }
}
