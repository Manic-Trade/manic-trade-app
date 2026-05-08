import 'dart:async';

import 'package:finality/data/drift/dao/turnkey_account_dao.dart';
import 'package:finality/data/drift/dao/turnkey_wallet_dao.dart';
import 'package:finality/data/drift/turnkey_wallet_database.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Turnkey 钱包选择器
///
/// 从本地数据库读取 Turnkey 钱包数据，提供钱包选择和监听功能
/// userId 由外部传入，本类只负责根据 userId 查询和选择钱包
class TurnkeyWalletSelector {
  static const String _keySelectedWalletIdPrefix = "turnkey_selected_walletId";

  final SharedPreferences _prefs;
  final TurnkeyWalletDao _walletDao;
  final TurnkeyAccountDao _accountDao;

  TurnkeyWalletSelector(this._prefs, TurnkeyWalletDatabase database)
      : _walletDao = database.turnkeyWalletDao,
        _accountDao = database.turnkeyAccountDao;

  /////////////////////////////////////////////////
  // Wallet ID
  ////////////////////////////////////////////////

  String _getSelectedWalletKey(String userId) {
    return "${_keySelectedWalletIdPrefix}_$userId";
  }

  String? _getSelectedWalletId(String userId) {
    return _prefs.getString(_getSelectedWalletKey(userId));
  }

  /// 计算实际选中的钱包 ID
  String? _calculateRealSelectedWalletId(
      String userId, List<String> walletIds, String? selectedId) {
    if (walletIds.isEmpty) {
      return null;
    }
    String resultWalletId = walletIds.first;
    if (selectedId != null && walletIds.contains(selectedId)) {
      resultWalletId = selectedId;
    }
    setSelectedWalletId(userId, resultWalletId, shouldNotify: false);
    return resultWalletId;
  }

  /// 设置选中的钱包 ID
  void setSelectedWalletId(String userId, String? walletId,
      {bool shouldNotify = true}) {
    final currentSelectedId = _getSelectedWalletId(userId);
    if (walletId == currentSelectedId) {
      return;
    }

    final key = _getSelectedWalletKey(userId);
    if (walletId == null) {
      _prefs.remove(key).ignore();
    } else {
      _prefs.setString(key, walletId).ignore();
    }
  }

  Stream<TurnkeyWallet?> selectedWalletAsStream(String userId) {
    return selectedWalletIdAsStream(userId).switchMap((walletId) async* {
      if (walletId != null) {
        yield* _walletDao.walletAsStream(walletId);
      } else {
        yield null;
      }
    });
  }

  Stream<String?> selectedWalletIdAsStream(String userId) {
    final selectedId = _getSelectedWalletId(userId);
    return _walletDao.walletIdsByUserIdAsStream(userId).map((walletIds) {
      return _calculateRealSelectedWalletId(userId, walletIds, selectedId);
    });
  }

  Future<TurnkeyWallet?> loadSelectedWallet(String userId) async {
    final id = await loadSelectedWalletId(userId);
    if (id != null) {
      return _walletDao.loadWallet(id);
    } else {
      return null;
    }
  }

  Future<String?> loadSelectedWalletId(String userId) async {
    final walletIds = await _walletDao.walletIdsByUserId(userId);
    final selectedId = _getSelectedWalletId(userId);
    return _calculateRealSelectedWalletId(userId, walletIds, selectedId);
  }

  /////////////////////////////////////////////////
  // WalletAccounts (TurnkeyWalletWithAccounts)
  ////////////////////////////////////////////////

  /// 监听当前选中钱包的变化（带 accounts）
  Stream<TurnkeyWalletWithAccounts?> selectedWalletStream(String userId) {
    return streamWalletAccountsWithNull(userId);
  }

  Stream<TurnkeyWalletWithAccounts?> streamWalletAccountsWithNull(
      String userId) {
    return selectedWalletAsStream(userId).switchMap((wallet) {
      if (wallet == null) {
        return Stream.value(null);
      } else {
        return _streamWalletAccountsWithWallet(wallet);
      }
    });
  }

  /// 监听所有钱包变化
  Stream<List<TurnkeyWalletWithAccounts>> walletsStream(String userId) {
    return streamAllWalletAccounts(userId);
  }

  Stream<List<TurnkeyWalletWithAccounts>> streamAllWalletAccounts(
      String userId) {
    return _walletDao.walletsByUserIdAsStream(userId).switchMap((wallets) {
      if (wallets.isEmpty) {
        return Stream.value(<TurnkeyWalletWithAccounts>[]);
      }
      final streams = wallets.map((wallet) {
        return _accountDao
            .accountsAsStreamByIndex(wallet.id, 0)
            .map((accounts) => TurnkeyWalletWithAccounts(wallet, accounts, 0));
      }).toList();
      return Rx.combineLatestList(streams);
    });
  }

  Stream<TurnkeyWalletWithAccounts> streamWalletAccounts(String userId) {
    return selectedWalletAsStream(userId)
        .mapNotNull((wallet) => wallet)
        .switchMap((wallet) => _streamWalletAccountsWithWallet(wallet));
  }

  Stream<TurnkeyWalletWithAccounts> _streamWalletAccountsWithWallet(
      TurnkeyWallet wallet) {
    return _accountDao
        .accountsAsStreamByIndex(wallet.id, 0)
        .map((accounts) => TurnkeyWalletWithAccounts(wallet, accounts, 0));
  }

  Future<TurnkeyWalletWithAccounts> loadWalletAccountsWithWallet(
      TurnkeyWallet wallet) async {
    final accounts = await _accountDao.accountsByIndex(wallet.id, 0);
    return TurnkeyWalletWithAccounts(wallet, accounts, 0);
  }

  Future<TurnkeyWalletWithAccounts?> loadWalletAccounts(String userId) async {
    final wallet = await loadSelectedWallet(userId);
    if (wallet != null) {
      return loadWalletAccountsWithWallet(wallet);
    } else {
      return null;
    }
  }

  Future<List<TurnkeyWalletWithAccounts>> loadAllWallets(String userId) async {
    final wallets = await _walletDao.loadWalletsByUserId(userId);
    final List<TurnkeyWalletWithAccounts> walletAccountsList = [];
    for (final wallet in wallets) {
      final accounts = await _accountDao.accountsByIndex(wallet.id, 0);
      walletAccountsList.add(TurnkeyWalletWithAccounts(wallet, accounts, 0));
    }
    return walletAccountsList;
  }

  Future<bool> hasWallet(String userId) async {
    final count = await _walletDao.count(userId);
    return count > 0;
  }
}
