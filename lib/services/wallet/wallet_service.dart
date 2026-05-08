import 'dart:async';

import 'package:finality/data/model/network_address_pair.dart';
import 'package:finality/domain/wallet/entities/unified_account.dart';
import 'package:finality/domain/wallet/entities/unified_wallet_accounts.dart';
import 'package:finality/domain/wallet/wallet_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart' as rx;

class WalletService {
  WalletService(this._walletSelector);

  final WalletSelector _walletSelector;

  final ValueNotifier<UnifiedWalletAccounts?> walletAccounts =
      ValueNotifier(null);
  final rx.BehaviorSubject<UnifiedWalletAccounts?> walletAccountsSubject =
      rx.BehaviorSubject.seeded(null);
  final ValueNotifier<List<NetworkAddressPair>> networkAddressPairs =
      ValueNotifier([]);
  StreamSubscription<UnifiedWalletAccounts?>? _streamSubscription;

  void init() {
    _streamSubscription =
        _walletSelector.streamSelectedWalletAccounts().listen((walletAccounts) {
      _handleWalletAccountsChange(walletAccounts);
      this.walletAccounts.value = walletAccounts;
      walletAccountsSubject.add(walletAccounts);
    });
  }

  void _handleWalletAccountsChange(UnifiedWalletAccounts? event) {
    if (event != null) {
      var pairs = event.networkAddressPairs;
      if (!listEquals(pairs, networkAddressPairs.value)) {
        networkAddressPairs.value = pairs;
      }
    } else {
      networkAddressPairs.value = [];
    }
  }

  UnifiedAccount? getSolanaAccount() {
    return walletAccounts.value?.getSolanaAccount();
  }

  void dispose() {
    _streamSubscription?.cancel();
    walletAccountsSubject.close();
  }

  Future<UnifiedWalletAccounts?> waitWalletAccounts(
      {Duration timeout = const Duration(seconds: 3)}) async {
    // 如果已经有值了，直接返回
    if (walletAccounts.value != null) {
      return walletAccounts.value;
    }

    try {
      // 监听 walletAccounts 的变化，过滤掉 null 值，等待第一个非 null 值
      return await walletAccountsSubject.stream
          .where((accounts) => accounts != null)
          .timeout(timeout)
          .first;
    } on TimeoutException {
      // 超时，返回 null（订阅会自动取消）
      return null;
    } catch (e) {
      // 其他错误，返回 null
      return null;
    }
  }
}
