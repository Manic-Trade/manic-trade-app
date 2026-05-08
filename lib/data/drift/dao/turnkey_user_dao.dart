import 'package:drift/drift.dart';
import 'package:finality/data/drift/turnkey_wallet_database.dart';

import '../tables/turnkey_wallet_tables.dart';

part 'turnkey_user_dao.g.dart';

@DriftAccessor(tables: [TurnkeyUsers])
class TurnkeyUserDao extends DatabaseAccessor<TurnkeyWalletDatabase>
    with _$TurnkeyUserDaoMixin {
  TurnkeyUserDao(super.db);

  Future<List<TurnkeyUser>> loadUsers() => select(turnkeyUsers).get();

  Future<TurnkeyUser?> loadUser(String id) =>
      (select(turnkeyUsers)..where((tbl) => tbl.id.equals(id)))
          .getSingleOrNull();

  Future<TurnkeyUser?> loadUserByEmail(String email) =>
      (select(turnkeyUsers)..where((tbl) => tbl.email.equals(email)))
          .getSingleOrNull();

  Future<TurnkeyUser?> loadUserByPhone(String phone) =>
      (select(turnkeyUsers)..where((tbl) => tbl.phone.equals(phone)))
          .getSingleOrNull();

  Future<int> insertUser(TurnkeyUsersCompanion user) =>
      into(turnkeyUsers).insert(user, mode: InsertMode.insertOrReplace);

  Future<bool> updateUser(TurnkeyUser user) =>
      update(turnkeyUsers).replace(user);

  Future<int> deleteUser(String id) =>
      (delete(turnkeyUsers)..where((tbl) => tbl.id.equals(id))).go();

  Stream<List<TurnkeyUser>> usersAsStream() => select(turnkeyUsers).watch();

  Stream<TurnkeyUser?> userAsStream(String id) =>
      (select(turnkeyUsers)..where((tbl) => tbl.id.equals(id)))
          .watchSingleOrNull();

  Future<int> count() =>
      select(turnkeyUsers).get().then((value) => value.length);

  Stream<int> streamCount() =>
      select(turnkeyUsers).watch().map((event) => event.length);

  Future<void> deleteAll() => delete(turnkeyUsers).go();

  Future<bool> has(String id) =>
      (select(turnkeyUsers)..where((tbl) => tbl.id.equals(id)))
          .getSingleOrNull()
          .then((user) => user != null);

  Stream<TurnkeyUser?> live(String id) =>
      (select(turnkeyUsers)..where((tbl) => tbl.id.equals(id)))
          .watchSingleOrNull();

  Future<void> updateUserName(String userId, String name) async {
    await (update(turnkeyUsers)..where((tbl) => tbl.id.equals(userId)))
        .write(TurnkeyUsersCompanion(
      name: Value(name),
      updatedAt: Value(DateTime.now()),
    ));
  }

  Future<void> updateUserEmail(String userId, String? email) async {
    await (update(turnkeyUsers)..where((tbl) => tbl.id.equals(userId)))
        .write(TurnkeyUsersCompanion(
      email: Value(email),
      updatedAt: Value(DateTime.now()),
    ));
  }

  Future<void> updateUserPhone(String userId, String? phone) async {
    await (update(turnkeyUsers)..where((tbl) => tbl.id.equals(userId)))
        .write(TurnkeyUsersCompanion(
      phone: Value(phone),
      updatedAt: Value(DateTime.now()),
    ));
  }

  /// Batch upsert users - useful for syncing from Turnkey SDK
  Future<void> upsertUsers(List<TurnkeyUsersCompanion> users) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(turnkeyUsers, users);
    });
  }
}

