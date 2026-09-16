import 'package:finality/core/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:reown_appkit/reown_appkit.dart';

/// AppKit Deep Link 处理器
/// 用于处理从外部钱包应用返回的 Deep Link
class AppKitDeepLinkHandler {
  AppKitDeepLinkHandler._();

  /// Method Channel 名称（与原生端通信）
  static const String _methodChannelName = 'trade.manic.app/methods';

  /// Event Channel 名称（接收原生端事件）
  static const String _eventChannelName = 'trade.manic.app/events';

  static const _methodChannel = MethodChannel(_methodChannelName);
  static const _eventChannel = EventChannel(_eventChannelName);

  static bool _isListenerInitialized = false;

  /// 当前活跃的 AppKitModal 实例（用于处理 Deep Link）
  static ReownAppKitModal? _activeAppKitModal;

  /// 设置当前活跃的 AppKitModal 实例
  static void setActiveAppKitModal(ReownAppKitModal? modal) {
    _activeAppKitModal = modal;
  }

  /// 初始化 Deep Link 监听器
  /// 应在 main.dart 中尽早调用
  static void initListener() {
    if (kIsWeb) {
      logger.i('AppKitDeepLinkHandler: Skipping init on web platform');
      return;
    }

    if (_isListenerInitialized) {
      logger.w('AppKitDeepLinkHandler: Listener already initialized');
      return;
    }

    try {
      _eventChannel.receiveBroadcastStream().listen(
            _onLinkReceived,
            onError: _onLinkError,
            cancelOnError: false,
          );
      _isListenerInitialized = true;
      logger.i('AppKitDeepLinkHandler: Listener initialized');
    } catch (e, stackTrace) {
      logger.e('AppKitDeepLinkHandler: Failed to initialize listener',
          error: e, stackTrace: stackTrace);
    }
  }

  /// 检查并处理初始链接（应用通过 Deep Link 启动时）
  static Future<void> checkInitialLink() async {
    if (kIsWeb) return;

    try {
      final initialLink =
          await _methodChannel.invokeMethod<String>('initialLink');
      if (initialLink != null && initialLink.isNotEmpty) {
        logger
            .i('AppKitDeepLinkHandler: Processing initial link: $initialLink');
        await _processLink(initialLink);
      }
    } on PlatformException catch (e) {
      logger
          .w('AppKitDeepLinkHandler: No initial link available - ${e.message}');
    } catch (e, stackTrace) {
      logger.e('AppKitDeepLinkHandler: Failed to check initial link',
          error: e, stackTrace: stackTrace);
    }
  }

  /// 处理接收到的链接
  static void _onLinkReceived(dynamic link) async {
    if (link == null || link is! String || link.isEmpty) {
      logger.w('AppKitDeepLinkHandler: Received invalid link: $link');
      return;
    }

    logger.i('AppKitDeepLinkHandler: Received link: $link');
    await _processLink(link);
  }

  /// 处理链接错误
  static void _onLinkError(dynamic error) {
    logger.e('AppKitDeepLinkHandler: Link stream error: $error');
  }

  /// 处理链接
  static Future<void> _processLink(String link) async {
    // 检查是否是 AppKit 相关的链接
    if (!_isAppKitLink(link)) {
      logger.i('AppKitDeepLinkHandler: Link not for AppKit, ignoring');
      return;
    }

    // 尝试让当前活跃的 AppKitModal 处理
    if (_activeAppKitModal != null) {
      try {
        final handled = await _activeAppKitModal!.dispatchEnvelope(link);
        if (handled) {
          logger.i('AppKitDeepLinkHandler: Link handled by AppKitModal');
          return;
        }
      } catch (e, stackTrace) {
        logger.e('AppKitDeepLinkHandler: Error handling link',
            error: e, stackTrace: stackTrace);
      }
    } else {
      logger.w('AppKitDeepLinkHandler: No active AppKitModal to handle link');
    }

    logger.w('AppKitDeepLinkHandler: Link not handled: $link');
  }

  /// 判断链接是否是 AppKit 相关的
  ///
  /// 注意：`manic-trade-app://` scheme 是多路复用的，除了 WalletConnect 还会
  /// 承载 Turnkey OAuth 回调（?code=&id_token=）。不能仅凭 scheme 判断，
  /// 必须显式排除 OAuth 回调，否则会把 Apple/Google OAuth 的 deep link 吞掉，
  /// 触发 “No active AppKitModal to handle link” 误告警。
  static bool _isAppKitLink(String link) {
    final lower = link.toLowerCase();
    // OAuth 回调（Turnkey 走 app_links 自行监听）—— 放行
    if (lower.contains('id_token=') || lower.contains('oauth-redirect')) {
      return false;
    }
    return lower.contains('wc') ||
        lower.contains('walletconnect') ||
        lower.contains('reown') ||
        lower.contains('appkit') ||
        link.startsWith('manic-trade-app://');
  }
}
