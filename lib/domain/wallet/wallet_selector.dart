import 'package:finality/domain/wallet/entities/unified_wallet_accounts.dart';
import 'package:finality/domain/wallet/turnkey_wallet_selector.dart';
import 'package:finality/domain/wallet/user_selector.dart';
import 'package:rxdart/rxdart.dart';

/// Turnkey-only wallet selector. Wraps [TurnkeyWalletSelector] and exposes a
/// unified [UnifiedWalletAccounts] surface for upper layers.
class WalletSelector {
  final TurnkeyWalletSelector _turnkeyWalletSelector;
  final UserSelector _userSelector;

  WalletSelector(
    this._turnkeyWalletSelector,
    this._userSelector,
  );

  bool get isTurnkeyUser => _userSelector.isTurnkeyUser();

  String? get _turnkeyUserId => _userSelector.selectedUserId;

  Stream<UnifiedWalletAccounts?> streamSelectedWalletAccounts() {
    return _userSelector.streamSelectedUserId().switchMap((userId) {
      if (userId == null) return Stream.value(null);
      return _turnkeyWalletSelector.selectedWalletStream(userId).map((wallet) {
        if (wallet == null) return null;
        return UnifiedWalletAccounts.fromTurnkey(wallet);
      });
    });
  }

  Stream<List<UnifiedWalletAccounts>> streamAllWalletAccounts() {
    return _userSelector.streamSelectedUserId().switchMap((userId) {
      if (userId == null) return Stream.value(<UnifiedWalletAccounts>[]);
      return _turnkeyWalletSelector.walletsStream(userId).map((wallets) =>
          wallets.map((e) => UnifiedWalletAccounts.fromTurnkey(e)).toList());
    });
  }

  Future<UnifiedWalletAccounts?> loadSelectedWalletAccounts() async {
    final userId = _turnkeyUserId;
    if (userId == null) return null;
    final wallet = await _turnkeyWalletSelector.loadWalletAccounts(userId);
    if (wallet == null) return null;
    return UnifiedWalletAccounts.fromTurnkey(wallet);
  }

  Future<List<UnifiedWalletAccounts>> loadAllWalletAccounts() async {
    final userId = _turnkeyUserId;
    if (userId == null) return [];
    final wallets = await _turnkeyWalletSelector.loadAllWallets(userId);
    return wallets.map((e) => UnifiedWalletAccounts.fromTurnkey(e)).toList();
  }

  void setSelectedTurnkeyWalletId(String walletId) {
    final userId = _turnkeyUserId;
    if (userId != null) {
      _turnkeyWalletSelector.setSelectedWalletId(userId, walletId);
    }
  }

  void setTurnkeyUserId(String userId) {
    _userSelector.setTurnkeyUserId(userId);
  }

  void clearSelectedUser() {
    _userSelector.clearSelectedUser();
  }

  Future<bool> hasUserAndWallet() async {
    final selectedUserId = _userSelector.selectedUserId;
    if (selectedUserId == null) return false;
    return _turnkeyWalletSelector.hasWallet(selectedUserId);
  }
}
