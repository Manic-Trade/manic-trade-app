import 'package:shared_preferences/shared_preferences.dart';

class WalletAuthStore {
  final SharedPreferencesWithCache _prefs;
  WalletAuthStore(this._prefs);

  // 访问令牌的 key 前缀
  static const String _accessTokenPrefix = 'siwe_access_token_';

  Future<bool> hasCredentials(String walletId) async {
    final token = await getAccessToken(walletId);
    return token != null && token.isNotEmpty;
  }

  Future<String?> getAccessToken(String walletId) async {
    final key = _accessTokenPrefix + walletId;
    return _prefs.getString(key);
  }

  Future<void> saveCredentials(String walletId, String accessToken) async {
    final tokenKey = _accessTokenPrefix + walletId;
    await _prefs.setString(tokenKey, accessToken);
  }

  Future<void> removeCredentials(String walletId) async {
    final tokenKey = _accessTokenPrefix + walletId;
    await _prefs.remove(tokenKey);
  }

  Future<void> removeAllCredentials() async {
    await _prefs.clear();
  }
}
