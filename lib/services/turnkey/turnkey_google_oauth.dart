import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:turnkey_sdk_flutter/turnkey_sdk_flutter.dart';

extension GoogleOAuthExtension on TurnkeyProvider {
  //必须等这个方法执行完成才能执行其他操作，否则有时会报错也跳首页了
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
    final providerName = 'google';

    // 1. 生成或使用提供的公钥
    final targetPublicKey = publicKey ?? await createApiKeyPair();

    // 2. 计算 nonce (与当前实现一致)
    final nonce = sha256.convert(utf8.encode(targetPublicKey)).toString();

    // 3. 获取 Google Client ID
    final googleClientId = clientId ??
        runtimeConfig?.authConfig.oAuthConfig?.googleClientId ??
        (throw Exception("Google Client ID not configured"));

    try {
      // 4. 初始化 GoogleSignIn (7.x API)
      await GoogleSignIn.instance.initialize(
        serverClientId: googleClientId,
        nonce: nonce, // 关键：传入自定义 nonce
      );

      // 5. 执行原生登录
      final account = await GoogleSignIn.instance.authenticate(
        scopeHint: ['email', 'openid'],
      );

      // 6. 获取 idToken
      final authentication = account.authentication;
      final idToken = authentication.idToken;

      if (idToken == null) {
        throw Exception('Failed to obtain ID token from Google');
      }

      // 7. 调用回调或登录/注册
      if (onSuccess != null) {
        onSuccess(
          oidcToken: idToken,
          publicKey: targetPublicKey,
          providerName: providerName,
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
