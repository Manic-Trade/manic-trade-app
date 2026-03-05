import 'package:drift/drift.dart';

@DataClassName('RecentSentAddress')
class RecentSentAddresses extends Table {
  TextColumn get networkCode => text()();
  TextColumn get address => text()();
  DateTimeColumn get lastUsedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {networkCode, address};
}

@DataClassName('SavedAddress')
class SavedAddresses extends Table {
  TextColumn get networkCode => text()();
  TextColumn get address => text()();
  TextColumn get label => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {networkCode, address};
}
