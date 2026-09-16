import 'package:drift/drift.dart';

import '../entities/token.dart';
import '../entities/token_holding.dart';
import '../entities/token_price.dart';

@UseRowClass(Token)
class Tokens extends Table {
  TextColumn get networkCode => text()();
  TextColumn get contractAddress => text()();
  TextColumn get symbol => text()();
  TextColumn get name => text()();
  IntColumn get decimals => integer()();
  TextColumn get iconUrl => text()();
  DateTimeColumn get tokenCreated => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {networkCode, contractAddress};
}

@UseRowClass(TokenHolding)
class TokenHoldings extends Table {
  TextColumn get networkCode => text()();
  TextColumn get contractAddress => text()();
  TextColumn get holderAddress => text()();
  TextColumn get balance => text()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {contractAddress, networkCode, holderAddress};
}

@UseRowClass(TokenPrice)
class TokenPrices extends Table {
  TextColumn get networkCode => text()();
  TextColumn get contractAddress => text()();
  TextColumn get currency => text()();
  TextColumn get price => text()();
  RealColumn get change24h => real().nullable()();
  DateTimeColumn get time => dateTime()();

  @override
  Set<Column> get primaryKey => {contractAddress, networkCode, currency};
}

