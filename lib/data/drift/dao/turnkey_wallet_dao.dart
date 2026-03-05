import 'package:drift/drift.dart';
import 'package:finality/data/drift/turnkey_wallet_database.dart';

import '../tables/turnkey_wallet_tables.dart';

part 'turnkey_wallet_dao.g.dart';

@DriftAccessor(tables: [TurnkeyWallets, TurnkeyUsers])
class TurnkeyWalletDao extends DatabaseAccessor<TurnkeyWalletDatabase>
    with _$TurnkeyWalletDaoMixin {
  TurnkeyWalletDao(super.db);

  // ==================== Wallet Operations ====================

  Future<List<TurnkeyWallet>> loadWallets() => select(turnkeyWallets).get();

  Future<List<TurnkeyWallet>> loadWalletsByUserId(String userId) =>
      (select(turnkeyWallets)..where((tbl) => tbl.userId.equals(userId))).get();

  Future<TurnkeyWallet?> loadWallet(String id) =>
      (select(turnkeyWallets)..where((tbl) => tbl.id.equals(id)))
          .getSingleOrNull();

  Future<int> insertWallet(TurnkeyWalletsCompanion wallet) =>
      into(turnkeyWallets).insert(wallet, mode: InsertMode.insertOrReplace);

  Future<bool> updateWallet(TurnkeyWallet wallet) =>
      update(turnkeyWallets).replace(wallet);

  Future<int> deleteWallet(String id) =>
      (delete(turnkeyWallets)..where((tbl) => tbl.id.equals(id))).go();

  Future<int> deleteWalletsByUserId(String userId) =>
      (delete(turnkeyWallets)..where((tbl) => tbl.userId.equals(userId))).go();

  Stream<List<TurnkeyWallet>> walletsAsStream() =>
      select(turnkeyWallets).watch();

  Stream<List<TurnkeyWallet>> walletsByUserIdAsStream(String userId) =>
      (select(turnkeyWallets)..where((tbl) => tbl.userId.equals(userId)))
          .watch();

  Stream<TurnkeyWallet?> walletAsStream(String id) =>
      (select(turnkeyWallets)..where((tbl) => tbl.id.equals(id)))
          .watchSingleOrNull();

  Future<int> count(String userId) =>
      (select(turnkeyWallets)..where((tbl) => tbl.userId.equals(userId)))
          .get()
          .then((value) => value.length);

  Stream<int> streamCount(String userId) =>
      (select(turnkeyWallets)..where((tbl) => tbl.userId.equals(userId)))
          .watch()
          .map((event) => event.length);

  Future<void> deleteAll() => delete(turnkeyWallets).go();

  Future<List<String>> walletIds() => select(turnkeyWallets)
      .get()
      .then((wallets) => wallets.map((w) => w.id).toList());

  Future<List<String>> walletIdsByUserId(String userId) =>
      (select(turnkeyWallets)..where((tbl) => tbl.userId.equals(userId)))
          .get()
          .then((wallets) => wallets.map((w) => w.id).toList());

  Stream<List<String>> walletIdsAsStream() => select(turnkeyWallets)
      .watch()
      .map((wallets) => wallets.map((w) => w.id).toList());

  Stream<List<String>> walletIdsByUserIdAsStream(String userId) =>
      (select(turnkeyWallets)..where((tbl) => tbl.userId.equals(userId)))
          .watch()
          .map((wallets) => wallets.map((w) => w.id).toList());

  Future<bool> has(String id) =>
      (select(turnkeyWallets)..where((tbl) => tbl.id.equals(id)))
          .getSingleOrNull()
          .then((wallet) => wallet != null);

  Stream<TurnkeyWallet?> live(String id) =>
      (select(turnkeyWallets)..where((tbl) => tbl.id.equals(id)))
          .watchSingleOrNull();

  Future<void> updateWalletName(String walletId, String name) async {
    await (update(turnkeyWallets)..where((tbl) => tbl.id.equals(walletId)))
        .write(TurnkeyWalletsCompanion(
      name: Value(name),
      updatedAt: Value(DateTime.now()),
    ));
  }

  /// Batch upsert wallets - useful for syncing from Turnkey SDK
  Future<void> upsertWallets(List<TurnkeyWalletsCompanion> wallets) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(turnkeyWallets, wallets);
    });
  }
}
