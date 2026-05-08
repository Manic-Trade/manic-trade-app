import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'dao/token_dao.dart';
import 'dao/token_holder_dao.dart';
import 'dao/token_price_dao.dart';
import 'entities/token.dart';
import 'entities/token_holding.dart';
import 'entities/token_price.dart';

import 'tables/token_tables.dart';

part 'token_database.g.dart';

@DriftDatabase(
  tables: [
    Tokens,
    TokenHoldings,
    TokenPrices,
  ],
  daos: [
    TokenDao,
    TokenHolderDao,
    TokenPriceDao,
  ],
)
class TokenDatabase extends _$TokenDatabase {
  TokenDatabase([QueryExecutor? implementation])
      : super(implementation ?? driftDatabase(name: 'token_database'));

  @override
  int get schemaVersion => 1;
}
