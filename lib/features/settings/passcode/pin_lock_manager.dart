import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:finality/common/utils/secure_crypto_utils.dart';
import 'package:finality/common/utils/shared_preferences_extensions.dart';
import 'package:finality/core/logger.dart';
import 'package:finality/features/settings/passcode/app_lock_wrong_level.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class PinLockManager {
  final SharedPreferences _preferences;

  PinLockManager(this._preferences);

  static const String _keyPinCode = "pin_code";
  static const String _keyPinEncryptedData = "pin_lock_encrypted_data";
  static const String _keyPinDecryptedData = "pin_lock_decrypted_data";
  static const String _keyPinWrongNumber = "pin_lock_wrong_number";
  static const String _keyPinLastWrongTime = "pin_lock_lastWrongTime";

  static const int _maxWrongNumber = 5;

  String? get _pinCode => _preferences.getString(_keyPinCode);

  set _pinCode(String? value) => _preferences.saveString(_keyPinCode, value);

  String? get _encryptedData => _preferences.getString(_keyPinEncryptedData);

  Future<bool> _setEncryptedData(String? value) async {
    var bool = await _preferences.saveString(_keyPinEncryptedData, value);
    if (bool) {
      (isSetPinNotifier as ValueNotifier).value = value != null;
    }
    return bool;
  }

  String get _decryptedData {
    var string = _preferences.getString(_keyPinDecryptedData);
    if (string == null) {
      var uuid = const Uuid().v4();
      _preferences.saveString(_keyPinDecryptedData, uuid);
      string = uuid;
    }
    return string;
  }

  set _decryptedData(String? value) =>
      _preferences.saveString(_keyPinDecryptedData, value);

  int? get _lastAllWrongTime => _preferences.getInt(_keyPinLastWrongTime);

  set _lastAllWrongTime(int? value) =>
      _preferences.saveInt(_keyPinLastWrongTime, value);

  int get _wrongNumber => _preferences.getInt(_keyPinWrongNumber) ?? 0;

  set _wrongNumber(int? value) {
    _lastAllWrongTime = DateTime.now().millisecondsSinceEpoch;
    _preferences.saveInt(_keyPinWrongNumber, value);
  }

  AppLockWrongLevel get wrongLevel {
    var values = AppLockWrongLevel.values;
    var levelIndex = (_wrongNumber) ~/ _maxWrongNumber;
    if (levelIndex > values.length) {
      return values.last;
    } else {
      return values[levelIndex];
    }
  }

  bool get isSetPin => _encryptedData != null;

  late ValueListenable<bool> isSetPinNotifier = ValueNotifier(isSetPin);

  int get wrongRemainNumber => _maxWrongNumber - _wrongNumber;

  bool get needShowWrongRemainNumber => _wrongNumber != 0;

  bool get canVerification {
    var time = _lastAllWrongTime;
    if (time == null) {
      return true;
    } else {
      var currentTimeMillis = DateTime.now().millisecondsSinceEpoch;
      return currentTimeMillis - time > wrongLevel.timeInterval;
    }
  }

  void resetWrongLevel() {
    _wrongNumber = 0;
    _lastAllWrongTime = null;
  }

  void resetLock() {
    _wrongNumber = 0;
    _lastAllWrongTime = null;
    _decryptedData = null;
    _setEncryptedData(null);
    _pinCode = null;
  }

  Future<bool> setPinCode(String pinCode) async {
    try {
      final encryptedBytes = SecureCryptoUtils.encrypt(
        pinCode,
        utf8.encode(_decryptedData),
      );
      return _setEncryptedData(base64.encode(encryptedBytes));
    } catch (error) {
      logger.e("setPinCode", error: error);
      return false;
    }
  }

  Future<bool> verification(String pinCode) async {
    var localEncryptedData = _encryptedData;
    if (localEncryptedData == null) {
      resetWrongLevel();
      return true;
    }
    try {
      final encryptedBytes = base64.decode(localEncryptedData);
      final decryptedBytes = SecureCryptoUtils.decrypt(
        pinCode,
        encryptedBytes,
      );
      final decryptedString = utf8.decode(decryptedBytes);

      if (_decryptedData == decryptedString) {
        resetWrongLevel();
        return true;
      } else {
        _wrongNumber++;
        return false;
      }
    } catch (error) {
      logger.e("verification", error: error);
      _wrongNumber++;
      return false;
    }
  }
}
