import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:app_links/app_links.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:turnkey_sdk_flutter/turnkey_sdk_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

/// 原生端 Method Channel，与 Android MainActivity.kt 保持一致
const MethodChannel _nativeChannel = MethodChannel('trade.manic.app/methods');

/// 用户在外部浏览器流程中返回 app 但未完成 OAuth，调用方应当静默处理
class OAuthCanceledException implements Exception {
  final String message;
  const OAuthCanceledException([this.message = 'OAuth canceled by user']);
  @override
  String toString() => message;
}

/// Android 上走外部浏览器（url_launcher + app_links）的 Turnkey OAuth 流程
///
/// 相比 WebView 版本：
/// - 和系统浏览器共享 Cookie，已登录的 Apple/X 账号可一键确认
/// - Apple 不会把这里识别为嵌入式 WebView 拒登
/// - 需要依赖自定义 scheme deep link 把 app 拉回来
///
/// 流程与 SDK [OAuthExtension] 完全一致，仅把 `ChromeSafariBrowser.open` 换成
/// `url_launcher.launchUrl(mode: externalApplication)`，并用 `app_links` 监听
/// 回跳 URL。
extension TurnkeyExternalBrowserOAuthExtension on TurnkeyProvider {
  /// Apple OAuth（外部浏览器版）
  Future<void> handleAppleOAuthViaExternalBrowser({
    String? clientId,
    String? redirectUri,
    String? sessionKey,
    bool? invalidateExisting,
    String? publicKey,
    Duration timeout = const Duration(minutes: 5),
    void Function({
      required String oidcToken,
      required String publicKey,
      required String providerName,
    })? onSuccess,
  }) async {
    final scheme = runtimeConfig?.appScheme;
    const providerName = 'apple';
    if (scheme == null) {
      throw Exception(
          'App scheme is not configured. Please set `appScheme` in TurnkeyConfig.');
    }

    final targetPublicKey = publicKey ?? await createApiKeyPair();
    try {
      final nonce = sha256.convert(utf8.encode(targetPublicKey)).toString();
      final appleClientId = clientId ??
          runtimeConfig?.authConfig.oAuthConfig?.appleClientId ??
          (throw Exception('Apple Client ID not configured'));
      final resolvedRedirectUri = redirectUri ??
          runtimeConfig?.authConfig.oAuthConfig?.oauthRedirectUri ??
          '$TURNKEY_OAUTH_REDIRECT_URL?scheme=${Uri.encodeComponent(scheme)}';

      final oauthUrl = '$TURNKEY_OAUTH_ORIGIN_URL'
          '?provider=${Uri.encodeComponent(providerName)}'
          '&clientId=${Uri.encodeComponent(appleClientId)}'
          '&redirectUri=${Uri.encodeComponent(resolvedRedirectUri)}'
          '&nonce=${Uri.encodeComponent(nonce)}';

      final params = await _launchAndWaitForDeepLink(
        url: oauthUrl,
        scheme: scheme,
        timeout: timeout,
      );
      final idToken = params['id_token'];
      if (idToken == null || idToken.isEmpty) {
        throw Exception('No id_token returned from Apple OAuth');
      }

      if (onSuccess != null) {
        onSuccess(
            oidcToken: idToken,
            publicKey: targetPublicKey,
            providerName: providerName);
      } else {
        await loginOrSignUpWithOAuth(
          oidcToken: idToken,
          publicKey: targetPublicKey,
          providerName: providerName,
          sessionKey: sessionKey,
          invalidateExisting: invalidateExisting,
        );
      }
    } catch (error) {
      await deleteUnusedKeyPairs();
      if (error is OAuthCanceledException) rethrow;
      throw Exception('Failed to login or signup with Apple: $error');
    }
  }

  /// X (Twitter) OAuth Link（外部浏览器版）
  ///
  /// 与 [handleXOAuthViaExternalBrowser] 的差别：
  /// - 不创建新 session，把 X identity 挂到当前已登录的 Turnkey user 上
  /// - nonce 使用当前 session 的 publicKey（SDK 默认 link 流程行为）
  /// - 拿到 oidcToken 后调用 [linkOauthProvider]（而不是 loginOrSignUpWithOAuth）
  Future<void> handleXOAuthLinkViaExternalBrowser({
    String? clientId,
    String? redirectUri,
    Duration timeout = const Duration(minutes: 5),
    void Function({
      required String oidcToken,
      required String providerName,
    })? onSuccess,
  }) async {
    final activeSession = session;
    if (activeSession == null) {
      throw StateError(
          'No active session. A user must be authenticated to link an OAuth provider.');
    }
    final scheme = runtimeConfig?.appScheme;
    const providerName = 'x';
    if (scheme == null) {
      throw Exception(
          'App scheme is not configured. Please set `appScheme` in TurnkeyConfig.');
    }

    try {
      final nonce =
          sha256.convert(utf8.encode(activeSession.publicKey)).toString();
      final xClientId = clientId ??
          runtimeConfig?.authConfig.oAuthConfig?.xClientId ??
          (throw Exception('X Client ID not configured'));
      final resolvedRedirectUri = redirectUri ??
          runtimeConfig?.authConfig.oAuthConfig?.oauthRedirectUri ??
          '$scheme://';

      final challengePair = await generateChallengePair();
      final verifier = challengePair.verifier;
      final codeChallenge = challengePair.codeChallenge;
      final state = const Uuid().v4();

      final xAuthUrl = '$X_AUTH_URL'
          '?client_id=${Uri.encodeComponent(xClientId)}'
          '&redirect_uri=${Uri.encodeComponent(resolvedRedirectUri)}'
          '&response_type=code'
          '&code_challenge=${Uri.encodeComponent(codeChallenge)}'
          '&code_challenge_method=S256'
          '&scope=${Uri.encodeComponent("tweet.read users.read")}'
          '&state=${Uri.encodeComponent(state)}';

      final params = await _launchAndWaitForDeepLink(
        url: xAuthUrl,
        scheme: scheme,
        timeout: timeout,
      );

      final authCode = params['code'];
      final returnedState = params['state'];
      if (returnedState != state) {
        throw Exception('Invalid state parameter received');
      }
      if (authCode == null || authCode.isEmpty) {
        throw Exception('No auth code returned from X OAuth');
      }

      final res = await requireClient.proxyOAuth2Authenticate(
        input: ProxyTOAuth2AuthenticateBody(
          provider: v1Oauth2Provider.oauth2_provider_x,
          authCode: authCode,
          redirectUri: resolvedRedirectUri,
          codeVerifier: verifier,
          clientId: xClientId,
          nonce: nonce,
        ),
      );
      final oidcToken = res.oidcToken;

      if (onSuccess != null) {
        onSuccess(oidcToken: oidcToken, providerName: providerName);
      } else {
        await linkOauthProvider(
          providerName: providerName,
          oidcToken: oidcToken,
        );
      }
    } catch (error) {
      if (error is OAuthCanceledException) rethrow;
      throw Exception('Failed to link X OAuth provider: $error');
    }
  }

  /// X (Twitter) OAuth（外部浏览器版）
  Future<void> handleXOAuthViaExternalBrowser({
    String? clientId,
    String? redirectUri,
    String? sessionKey,
    bool? invalidateExisting,
    String? publicKey,
    Duration timeout = const Duration(minutes: 5),
    void Function({
      required String oidcToken,
      required String publicKey,
      required String providerName,
    })? onSuccess,
  }) async {
    final scheme = runtimeConfig?.appScheme;
    const providerName = 'x';
    if (scheme == null) {
      throw Exception(
          'App scheme is not configured. Please set `appScheme` in TurnkeyConfig.');
    }

    final targetPublicKey = publicKey ?? await createApiKeyPair();
    try {
      final nonce = sha256.convert(utf8.encode(targetPublicKey)).toString();
      final xClientId = clientId ??
          runtimeConfig?.authConfig.oAuthConfig?.xClientId ??
          (throw Exception('X Client ID not configured'));
      final resolvedRedirectUri = redirectUri ??
          runtimeConfig?.authConfig.oAuthConfig?.oauthRedirectUri ??
          '$scheme://';

      final challengePair = await generateChallengePair();
      final verifier = challengePair.verifier;
      final codeChallenge = challengePair.codeChallenge;
      final state = const Uuid().v4();

      final xAuthUrl = '$X_AUTH_URL'
          '?client_id=${Uri.encodeComponent(xClientId)}'
          '&redirect_uri=${Uri.encodeComponent(resolvedRedirectUri)}'
          '&response_type=code'
          '&code_challenge=${Uri.encodeComponent(codeChallenge)}'
          '&code_challenge_method=S256'
          '&scope=${Uri.encodeComponent("tweet.read users.read")}'
          '&state=${Uri.encodeComponent(state)}';

      final params = await _launchAndWaitForDeepLink(
        url: xAuthUrl,
        scheme: scheme,
        timeout: timeout,
      );

      final authCode = params['code'];
      final returnedState = params['state'];
      if (returnedState != state) {
        throw Exception('Invalid state parameter received');
      }
      if (authCode == null || authCode.isEmpty) {
        throw Exception('No auth code returned from X OAuth');
      }

      final res = await requireClient.proxyOAuth2Authenticate(
        input: ProxyTOAuth2AuthenticateBody(
          provider: v1Oauth2Provider.oauth2_provider_x,
          authCode: authCode,
          redirectUri: resolvedRedirectUri,
          codeVerifier: verifier,
          clientId: xClientId,
          nonce: nonce,
        ),
      );
      final oidcToken = res.oidcToken;

      if (onSuccess != null) {
        onSuccess(
            oidcToken: oidcToken,
            publicKey: targetPublicKey,
            providerName: providerName);
      } else {
        await loginOrSignUpWithOAuth(
          oidcToken: oidcToken,
          publicKey: targetPublicKey,
          providerName: providerName,
          sessionKey: sessionKey,
          invalidateExisting: invalidateExisting,
        );
      }
    } catch (error) {
      await deleteUnusedKeyPairs();
      if (error is OAuthCanceledException) rethrow;
      throw Exception('Failed to login or signup with X: $error');
    }
  }
}

/// 启动外部浏览器打开 [url]，并监听 `app_links` 等待回跳到 [scheme] 的 deep link。
///
/// 只要 deep link 命中，就返回其 query 参数。超时或浏览器无法启动则抛异常。
Future<Map<String, String>> _launchAndWaitForDeepLink({
  required String url,
  required String scheme,
  required Duration timeout,
}) async {
  final appLinks = AppLinks();
  final completer = Completer<Map<String, String>>();
  late final StreamSubscription<Uri> subscription;
  subscription = appLinks.uriLinkStream.listen((uri) {
    if (uri.toString().startsWith('$scheme:')) {
      if (!completer.isCompleted) {
        completer.complete(Map<String, String>.from(uri.queryParameters));
      }
    }
  }, onError: (e) {
    if (!completer.isCompleted) completer.completeError(e);
  });

  // 监听 app 生命周期：用户离开 app（去浏览器）再回到 app 而没完成 OAuth，
  // 视为取消；不然调用方的 loading 要等到 timeout 才结束。
  // 给回来后一段 grace period 留给 deep link 先触发 complete。
  bool leftApp = false;
  final lifecycleListener = AppLifecycleListener(
    onStateChange: (state) {
      if (state == AppLifecycleState.hidden ||
          state == AppLifecycleState.inactive ||
          state == AppLifecycleState.paused) {
        leftApp = true;
      } else if (state == AppLifecycleState.resumed && leftApp) {
        Future.delayed(const Duration(milliseconds: 800), () {
          if (!completer.isCompleted) {
            completer.completeError(const OAuthCanceledException());
          }
        });
      }
    },
  );

  try {
    final ok = await _launchInBrowser(url);
    if (!ok) {
      throw Exception('Failed to launch external browser');
    }
    return await completer.future.timeout(
      timeout,
      onTimeout: () => throw Exception('OAuth authentication timed out'),
    );
  } finally {
    await subscription.cancel();
    lifecycleListener.dispose();
  }
}

/// 尽量在**浏览器**里打开 URL，避免被 X / YouTube 等 App Link 拦截。
///
/// Android：走 MainActivity.kt 的 `launchUrlInBrowser` 原生方法，显式
/// `setPackage(<browser>)` 绕过 App Link 解析。若原生方法失败则回退到 url_launcher。
/// 其他平台：直接 url_launcher。
Future<bool> _launchInBrowser(String url) async {
  if (Platform.isAndroid) {
    try {
      final ok = await _nativeChannel
          .invokeMethod<bool>('launchUrlInBrowser', {'url': url});
      if (ok == true) return true;
    } on PlatformException {
      // fallthrough 到 url_launcher
    }
  }
  return launchUrl(
    Uri.parse(url),
    mode: LaunchMode.externalApplication,
  );
}
