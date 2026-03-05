import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:finality/data/drift/entities/token.dart';
import 'package:finality/data/drift/entities/token_holding.dart';
import 'package:finality/data/drift/entities/token_price.dart';
import 'package:finality/data/model/token_position.dart';
import 'package:finality/data/realtime/model/holding_request.dart';
import 'package:finality/data/realtime/realtime_holding_transport.dart';
import 'package:finality/data/repository/holdings_data_repository.dart';
import 'package:finality/di/injector.dart';
import 'package:finality/domain/wallet/entities/account_network.dart';
import 'package:flutter/foundation.dart';

/// 负责处理 TransferBuilderSheet 的所有业务逻辑
/// 不使用 GetxController 的原因:
/// 1. 该页面是弹窗, getx的路由支持不好
/// 2. 状态和逻辑都是局限在这个页面内，不需要跨页面共享
class TransferBuilderLogic {
  final AccountNetwork accountNetwork;
  late final ValueNotifier<Token> tokenNotifier;
  late final ValueNotifier<bool> _isInputAmountNotifier = ValueNotifier(true);
  ValueListenable<bool> get isInputAmountNotifier => _isInputAmountNotifier;
  late final ValueNotifier<String> inputAmountNotifier;
  late final ValueNotifier<String> inputPriceNotifier;
  late final ValueNotifier<String> tokenBalanceNotifier;
  late final ValueNotifier<TokenPrice?> tokenPriceNotifier;

  final RealtimeHoldingTransport holdingTransport = injector();
  final HoldingsDataRepository repository = injector();

  StreamSubscription? holdingSubscription;
  StreamSubscription? priceSubscription;

  TransferBuilderLogic({
    required this.accountNetwork,
    required Token initialToken,
  }) : tokenNotifier = ValueNotifier(initialToken);

  static const int priceDecimalPlaces = 4; // 价格的最大小数位数
  static const String approximately = ''; // ≈

  void init() {
    inputAmountNotifier = ValueNotifier('');
    inputPriceNotifier = ValueNotifier('');
    tokenBalanceNotifier = ValueNotifier("0");
    tokenPriceNotifier = ValueNotifier(null);
    var currentToken = tokenNotifier.value;
    _updateTokenHolding(currentToken, null);
    _updateTokenPrice(currentToken, null);
    _fetchTokenBalance(currentToken);
    _fetchNetworkFee();
  }

  void dispose() {
    tokenNotifier.dispose();
    inputAmountNotifier.dispose();
    inputPriceNotifier.dispose();
    holdingSubscription?.cancel();
    priceSubscription?.cancel();
  }

  String replaceInputValue(String value) {
    return value.replaceAll(approximately, '');
  }

  String getRealInputPrice() {
    return replaceInputValue(inputPriceNotifier.value);
  }

  void onNumberPressed(String number) {
    var inputAmount = inputAmountNotifier.value;
    if (inputAmount.isNotEmpty) {
      var inputAmountDecimal = Decimal.tryParse(inputAmount) ?? Decimal.zero;
      final balance = tokenBalanceNotifier.value;
      if (inputAmountDecimal > Decimal.parse(balance.toString())) {
        return;
      }
    }

    final isInputAmount = isInputAmountNotifier.value;
    final notifier = isInputAmount ? inputAmountNotifier : inputPriceNotifier;
    final currentValue = replaceInputValue(notifier.value);
    // Early returns for invalid inputs
    if (currentValue == '0' && number == '0') return;
    if (number == '.' && currentValue.contains('.')) return;

    // 价格输入限制最多输入 priceDecimalPlaces 位小数
    if (!isInputAmount && currentValue.contains('.')) {
      final decimalPlaces = currentValue.split('.')[1].length;
      if (decimalPlaces >= priceDecimalPlaces && number != '.') return;
    }

    // Update the input value
    if (currentValue == '' && number == '.') {
      notifier.value = "0.";
    } else {
      notifier.value =
          currentValue == '0' && number != '.' ? number : currentValue + number;
    }

    _updateDependentField(isInputAmount);
  }

  bool onDeletePressed() {
    final isInputAmount = isInputAmountNotifier.value;
    final notifier = isInputAmount ? inputAmountNotifier : inputPriceNotifier;
    final currentValue = notifier.value.replaceAll(approximately, '');
    if (currentValue.isEmpty) return false;

    // Update the input value
    notifier.value = currentValue.length > 1
        ? currentValue.substring(0, currentValue.length - 1)
        : '';

    _updateDependentField(isInputAmount);
    return true;
  }

  void _updateDependentField(bool isInputAmount) {
    final value = double.tryParse(isInputAmount
            ? inputAmountNotifier.value
            : inputPriceNotifier.value) ??
        0;

    var unitPrice = _getCurrentTokenUnitPrice();
    if (isInputAmount) {
      inputPriceNotifier.value = _calculatePrice(
          Decimal.parse(value.toString()), Decimal.parse(unitPrice));
    } else {
      inputAmountNotifier.value = _calculateAmount(
          Decimal.parse(value.toString()), Decimal.parse(unitPrice));
    }
  }

  String _calculateAmount(Decimal price, Decimal unitPrice) {
    if (price == Decimal.zero || unitPrice == Decimal.zero) {
      return "0";
    }
    return (price / unitPrice)
        .toDecimal(scaleOnInfinitePrecision: tokenNotifier.value.decimals)
        .toString();
  }

  String _calculatePrice(Decimal amount, Decimal unitPrice) {
    return (amount * unitPrice).toString();
  }

  void updateSelectedTokenWithAsset(TokenPosition tokenPosition) {
    tokenNotifier.value = tokenPosition.token;
    inputAmountNotifier.value = '';
    inputPriceNotifier.value = '';
    _updateTokenHolding(tokenPosition.token,
        tokenPosition.holdingPrice.holding);
    _updateTokenPrice(tokenPosition.token,
        tokenPosition.holdingPrice.price);
    _fetchTokenBalance(tokenPosition.token);
  }

  void setAmountToPercentageBalance(double percentage) {
    var balanceDecimal = Decimal.parse(_getCurrentTokenBalance());
    var unitPriceDecimal =
        Decimal.parse(_getCurrentTokenUnitPrice().toString());
    if (percentage == 1) {
      inputAmountNotifier.value =
          Decimal.parse(balanceDecimal.toString()).toString();
      if (isInputAmountNotifier.value) {
        inputPriceNotifier.value =
            _calculatePrice(balanceDecimal, unitPriceDecimal);
      } else {
        var priceDecimal = (balanceDecimal * unitPriceDecimal)
            .truncate(scale: priceDecimalPlaces);
        inputPriceNotifier.value = "${priceDecimal.toString()}$approximately";
      }
    } else {
      var percentageDecimal = Decimal.parse(percentage.toString());
      var unitPriceDecimal =
          Decimal.parse(_getCurrentTokenUnitPrice().toString());
      var amountDecimal = (balanceDecimal * percentageDecimal)
          .truncate(scale: tokenNotifier.value.decimals);
      if (isInputAmountNotifier.value) {
        inputAmountNotifier.value = amountDecimal.toString();
        inputPriceNotifier.value =
            _calculatePrice(amountDecimal, unitPriceDecimal);
      } else {
        var priceDecimal = (amountDecimal * unitPriceDecimal)
            .truncate(scale: priceDecimalPlaces);
        inputPriceNotifier.value = priceDecimal.toString();
        inputAmountNotifier.value =
            _calculateAmount(priceDecimal, unitPriceDecimal);
      }
    }
  }

  void _updateTokenHolding(Token token, TokenHolding? holding) {
    holdingSubscription?.cancel();
    tokenBalanceNotifier.value = holding?.balance ?? "0";
    holdingSubscription = holdingTransport
        .subscribeHolding(HoldingRequest(
      contractAddress: token.contractAddress,
      networkCode: token.networkCode,
      holderAddress: accountNetwork.account.address,
    ))
        .listen((holding) {
      tokenBalanceNotifier.value = holding.balance;
    });
  }

  void _updateTokenPrice(Token token, TokenPrice? price) {
    priceSubscription?.cancel();
    tokenPriceNotifier.value = price;
  }

  String _getCurrentTokenUnitPrice() {
    return tokenPriceNotifier.value?.price ?? "0";
  }

  String _getCurrentTokenBalance() {
    return tokenBalanceNotifier.value;
  }

  /// 获取token最新的余额和单价
  void _fetchTokenBalance(Token token) {
    repository.fetchTokenHoldingPrice(token.contractAddress, token.networkCode,
        accountNetwork.account.address);
  }

  void _fetchNetworkFee() async {
    // var fee = await repository.fetchNetworkFee();
    // print(fee.fee);
  }
}
