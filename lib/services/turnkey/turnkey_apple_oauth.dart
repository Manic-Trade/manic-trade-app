import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:finality/env/app_secrets.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:turnkey_sdk_flutter/turnkey_sdk_flutter.dart';

extension AppleOAuthExtension on TurnkeyProvider {
  /// iOS 原生 Apple 登录
  ///
  /// ⚠️ 已弃用，不要再接入！
  /// 原因：iOS 原生 ASAuthorizationAppleIDProvider 返回的 identityToken
  /// `aud` 永远是 App Bundle ID（trade.manic），而 Android/Web 走 Turnkey
  /// 浏览器 OAuth 用的是 Services ID（trade.manic.web）。即使 Apple grouping
  /// 生效、两端 `sub` 相同，Turnkey 后端按 (iss, aud, sub) 识别 OIDC 身份，
  /// 会把同一个 Apple 账号拆成两个 sub-org / 两套钱包。
  /// 统一使用 [TurnkeyManager.handleAppleOAuth]（浏览器流）替代。
  ///
  /// 流程：
  /// 1. 生成/使用 targetPublicKey
  /// 2. 传入 sha256(targetPublicKey) 作为 Apple 的 nonce
  ///    （Apple 不会自己 hash，JWT 里的 nonce claim 就等于我们传入的值）
  ///    这样 JWT nonce claim = sha256(publicKey)，与 Turnkey 校验规则一致
  /// 3. 使用 identityToken 走 Turnkey loginOrSignUpWithOAuth
  @Deprecated('iOS 原生流 aud=Bundle ID 会与 web 流 aud=Services ID 冲突，'
      '导致同一 Apple 账号被 Turnkey 拆成两个 sub-org。改用 handleAppleOAuth。')
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
    final providerName = 'apple';

    final targetPublicKey = publicKey ?? await createApiKeyPair();
    // Apple 不会自己 hash nonce，JWT nonce claim 直接等于我们传入的值，
    // Turnkey 期望 nonce == sha256(publicKey)，所以这里手动算 sha256
    final hashedNonce = sha256.convert(utf8.encode(targetPublicKey)).toString();

    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
        webAuthenticationOptions: WebAuthenticationOptions(
          clientId: AppSecrets.appleClientId, // trade.manic.web
          redirectUri: Uri.parse(
              'https://oauth-redirect.turnkey.com?scheme=manic-trade-app'),
        ),
      );

      final idToken = credential.identityToken;
      if (idToken == null) {
        throw Exception('Failed to obtain identity token from Apple');
      }

      // Apple 只在首次授权时返回 email / fullName
      final email = credential.email;
      final fullName = [
        credential.givenName,
        credential.familyName,
      ].where((e) => e != null && e.isNotEmpty).join(' ');

      if (onSuccess != null) {
        onSuccess(
          oidcToken: idToken,
          publicKey: targetPublicKey,
          providerName: providerName,
          email: email,
          fullName: fullName.isEmpty ? null : fullName,
        );
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
      rethrow;
    }
  }
}
