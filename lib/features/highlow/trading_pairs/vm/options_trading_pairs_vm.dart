import 'package:finality/core/logger.dart';
import 'package:finality/core/state/ui_data.dart';
import 'package:finality/core/state/ui_state.dart';
import 'package:finality/data/drift/options_database.dart';
import 'package:finality/di/injector.dart';
import 'package:finality/domain/options/entities/options_trading_pair_detail.dart';
import 'package:finality/domain/options/options_data_repository.dart';
import 'package:finality/features/highlow/trading_pairs/models/options_trading_pair_vo.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:store_scope/store_scope.dart';

final optionsTradingPairsVMProvider =
    ViewModelProvider<OptionsTradingPairsVM>((space) {
  return OptionsTradingPairsVM(injector());
});

class OptionsTradingPairsVM extends ViewModel {
  final OptionsDataRepository _repository;

  OptionsTradingPairsVM(this._repository);

  final ValueNotifier<
          UiState<List<UiData<OptionsTradingPairDetail, OptionsTradingPairVO>>>>
      _tradingPairsState = ValueNotifier(UiState.initial());

  ValueListenable<
          UiState<List<UiData<OptionsTradingPairDetail, OptionsTradingPairVO>>>>
      get tradingPairsState => _tradingPairsState;

  @override
  void init() {
    super.init();
    _fetchTradingPairs(true);
  }

  Future<void> _fetchTradingPairs(bool isInitial) async {
    if (isInitial) {
      _tradingPairsState.updateIfEmpty(() => UiState.loading());
    }
    try {
      if (isInitial) {
        var localTradingPairDetails =
            await _repository.loadLocalTradingPairDetails();
        if (localTradingPairDetails.isNotEmpty) {
          _updateTradingPairs(localTradingPairDetails);
        }
      }
      var remoteTradingPairDetails =
          await _repository.fetchTradingPairDetails();
      _updateTradingPairs(remoteTradingPairDetails);
    } catch (e, stackTrace) {
      logger.e(e, stackTrace: stackTrace);
      if (isInitial) {
        _tradingPairsState.updateIfEmpty(() => UiState.failure(e, retry: () {
              _fetchTradingPairs(isInitial);
            }));
      }
    }
  }

  void _updateTradingPairs(List<OptionsTradingPairDetail> tradingPairDetails) {
    tradingPairDetails
        .sort((a, b) => (b.tick?.payout ?? 0).compareTo(a.tick?.payout ?? 0));
    final uiDataList = tradingPairDetails
        .map((e) => UiData(
            raw: e,
            uiModel: OptionsTradingPairVO.fromOptionsTradingPairDetail(e)))
        .toList();
    _tradingPairsState.value = UiState.success(uiDataList);
  }

  void refreshTradingPairs() {
    if (!_tradingPairsState.value.isLoading) {
      _fetchTradingPairs(_tradingPairsState.value.isInitial);
    }
  }

  Future<OptionsTradingPair?> loadTradingPairsByFeedId(String feedId) async {
    var valueOrFallback = tradingPairsState.value.valueOrFallback;
    if (valueOrFallback != null && valueOrFallback.isNotEmpty) {
      return valueOrFallback
          .firstWhereOrNull((element) => element.raw.pair.feedId == feedId)
          ?.raw
          .pair;
    }
    var tradingPair = await _repository.loadTradingPairFeedId(feedId);
    if (tradingPair != null) {
      return tradingPair;
    }
    return null;
  }
}
