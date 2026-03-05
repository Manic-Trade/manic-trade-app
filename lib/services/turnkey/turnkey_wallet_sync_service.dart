import 'package:drift/drift.dart';
import 'package:finality/core/logger.dart';
import 'package:finality/data/drift/turnkey_wallet_database.dart';
import 'package:finality/services/turnkey/turnkey_manager.dart';
import 'package:turnkey_sdk_flutter/turnkey_sdk_flutter.dart';

/// Turnkey wallet sync service
///
/// Syncs data from Turnkey SDK to local database for fast loading and offline access
class TurnkeyWalletSyncService {
  final TurnkeyWalletDatabase _turnkeyWalletDatabase;
  final TurnkeyManager _turnkeyManager;

  TurnkeyWalletSyncService(this._turnkeyWalletDatabase, this._turnkeyManager);

  bool _isListening = false;
  bool get isListening => _isListening;

  Future<void> readyTurnkeyProvider() async {
    final stopwatch = Stopwatch()..start();
    await _turnkeyManager.ensureInitialized();
    stopwatch.stop();
    logger.d(
        'TurnkeyWalletSyncService: _turnkeyProvider.ready took ${stopwatch.elapsedMilliseconds}ms');
  }

  /// Listen to TurnkeyProvider changes and auto-sync
  void startListening() async {
    _isListening = true;
    _turnkeyManager.addListener(_onProviderChanged);
    readyTurnkeyProvider();
    // Initial sync
    _syncFromProvider();
  }

  /// Stop listening
  void stopListening() {
    _isListening = false;
    _turnkeyManager.removeListener(_onProviderChanged);
  }

  void _onProviderChanged() {
    _syncFromProvider();
  }

  /// Sync data from TurnkeyProvider to local database
  Future<void> _syncFromProvider() async {
    try {
      final user = _turnkeyManager.user;
      final wallets = _turnkeyManager.wallets;

      if (user == null) {
        logger.d('TurnkeyWalletSyncService: No user, skipping sync');
        return;
      }

      logger.d(
          'TurnkeyWalletSyncService: Syncing user ${user.userId} with ${wallets?.length ?? 0} wallets');

      await syncUser(user);

      if (wallets != null && wallets.isNotEmpty) {
        await syncWallets(user.userId, wallets);
      }
    } catch (e, stackTrace) {
      logger.e('TurnkeyWalletSyncService: Sync failed',
          error: e, stackTrace: stackTrace);
    }
  }

  /// Sync user info
  Future<void> syncUser(v1User user) async {
    final userCompanion = TurnkeyUsersCompanion(
      id: Value(user.userId),
      name: Value(user.userName),
      email: Value(user.userEmail),
      // phone: from user if available
      updatedAt: Value(DateTime.now()),
    );
    await _turnkeyWalletDatabase.syncUser(userCompanion);
  }

  /// Sync wallet list
  Future<void> syncWallets(String userId, List<Wallet> wallets) async {
    final walletCompanions = <TurnkeyWalletsCompanion>[];
    final accountCompanions = <TurnkeyAccountsCompanion>[];

    for (final wallet in wallets) {
      walletCompanions.add(_convertWallet(userId, wallet));

      for (final account in wallet.accounts) {
        accountCompanions.add(_convertAccount(wallet.id, account));
      }
    }

    await _turnkeyWalletDatabase.syncWallets(walletCompanions);
    await _turnkeyWalletDatabase.syncAccounts(accountCompanions);
  }

  /// Convert Turnkey Wallet to database Companion
  TurnkeyWalletsCompanion _convertWallet(String userId, Wallet wallet) {
    return TurnkeyWalletsCompanion(
      id: Value(wallet.id),
      userId: Value(userId),
      name: Value(wallet.name),
      // SDK Wallet has no exported/imported, use default
      updatedAt: Value(DateTime.now()),
    );
  }

  /// Convert Turnkey Account to database Companion
  TurnkeyAccountsCompanion _convertAccount(
      String walletId, v1WalletAccount account) {
    return TurnkeyAccountsCompanion(
      id: Value(account.walletAccountId),
      walletId: Value(walletId),
      networkCode: Value(_convertAddressFormat(account.addressFormat)),
      address: Value(account.address),
      publicKey: Value(account.publicKey ?? ''),
      derivationPath: Value(account.path),
      keyIndex: Value(_extractKeyIndex(account.addressFormat, account.path)),
    );
  }

  /// Convert address format to network code
  String _convertAddressFormat(v1AddressFormat format) {
    switch (format) {
      case v1AddressFormat.address_format_solana:
        return 'solana';
      case v1AddressFormat.address_format_ethereum:
        return 'ethereum';
      default:
        return format.name;
    }
  }

  /// Extract key index from derivation path
  int _extractKeyIndex(v1AddressFormat format, String path) {
    final segments = path.replaceFirst(RegExp(r'^m/'), '').split('/');
    final numbers = segments
        .map((segment) => int.tryParse(segment.replaceAll("'", '')))
        .whereType<int>()
        .toList();

    if (numbers.isEmpty) return 0;

    switch (format) {
      case v1AddressFormat.address_format_solana:
        // Solana: m/44'/501'/{account_index}'/0'
        return numbers.length >= 2 ? numbers[numbers.length - 2] : 0;
      case v1AddressFormat.address_format_ethereum:
        // Ethereum: m/44'/60'/0'/0/{account_index}
        return numbers.last;
      default:
        return numbers.last;
    }
  }

  /// Manually trigger full sync
  Future<void> forceSync() async {
    await _syncFromProvider();
  }

  /// Clear local data for given user
  Future<void> clearUserData(String userId) async {
    await _turnkeyWalletDatabase.clearUserData(userId);
  }

  /// Clear all local data
  Future<void> clearAll() async {
    await _turnkeyWalletDatabase.clearAll();
  }
}
