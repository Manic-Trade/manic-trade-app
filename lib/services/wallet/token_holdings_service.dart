import 'dart:async';

import 'package:finality/common/utils/value_listenable_removable.dart';
import 'package:finality/core/logger.dart';
import 'package:finality/core/state/ui_state.dart';
import 'package:finality/data/drift/entities/token_holding.dart';
import 'package:finality/data/drift/entities/token_price.dart';
import 'package:finality/data/model/network_address_pair.dart';
import 'package:finality/data/realtime/model/token_holding_price.dart';
import 'package:finality/data/repository/holdings_data_repository.dart';
import 'package:finality/di/injector.dart';
import 'package:finality/domain/wallet/entities/unified_wallet_accounts.dart';
import 'package:finality/services/wallet/wallet_service.dart';
import 'package:flutter/foundation.dart';

part 'holding_price_manager.dart';

class TokenHoldingsService {
  final WalletService _walletService;
  TokenHoldingsService(this._walletService);

  final HoldingsDataRepository _repository = injector();

  ValueNotifier<UnifiedWalletAccounts?> get walletAccounts =>
      _walletService.walletAccounts;
  ValueNotifier<List<NetworkAddressPair>> get networkAddressPairs =>
      _walletService.networkAddressPairs;

  late final _HoldingPriceManager _holdingPriceManager = _HoldingPriceManager(
    repository: _repository,
    getCurrentCurrency: () => "USD",
    onHoldingPricesChanged: _onHoldingPricesChanged,
  );
  ValueNotifier<List<TokenHoldingPrice>> tokenHoldingPrices = ValueNotifier([]);

  ValueNotifier<double> totalAssetValue = ValueNotifier(0.0); // Total asset value
  ValueNotifier<double> total24hChange = ValueNotifier(0.0); // Total 24h change amount
  ValueNotifier<double> total24hChangeRate = ValueNotifier(0.0); // Total 24h change rate
  final _fetchHoldingsUiState = ValueNotifier<UiState<void>>(UiState.initial());
  ValueListenable<UiState<void>> get fetchHoldingsUiState =>
      _fetchHoldingsUiState;
  Removable? _networkAddressPairsRemovable;
  StreamSubscription? _fiatCurrencyUnitSubscription;

  init() {
    _networkAddressPairsRemovable = _walletService.networkAddressPairs
        .listen(onNetworkAddressPairsUpdate, immediate: true);
  }

  void onNetworkAddressPairsUpdate(
      List<NetworkAddressPair> networkAddressPairs) {
    Future.delayed(Duration(milliseconds: 80), () {
      _fetchAccountsHoldings(networkAddressPairs);
    });
    _holdingPriceManager.startListening(networkAddressPairs);
  }

  void _onHoldingPricesChanged(List<TokenHoldingPrice> prices) {
    tokenHoldingPrices.value = prices;
    double totalValue = 0.0; // Total asset value
    double totalChangeValue = 0.0; // Total 24h change amount

    for (var price in prices) {
      final currentValue = price.currencyValue;
      totalValue += currentValue;

      // Calculate value 24h ago
      if (price.price?.change24h != null) {
        final change24h = price.price!.change24h!;
        // currentValue / (1 + changeRate) = value 24h ago
        final previousValue = currentValue / (1 + change24h);
        totalChangeValue += (currentValue - previousValue);
      }
    }

    totalAssetValue.value = totalValue;
    total24hChange.value = totalChangeValue;
    // Calculate total change rate (0 if total asset is 0)
    total24hChangeRate.value = totalValue > 0
        ? totalChangeValue / (totalValue - totalChangeValue)
        : 0.0;
  }

  Future<void> _fetchAccountsHoldings(
      List<NetworkAddressPair> networkAddressPairs) async {
    try {
      _fetchHoldingsUiState.value = UiState.loading();
      await _repository.fetchAllTokenAssets(networkAddressPairs);
      _fetchHoldingsUiState.value = UiState.success(null);
    } catch (error, stackTrace) {
      logger.e("fetchAccountsHoldings error",
          error: error, stackTrace: stackTrace);
      _fetchHoldingsUiState.value = UiState.failure(error, retry: () {
        _fetchAccountsHoldings(networkAddressPairs);
      });
    }
  }

  /// Refresh balances
  Future<void> fetchCurrentAccountsHoldings() async {
    var currentPairs = networkAddressPairs.value;
    if (currentPairs.isNotEmpty) {
      await _fetchAccountsHoldings(currentPairs);
    }
  }

  void dispose() {
    _holdingPriceManager.cleanup();
    _networkAddressPairsRemovable?.cancel();
    _fiatCurrencyUnitSubscription?.cancel();
  }
}
