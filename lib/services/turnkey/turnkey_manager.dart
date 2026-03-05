import 'dart:async';

import 'package:finality/core/logger.dart';
import 'package:finality/di/injector.dart';
import 'package:finality/domain/auth/wallet_auth_manager.dart';
import 'package:finality/env/app_secrets.dart';
import 'package:finality/domain/wallet/wallet_selector.dart';
import 'package:finality/routes/app_pages.dart';
import 'package:finality/services/turnkey/turnkey_google_oauth.dart';
import 'package:finality/services/turnkey/turnkey_wallet_sync_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:turnkey_sdk_flutter/turnkey_sdk_flutter.dart';

/// Facade/proxy for TurnkeyProvider
///
/// Uses TurnkeyProvider as internal implementation detail and exposes a unified API.
/// Benefits:
/// 1. Isolates SDK dependency, business code does not directly depend on TurnkeyProvider
/// 2. Fixes reference invalidation when provider is recreated
/// 3. Easy to add extra logging, error handling, etc.
class TurnkeyManager {
  TurnkeyManager();

  /// Internal TurnkeyProvider instance (not exposed)
  late TurnkeyProvider _provider;

  // ============ Session event streams ============

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

  /// Keeps track of externally added listeners for re-attachment when provider is recreated
  final Set<VoidCallback> _externalListeners = {};

  static const String defaultWalletName = "ManicTrade";

  // ============ Proxy properties ============

  /// Future that completes when Provider is initialized
  Future<void> ensureInitialized() => _provider.ensureInitialized();

  /// Current user info
  v1User? get user => _provider.user;

  /// Current wallet list
  List<Wallet>? get wallets => _provider.wallets;

  /// Current Session
  Session? get session => _provider.session;

  /// Auth state
  AuthState get authState => _provider.authState;

  // ============ ChangeNotifier proxy ============

  /// Add listener
  ///
  /// Note: listener is stored internally and will be re-attached when provider is recreated
  void addListener(VoidCallback listener) {
    _externalListeners.add(listener);
    _provider.addListener(listener);
  }

  /// Remove listener
  void removeListener(VoidCallback listener) {
    _externalListeners.remove(listener);
    _provider.removeListener(listener);
  }

  // ============ Error handling ============

  /// Handle uncaught exceptions, check if it's a Turnkey auth error. After session expiry TurnkeyProvider._init always fails, must recreate TurnkeyProvider
  ///
  /// If it's an auth error (code 7 or 16), clears session and redirects user to re-login
  /// Returns true if error was handled, false if not a Turnkey auth error
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

    // code 7 = Unauthenticated, code 16 = Unauthenticated (alternative case)
    if (error.code != 7 && error.code != 16) {
      return false;
    }
    return true;
  }

  // ============ Session management ============

  /// Clear all sessions
  Future<void> clearAllSessions() async {
    try {
      await _provider.clearAllSessions();
    } catch (e, stackTrace) {
      logger.e('TurnkeyManager: clearAllSessions failed',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // ============ OTP auth ============

  /// Initialize OTP
  Future<String> initOtp({
    required OtpType otpType,
    required String contact,
  }) async {
    await _provider.ensureInitialized();
    return await _provider.initOtp(otpType: otpType, contact: contact);
  }

  /// Login or signup with OTP
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

  // ============ OAuth auth ============
  
  /// Login with Google OAuth
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

  /// Login with Google native (custom impl, supports native Google Sign-In)
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

  // ============ Signing operations ============

  /// Sign message
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

  /// Sign transaction
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

  /// Refresh wallets
  Future<void> refreshWallets() async {
    try {
      await _provider.ensureInitialized();
      await _provider.refreshWallets();
    } catch (e, stackTrace) {
      handleTurnkeyError(e, stackTrace);
      rethrow;
    }
  }

  // ============ External wallet auth ============

  /// Login or signup with Turnkey using external Web3 wallet
  ///
  /// [wallet] Wallet instance implementing [WalletInterface]
  /// [sessionKey] Optional session storage key
  /// [expirationSeconds] Optional session expiration in seconds
  /// [invalidateExisting] Whether to invalidate existing session (login only)
  /// [createSubOrgParams] Sub-org creation params (signup only)
  ///
  /// Returns [LoginOrSignUpWithWalletResult] with session token and operation type
  Future<LoginOrSignUpWithWalletResult> loginOrSignUpWithWallet({
    required WalletInterface wallet,
    String? sessionKey,
    String? expirationSeconds,
    bool invalidateExisting = false,
    CreateSubOrgParams? createSubOrgParams,
  }) async {
    await _provider.ensureInitialized();
    try {
      // Use default sub-org params if not provided
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

  /// Login with external wallet only (user must already exist)
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

  /// Signup with external wallet only (create new user)
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

  // ============ Init and lifecycle ============

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
      },
    );
  }

  /// Handle session invalid (expired or cleared)
  Future<void> _handleSessionInvalid({bool reinitialize = false}) async {
    // 1. Clear session and reinitialize provider
    if (reinitialize) {
      await _reinitialize();
    }

    // Check if Turnkey user is logged in; if not, cleanup is done
    if (!injector.isRegistered<WalletSelector>()) return;
    if (!injector<WalletSelector>().isTurnkeyUser) return;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      bool needToJumpToWelcome = true;
      // 2. Stop sync service
      if (injector.isRegistered<TurnkeyWalletSyncService>()) {
        var turnkeyWalletSyncService = injector<TurnkeyWalletSyncService>();
        if (turnkeyWalletSyncService.isListening) {
          turnkeyWalletSyncService.stopListening();
        } else {
          // Sync service not listening means already on welcome page, skip
          needToJumpToWelcome = false;
        }
      }

      // 3. Clear server auth
      if (injector.isRegistered<WalletAuthManager>()) {
        var walletAuthManager = injector<WalletAuthManager>();
        await walletAuthManager.logoutAllWallets();
      }

      // 4. Clear user selection
      injector<WalletSelector>().clearSelectedUser();

      // 5. Navigate to welcome page
      if (needToJumpToWelcome) {
        Get.offAllNamed(Routes.welcome);
      }
    });
  }

  /// Initialize Provider
  void initialize() {
    if (_isInitialized) return;
    _isInitialized = true;
    try {
      _provider = TurnkeyProvider(config: _createTurnkeyConfig(), autoInit: false);
      _provider.ensureInitialized();
    } catch (e, stackTrace) {
      logger.e('TurnKeyProviderManager: initialize failed',
          error: e, stackTrace: stackTrace);
    }
  }

  /// Reinitialize provider (reset state after session invalid)
  Future<void> _reinitialize() async {
    // Save current listeners (before old provider is destroyed)
    final listenersToRestore = Set<VoidCallback>.from(_externalListeners);
    for (final listener in listenersToRestore) {
      _provider.removeListener(listener);
    }
    try {
      // Clear all sessions first
      await _provider.clearAllSessions();
    } catch (e, stackTrace) {
      logger.e('TurnkeyManager: clearAllSessions failed',
          error: e, stackTrace: stackTrace);
    }

    // Recreate provider to fully reset internal state
    _isInitialized = false;
    initialize();

    // Re-attach previous listeners to new provider
    for (final listener in listenersToRestore) {
      _provider.addListener(listener);
    }

    logger.d(
        'TurnkeyManager: reinitialize completed, restored ${listenersToRestore.length} listeners');
  }
}
