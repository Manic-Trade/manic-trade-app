import 'package:easy_refresh/easy_refresh.dart';
import 'package:finality/common/constants/blockchain.dart';
import 'package:finality/common/utils/value_listenable_removable.dart';
import 'package:finality/core/notifier/computed_notifier.dart';
import 'package:finality/core/state/ui_state.dart';
import 'package:finality/data/drift/entities/token_holding.dart';
import 'package:finality/data/model/token_position.dart';
import 'package:finality/data/network/manic_trade_data_source.dart';
import 'package:finality/data/realtime/model/token_holding_price.dart';
import 'package:finality/di/injector.dart';
import 'package:finality/domain/wallet/entities/unified_wallet_accounts.dart';
import 'package:finality/features/assets/holdings/holdings_ui_model.dart';
import 'package:finality/features/positions/vm/opened_positions_vm.dart';
import 'package:finality/services/wallet/token_position_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:store_scope/store_scope.dart';

final holdingsViewModelProvider = ViewModelProvider(
  (space) => HoldingsViewModel(
    injector<TokenPositionService>(),
    injector<ManicTradeDataSource>(),
    space.bind(openedPositionsVMProvider),
  ),
);

class HoldingsViewModel extends ViewModel {
  HoldingsViewModel(
    this._tokenPositionService,
    this._manicTradeDataSource,
    this._gameStatusVM,
  );

  final TokenPositionService _tokenPositionService;
  final ManicTradeDataSource _manicTradeDataSource;
  final OpenedPositionsVM _gameStatusVM;

  final ValueNotifier<List<TokenPosition>> _tokenPositionsNotifier =
      ValueNotifier([]);
  final ValueNotifier<CashTokenPostions> _holdingsUiModelNotifier =
      ValueNotifier(
    CashTokenPostions(
      tokenPositions: [],
      totalValue: 0.0,
    ),
  );

  final ValueNotifier<double> _totalAssetValueNotifier = ValueNotifier(0.0);

  ValueNotifier<UnifiedWalletAccounts?> get walletAccounts =>
      _tokenPositionService.walletAccounts;

  ValueListenable<List<TokenPosition>> get allTokenPositions =>
      _tokenPositionService.tokenPositions;

  ValueListenable<List<TokenPosition>> get tokenPositionsNotifier =>
      _tokenPositionsNotifier;

  ValueListenable<CashTokenPostions> get cashTokenPostionsNotifier =>
      _holdingsUiModelNotifier;

  ValueListenable<double> get totalAssetValueNotifier =>
      _totalAssetValueNotifier;

  ValueListenable<double> get totalPendingPositionAssetValue =>
      _gameStatusVM.totalPendingPositionAssetValue;

  ValueListenable<UiState<void>> get fetchHoldingsUiState =>
      _tokenPositionService.fetchHoldingsUiState;

  late final ValueListenable<bool> showLoading =
      ComputedNotifier2<bool, UiState<void>, List<TokenPosition>>(
    source1: fetchHoldingsUiState,
    source2: tokenPositionsNotifier,
    compute: (uiState, _) =>
        uiState is Loading && allTokenPositions.value.isEmpty,
  );

  final ValueNotifier<bool> isCashTokenExpanded = ValueNotifier(false);
  final refreshController = EasyRefreshController();
  final scrollController = ScrollController();

  @override
  void init() {
    super.init();
    var pendingPositionAssetValueRemovable = _gameStatusVM
        .totalPendingPositionAssetValue
        .listen(_onPendingPositionAssetValueChanged, immediate: true);
    addCloseable(() {
      pendingPositionAssetValueRemovable.remove();
    });

    var tokenPositionsRemovable = _tokenPositionService.tokenPositions
        .listen(_onAllTokenPositionsChanged, immediate: true);
    addCloseable(() {
      tokenPositionsRemovable.remove();
    });
  }

  void _onAllTokenPositionsChanged(List<TokenPosition> tokenPositions) {
    _tokenPositionsNotifier.value = tokenPositions;
    _onShowedTokenPositionsChanged(tokenPositions);
    _updateTotalAssetValue(_tokenPositionService.totalAssetValue.value,
        _gameStatusVM.totalPendingPositionAssetValue.value);
  }

  void _onPendingPositionAssetValueChanged(double pendingPositionValue) {
    _updateTotalAssetValue(_tokenPositionService.totalAssetValue.value,
        _gameStatusVM.totalPendingPositionAssetValue.value);
  }

  void _updateTotalAssetValue(
      double tokenTotalValue, double pendingPositionValue) {
    _totalAssetValueNotifier.value = tokenTotalValue;
  }

  void _onShowedTokenPositionsChanged(List<TokenPosition> tokenPositions) {
    final showedPositions = _tokenPositionsNotifier.value;

    final cashPositions = <TokenPosition>[];
    double cashTotalValue = 0.0;

    for (final position in showedPositions) {
      if (position.token.isStablecoin) {
        cashPositions.add(position);
        cashTotalValue += position.holdingPrice.currencyValue;
      }
    }
    if (cashPositions.isEmpty) {
      final solanaAddress = _tokenPositionService.walletAccounts.value
          ?.getSolanaAccount()
          ?.address;
      if (solanaAddress != null) {
        cashPositions.add(TokenPosition(
          Tokens.usdc,
          TokenHoldingPrice(
            TokenHolding(
              networkCode: Tokens.usdc.networkCode,
              contractAddress: Tokens.usdc.contractAddress,
              holderAddress: solanaAddress,
              balance: '0',
            ),
            null,
          ),
        ));
      }
    }

    _holdingsUiModelNotifier.value = CashTokenPostions(
      tokenPositions: cashPositions,
      totalValue: cashTotalValue,
    );
  }

  Future<void> refreshData() async {
    await Future.wait([
      _tokenPositionService.fetchCurrentAccountsTokenPositions(),
      _gameStatusVM.fetchInitialPositions(),
    ]);
  }

  void callRefresh() {
    if (showLoading.value) return;
    if (scrollController.hasClients) {
      if (scrollController.offset <= 0) {
        if (refreshController.headerState?.mode == IndicatorMode.inactive) {
          refreshController.callRefresh();
        }
      } else {
        scrollController.jumpTo(0);
      }
    }
  }

  Future<void> triggerAirdrop() async {
    final address = walletAccounts.value?.getSolanaAccount()?.address;
    if (address == null) return;
    await _manicTradeDataSource.triggerAirdrop(address);
    Future.delayed(const Duration(seconds: 1), () {
      _tokenPositionService.fetchCurrentAccountsTokenPositions();
    });
  }
}
