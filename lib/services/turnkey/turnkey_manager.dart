import 'dart:async';
import 'dart:io' show Platform;

import 'package:finality/core/logger.dart';
import 'package:finality/di/injector.dart';
import 'package:finality/domain/auth/wallet_auth_manager.dart';
import 'package:finality/domain/wallet/wallet_selector.dart';
import 'package:finality/env/app_secrets.dart';
import 'package:finality/routes/app_pages.dart';
import 'package:finality/services/turnkey/turnkey_apple_oauth.dart';
import 'package:finality/services/turnkey/turnkey_external_browser_oauth.dart';
import 'package:finality/services/turnkey/turnkey_google_oauth.dart';
import 'package:finality/services/turnkey/turnkey_wallet_sync_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:turnkey_sdk_flutter/turnkey_sdk_flutter.dart';

/// TurnkeyProvider 的外观类/代理类
///
/// 将 TurnkeyProvider 作为内部实现细节，对外提供统一的接口。
/// 这样可以：
/// 1. 隔离 SDK 依赖，业务代码不直接依赖 TurnkeyProvider
/// 2. 解决 provider 重建后引用失效的问题
/// 3. 方便添加额外的日志、错误处理等逻辑
class TurnkeyManager {
  TurnkeyManager();

  /// 内部 TurnkeyProvider 实例（不对外暴露）
  late TurnkeyProvider _provider;

  // ============ Session 事件流 ============

  StreamController<Session> sessionSelectedStreamController =
      StreamController<Session>.broadcast();
  Stream<Session> get sessionSelectedStream =>
      sessionSelectedStreamController.stream;
  StreamController<Session> sessionClearedStreamController =
      StreamController<Session>.broadcast();
  Stream<Session> get sessionClearedStream =>
      sessionClearedStreamController.stream;
  StreamController<Session> sessionCreatedStreamController =
      StreamController<Session>.broadcast();
  Stream<Session> get sessionCreatedStream =>
      sessionCreatedStreamController.stream;
  StreamController<Session> sessionRefreshedStreamController =
      StreamController<Session>.broadcast();
  Stream<Session> get sessionRefreshedStream =>
      sessionRefreshedStreamController.stream;
  StreamController<Session> sessionExpiredStreamController =
      StreamController<Session>.broadcast();
  Stream<Session> get sessionExpiredStream =>
      sessionExpiredStreamController.stream;

  bool _isInitialized = false;

  /// 维护外部添加的 listener 列表，用于 provider 重建时重新添加
  final Set<VoidCallback> _externalListeners = {};

  static const String defaultWalletName = "ManicTrade";

  // ============ 代理属性 ============

  /// Provider 初始化完成的 Future
  Future<void> ensureInitialized() => _provider.ensureInitialized();

  /// 当前用户信息
  v1User? get user => _provider.user;

  /// 当前钱包列表
  List<Wallet>? get wallets => _provider.wallets;

  /// 当前 Session
  Session? get session => _provider.session;

  /// 认证状态
  AuthState get authState => _provider.authState;

  // ============ ChangeNotifier 代理 ============

  /// 添加监听器
  ///
  /// 注意：listener 会被保存在内部列表中，当 provider 重建时会自动重新添加
  void addListener(VoidCallback listener) {
    _externalListeners.add(listener);
    _provider.addListener(listener);
  }

  /// 移除监听器
  void removeListener(VoidCallback listener) {
    _externalListeners.remove(listener);
    _provider.removeListener(listener);
  }

  // ============ 错误处理 ============

  /// 处理未捕获的异常，检查是否是 Turnkey 认证错误, 登录过期后 TurnkeyProvider._init 都报错，必须重新创建新的 TurnkeyProvider
  ///
  /// 如果是认证错误（code 7 或 16），会自动清除 session 并引导用户重新登录
  /// 返回 true 表示错误已被处理，false 表示不是 Turnkey 认证错误
  bool handleTurnkeyError(Object error, StackTrace stackTrace) {
    if (!checkIsTurnkeySessionValidError(error)) {
      return false;
    }
    logger.e('TurnkeyManager: Authentication failed, clearing session',
        error: error, stackTrace: stackTrace);

    try {
      _handleSessionInvalid(reinitialize: true);
    } catch (e) {
      logger.e('TurnkeyManager: Failed to handle session invalid', error: e);
    }

    return true;
  }

  static bool checkIsTurnkeySessionValidError(Object error) {
    if (error is! TurnkeyRequestError) {
      return false;
    }

    // code 7 = Unauthenticated, code 16 = Unauthenticated (另一种情况)
    if (error.code != 7 && error.code != 16) {
      return false;
    }
    return true;
  }

  // ============ Session 管理 ============

  /// 清除所有 Session
  Future<void> clearAllSessions() async {
    try {
      await _provider.clearAllSessions();
    } catch (e, stackTrace) {
      logger.e('TurnkeyManager: clearAllSessions failed',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // ============ OTP 认证 ============

  /// 初始化 OTP
  Future<String> initOtp({
    required OtpType otpType,
    required String contact,
  }) async {
    await _provider.ensureInitialized();
    return await _provider.initOtp(otpType: otpType, contact: contact);
  }

  /// 使用 OTP 登录或注册
  Future<LoginOrSignUpWithOtpResult> loginOrSignUpWithOtp({
    required String otpId,
    required String otpCode,
    required String contact,
    required OtpType otpType,
    String? publicKey,
    bool invalidateExisting = false,
    String? sessionKey,
    CreateSubOrgParams? createSubOrgParams,
  }) async {
    await _provider.ensureInitialized();
    return await _provider.loginOrSignUpWithOtp(
      otpId: otpId,
      otpCode: otpCode,
      contact: contact,
      otpType: otpType,
      publicKey: publicKey,
      invalidateExisting: invalidateExisting,
      sessionKey: sessionKey,
      createSubOrgParams: createSubOrgParams,
    );
  }

  // ============ OAuth 认证 ============

  /// 使用 Google OAuth 登录
  Future<void> handleGoogleOAuth({
    String? clientId,
    String? sessionKey,
    bool? invalidateExisting,
    String? publicKey,
    void Function({
      required String oidcToken,
      required String publicKey,
      required String providerName,
    })? onSuccess,
  }) async {
    await _provider.ensureInitialized();
    return await _provider.handleGoogleOAuth(
      clientId: clientId,
      sessionKey: sessionKey,
      invalidateExisting: invalidateExisting,
      publicKey: publicKey,
      onSuccess: onSuccess,
    );
  }

  /// Android 上的 Chrome Custom Tabs 可用性缓存：
  /// null 表示还没探测过；探测后缓存结果，避免每次登录都过一次 method channel。
  static bool? _cctAvailableCache;
  static const MethodChannel _nativeChannel =
      MethodChannel('trade.manic.app/methods');

  /// Android 上探测系统是否存在支持 Chrome Custom Tabs 的浏览器。
  /// 非 Android 平台直接返回 false（不走此分支）。
  static Future<bool> _isAndroidCctAvailable() async {
    if (!Platform.isAndroid) return false;
    if (_cctAvailableCache != null) return _cctAvailableCache!;
    try {
      final ok = await _nativeChannel
          .invokeMethod<bool>('isChromeCustomTabsAvailable');
      _cctAvailableCache = ok ?? false;
    } on PlatformException {
      _cctAvailableCache = false;
    }
    return _cctAvailableCache!;
  }

  /// X OAuth
  ///
  /// Android 选路逻辑：
  ///   支持 Chrome Custom Tabs → 走 SDK 原生流程（体验最好，tab 自动关）
  ///   不支持（如部分 MIUI / HyperOS）→ 回退到外部浏览器 + deep link
  /// 其他平台：沿用 SDK 的 SFSafariViewController 流
  Future<void> handleXOAuth({
    String? clientId,
    String? sessionKey,
    bool? invalidateExisting,
    String? publicKey,
    void Function({
      required String oidcToken,
      required String publicKey,
      required String providerName,
    })? onSuccess,
  }) async {
    await _provider.ensureInitialized();
    logger.d('handleXOAuth:${AppSecrets.xClientId}');
    const redirectUri =
        'https://oauth-redirect.turnkey.com?scheme=manic-trade-app';
    if (Platform.isAndroid && !(await _isAndroidCctAvailable())) {
      logger.d('CCT unavailable, fallback to external browser for X OAuth');
      return await _provider.handleXOAuthViaExternalBrowser(
        clientId: clientId,
        sessionKey: sessionKey,
        invalidateExisting: invalidateExisting,
        publicKey: publicKey,
        onSuccess: onSuccess,
        redirectUri: redirectUri,
      );
    }
    return await _provider.handleXOAuth(
      clientId: clientId,
      sessionKey: sessionKey,
      invalidateExisting: invalidateExisting,
      publicKey: publicKey,
      onSuccess: onSuccess,
      redirectUri: redirectUri,
    );
  }

  /// X OAuth Link：把 X identity 挂到当前已登录的 Turnkey user 上（不创建新 session）
  ///
  /// 选路逻辑与 [handleXOAuth] 完全一致：
  ///   Android 支持 CCT → SDK 内置 ChromeSafariBrowser
  ///   Android 不支持 CCT → 外部浏览器 + deep link
  ///   其他平台 → SDK 默认（SFSafariViewController 等）
  Future<void> handleXOAuthLink({
    String? clientId,
    void Function({
      required String oidcToken,
      required String providerName,
    })? onSuccess,
  }) async {
    await _provider.ensureInitialized();
    const redirectUri =
        'https://oauth-redirect.turnkey.com?scheme=manic-trade-app';
    if (Platform.isAndroid && !(await _isAndroidCctAvailable())) {
      logger.d('CCT unavailable, fallback to external browser for X OAuth link');
      return await _provider.handleXOAuthLinkViaExternalBrowser(
        clientId: clientId,
        redirectUri: redirectUri,
        onSuccess: onSuccess,
      );
    }
    return await _provider.handleXOAuthLink(
      clientId: clientId,
      redirectUri: redirectUri,
      onSuccess: onSuccess,
    );
  }

  /// 已登录 Turnkey user 的 X provider（如果存在）
  ///
  /// 用于业务侧判断「是否已经在 Turnkey 上挂过 X」从而短路 link 流程。
  /// 匹配规则：先按 providerName，再按 issuer 域名兜底（防止 max.com 这种被字符串
  /// 包含命中）。
  v1OauthProvider? get xOauthProvider =>
      _provider.user?.oauthProviders.firstWhereOrNull(_isXProvider);

  static bool _isXProvider(v1OauthProvider p) {
    final name = p.providerName.toLowerCase();
    if (name == 'x' || name == 'twitter') return true;
    final host = Uri.tryParse(p.issuer)?.host.toLowerCase() ?? '';
    return host == 'x.com' ||
        host == 'twitter.com' ||
        host.endsWith('.x.com') ||
        host.endsWith('.twitter.com');
  }

  /// Apple OAuth（浏览器流），Android 使用 WebView，其他平台走 SDK
  Future<void> handleAppleOAuth({
    String? clientId,
    String? sessionKey,
    bool? invalidateExisting,
    String? publicKey,
    void Function({
      required String oidcToken,
      required String publicKey,
      required String providerName,
    })? onSuccess,
  }) async {
    await _provider.ensureInitialized();
    // 注意：不要传自定义 onSuccess（除非调用方明确需要）。
    // Turnkey SDK 的 onSuccess 签名是 `void Function`，内部调用时 **不会 await**，
    // 如果在 onSuccess 里做 async 的 loginOrSignUpWithOAuth，会在 session 还没存好时
    // 就提前返回，导致后续 refreshWallets 报 "No session initialized"。
    // 走 SDK 默认分支（onSuccess 为 null）时，SDK 会 await loginOrSignUpWithOAuth。
    const redirectUri =
        'https://oauth-redirect.turnkey.com?scheme=manic-trade-app';
    if (Platform.isAndroid && !(await _isAndroidCctAvailable())) {
      logger.d('CCT unavailable, fallback to external browser for Apple OAuth');
      return await _provider.handleAppleOAuthViaExternalBrowser(
        clientId: clientId,
        sessionKey: sessionKey,
        invalidateExisting: invalidateExisting,
        publicKey: publicKey,
        redirectUri: redirectUri,
        onSuccess: onSuccess,
      );
    }
    return await _provider.handleAppleOAuth(
      clientId: clientId,
      sessionKey: sessionKey,
      invalidateExisting: invalidateExisting,
      publicKey: publicKey,
      redirectUri: redirectUri,
      onSuccess: onSuccess,
    );
  }

  /// 使用 Apple 原生登录（iOS Sign in with Apple）
  ///
  /// ⚠️ 已弃用，不要再接入！
  /// iOS 原生 SDK 返回的 identityToken `aud` 永远等于 App Bundle ID
  /// （trade.manic），而 Android/Web 浏览器流 `aud` 是 Services ID
  /// （trade.manic.web）。Turnkey 后端按 (iss, aud, sub) 匹配 OIDC 身份，
  /// 即使 Apple `sub` 相同也会拆成两个 sub-org / 两套钱包。
  /// 所有平台统一用 [handleAppleOAuth]（浏览器流）。
  @Deprecated('会导致同一 Apple 账号在 Turnkey 被拆成两个账户，改用 handleAppleOAuth')
  Future<void> handleAppleOAuthNative({
    String? sessionKey,
    bool? invalidateExisting,
    String? publicKey,
    void Function({
      required String oidcToken,
      required String publicKey,
      required String providerName,
      String? email,
      String? fullName,
    })? onSuccess,
  }) async {
    await _provider.ensureInitialized();
    return await _provider.handleAppleOAuthNative(
      sessionKey: sessionKey,
      invalidateExisting: invalidateExisting,
      publicKey: publicKey,
      onSuccess: onSuccess,
    );
  }

  /// 使用 Google 原生登录（自定义实现，支持原生 Google Sign-In）
  Future<void> handleGoogleOAuthNative({
    String? clientId,
    String? sessionKey,
    bool? invalidateExisting,
    String? publicKey,
    void Function({
      required String oidcToken,
      required String publicKey,
      required String providerName,
    })? onSuccess,
  }) async {
    await _provider.ensureInitialized();
    return await _provider.handleGoogleOAuthNative(
      clientId: clientId,
      sessionKey: sessionKey,
      invalidateExisting: invalidateExisting,
      publicKey: publicKey,
      onSuccess: onSuccess,
    );
  }

  // ============ 签名操作 ============

  /// 签名消息
  Future<v1SignRawPayloadResult> signMessage({
    required String message,
    required v1WalletAccount walletAccount,
    v1PayloadEncoding? encoding,
    v1HashFunction? hashFunction,
    bool? addEthereumPrefix,
  }) async {
    try {
      await _provider.ensureInitialized();
      return await _provider.signMessage(
        message: message,
        walletAccount: walletAccount,
        encoding: encoding,
        hashFunction: hashFunction,
        addEthereumPrefix: addEthereumPrefix,
      );
    } catch (e, stackTrace) {
      handleTurnkeyError(e, stackTrace);
      rethrow;
    }
  }

  /// 签名交易
  Future<v1SignTransactionResult> signTransaction({
    required String signWith,
    required String unsignedTransaction,
    required v1TransactionType type,
  }) async {
    try {
      await _provider.ensureInitialized();
      return await _provider.signTransaction(
        signWith: signWith,
        unsignedTransaction: unsignedTransaction,
        type: type,
      );
    } catch (e, stackTrace) {
      handleTurnkeyError(e, stackTrace);
      rethrow;
    }
  }

  /// 刷新钱包
  Future<void> refreshWallets() async {
    try {
      await _provider.ensureInitialized();
      await _provider.refreshWallets();
    } catch (e, stackTrace) {
      handleTurnkeyError(e, stackTrace);
      rethrow;
    }
  }

  // ============ 外部钱包认证 ============

  /// 使用外部 Web3 钱包登录或注册 Turnkey
  ///
  /// [wallet] 实现了 [WalletInterface] 的钱包实例
  /// [sessionKey] 可选的会话存储键
  /// [expirationSeconds] 可选的会话过期时间（秒）
  /// [invalidateExisting] 是否使现有会话失效（仅登录时）
  /// [createSubOrgParams] 子组织创建参数（仅注册时）
  ///
  /// 返回 [LoginOrSignUpWithWalletResult]，包含会话令牌和执行的操作类型
  Future<LoginOrSignUpWithWalletResult> loginOrSignUpWithWallet({
    required WalletInterface wallet,
    String? sessionKey,
    String? expirationSeconds,
    bool invalidateExisting = false,
    CreateSubOrgParams? createSubOrgParams,
  }) async {
    await _provider.ensureInitialized();
    try {
      // 使用默认的子组织参数（如果未提供）
      final params = createSubOrgParams ??
          CreateSubOrgParams(
            customWallet: CustomWallet(
              walletName: defaultWalletName,
              walletAccounts: [
                DEFAULT_ETHEREUM_ACCOUNT,
                DEFAULT_SOLANA_ACCOUNT,
              ],
            ),
          );

      return await _provider.loginOrSignUpWithWallet(
        wallet: wallet,
        sessionKey: sessionKey,
        expirationSeconds: expirationSeconds,
        invalidateExisting: invalidateExisting,
        createSubOrgParams: params,
      );
    } catch (e, stackTrace) {
      handleTurnkeyError(e, stackTrace);
      rethrow;
    }
  }

  /// 仅使用外部钱包登录（用户必须已存在）
  Future<LoginWithWalletResult> loginWithWallet({
    required WalletInterface wallet,
    String? organizationId,
    String? expirationSeconds,
    bool invalidateExisting = false,
    String? sessionKey,
  }) async {
    try {
      await _provider.ensureInitialized();
      return await _provider.loginWithWallet(
        wallet: wallet,
        organizationId: organizationId,
        expirationSeconds: expirationSeconds,
        invalidateExisting: invalidateExisting,
        sessionKey: sessionKey,
      );
    } catch (e, stackTrace) {
      handleTurnkeyError(e, stackTrace);
      rethrow;
    }
  }

  /// 仅使用外部钱包注册（创建新用户）
  Future<SignUpWithWalletResult> signUpWithWallet({
    required WalletInterface wallet,
    String? sessionKey,
    String? expirationSeconds,
    CreateSubOrgParams? createSubOrgParams,
  }) async {
    try {
      await _provider.ensureInitialized();
      final params = createSubOrgParams ??
          CreateSubOrgParams(
            customWallet: CustomWallet(
              walletName: defaultWalletName,
              walletAccounts: [
                DEFAULT_ETHEREUM_ACCOUNT,
                DEFAULT_SOLANA_ACCOUNT,
              ],
            ),
          );

      return await _provider.signUpWithWallet(
        wallet: wallet,
        sessionKey: sessionKey,
        expirationSeconds: expirationSeconds,
        createSubOrgParams: params,
      );
    } catch (e, stackTrace) {
      handleTurnkeyError(e, stackTrace);
      rethrow;
    }
  }

  // ============ 初始化和生命周期管理 ============

  TurnkeyConfig _createTurnkeyConfig() {
    final createSubOrgParams = CreateSubOrgParams(
      customWallet: CustomWallet(
        walletName: defaultWalletName,
        walletAccounts: [
          DEFAULT_ETHEREUM_ACCOUNT,
          DEFAULT_SOLANA_ACCOUNT,
        ],
      ),
    );
    return TurnkeyConfig(
      apiBaseUrl: "https://api.turnkey.com",
      authProxyBaseUrl: "https://authproxy.turnkey.com",
      organizationId: AppSecrets.turnkeyOrganizationId,
      authProxyConfigId: AppSecrets.turnkeyAuthProxyConfigId,
      appScheme: "manic-trade-app",
      authConfig: AuthConfig(
        autoRefreshManagedState: true,
        autoFetchWalletKitConfig: true,
        createSubOrgParams: MethodCreateSubOrgParams(
          emailOtpAuth: createSubOrgParams,
          smsOtpAuth: createSubOrgParams,
          oAuth: createSubOrgParams,
          passkeyAuth: createSubOrgParams,
        ),
        oAuthConfig: OAuthConfig(
          googleClientId: AppSecrets.googleClientId,
          xClientId: AppSecrets.xClientId,
          appleClientId: AppSecrets.appleClientId,
          oauthRedirectUri:
              'https://oauth-redirect.turnkey.com?scheme=manic-trade-app',
        ),
      ),
      onSessionSelected: (session) {
        logger.d("onSessionSelected: $session");
        sessionSelectedStreamController.add(session);
      },
      onSessionCleared: (session) {
        logger.d("onSessionCleared: $session");
        sessionClearedStreamController.add(session);
        _handleSessionInvalid();
      },
      onSessionCreated: (session) {
        logger.d("onSessionCreated: $session");
        sessionCreatedStreamController.add(session);
      },
      onSessionRefreshed: (session) {
        logger.d("onSessionRefreshed: $session");
        sessionRefreshedStreamController.add(session);
      },
      onSessionExpired: (session) {
        logger.d("onSessionExpired: $session");
        sessionExpiredStreamController.add(session);
        _handleSessionInvalid();
      },
      onSessionEmpty: () {
        logger.d("onSessionEmpty");
        _handleSessionInvalid();
      },
    );
  }

  /// 处理 session 失效（过期或被清除）
  Future<void> _handleSessionInvalid({bool reinitialize = false}) async {
    // 1. 清除 session 并重新初始化 provider
    if (reinitialize) {
      await _reinitialize();
    }

    // 检查是否有 Turnkey 用户登录，没有的话说明已经清理完了
    if (!injector.isRegistered<WalletSelector>()) return;
    if (!injector<WalletSelector>().isTurnkeyUser) return;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      bool needToJumpToWelcome = true;
      // 2. 停止同步服务
      if (injector.isRegistered<TurnkeyWalletSyncService>()) {
        var turnkeyWalletSyncService = injector<TurnkeyWalletSyncService>();
        if (turnkeyWalletSyncService.isListening) {
          turnkeyWalletSyncService.stopListening();
        } else {
          //同步服务没有在监听，说明已经跳转到欢迎页了，别再跳了
          needToJumpToWelcome = false;
        }
      }

      // 3. 清除服务器认证
      if (injector.isRegistered<WalletAuthManager>()) {
        var walletAuthManager = injector<WalletAuthManager>();
        await walletAuthManager.logoutAllWallets();
      }

      // 4. 清除用户选择
      injector<WalletSelector>().clearSelectedUser();

      // 5. 跳转到欢迎页
      if (needToJumpToWelcome) {
        Get.offAllNamed(Routes.welcome);
      }
    });
  }

  /// 初始化 Provider
  void initialize() {
    if (_isInitialized) return;
    _isInitialized = true;
    try {
      _provider =
          TurnkeyProvider(config: _createTurnkeyConfig(), autoInit: false);
      _provider.ensureInitialized();
    } catch (e, stackTrace) {
      logger.e('TurnKeyProviderManager: initialize failed',
          error: e, stackTrace: stackTrace);
    }
  }

  /// 重新初始化 provider（用于 session 失效后重置状态）
  Future<void> _reinitialize() async {
    // 保存当前的 listeners（在旧 provider 销毁前）
    final listenersToRestore = Set<VoidCallback>.from(_externalListeners);
    for (final listener in listenersToRestore) {
      _provider.removeListener(listener);
    }
    try {
      await clearAllSessions();
    } catch (_) {
      // 已在 clearAllSessions 中记录日志，这里忽略以继续重建流程
    }

    // 重新创建 provider，确保内部状态完全重置
    _isInitialized = false;
    initialize();

    // 将之前的 listeners 重新添加到新的 provider 上
    for (final listener in listenersToRestore) {
      _provider.addListener(listener);
    }

    logger.d(
        'TurnkeyManager: reinitialize completed, restored ${listenersToRestore.length} listeners');
  }
}
