import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:finality/data/drift/converters/options_converter.dart';
import 'package:finality/data/drift/dao/options_trading_pair_dao.dart';
import 'package:finality/data/drift/entities/options_trading_schedule.dart';
import 'package:finality/data/drift/tables/options_tables.dart';

part 'options_database.g.dart';

@DriftDatabase(
  tables: [
    OptionsTradingPairs,
  ],
  daos: [
    OptionsTradingPairDao,
  ],
)
class OptionsDatabase extends _$OptionsDatabase {
  OptionsDatabase([QueryExecutor? implementation])
      : super(implementation ?? driftDatabase(name: 'options_database'));

  @override
  int get schemaVersion => 1;
}
