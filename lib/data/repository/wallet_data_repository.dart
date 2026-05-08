import 'package:finality/common/constants/blockchain.dart';
import 'package:finality/data/drift/dao/token_dao.dart';
import 'package:finality/data/drift/entities/token.dart';

class WalletDataRepository {
  final TokenDao coinDao;

  WalletDataRepository(this.coinDao);

  Future<void> checkCoinsAndInit() async {
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

  String? compareAndGeLatest(String? current, String? other,
      DateTime currentTime, DateTime? otherTime) {
    String? latest = current;
    if (other != null && current == null) {
      latest = other;
    } else if (other != null && current != null) {
      if (otherTime != null && otherTime.isAfter(currentTime)) {
        latest = other;
      }
    }
    return latest;
  }
}
