import 'package:finality/domain/wallet/entities/unified_wallet_accounts.dart';
import 'package:finality/domain/wallet/turnkey_wallet_selector.dart';
import 'package:finality/domain/wallet/user_selector.dart';
import 'package:rxdart/rxdart.dart';

/// 统一钱包选择器
///
/// 封装 TurnkeyWalletSelector，
/// 根据 UserSelector 判断当前用户，对外提供统一的 UnifiedWalletAccounts 数据
class WalletSelector {
  final TurnkeyWalletSelector _turnkeyWalletSelector;
  final UserSelector _userSelector;

  WalletSelector(
    this._turnkeyWalletSelector,
    this._userSelector,
  );

  /// 当前是否是 Turnkey 用户
  bool get isTurnkeyUser => _userSelector.isTurnkeyUser();

  /// 监听当前选中的钱包账户变化
  Stream<UnifiedWalletAccounts?> streamSelectedWalletAccounts() {
    return _userSelector.streamSelectedUserId().switchMap((userId) {
      if (userId == null) {
        return Stream.value(null);
      }
      return _turnkeyWalletSelector.selectedWalletStream(userId).map((wallet) {
        if (wallet == null) return null;
        return UnifiedWalletAccounts.fromTurnkey(wallet);
      });
    });
  }

  Stream<List<UnifiedWalletAccounts>> streamAllWalletAccounts() {
    return _userSelector.streamSelectedUserId().switchMap((userId) {
      if (userId == null) {
        return Stream.value(<UnifiedWalletAccounts>[]);
      }
      return _turnkeyWalletSelector.walletsStream(userId).map((wallets) =>
          wallets.map((e) => UnifiedWalletAccounts.fromTurnkey(e)).toList());
    });
  }

  /// 异步加载当前选中的钱包账户
  Future<UnifiedWalletAccounts?> loadSelectedWalletAccounts() async {
    final userId = _userSelector.selectedUserId;
    if (userId != null) {
      final wallet = await _turnkeyWalletSelector.loadWalletAccounts(userId);
      if (wallet != null) {
        return UnifiedWalletAccounts.fromTurnkey(wallet);
      }
    }
    return null;
  }

  Future<List<UnifiedWalletAccounts>> loadAllWalletAccounts() async {
    final userId = _userSelector.selectedUserId;
    if (userId != null) {
      final wallets = await _turnkeyWalletSelector.loadAllWallets(userId);
      return wallets
          .map((e) => UnifiedWalletAccounts.fromTurnkey(e))
          .toList();
    }
    return [];
  }

  /// 设置选中的 Turnkey 钱包
  void setSelectedTurnkeyWalletId(String walletId) {
    final userId = _userSelector.selectedUserId;
    if (userId != null) {
      _turnkeyWalletSelector.setSelectedWalletId(userId, walletId);
    }
  }

  /// 设置 Turnkey 用户
  void setTurnkeyUserId(String userId) {
    _userSelector.setTurnkeyUserId(userId);
  }

  /// 清除选中的用户
  void clearSelectedUser() {
    _userSelector.clearSelectedUser();
  }

  Future<bool> hasUserAndWallet() async {
    final selectedUserId = _userSelector.selectedUserId;
    if (selectedUserId == null) {
      return false;
    }
    return _turnkeyWalletSelector.hasWallet(selectedUserId);
  }
}
