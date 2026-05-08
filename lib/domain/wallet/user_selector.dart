import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserSelector {
  static const String _keySelectedUserId = "userSelector.selectedUserId";

  final SharedPreferences _prefs;

  late final BehaviorSubject<String?> _userIdSubject =
      BehaviorSubject.seeded(selectedUserId);

  UserSelector(this._prefs);

  String? get selectedUserId => _prefs.getString(_keySelectedUserId);

  void _setUserId(String? userId) {
    if (userId == selectedUserId) {
      if (_userIdSubject.value != userId) {
        _userIdSubject.add(userId);
      }
      return;
    }
    if (userId == null) {
      _prefs.remove(_keySelectedUserId).ignore();
    } else {
      _prefs.setString(_keySelectedUserId, userId).ignore();
    }
    if (_userIdSubject.value != userId) {
      _userIdSubject.add(userId);
    }
  }

  void setTurnkeyUserId(String userId) {
    _setUserId(userId);
  }

  void clearSelectedUser() {
    _setUserId(null);
  }

  bool isTurnkeyUser() {
    return selectedUserId != null;
  }

  Stream<String?> streamSelectedUserId() {
    return _userIdSubject.stream;
  }
}
