import 'package:finality/domain/wallet/user_selector.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 当前登录用户作用域下的本地 KV 存储。
///
/// 所有读写都会自动以 `UserSelector.selectedUserId` 作为 key 前缀，
/// 没有当前用户时读返回 null、写静默忽略。登出时 `UserSelector.clearSelectedUser()`
/// 被调用后，当前用户视角下的数据天然不可见，不需要显式清理。
///
/// 用途：存放和"当前用户"绑定的偏好/缓存字段（如登录时的外部钱包地址、
/// X @handle 缓存等）。不适合放跨用户共享的设置（那些应该继续放 `AppPreferences`）。
class UserProfileStore {
  UserProfileStore(this._prefs, this._userSelector);

  final SharedPreferences _prefs;
  final UserSelector _userSelector;

  static const String _keyPrefix = 'userProfile';
  static const String _keyLoginWalletAddress = 'loginWalletAddress';
  static const String _keyTwitterName = 'twitterName';

  /// Web3 登录时用来签名的外部钱包地址（Phantom / MetaMask 等）。
  /// OAuth / Email 登录用户该字段为 null。用于 UID 展示。
  String? get loginWalletAddress => _readString(_keyLoginWalletAddress);
  set loginWalletAddress(String? value) =>
      _writeString(_keyLoginWalletAddress, value);

  /// 后端返回的 X @handle 缓存，用于页面首帧立即展示，不用等网络请求。
  String? get twitterName => _readString(_keyTwitterName);
  set twitterName(String? value) => _writeString(_keyTwitterName, value);

  String? _readString(String key) {
    final namespaced = _namespacedKey(key);
    if (namespaced == null) return null;
    return _prefs.getString(namespaced);
  }

  void _writeString(String key, String? value) {
    final namespaced = _namespacedKey(key);
    if (namespaced == null) return;
    if (value == null) {
      _prefs.remove(namespaced);
    } else {
      _prefs.setString(namespaced, value);
    }
  }

  String? _namespacedKey(String key) {
    final userId = _userSelector.selectedUserId;
    if (userId == null || userId.isEmpty) return null;
    return '$_keyPrefix.$userId.$key';
  }
}
