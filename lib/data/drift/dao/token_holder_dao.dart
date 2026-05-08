import 'package:drift/drift.dart';
import 'package:rxdart/rxdart.dart';
import '../entities/token_holding.dart';
import '../tables/token_tables.dart';
import '../token_database.dart';
import '../../../data/model/network_address_pair.dart';

part 'token_holder_dao.g.dart';

@DriftAccessor(tables: [TokenHoldings])
class TokenHolderDao extends DatabaseAccessor<TokenDatabase>
    with _$TokenHolderDaoMixin {
  TokenHolderDao(super.db);

  Future<TokenHolding?> loadHolding(
    String contractAddress,
    String networkCode,
    String address,
  ) {
    return (select(tokenHoldings)
          ..where((t) =>
              t.contractAddress.equals(contractAddress) &
              t.networkCode.equals(networkCode) &
              t.holderAddress.equals(address)))
        .getSingleOrNull();
  }

  Future<List<TokenHolding>> loadHoldings(
    String networkCode,
    String holderAddress,
  ) {
    return (select(tokenHoldings)
          ..where((t) =>
              t.networkCode.equals(networkCode) &
              t.holderAddress.equals(holderAddress) &
              t.balance.isNotValue('0')))
        .get();
  }

  Stream<List<TokenHolding>> streamHoldings(
    String networkCode,
    String holderAddress,
  ) {
    return (select(tokenHoldings)
          ..where((t) =>
              t.networkCode.equals(networkCode) &
              t.holderAddress.equals(holderAddress) &
              t.balance.isNotValue('0')))
        .watch();
  }

  Stream<List<TokenHolding>> streamAllHoldings(
      List<NetworkAddressPair> networkAddressPairs) {
    if (networkAddressPairs.isEmpty) {
      // 如果列表为空，返回空列表流
      return Stream.value([]);
    } else if (networkAddressPairs.length == 1) {
      // 如果只有一个网络地址对，直接返回该地址的持有信息流
      return streamHoldings(
          networkAddressPairs[0].networkCode, networkAddressPairs[0].address);
    }
    // 处理多个网络地址对的情况
    final uniquePairs = networkAddressPairs.toSet(); // 去重
    final streams = uniquePairs
        .map((e) => streamHoldings(e.networkCode, e.address))
        .toList();
    // 合并所有流的最新数据
    return Rx.combineLatestList(streams)
        .map((lists) => lists.expand((list) => list).toList());
  }

  Future<void> deleteHoldings(
    String networkCode,
    String holderAddress,
  ) {
    return (delete(tokenHoldings)
          ..where((t) =>
              t.networkCode.equals(networkCode) &
              t.holderAddress.equals(holderAddress)))
        .go();
  }

  Future<void> deleteAllHoldings(
      Iterable<NetworkAddressPair> networkAddressPairs) async {
    for (var pair in networkAddressPairs) {
      await deleteHoldings(pair.networkCode, pair.address);
    }
  }

  Future<void> replaceHoldings(
    String networkCode,
    String holderAddress,
    List<TokenHolding> items,
  ) async {
    await transaction(() async {
      await deleteHoldings(networkCode, holderAddress);
      if (items.isNotEmpty) {
        await batch((batch) {
          batch.insertAll(
            tokenHoldings,
            items.map((item) => TokenHoldingsCompanion.insert(
                  networkCode: item.networkCode,
                  contractAddress: item.contractAddress,
                  holderAddress: item.holderAddress,
                  balance: item.balance,
                  updatedAt: item.updatedAt == null
                      ? const Value.absent()
                      : Value(item.updatedAt),
                )),
            mode: InsertMode.insertOrReplace,
          );
        });
      }
    });
  }

  Future<void> saveHoldings(List<TokenHolding> items) async {
    if (items.isEmpty) return;
    if (items.length == 1) {
      await saveHolding(items[0]);
      return;
    }

    await transaction(() async {
      // 1. 批量获取所有已存在的记录
      final existingItems = await (select(tokenHoldings)
            ..where((t) =>
                t.contractAddress
                    .isIn(items.map((e) => e.contractAddress).toList()) &
                t.networkCode.isIn(items.map((e) => e.networkCode).toList()) &
                t.holderAddress
                    .isIn(items.map((e) => e.holderAddress).toList())))
          .get();

      // 2. 创建现有记录的查找映射
      final existingMap = {
        for (var item in existingItems)
          '${item.contractAddress}_${item.networkCode}_${item.holderAddress}':
              item
      };

      // 3. 分离需要更新和插入的记录
      final toUpdate = <TokenHolding>[];
      final toInsert = <TokenHolding>[];

      for (final item in items) {
        final key =
            '${item.contractAddress}_${item.networkCode}_${item.holderAddress}';
        final existing = existingMap[key];

        if (existing != null && item.isNewer(existing)) {
          toUpdate.add(item);
        } else if (existing == null) {
          toInsert.add(item);
        }
      }

      // 4. 批量插入新记录
      if (toInsert.isNotEmpty) {
        await batch((batch) {
          batch.insertAll(
            tokenHoldings,
            toInsert, // 直接使用 TokenHolding 对象
            mode: InsertMode.insertOrReplace,
          );
        });
      }

      // 5. 批量更新现有记录
      if (toUpdate.isNotEmpty) {
        await batch((batch) {
          for (final item in toUpdate) {
            batch.update(
              tokenHoldings,
              item, // 直接使用 TokenHolding 对象
              where: (t) =>
                  t.contractAddress.equals(item.contractAddress) &
                  t.networkCode.equals(item.networkCode) &
                  t.holderAddress.equals(item.holderAddress),
            );
          }
        });
      }
    });
  }

  Future<void> saveHolding(TokenHolding item) async {
    final isAlreadyExists = await checkAlreadyExists(item);

    if (isAlreadyExists == null) return;

    final companion = TokenHoldingsCompanion(
      networkCode: Value(item.networkCode),
      contractAddress: Value(item.contractAddress),
      holderAddress: Value(item.holderAddress),
      balance: Value(item.balance),
      updatedAt:
          item.updatedAt == null ? const Value.absent() : Value(item.updatedAt),
    );

    if (isAlreadyExists) {
      await (update(tokenHoldings)
            ..where((t) =>
                t.contractAddress.equals(item.contractAddress) &
                t.networkCode.equals(item.networkCode) &
                t.holderAddress.equals(item.holderAddress)))
          .write(companion);
    } else {
      await into(tokenHoldings)
          .insert(companion, mode: InsertMode.insertOrReplace);
    }
  }

  Future<bool?> checkAlreadyExists(TokenHolding item) async {
    var local = await loadHolding(
        item.contractAddress, item.networkCode, item.holderAddress);
    if (local == null) {
      return false;
    }
    return item.isNewer(local) ? true : null;
  }
}
