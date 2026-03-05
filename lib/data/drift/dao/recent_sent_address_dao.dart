import 'package:drift/drift.dart';
import '../user_preferences_database.dart';
import '../tables/user_preferences_tables.dart';

part 'recent_sent_address_dao.g.dart';

@DriftAccessor(tables: [RecentSentAddresses])
class RecentSentAddressDao extends DatabaseAccessor<UserPreferencesDatabase>
    with _$RecentSentAddressDaoMixin {
  RecentSentAddressDao(super.db);

  Stream<List<RecentSentAddress>> streamItems() {
    return (select(recentSentAddresses)
          ..orderBy([(t) => OrderingTerm.desc(t.lastUsedAt)]))
        .watch();
  }

  Future<void> insertItem(RecentSentAddress item) {
    return into(recentSentAddresses).insertOnConflictUpdate(item);
  }

  Future<void> deleteItem(RecentSentAddress item) {
    return (delete(recentSentAddresses)
          ..where((t) =>
              t.networkCode.equals(item.networkCode) &
              t.address.equals(item.address)))
        .go();
  }

  Future<void> deleteAllItems() {
    return (delete(recentSentAddresses)).go();
  }
}
