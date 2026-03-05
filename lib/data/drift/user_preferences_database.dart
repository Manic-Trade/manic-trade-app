import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'dao/recent_sent_address_dao.dart';
import 'dao/saved_address_dao.dart';
import 'tables/user_preferences_tables.dart';

part 'user_preferences_database.g.dart';

@DriftDatabase(
  tables: [
    RecentSentAddresses,
    SavedAddresses,
  ],
  daos: [
    RecentSentAddressDao,
    SavedAddressDao,
  ],
)
class UserPreferencesDatabase extends _$UserPreferencesDatabase {
  UserPreferencesDatabase([QueryExecutor? implementation])
      : super(
            implementation ?? driftDatabase(name: 'user_preferences_database'));

  @override
  int get schemaVersion => 1;
}
