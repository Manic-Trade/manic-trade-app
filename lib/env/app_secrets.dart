/// 敏感配置项，通过 `--dart-define-from-file=.env.json` 注入
///
/// 所有值在编译时注入，不会以明文形式存在于 app bundle 中。
/// 开发者需要复制 `.env.json.example` 为 `.env.json` 并填入实际值。
class AppSecrets {
  AppSecrets._();

  /// Turnkey Organization ID
  static const String turnkeyOrganizationId =
      String.fromEnvironment('TURNKEY_ORGANIZATION_ID');

  /// Turnkey Auth Proxy Config ID
  static const String turnkeyAuthProxyConfigId =
      String.fromEnvironment('TURNKEY_AUTH_PROXY_CONFIG_ID');

  /// Google OAuth Web Client ID（用于 Turnkey OAuth 登录）
  static const String googleClientId =
      String.fromEnvironment('GOOGLE_CLIENT_ID');
}
