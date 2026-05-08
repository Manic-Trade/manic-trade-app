import 'package:drift/drift.dart';
import '../entities/token_price.dart';
import '../tables/token_tables.dart';
import '../token_database.dart';

part 'token_price_dao.g.dart';

@DriftAccessor(tables: [TokenPrices])
class TokenPriceDao extends DatabaseAccessor<TokenDatabase>
    with _$TokenPriceDaoMixin {
  TokenPriceDao(super.db);

  Future<TokenPrice?> loadPrice(
    String contractAddress,
    String networkCode,
    String currency,
  ) {
    return (select(tokenPrices)
          ..where((t) =>
              t.contractAddress.equals(contractAddress) &
              t.networkCode.equals(networkCode) &
              t.currency.equals(currency.toUpperCase())))
        .getSingleOrNull();
  }

  Future<bool?> checkAlreadyExists(TokenPrice item, TokenPrice? local) async {
    if (local == null) {
      return false;
    }
    return item.isNewer(local) ? true : null;
  }

  Future<void> savePrices(List<TokenPrice> items) async {
    await transaction(() async {
      for (final item in items) {
        await savePrice(item);
      }
    });
  }

  Future<void> savePrice(TokenPrice item) async {
    var local =
        await loadPrice(item.contractAddress, item.networkCode, item.currency);
    final isAlreadyExists = await checkAlreadyExists(item, local);
    // 如果不需要更新，直接返回
    if (isAlreadyExists == null) return;

    // 如果需要更新，先合并数据
    final tokenToSave = isAlreadyExists ? mergePrice(item, local) : item;

    if (isAlreadyExists == true) {
      await (update(tokenPrices)
            ..where((t) =>
                t.contractAddress.equals(item.contractAddress) &
                t.networkCode.equals(item.networkCode) &
                t.currency.equals(item.currency.toUpperCase())))
          .write(tokenToSave);
    } else if (isAlreadyExists == false) {
      await into(tokenPrices)
          .insert(tokenToSave, mode: InsertMode.insertOrReplace);
    }
  }

  TokenPrice mergePrice(TokenPrice item, TokenPrice? local) {
    return item.mergePrice(local);
  }
}
