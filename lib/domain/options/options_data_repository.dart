import 'package:finality/data/drift/options_database.dart';
import 'package:finality/data/network/manic_price_data_source.dart';
import 'package:finality/domain/options/entities/options_trading_pair_detail.dart';
import 'package:finality/domain/options/mappers/trading_pair_mapper.dart';

class OptionsDataRepository {
  final OptionsDatabase _optionsDatabase;
  final ManicPriceDataSource _manicPriceDataSource;

  OptionsDataRepository(
      {required OptionsDatabase optionsDatabase,
      required ManicPriceDataSource manicPriceDataSource})
      : _optionsDatabase = optionsDatabase,
        _manicPriceDataSource = manicPriceDataSource;

  Future<List<OptionsTradingPairDetail>> loadLocalTradingPairDetails() async {
    var optionsTradingPairs =
        await _optionsDatabase.optionsTradingPairDao.loadAllItems();

    return optionsTradingPairs
        .map((e) => OptionsTradingPairDetail(pair: e, tick: null))
        .toList();
  }

  Future<List<OptionsTradingPairDetail>> fetchTradingPairDetails() async {
    final tradingPairs = await _manicPriceDataSource.getTradingPairs();
    List<OptionsTradingPair> optionsTradingPairs = [];
    List<OptionsTradingPairDetail> optionsTradingPairDetails = [];
    for (var tradingPair in tradingPairs) {
      final optionsTradingPair = tradingPair.toOptionsTradingPair();
      optionsTradingPairs.add(optionsTradingPair);
      var optionsTradingPairTick = tradingPair.toOptionsTradingPairTick();
      var optionsTradingPairDetail = OptionsTradingPairDetail(
          pair: optionsTradingPair, tick: optionsTradingPairTick);
      optionsTradingPairDetails.add(optionsTradingPairDetail);
    }
    // 异步保存交易对信息
    _optionsDatabase.optionsTradingPairDao.saveItems(optionsTradingPairs);
    return optionsTradingPairDetails;
  }

  Future<OptionsTradingPair?> loadTradingPairFeedId(String feedId) async {
    var optionsTradingPair =
        await _optionsDatabase.optionsTradingPairDao.loadItem(feedId);
    return optionsTradingPair;
  }
}
