import 'package:finality/core/logger.dart';
import 'package:finality/domain/auth/user_profile_store.dart';
import 'package:finality/domain/auth/wallet_auth_manager.dart';
import 'package:finality/domain/wallet/wallet_selector.dart';
import 'package:finality/services/turnkey/turnkey_manager.dart';
import 'package:finality/services/turnkey/turnkey_wallet_sync_service.dart';

/// Turnkey 登录成功后的统一收尾数据（各登录路径填完就交给 coordinator）。
class TurnkeyLoginResult {
  const TurnkeyLoginResult({
    required this.userId,
    required this.tradeWalletAddress,
    this.loginWalletAddress,
  });

  /// Turnkey 的 userId，作为 UserSelector 的选中用户
  final String userId;

  /// Turnkey 托管钱包的 Solana 地址，用于埋点 identify
  final String tradeWalletAddress;

  /// 外部登录钱包地址（仅 Web3 钱包登录时有值）
  final String? loginWalletAddress;
}

/// 登录/登出流程协调器
///
/// 收敛 3 条登录路径（Web3 / OAuth / Email）完成 Turnkey 认证之后的公共步骤，
/// 以及 3 处登出入口（user_page / preferences_page / env_settings_screen）的
/// 公共清理步骤。调用方只负责各自特有的认证环节，收尾统一走这里，保证对称性。
class AuthSessionCoordinator {
  AuthSessionCoordinator(
    this._turnkeyManager,
    this._syncService,
    this._walletAuthManager,
    this._walletSelector,
    this._profileStore,
  );

  final TurnkeyManager _turnkeyManager;
  final TurnkeyWalletSyncService _syncService;
  final WalletAuthManager _walletAuthManager;
  final WalletSelector _walletSelector;
  final UserProfileStore _profileStore;

  /// Turnkey 登录最后一公里：设置当前用户、写入 per-user 资料、同步钱包、埋点。
  ///
  /// 调用前提：
  /// - Turnkey 已登录（`turnkeyManager.user` 已就绪）；
  /// - 服务端 token 已写入（`walletAuthManager.loginTurnkeyWallet` 已完成）。
  Future<void> finalizeTurnkeyLogin(TurnkeyLoginResult result) async {
    // 1. 必须先设置 userId，后续 UserProfileStore 才能拿到 key 前缀
    _walletSelector.setTurnkeyUserId(result.userId);

    // 2. per-user 资料：始终覆盖写，避免同一 userId 先 Web3 后 Email 登录时残留旧地址
    final loginWallet = result.loginWalletAddress;
    _profileStore.loginWalletAddress =
        (loginWallet != null && loginWallet.isNotEmpty) ? loginWallet : null;

    // 3. 同步 Turnkey 钱包数据并开启监听
    await _syncService.forceSync();
    _syncService.startListening();
  }

  /// 统一登出：停同步、清 Turnkey session、清服务端 token、清当前用户。
  ///
  /// 每一步独立容错：任一步抛错只记日志不中断，保证清理尽力完成，避免停在
  /// 半登出状态（比如 Turnkey 清理失败但服务端 token 仍有效）。
  ///
  /// 说明：UserProfileStore 按 userId 命名空间，`clearSelectedUser` 之后当前
  /// 用户视角下的数据天然不可见，不需要显式清理。
  Future<void> logout() async {
    await _runSafely('stopListening', () async {
      if (_syncService.isListening) {
        _syncService.stopListening();
      }
    });
    await _runSafely(
        'clearTurnkeySessions', () => _turnkeyManager.clearAllSessions());
    await _runSafely(
        'logoutAllWallets', () => _walletAuthManager.logoutAllWallets());
    await _runSafely('clearSelectedUser', () async {
      _walletSelector.clearSelectedUser();
    });
  }

  /// 仅清除服务端认证 token（并清掉 per-user 的后端缓存），保留 Turnkey session
  /// 和当前选中用户。
  ///
  /// 场景：环境切换。新环境下服务端 base_url 不同，旧 token 无效；但 Turnkey
  /// session 不绑定环境、UserSelector 也保留，重启后仍是已登录态，下一次调用
  /// 服务端接口时会自动重新拿 token，对用户无感。
  Future<void> invalidateServerToken() async {
    await _walletAuthManager.logoutAllWallets();
  }

  Future<void> _runSafely(String step, Future<void> Function() action) async {
    try {
      await action();
    } catch (e, stackTrace) {
      logger.e('AuthSessionCoordinator.logout step [$step] failed',
          error: e, stackTrace: stackTrace);
    }
  }
}
