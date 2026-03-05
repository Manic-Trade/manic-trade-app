import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:finality/common/utils/shared_preferences_extensions.dart';
import 'package:rxdart/rxdart.dart' as rxdart;
import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  final SharedPreferences _preferences;

  AppPreferences(this._preferences);

  static const String _keyFiatCurrencyUnit = "fiatCurrencyUnit";
  static const String _keyLanguage = "language";
  static const String _keyTheme = "theme";
  static const String _keyAmountVisible = "app_amountVisible";
  static const String _keyInvitationCodeOfInviter =
      "invitation_code_of_inviter";
  static const String _keyFirstCreateWalletTimestamp =
      "first_create_wallet_timestamp";
  static const String _keyWakeLock = "wakeLock";
  static const String _keyHapticFeedback = "hapticFeedback";
  static const String _keyBasedOnMarketCap = "BasedOnMarketCap";
  static const String _keyRestoredCloudBackupWallet =
      "restored_cloud_backup_wallet";

  late final rxdart.BehaviorSubject<String> _fiatCurrencyUnitSubject =
      rxdart.BehaviorSubject.seeded(fiatCurrencyUnit);

  late final rxdart.BehaviorSubject<Locale?> _localeSubject =
      rxdart.BehaviorSubject.seeded(locale);

  late final rxdart.BehaviorSubject<ThemeMode> _themeModeSubject =
      rxdart.BehaviorSubject.seeded(themeMode);

  String get fiatCurrencyUnit =>
      _preferences.getString(_keyFiatCurrencyUnit) ?? "USD";

  set fiatCurrencyUnit(String value) {
    _preferences.setString(_keyFiatCurrencyUnit, value);
    _fiatCurrencyUnitSubject.add(value);
  }

  Stream<String> streamFiatCurrencyUnit() {
    return _fiatCurrencyUnitSubject.stream;
  }

  String? get _languageCode => _preferences.getString(_keyLanguage) ?? "en";

  set _languageCode(String? value) =>
      _preferences.saveString(_keyLanguage, value);

  int? get _themeModeInt => _preferences.getInt(_keyTheme);

  set _themeModeInt(int? value) => _preferences.saveInt(_keyTheme, value);

  Locale? get locale {
    var languageCode = _languageCode;
    if (languageCode != null && languageCode.isNotEmpty) {
      return Locale.fromSubtags(languageCode: languageCode);
    }
    return null;
  }

  set locale(Locale? locale) {
    _languageCode = locale?.languageCode;
    _localeSubject.add(locale);
  }

  Stream<Locale?> streamLocale() {
    return _localeSubject.stream;
  }

  ThemeMode get themeMode {
    var themeModeInt = _themeModeInt;
    if (themeModeInt != null) {
      return ThemeMode.values[themeModeInt];
    }
    return ThemeMode.dark;
  }

  set themeMode(ThemeMode themeMode) {
    _themeModeInt = themeMode.index;
    _themeModeSubject.add(themeMode);
  }

  Stream<ThemeMode> streamThemeMode() {
    return _themeModeSubject.stream;
  }

  late ValueListenable<bool> amountVisibleNotifier =
      ValueNotifier(amountVisible);

  bool get amountVisible {
    return _preferences.getBool(_keyAmountVisible) ?? true;
  }

  set amountVisible(bool amountVisible) {
    _preferences.setBool(_keyAmountVisible, amountVisible);
    (amountVisibleNotifier as ValueNotifier).value = amountVisible;
  }

  //邀请人的邀请码
  String? get invitationCodeOfInviter {
    return _preferences.getString(_keyInvitationCodeOfInviter);
  }

  set invitationCodeOfInviter(String? value) {
    if (value == null) {
      _preferences.remove(_keyInvitationCodeOfInviter);
    } else {
      _preferences.setString(_keyInvitationCodeOfInviter, value);
    }
  }

  //第一次创建新钱包的时间，包括助记词导入
  int? get firstCreateWalletTimestamp {
    return _preferences.getInt(_keyFirstCreateWalletTimestamp);
  }

  set firstCreateWalletTimestamp(int? value) {
    if (value == null) {
      _preferences.remove(_keyFirstCreateWalletTimestamp);
    } else {
      _preferences.setInt(_keyFirstCreateWalletTimestamp, value);
    }
  }

  //使用过云备份恢复钱包
  bool get restoredCloudBackupWallet {
    return _preferences.getBool(_keyRestoredCloudBackupWallet) ?? false;
  }

  void setRestoredCloudBackupWallet() {
    _preferences.setBool(_keyRestoredCloudBackupWallet, true);
  }

  late ValueListenable<bool> wakeLockEnabledNotifier =
      ValueNotifier(wakeLockEnabled);

  bool get wakeLockEnabled {
    return _preferences.getBool(_keyWakeLock) ?? false;
  }

  set wakeLockEnabled(bool value) {
    _preferences.setBool(_keyWakeLock, value);
    (wakeLockEnabledNotifier as ValueNotifier).value = value;
  }

  late ValueListenable<bool> hapticFeedbackEnabledNotifier =
      ValueNotifier(hapticFeedbackEnabled);

  bool get hapticFeedbackEnabled {
    return _preferences.getBool(_keyHapticFeedback) ?? true;
  }

  set hapticFeedbackEnabled(bool value) {
    _preferences.setBool(_keyHapticFeedback, value);
    (hapticFeedbackEnabledNotifier as ValueNotifier).value = value;
  }

  late ValueListenable<bool> basedOnMarketCapNotifier =
      ValueNotifier(basedOnMarketCap);

  bool get basedOnMarketCap {
    return _preferences.getBool(_keyBasedOnMarketCap) ?? false;
  }

  set basedOnMarketCap(bool value) {
    _preferences.setBool(_keyBasedOnMarketCap, value);
    (basedOnMarketCapNotifier as ValueNotifier).value = value;
  }
}
