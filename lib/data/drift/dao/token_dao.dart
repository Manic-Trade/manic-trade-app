import 'package:drift/drift.dart';
import '../entities/token.dart';
import '../tables/token_tables.dart';
import '../token_database.dart';

part 'token_dao.g.dart';

@DriftAccessor(tables: [Tokens])
class TokenDao extends DatabaseAccessor<TokenDatabase> with _$TokenDaoMixin {
  TokenDao(super.db);

  Future<bool> checkTokensIsNotEmpty() {
    return customSelect('SELECT EXISTS(SELECT 1 FROM tokens LIMIT 1) as exists')
        .getSingle()
        .then((row) => row.read<bool>('exists'));
  }

  Future<Token?> loadToken(String contractAddress, String networkCode) {
    return (select(tokens)
          ..where((t) =>
              t.contractAddress.equals(contractAddress) &
              t.networkCode.equals(networkCode)))
        .getSingleOrNull();
  }

  Future<List<Token>> loadTokens(
      List<String> contractAddresses, List<String> networkCodes) {
    return (select(tokens)
          ..where((t) =>
              t.contractAddress.isIn(contractAddresses) &
              t.networkCode.isIn(networkCodes)))
        .get();
  }

  Future<Token?> loadNativeToken(String networkCode) {
    return (select(tokens)
          ..where((t) =>
              t.networkCode.equals(networkCode) &
              (t.contractAddress.equals('0') |
                  t.contractAddress.equals('') |
                  t.contractAddress.equals('0x0'))))
        .getSingleOrNull();
  }

  Future<List<Token>> loadAllTokens() {
    return select(tokens).get();
  }

  Stream<List<Token>> streamAllTokens() {
    return select(tokens).watch();
  }

  Future<void> saveTokens(List<Token> tokens) async {
    for (final token in tokens) {
      await saveToken(token);
    }
  }
  
Future<void> saveToken(Token token) async {
  await transaction(() async {
    final local = await loadToken(token.contractAddress, token.networkCode);
    final isAlreadyExists = checkAlreadyExists(token, local);
    
    // 如果不需要更新，直接返回
    if (isAlreadyExists == null) return;
    
    // 如果需要更新，先合并数据
    final tokenToSave = isAlreadyExists ? mergeToken(token, local) : token;
    
    // 使用 upsert 操作，自动处理插入或更新
    await into(tokens).insertOnConflictUpdate(
      TokensCompanion.insert(
        symbol: tokenToSave.symbol,
        name: tokenToSave.name,
        networkCode: tokenToSave.networkCode,
        decimals: tokenToSave.decimals,
        contractAddress: tokenToSave.contractAddress,
        iconUrl: tokenToSave.iconUrl,
        tokenCreated: tokenToSave.tokenCreated == null
            ? const Value.absent()
            : Value(tokenToSave.tokenCreated),
        updatedAt: tokenToSave.updatedAt == null
            ? const Value.absent()
            : Value(tokenToSave.updatedAt),
      ),
    );
  });
}

  /// 检查token是否需要更新
  /// Returns:
  ///   - null: tokens完全相等或本地版本更新，无需操作
  ///   - false: 本地不存在该token，需要插入
  ///   - true: 本地版本较旧，需要更新
  bool? checkAlreadyExists(Token newToken, Token? local) {
    // 1. 完全相等的情况
    if (local == newToken) {
      return null;
    }

    // 2. 本地不存在的情况
    if (local == null) {
      return false;
    }

    // 3. 比较更新时间
    final localUpdatedTime = local.updatedAt;
    final itemUpdatedTime = newToken.updatedAt;

    // 如果本地有更新时间但新token没有，保留本地版本
    if (localUpdatedTime != null && itemUpdatedTime == null) {
      return null;
    }

    // 如果本地版本更新，保留本地版本
    if (localUpdatedTime != null &&
        itemUpdatedTime != null &&
        localUpdatedTime.isAfter(itemUpdatedTime)) {
      return null;
    }

    // 其他情况需要更新
    return true;
  }

  //合并新老 token 信息，避免新的token信息有字段缺失
  Token mergeToken(Token newToken, Token? local) {
    if (local == null) {
      return newToken;
    }
    DateTime? tokenCreated;
    if (newToken.tokenCreated == null && local.tokenCreated != null) {
      tokenCreated = local.tokenCreated;
    }
    String? iconURL;
    //宽松判断，如果iconURL长度大于10，则iconURL是有效的
    if (newToken.iconUrl.length < 10 && local.iconUrl.length > 10) {
      iconURL = local.iconUrl;
    }
    int? decimals;
    if (newToken.decimals == 0 && local.decimals != 0) {
      decimals = local.decimals;
    }
    if (tokenCreated == null || iconURL == null || decimals == null) {
      return newToken.copyWith(
        tokenCreated: tokenCreated == null
            ? (newToken.tokenCreated == null
                ? Value.absent()
                : Value(newToken.tokenCreated))
            : Value(tokenCreated),
        iconUrl: iconURL ?? newToken.iconUrl,
        decimals: decimals ?? newToken.decimals,
      );
    }

    return newToken;
  }

  Future<void> insertToken(Token token) {
    return into(tokens).insert(token,mode: InsertMode.insertOrReplace);
  }

  Future<void> updateToken(Token token) {
    return update(tokens).replace(token);
  }
}
