import 'package:finality/data/drift/dao/token_dao.dart';
import 'package:finality/data/drift/entities/token.dart';
import 'package:finality/common/constants/blockchain.dart';

class WalletDataRepository {
  final TokenDao coinDao;

  WalletDataRepository(this.coinDao);

  Future<void> checkCoinsAndInit() async {
    // 检查是否每个链的原生代币都初始化到数据库了
    await coinDao.saveTokens(Tokens.all);
  }

  Future<List<Token>> officialCoins(String? vaultToken) async {
    var officialCoins = await coinDao.loadAllTokens();
    if (officialCoins.isNotEmpty) {
      return officialCoins;
    } else {
      await coinDao.saveTokens(Tokens.all);
      return Tokens.all;
    }
  }

  saveCoins(List<Token> officialCoins) async {
    await coinDao.saveTokens(officialCoins);
  }
}
