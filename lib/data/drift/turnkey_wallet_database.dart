import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'dao/turnkey_account_dao.dart';
import 'dao/turnkey_user_dao.dart';
import 'dao/turnkey_wallet_dao.dart';
import 'tables/turnkey_wallet_tables.dart';

part 'turnkey_wallet_database.g.dart';

@DriftDatabase(
  tables: [
    TurnkeyUsers,
    TurnkeyWallets,
    TurnkeyAccounts,
  ],
  daos: [
    TurnkeyUserDao,
    TurnkeyWalletDao,
    TurnkeyAccountDao,
  ],
)
class TurnkeyWalletDatabase extends _$TurnkeyWalletDatabase {
  TurnkeyWalletDatabase([QueryExecutor? implementation])
      : super(implementation ?? driftDatabase(name: 'turnkey_wallet_database'));

  @override
  int get schemaVersion => 1;

  /// Load all wallets with their accounts for a specific user
  Future<List<TurnkeyWalletWithAccounts>> loadAllWalletAccounts(
      String userId) async {
    final wallets = await turnkeyWalletDao.loadWalletsByUserId(userId);
    final List<TurnkeyWalletWithAccounts> walletAccountsList = [];
    for (final wallet in wallets) {
      final accounts = await turnkeyAccountDao.accountsByIndex(wallet.id, 0);
      walletAccountsList.add(TurnkeyWalletWithAccounts(wallet, accounts, 0));
    }
    return walletAccountsList;
  }

  /// Sync user data from Turnkey SDK
  Future<void> syncUser(TurnkeyUsersCompanion user) async {
    await turnkeyUserDao.insertUser(user);
  }

  /// Sync wallets from Turnkey SDK
  Future<void> syncWallets(List<TurnkeyWalletsCompanion> wallets) async {
    await turnkeyWalletDao.upsertWallets(wallets);
  }

  /// Sync accounts from Turnkey SDK
  Future<void> syncAccounts(List<TurnkeyAccountsCompanion> accounts) async {
    await turnkeyAccountDao.upsertAccounts(accounts);
  }

  /// Full sync: user, wallets, and accounts
  Future<void> fullSync({
    required TurnkeyUsersCompanion user,
    required List<TurnkeyWalletsCompanion> wallets,
    required List<TurnkeyAccountsCompanion> accounts,
  }) async {
    await transaction(() async {
      await syncUser(user);
      await syncWallets(wallets);
      await syncAccounts(accounts);
    });
  }

  /// Clear all data for a specific user
  Future<void> clearUserData(String userId) async {
    await transaction(() async {
      // Get all wallets for this user
      final wallets = await turnkeyWalletDao.loadWalletsByUserId(userId);
      // Delete accounts for each wallet
      for (final wallet in wallets) {
        await turnkeyAccountDao.deleteAccountsByWalletId(wallet.id);
      }
      // Delete all wallets for this user
      await turnkeyWalletDao.deleteWalletsByUserId(userId);
      // Delete the user
      await turnkeyUserDao.deleteUser(userId);
    });
  }

  /// Clear all data in the database
  Future<void> clearAll() async {
    await transaction(() async {
      await turnkeyAccountDao.deleteAll();
      await turnkeyWalletDao.deleteAll();
      await turnkeyUserDao.deleteAll();
    });
  }
}

/// A class representing a Turnkey wallet with its associated accounts
class TurnkeyWalletWithAccounts {
  final TurnkeyWallet wallet;
  final List<TurnkeyAccount> accounts;
  final int accountIndex;

  const TurnkeyWalletWithAccounts(
    this.wallet,
    this.accounts,
    this.accountIndex,
  );

  bool get isAllAccounts => accounts.length > 1;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TurnkeyWalletWithAccounts &&
          runtimeType == other.runtimeType &&
          wallet == other.wallet &&
          accounts == other.accounts &&
          accountIndex == other.accountIndex;

  @override
  int get hashCode => Object.hash(wallet, accounts, accountIndex);
}
