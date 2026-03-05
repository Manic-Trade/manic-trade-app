/// Sensitive configuration values injected via `--dart-define-from-file=.env.json`.
///
/// All values are injected at compile time and will not exist in plaintext in the app bundle.
/// Developers need to copy `.env.json.example` to `.env.json` and fill in actual values.
class AppSecrets {
  AppSecrets._();

  /// Turnkey Organization ID
  static const String turnkeyOrganizationId =
      String.fromEnvironment('TURNKEY_ORGANIZATION_ID');

  /// Turnkey Auth Proxy Config ID
  static const String turnkeyAuthProxyConfigId =
      String.fromEnvironment('TURNKEY_AUTH_PROXY_CONFIG_ID');

  /// Google OAuth Web Client ID (used for Turnkey OAuth login)
  static const String googleClientId =
      String.fromEnvironment('GOOGLE_CLIENT_ID');
}
