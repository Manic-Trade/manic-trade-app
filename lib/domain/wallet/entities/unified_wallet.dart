import 'package:finality/data/drift/turnkey_wallet_database.dart';

/// 统一的钱包实体（Domain 层）
/// 目前只支持 Turnkey 钱包
class UnifiedWallet {
  final TurnkeyWallet _turnkeyWallet;

  String get id => _turnkeyWallet.id;

  String get name => _turnkeyWallet.name;

  String? get avatar => null;

  TurnkeyWallet get turnkeyWallet => _turnkeyWallet;

  UnifiedWallet(this._turnkeyWallet);

  /// 从 Turnkey 钱包创建（从本地数据库）
  factory UnifiedWallet.fromTurnkey(TurnkeyWallet turnkeyWallet) {
    return UnifiedWallet(turnkeyWallet);
  }
}
