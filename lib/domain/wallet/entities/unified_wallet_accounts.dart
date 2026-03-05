import 'package:collection/collection.dart';
import 'package:finality/common/constants/blockchain.dart';
import 'package:finality/data/drift/turnkey_wallet_database.dart';
import 'package:finality/data/model/network_address_pair.dart';
import 'package:finality/domain/wallet/entities/unified_account.dart';
import 'package:finality/domain/wallet/entities/unified_wallet.dart';

class UnifiedWalletAccounts {
  final UnifiedWallet wallet;
  final List<UnifiedAccount> accounts;

  UnifiedWalletAccounts({
    required this.wallet,
    required this.accounts,
  });

  /// 从 Turnkey 钱包创建（从本地数据库）
  factory UnifiedWalletAccounts.fromTurnkey(
      TurnkeyWalletWithAccounts turnkeyWalletWithAccounts) {
    return UnifiedWalletAccounts(
      wallet: UnifiedWallet.fromTurnkey(turnkeyWalletWithAccounts.wallet),
      accounts: turnkeyWalletWithAccounts.accounts
          .map((a) => UnifiedAccount.fromTurnkey(a))
          .toList(),
    );
  }

  /// 获取 Solana 账户
  UnifiedAccount? getSolanaAccount() {
    return accounts.firstWhereOrNull(
      (account) => account.networkCode == NetworkCodes.solana,
    );
  }

  /// 获取网络地址对列表
  List<NetworkAddressPair> get networkAddressPairs {
    return accounts
        .map((account) =>
            NetworkAddressPair(account.networkCode, account.address))
        .toList();
  }
}
