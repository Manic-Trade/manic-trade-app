import 'package:collection/collection.dart';
import 'package:finality/services/turnkey/turnkey_manager.dart';
import 'package:turnkey_sdk_flutter/turnkey_sdk_flutter.dart';

class TurnkeyWalletUtils {
  static Wallet? findManicTradeWallet(TurnkeyManager turnkeyManager) {
    var wallets = turnkeyManager.wallets;
    if (wallets == null || wallets.isEmpty) {
      return null;
    }
    if (wallets.length == 1) {
      return wallets.first;
    }
    var firstWhereOrNull = wallets.firstWhereOrNull(
        (element) => element.name == TurnkeyManager.defaultWalletName);

    if (firstWhereOrNull != null) {
      return firstWhereOrNull;
    }
    var firstWhereOrNull2 = wallets.firstWhereOrNull((element) =>
        element.accounts.length >= 2 &&
        element.accounts.any((element) =>
            element.addressFormat == v1AddressFormat.address_format_ethereum) &&
        element.accounts.any((element) =>
            element.addressFormat == v1AddressFormat.address_format_solana));

    return firstWhereOrNull2;
  }
}
