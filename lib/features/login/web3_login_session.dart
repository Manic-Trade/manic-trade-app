import 'package:finality/core/logger.dart';
import 'package:finality/services/appkit/appkit_deep_link_handler.dart';
import 'package:reown_appkit/reown_appkit.dart';

/// Web3 钱包登录流程的共享会话
///
/// 在 Web3WalletLoginScreen 和 Web3WalletAuthenticatingScreen 之间
/// 共享 AppKitModal 实例和连接信息，统一管理生命周期。
///
/// 使用方式：
/// 1. LoginScreen 连接钱包后调用 [start] 创建会话
/// 2. AuthenticatingScreen 通过 [current] 获取会话
/// 3. 认证完成或页面销毁时调用 [dispose] 清理
class Web3LoginSession {
  static Web3LoginSession? _current;

  final ReownAppKitModal appKitModal;
  final String walletAddress;
  final String namespace;
  final String chainId;

  Web3LoginSession._({
    required this.appKitModal,
    required this.walletAddress,
    required this.namespace,
    required this.chainId,
  });

  /// 获取当前活跃的登录会话
  static Web3LoginSession? get current => _current;

  /// 开始新的登录会话，转移 AppKitModal 所有权
  static void start({
    required ReownAppKitModal appKitModal,
    required String walletAddress,
    required String namespace,
    required String chainId,
  }) {
    _current = Web3LoginSession._(
      appKitModal: appKitModal,
      walletAddress: walletAddress,
      namespace: namespace,
      chainId: chainId,
    );
  }

  /// 释放所有权：清空当前引用并返回 appKitModal，不做断开/dispose
  ///
  /// 用于把 appKitModal 的所有权交还给上一页（如用户从认证页中途返回时，
  /// LoginScreen 取回 appKitModal 继续复用，避免重新初始化）。
  /// 调用后 [current] 变为 null，原有的 [dispose] 不会再清理这个实例。
  static ReownAppKitModal? release() {
    final session = _current;
    _current = null;
    return session?.appKitModal;
  }

  /// 清理会话：断开连接并释放 AppKitModal
  static void dispose() {
    final session = _current;
    if (session == null) return;
    _current = null;

    try {
      AppKitDeepLinkHandler.setActiveAppKitModal(null);
      if (session.appKitModal.isConnected) {
        session.appKitModal.disconnect();
      }
      session.appKitModal.dispose();
    } catch (e) {
      logger.w('Web3LoginSession: cleanup error (ignored)', error: e);
    }
  }
}
