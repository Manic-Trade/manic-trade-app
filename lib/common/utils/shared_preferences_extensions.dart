import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

extension PreferencesExtensions on SharedPreferences {
  Future<bool> saveString(String key, String? value) {
    if (value != null) {
      return setString(key, value);
    } else {
      return remove(key);
    }
  }

  Future<bool> saveInt(String key, int? value) {
    if (value != null) {
      return setInt(key, value);
    } else {
      return remove(key);
    }
  }

  Future<void> saveMap(
    String key,
    Map<String, dynamic> map,
  ) async {
    final String jsonString = jsonEncode(map);
    await setString(key, jsonString);
  }

  Future<Map<String, dynamic>> getMap(String key) async {
    final String? jsonString = getString(key);
    if (jsonString != null) {
      return jsonDecode(jsonString);
    } else {
      return {};
    }
  }
}
