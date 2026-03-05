import 'dart:async';

import 'package:collection/collection.dart';
import 'package:finality/domain/wallet/entities/account_network.dart';
import 'package:finality/domain/wallet/entities/unified_wallet_accounts.dart';
import 'package:finality/data/drift/user_preferences_database.dart';
import 'package:finality/domain/wallet/wallet_selector.dart';
import 'package:finality/data/model/network_address_pair.dart';
import 'package:finality/di/injector.dart';
import 'package:flutter/material.dart';
import 'package:store_scope/store_scope.dart';

final transferAddressVMProvider = ViewModelProvider.withArgument(
  (StoreSpace storeSpace, AccountNetwork accountNetwork) => TransferAddressVM(
    userPreferencesDb: injector(),
    walletSelector: injector(),
    accountNetwork: accountNetwork,
  ),
);

class TransferAddressVM extends ViewModel {
  final UserPreferencesDatabase userPreferencesDb;
  final WalletSelector walletSelector;
  final AccountNetwork accountNetwork;

  TransferAddressVM({
    required this.userPreferencesDb,
    required this.walletSelector,
    required this.accountNetwork,
  });

  final ValueNotifier<List<RecentSentAddress>> recentSentAddresses =
      ValueNotifier([]);
  final ValueNotifier<List<SavedAddress>> savedAddresses = ValueNotifier([]);
  final ValueNotifier<List<UnifiedWalletAccounts>> otherWalletAccounts =
      ValueNotifier([]);
  List<UnifiedWalletAccounts> allWalletAccounts = [];

  final ValueNotifier<bool> hasRecent = ValueNotifier(false);
  final ValueNotifier<bool> hasSaved = ValueNotifier(false);
  final ValueNotifier<bool> hasOtherWallets = ValueNotifier(false);

  StreamSubscription<List<RecentSentAddress>>? recentSubscription;
  StreamSubscription<List<SavedAddress>>? savedSubscription;

  @override
  void init() {
    super.init();
    recentSubscription =
        userPreferencesDb.recentSentAddressDao.streamItems().listen((event) {
      if (event.isNotEmpty) {
        recentSentAddresses.value = event
            .where(
                (element) => element.address != accountNetwork.account.address)
            .toList();
        hasRecent.value = recentSentAddresses.value.isNotEmpty;
      } else {
        hasRecent.value = false;
        recentSentAddresses.value = [];
      }
    });

    savedSubscription =
        userPreferencesDb.savedAddressDao.streamItems().listen((event) {
      savedAddresses.value = event;
      hasSaved.value = savedAddresses.value.isNotEmpty;
    });

    walletSelector.loadAllWalletAccounts().then((event) {
      if (event.isNotEmpty) {
        allWalletAccounts = event;
        otherWalletAccounts.value = event
            .where(
                (wallet) => wallet.wallet.id != accountNetwork.account.walletId)
            .toList();
        hasOtherWallets.value = otherWalletAccounts.value.isNotEmpty;
      }
    });
  }

  // 检查传入的地址是否已经保存
  bool checkAddressAlreadySaved(NetworkAddressPair networkAddressPair) {
    return savedAddresses.value.any((element) {
      return element.address == networkAddressPair.address &&
          element.networkCode == networkAddressPair.networkCode;
    });
  }

  // 检查传入的地址是否属于用户拥有的任何钱包，包括当前选中的钱包和其他钱包。
  bool checkAddressInMyWallets(NetworkAddressPair networkAddressPair) {
    // 检查传入的地址是否在当前钱包的账户中
    bool isInCurrentWallet = accountNetwork.account.address ==
            networkAddressPair.address &&
        accountNetwork.account.networkCode == networkAddressPair.networkCode;

    if (isInCurrentWallet) {
      return true;
    }

    // 检查是否在其他钱包账户中
    return otherWalletAccounts.value.any((walletAccount) {
      return walletAccount.accounts.any((account) {
        return account.address == networkAddressPair.address &&
            account.networkCode == networkAddressPair.networkCode;
      });
    });
  }

  SavedAddress? findSavedAddressByAddress(
      NetworkAddressPair networkAddressPair) {
    return savedAddresses.value.firstWhereOrNull((savedAddress) {
      return savedAddress.address == networkAddressPair.address &&
          savedAddress.networkCode == networkAddressPair.networkCode;
    });
  }

  UnifiedWalletAccounts? findWalletAccountsByAddress(
      NetworkAddressPair networkAddressPair) {
    return allWalletAccounts.firstWhereOrNull((walletAccount) {
      return walletAccount.accounts.any((account) {
        return account.address == networkAddressPair.address &&
            account.networkCode == networkAddressPair.networkCode;
      });
    });
  }

  /// 获取保存按钮的显示状态
  /// 返回值：
  /// - null: 不显示任何按钮（是我的钱包）
  /// - true: 显示保存按钮（未保存且不是我的钱包）
  /// - false: 显示修改按钮（已保存）
  bool? getSaveButtonState(NetworkAddressPair networkAddressPair) {
    // 检查是否已保存
    bool isAlreadySaved = checkAddressAlreadySaved(networkAddressPair);
    // 如果未保存，检查是否属于我的钱包
    if (!isAlreadySaved) {
      //属于我的钱包时不显示按钮
      if (checkAddressInMyWallets(networkAddressPair)) {
        return null;
      }
    }

    // 如果已保存，显示修改按钮；如果未保存，显示保存按钮
    return !isAlreadySaved;
  }

  Future<void> saveAddress(SavedAddress address) {
    return userPreferencesDb.savedAddressDao.insertItem(address);
  }

  Future<void> deleteAddress(SavedAddress address) {
    return userPreferencesDb.savedAddressDao.deleteItem(address);
  }

  Future<void> deleteRecentAddress(RecentSentAddress recentSentAddress) {
    return userPreferencesDb.recentSentAddressDao.deleteItem(recentSentAddress);
  }

  @override
  void dispose() {
    recentSubscription?.cancel();
    savedSubscription?.cancel();
    super.dispose();
  }
}
