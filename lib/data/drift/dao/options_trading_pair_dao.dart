import 'package:drift/drift.dart';
import 'package:finality/data/drift/options_database.dart';
import 'package:finality/data/drift/tables/options_tables.dart';

part 'options_trading_pair_dao.g.dart';

@DriftAccessor(tables: [OptionsTradingPairs])
class OptionsTradingPairDao extends DatabaseAccessor<OptionsDatabase>
    with _$OptionsTradingPairDaoMixin {
  OptionsTradingPairDao(super.db);

  Future<void> saveItem(OptionsTradingPair item) {
    return into(optionsTradingPairs).insertOnConflictUpdate(item);
  }

  Future<void> saveItems(List<OptionsTradingPair> items) {
    return batch((b) {
      b.insertAllOnConflictUpdate(optionsTradingPairs, items);
    });
  }

  Future<OptionsTradingPair?> loadItem(String feedId) {
    return (select(optionsTradingPairs)..where((t) => t.feedId.equals(feedId))).getSingleOrNull();
  }

  Future<List<OptionsTradingPair>> loadAllItems() {
    return select(optionsTradingPairs).get();
  }

  Stream<OptionsTradingPair?> streamItem(String feedId) {
    return (select(optionsTradingPairs)..where((t) => t.feedId.equals(feedId))).watchSingleOrNull();
  }

  Stream<List<OptionsTradingPair>> streamItems() {
    return select(optionsTradingPairs).watch();
  }
}
