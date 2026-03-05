part of 'token_holdings_service.dart';

/// 1. Listen to user token holdings changes
/// 2. Price fixed at 1 (no real-time price subscription)
/// 3. For TokenHoldingsService use only
class _HoldingPriceManager {
  final HoldingsDataRepository _repository;
  final String Function() _getCurrentCurrency;
  final void Function(List<TokenHoldingPrice>) _onHoldingPricesChanged;

  _HoldingPriceManager({
    required HoldingsDataRepository repository,
    required String Function() getCurrentCurrency,
    required void Function(List<TokenHoldingPrice>) onHoldingPricesChanged,
  })  : _onHoldingPricesChanged = onHoldingPricesChanged,
        _repository = repository,
        _getCurrentCurrency = getCurrentCurrency;

  List<TokenHoldingPrice> _tokenHoldingPrices = [];

  List<TokenHoldingPrice> get tokenHoldingPrices => _tokenHoldingPrices;

  StreamSubscription? _holdingsSubscription;

  void startListening(List<NetworkAddressPair> networkAddressPairs) {
    cleanup();
    _holdingsSubscription = _repository.holderDao
        .streamAllHoldings(networkAddressPairs)
        .listen(_handleHoldingsUpdate);
  }

  void _handleHoldingsUpdate(List<TokenHolding> tokenHoldings) {
    if (tokenHoldings.isEmpty) {
      _tokenHoldingPrices = [];
      _onHoldingPricesChanged.call(_tokenHoldingPrices);
      return;
    }

    _tokenHoldingPrices = tokenHoldings.map((holding) {
      // Price fixed at 1
      final fixedPrice = TokenPrice(
        networkCode: holding.networkCode,
        contractAddress: holding.contractAddress,
        currency: _getCurrentCurrency(),
        price: '1',
        time: DateTime.now(),
      );
      return TokenHoldingPrice(holding, fixedPrice);
    }).toList();

    _onHoldingPricesChanged.call(_tokenHoldingPrices);
  }

  void cleanup() {
    _holdingsSubscription?.cancel();
    _holdingsSubscription = null;
  }

  void reset() {
    cleanup();
    _tokenHoldingPrices = [];
    _onHoldingPricesChanged.call(_tokenHoldingPrices);
  }
}
