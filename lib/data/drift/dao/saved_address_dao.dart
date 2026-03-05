import 'package:drift/drift.dart';
import '../user_preferences_database.dart';
import '../tables/user_preferences_tables.dart';

part 'saved_address_dao.g.dart';

@DriftAccessor(tables: [SavedAddresses])
class SavedAddressDao extends DatabaseAccessor<UserPreferencesDatabase>
    with _$SavedAddressDaoMixin {
  SavedAddressDao(super.db);

  Stream<List<SavedAddress>> streamItems() {
    return (select(savedAddresses)).watch();
  }

  Future<void> insertItem(SavedAddress item) {
    return into(savedAddresses).insertOnConflictUpdate(item);
  }

  Future<void> deleteItem(SavedAddress item) {
    return (delete(savedAddresses)
          ..where((t) =>
              t.networkCode.equals(item.networkCode) &
              t.address.equals(item.address)))
        .go();
  }
}
