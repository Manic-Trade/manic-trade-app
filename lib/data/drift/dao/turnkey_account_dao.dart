import 'package:drift/drift.dart';
import 'package:finality/data/drift/turnkey_wallet_database.dart';

import '../tables/turnkey_wallet_tables.dart';

part 'turnkey_account_dao.g.dart';

@DriftAccessor(tables: [TurnkeyAccounts])
class TurnkeyAccountDao extends DatabaseAccessor<TurnkeyWalletDatabase>
    with _$TurnkeyAccountDaoMixin {
  TurnkeyAccountDao(super.db);

  Future<List<TurnkeyAccount>> loadAccounts(String walletId) =>
      (select(turnkeyAccounts)..where((tbl) => tbl.walletId.equals(walletId)))
          .get();

  Future<List<TurnkeyAccount>> accountsByIndex(String walletId, int keyIndex) =>
      (select(turnkeyAccounts)
            ..where((tbl) =>
                tbl.walletId.equals(walletId) & tbl.keyIndex.equals(keyIndex)))
          .get();

  Future<List<TurnkeyAccount>> accountsByIndexAndNetwork(
    String walletId,
    int index,
    String networkCode,
  ) =>
      (select(turnkeyAccounts)
            ..where((tbl) =>
                tbl.walletId.equals(walletId) &
                tbl.keyIndex.equals(index) &
                tbl.networkCode.equals(networkCode)))
          .get();

  Future<List<TurnkeyAccount>> accountsByNetwork(String networkCode) =>
      (select(turnkeyAccounts)
            ..where((tbl) => tbl.networkCode.equals(networkCode)))
          .get();

  Stream<List<TurnkeyAccount>> accountsAsStream(String walletId) =>
      (select(turnkeyAccounts)..where((tbl) => tbl.walletId.equals(walletId)))
          .watch();

  Stream<List<TurnkeyAccount>> walletsAccountsAsStream(List<String> walletIds) =>
      (select(turnkeyAccounts)..where((tbl) => tbl.walletId.isIn(walletIds)))
          .watch();

  Stream<List<TurnkeyAccount>> accountsAsStreamByIndex(
          String walletId, int index) =>
      (select(turnkeyAccounts)
            ..where((tbl) =>
                tbl.walletId.equals(walletId) & tbl.keyIndex.equals(index)))
          .watch();

  Stream<List<TurnkeyAccount>> accountsAsStreamByIndexAndNetwork(
    String walletId,
    int index,
    String networkCode,
  ) =>
      (select(turnkeyAccounts)
            ..where((tbl) =>
                tbl.walletId.equals(walletId) &
                tbl.keyIndex.equals(index) &
                tbl.networkCode.equals(networkCode)))
          .watch();

  Future<TurnkeyAccount?> account(
    String walletId,
    String networkCode,
    String address,
  ) =>
      (select(turnkeyAccounts)
            ..where((tbl) =>
                tbl.walletId.equals(walletId) &
                tbl.networkCode.equals(networkCode) &
                tbl.address.equals(address)))
          .getSingleOrNull();

  Future<TurnkeyAccount?> accountById(String id) =>
      (select(turnkeyAccounts)..where((tbl) => tbl.id.equals(id)))
          .getSingleOrNull();

  Future<TurnkeyAccount?> accountByAddress(String address) =>
      (select(turnkeyAccounts)..where((tbl) => tbl.address.equals(address)))
          .getSingleOrNull();

  Stream<TurnkeyAccount?> accountAsStream(
    String walletId,
    String networkCode,
    String address,
  ) =>
      (select(turnkeyAccounts)
            ..where((tbl) =>
                tbl.walletId.equals(walletId) &
                tbl.networkCode.equals(networkCode) &
                tbl.address.equals(address)))
          .watchSingleOrNull();

  Future<int> insertAccount(TurnkeyAccountsCompanion account) =>
      into(turnkeyAccounts).insert(account, mode: InsertMode.insertOrReplace);

  Future<bool> updateAccount(TurnkeyAccount account) =>
      update(turnkeyAccounts).replace(account);

  Future<int> deleteAccount(String id) =>
      (delete(turnkeyAccounts)..where((tbl) => tbl.id.equals(id))).go();

  Future<int> deleteAccountsByWalletId(String walletId) =>
      (delete(turnkeyAccounts)..where((tbl) => tbl.walletId.equals(walletId)))
          .go();

  Future<void> deleteAll() => delete(turnkeyAccounts).go();

  /// Batch upsert accounts - useful for syncing from Turnkey SDK
  Future<void> upsertAccounts(List<TurnkeyAccountsCompanion> accounts) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(turnkeyAccounts, accounts);
    });
  }

  /// Save accounts with conflict resolution
  Future<void> saveAccounts(List<TurnkeyAccountsCompanion> accounts) async {
    if (accounts.isEmpty) return;
    await batch((batch) {
      batch.insertAllOnConflictUpdate(turnkeyAccounts, accounts);
    });
  }
}

