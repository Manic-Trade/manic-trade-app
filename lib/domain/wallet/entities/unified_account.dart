import 'package:finality/data/drift/turnkey_wallet_database.dart';

/// 统一的账户实体
/// 目前只支持 Turnkey 账户
class UnifiedAccount {
  final String address;
  final String networkCode;
  final TurnkeyAccount turnkeyAccount;
  final int keyIndex;

  UnifiedAccount({
    required this.address,
    required this.networkCode,
    required this.turnkeyAccount,
    required this.keyIndex,
  });

  String get walletId => turnkeyAccount.walletId;

  String get path => turnkeyAccount.derivationPath;

  /// 获取公钥
  String? get publicKey => turnkeyAccount.publicKey;

  /// 从 Turnkey 账户创建（从本地数据库）
  factory UnifiedAccount.fromTurnkey(TurnkeyAccount account) {
    return UnifiedAccount(
      address: account.address,
      networkCode: account.networkCode,
      turnkeyAccount: account,
      keyIndex: account.keyIndex,
    );
  }
}
