import 'dart:async';

import 'package:collection/collection.dart';
import 'package:finality/common/constants/currencies.dart';
import 'package:finality/data/drift/dao/token_dao.dart';
import 'package:finality/data/drift/dao/token_holder_dao.dart';
import 'package:finality/data/drift/dao/token_price_dao.dart';
import 'package:finality/data/drift/entities/token.dart';
import 'package:finality/data/drift/entities/token_holding.dart';
import 'package:finality/data/drift/entities/token_price.dart';
import 'package:finality/common/constants/blockchain.dart';
import 'package:finality/data/model/network_address_pair.dart';
import 'package:finality/data/model/token_asset.dart';
import 'package:finality/data/network/manic_trade_data_source.dart';
import 'package:finality/data/realtime/model/token_holding_price.dart';

class HoldingsDataRepository {
  final TokenDao tokenDao;
  final TokenHolderDao holderDao;
  final TokenPriceDao priceDao;
  final ManicTradeDataSource _remote;

  HoldingsDataRepository(
      {required this.tokenDao,
      required this.holderDao,
      required this.priceDao,
      required ManicTradeDataSource board})
      : _remote = board;

  final _tokenPricesUpdateController =
      StreamController<List<TokenPrice>>.broadcast();

  Stream<List<TokenPrice>> get tokenPricesUpdateStream =>
      _tokenPricesUpdateController.stream;

  final _tokenHoldingsUpdateController =
      StreamController<List<TokenHolding>>.broadcast();

  Stream<List<TokenHolding>> get tokenHoldingsUpdateStream =>
      _tokenHoldingsUpdateController.stream;

  Future<List<TokenAsset>> _fetchSolanaTokenAssets(String address,
      {String? tokenAddress}) async {
    var tokenBalanceResponse = await _remote.getTokenBalance();
    var address = tokenBalanceResponse.wallet;

    var token = Tokens.usdc;
    var price = TokenPrice(
        networkCode: token.networkCode,
        contractAddress: token.contractAddress,
        currency: Currencies.usd,
        price: "1",
        time: DateTime.now());
    var holding = TokenHolding(
        networkCode: token.networkCode,
        contractAddress: token.contractAddress,
        holderAddress: address,
        balance: tokenBalanceResponse.uiBalance);

    List<TokenAsset> tokenAssets = [
      TokenAsset(token, TokenHoldingPrice(holding, price))
    ];

    await saveTokenAssets(NetworkCodes.solana, address, tokenAssets);

    return tokenAssets;
  }

  Future<List<TokenAsset>> fetchAllTokenAssets(
      List<NetworkAddressPair> networkAddressPairs) async {
    List<TokenAsset> allTokenAssets = [];
    for (var networkAddressPair in networkAddressPairs) {
      if (networkAddressPair.networkCode == NetworkCodes.solana) {
        var solanaAssets =
            await _fetchSolanaTokenAssets(networkAddressPair.address);
        allTokenAssets.addAll(solanaAssets);
      }

      /// fetch other network token assets
    }
    List<TokenHolding> allTokenHoldings = [];
    List<TokenPrice> allTokenPrices = [];
    for (var tokenAsset in allTokenAssets) {
      allTokenHoldings.add(tokenAsset.holdingPrice.holding);
      var price = tokenAsset.holdingPrice.price;
      if (price != null) {
        allTokenPrices.add(price);
      }
    }
    _tokenHoldingsUpdateController.add(allTokenHoldings);
    _tokenPricesUpdateController.add(allTokenPrices);
    return allTokenAssets;
  }

  Future<TokenAsset> fetchTokenAsset(
      String contractAddress, String networkCode, String holderAddress) async {
    TokenAsset? tokenAsset;
    if (networkCode == NetworkCodes.solana) {
      var tokenAssets = await _fetchSolanaTokenAssets(holderAddress,
          tokenAddress: contractAddress);
      tokenAsset = tokenAssets
          .firstWhereOrNull((e) => e.token.contractAddress == contractAddress);
    }
    if (tokenAsset == null) {
      throw UnimplementedError(
          "Not supported network: networkCode=$networkCode, contractAddress=$contractAddress, address=$holderAddress");
    }
    _tokenHoldingsUpdateController.add([tokenAsset.holdingPrice.holding]);
    var price = tokenAsset.holdingPrice.price;
    if (price != null) {
      _tokenPricesUpdateController.add([price]);
    }

    return tokenAsset;
  }

  Future<void> saveTokenAssets(String networkCode, String holderAddress,
      List<TokenAsset> tokenAssets) async {
    List<Token> tokens = [];
    List<TokenHolding> holdings = [];
    List<TokenPrice> prices = [];
    for (var tokenAsset in tokenAssets) {
      tokens.add(tokenAsset.token);
      holdings.add(tokenAsset.holdingPrice.holding);
      var tokenPrice = tokenAsset.holdingPrice.price;
      if (tokenPrice != null) {
        prices.add(tokenPrice);
      }
    }
    await tokenDao.saveTokens(tokens);
    await holderDao.replaceHoldings(networkCode, holderAddress, holdings);
    await priceDao.savePrices(prices);
  }

  Future<void> saveTokenAsset(TokenAsset tokenAsset) async {
    await tokenDao.saveToken(tokenAsset.token);
    await holderDao.saveHolding(tokenAsset.holdingPrice.holding);
    var tokenPrice = tokenAsset.holdingPrice.price;
    if (tokenPrice != null) {
      await priceDao.savePrice(tokenPrice);
    }
  }

  Future<TokenHolding?> loadTokenHoldingFromLocal(
      String contractAddress, String networkCode, String address) async {
    return holderDao.loadHolding(contractAddress, networkCode, address);
  }

  Future<TokenHoldingPrice> fetchTokenHoldingPrice(
      String contractAddress, String networkCode, String holderAddress) async {
    var tokenAsset =
        await fetchTokenAsset(contractAddress, networkCode, holderAddress);
    return tokenAsset.holdingPrice;
  }
}
