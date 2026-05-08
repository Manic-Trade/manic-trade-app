import 'package:drift/drift.dart';
import 'package:finality/core/logger.dart';
import 'package:finality/data/drift/turnkey_wallet_database.dart';
import 'package:finality/services/turnkey/turnkey_manager.dart';
import 'package:turnkey_sdk_flutter/turnkey_sdk_flutter.dart';

/// Turnkey 钱包同步服务
///
/// 负责将 Turnkey SDK 中的数据同步到本地数据库，
/// 以便快速加载和离线访问
class TurnkeyWalletSyncService {
  final TurnkeyWalletDatabase _turnkeyWalletDatabase;
  final TurnkeyManager _turnkeyManager;

  TurnkeyWalletSyncService(
    this._turnkeyWalletDatabase,
    this._turnkeyManager,
  );

  bool _isListening = false;
  bool get isListening => _isListening;

  Future<void> readyTurnkeyProvider() async {
    final stopwatch = Stopwatch()..start();
    await _turnkeyManager.ensureInitialized();
    stopwatch.stop();
    logger.d(
        'TurnkeyWalletSyncService: _turnkeyProvider.ready took ${stopwatch.elapsedMilliseconds}ms');
  }

  /// 监听 TurnkeyProvider 变化并自动同步
  void startListening() async {
    _isListening = true;

    _turnkeyManager.addListener(_syncFromProvider);
    readyTurnkeyProvider();
    // 初始同步
    _syncFromProvider();
  }

  /// 停止监听
  void stopListening() {
    _isListening = false;
    _turnkeyManager.removeListener(_syncFromProvider);
  }

  /// 从 TurnkeyProvider 同步数据到本地数据库
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

      // _identifyUser(user, wallets);
    } catch (e, stackTrace) {
      logger.e('TurnkeyWalletSyncService: Sync failed',
          error: e, stackTrace: stackTrace);
    }
  }

  /// 同步用户信息
  Future<void> syncUser(v1User user) async {
    final userCompanion = TurnkeyUsersCompanion(
      id: Value(user.userId),
      name: Value(user.userName),
      email: Value(user.userEmail),
      // phone: 从 user 获取（如果有的话）
      updatedAt: Value(DateTime.now()),
    );
    await _turnkeyWalletDatabase.syncUser(userCompanion);
  }

  /// 同步钱包列表
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

  /// 转换 Turnkey Wallet 为数据库 Companion
  TurnkeyWalletsCompanion _convertWallet(String userId, Wallet wallet) {
    return TurnkeyWalletsCompanion(
      id: Value(wallet.id),
      userId: Value(userId),
      name: Value(wallet.name),
      // SDK 的 Wallet 类没有 exported/imported 属性，使用默认值
      updatedAt: Value(DateTime.now()),
    );
  }

  /// 转换 Turnkey Account 为数据库 Companion
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

  /// 转换地址格式为网络代码
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

  /// 从派生路径中提取 key index
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

  /// 手动触发全量同步
  Future<void> forceSync() async {
    await _syncFromProvider();
  }

  /// 清除指定用户的本地数据
  Future<void> clearUserData(String userId) async {
    await _turnkeyWalletDatabase.clearUserData(userId);
  }

  /// 清除所有本地数据
  Future<void> clearAll() async {
    await _turnkeyWalletDatabase.clearAll();
  }
}
