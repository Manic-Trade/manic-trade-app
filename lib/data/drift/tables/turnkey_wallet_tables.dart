import 'package:drift/drift.dart';

@DataClassName("TurnkeyUser")
class TurnkeyUsers extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get email => text().nullable()();
  TextColumn get phone => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName("TurnkeyWallet")
class TurnkeyWallets extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().references(TurnkeyUsers, #id)();

  TextColumn get name => text()();
    /// True when a given Wallet is exported, false otherwise.
  BoolColumn get exported => boolean().withDefault(const Constant(false))();

  /// True when a given Wallet is imported, false otherwise.
  BoolColumn get imported => boolean().withDefault(const Constant(false))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}


@DataClassName("TurnkeyAccount")
class TurnkeyAccounts extends Table {
  //v1WalletAccount.walletAccountId
  TextColumn get id => text()();
  //v1WalletAccount.walletId
  TextColumn get walletId => text().references(TurnkeyWallets, #id)();
  TextColumn get networkCode => text()();
  TextColumn get address => text()();
  TextColumn get publicKey => text()();
  TextColumn get derivationPath => text()();
  IntColumn get keyIndex => integer()();

  @override
  Set<Column> get primaryKey => {id};
}