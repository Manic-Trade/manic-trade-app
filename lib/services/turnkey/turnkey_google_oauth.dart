import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:turnkey_sdk_flutter/turnkey_sdk_flutter.dart';

extension GoogleOAuthExtension on TurnkeyProvider {
  // Must wait for this method to complete before other operations, otherwise errors may occur or navigation to home may happen
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

    // 1. Generate or use the provided public key
    final targetPublicKey = publicKey ?? await createApiKeyPair();

    // 2. Calculate nonce (consistent with current implementation)
    final nonce = sha256.convert(utf8.encode(targetPublicKey)).toString();

    // 3. Get Google Client ID
    final googleClientId = clientId ??
        runtimeConfig?.authConfig.oAuthConfig?.googleClientId ??
        (throw Exception("Google Client ID not configured"));

    try {
      // 4. Initialize GoogleSignIn (7.x API)
      await GoogleSignIn.instance.initialize(
        serverClientId: googleClientId,
        nonce: nonce, // Critical: pass custom nonce
      );

      // 5. Perform native login
      final account = await GoogleSignIn.instance.authenticate(
        scopeHint: ['email', 'openid'],
      );

      // 6. Get idToken
      final authentication = account.authentication;
      final idToken = authentication.idToken;

      if (idToken == null) {
        throw Exception('Failed to obtain ID token from Google');
      }

      // 7. Call callback or login/signup
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
