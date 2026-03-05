import 'package:finality/common/utils/value_listenable_removable.dart';
import 'package:finality/core/state/ui_state.dart';
import 'package:finality/data/drift/entities/token.dart';
import 'package:finality/data/drift/entities/token_id.dart';
import 'package:finality/data/drift/token_database.dart';
import 'package:finality/data/model/token_position.dart';
import 'package:finality/data/realtime/model/token_holding_price.dart';
import 'package:finality/di/injector.dart';
import 'package:finality/domain/wallet/entities/unified_wallet_accounts.dart';
import 'package:finality/services/wallet/token_holdings_service.dart';
import 'package:flutter/foundation.dart';

class TokenPositionService {
  final TokenHoldingsService _holdingsService;
  TokenPositionService(this._holdingsService);
  final TokenDatabase _tokenDatabase = injector();

  ValueNotifier<UnifiedWalletAccounts?> get walletAccounts =>
      _holdingsService.walletAccounts;
  ValueListenable<double> get totalAssetValue =>
      _holdingsService.totalAssetValue;
  ValueListenable<double> get total24hChange =>
      _holdingsService.total24hChange;
  ValueListenable<double> get total24hChangeRate =>
      _holdingsService.total24hChangeRate;
  ValueListenable<UiState<void>> get fetchHoldingsUiState =>
      _holdingsService.fetchHoldingsUiState;

  ValueNotifier<List<TokenPosition>> tokenPositions = ValueNotifier([]);
  final Map<TokenId, Token> _tokenCache = {};
  Removable? _subscription;

  void init() {
    _subscription = _holdingsService.tokenHoldingPrices.listen((event) {
      _onTokenHoldingPricesChange(event);
    }, immediate: true);
  }

  void _onTokenHoldingPricesChange(List<TokenHoldingPrice> event) async {
    List<TokenPosition> positions = [];
    for (var holdingPrice in event) {
      var cacheKey = TokenId(
        contractAddress: holdingPrice.holding.contractAddress,
        networkCode: holdingPrice.holding.networkCode,
      );

      var token = _tokenCache[cacheKey];
      if (token == null) {
        token = await _tokenDatabase.tokenDao.loadToken(
            holdingPrice.holding.contractAddress,
            holdingPrice.holding.networkCode);
        if (token != null) {
          _tokenCache[cacheKey] = token;
        }
      }
      if (token != null) {
        positions.add(TokenPosition(token, holdingPrice));
      }
    }
    positions.sort((a, b) {
      if (b.token.isNativeToken != a.token.isNativeToken) {
        return b.token.isNativeToken ? 1 : -1;
      }
      return b.holdingPrice.currencyValue
          .compareTo(a.holdingPrice.currencyValue);
    });
    tokenPositions.value = positions;
  }

  Future<void> fetchCurrentAccountsTokenPositions() async {
    await _holdingsService.fetchCurrentAccountsHoldings();
  }

  void dispose() {
    _subscription?.cancel();
  }
}
