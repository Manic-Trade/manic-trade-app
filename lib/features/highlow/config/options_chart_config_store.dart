import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'options_chart_config.dart';

/// Options 图表配置存储
///
/// 负责 [OptionsChartConfig] 的持久化存储和状态管理。
/// 使用 JSON 序列化存储配置，提供 [ValueNotifier] 用于监听配置变化。
class OptionsChartConfigStore {
  final SharedPreferencesWithCache _prefs;

  /// 存储 key，使用 v1 后缀便于后续版本迁移
  static const String _key = "options_chart_config_v2";

  OptionsChartConfigStore(this._prefs);

  /// 配置变化通知器，UI 层可以监听此 Notifier 来响应配置变化
  late final ValueNotifier<OptionsChartConfig> configNotifier =
      ValueNotifier(_loadConfig());

  /// 获取当前配置
  OptionsChartConfig get config => configNotifier.value;

  /// 从 SharedPreferences 加载配置
  OptionsChartConfig _loadConfig() {
    final jsonStr = _prefs.getString(_key);
    if (jsonStr != null) {
      try {
        return OptionsChartConfig.fromJson(jsonDecode(jsonStr));
      } catch (e) {
        debugPrint('OptionsChartConfigStore: Failed to parse config: $e');
      }
    }
    return const OptionsChartConfig();
  }

  /// 更新配置
  ///
  /// 同时更新内存中的 [configNotifier] 和持久化存储
  Future<void> updateConfig(OptionsChartConfig config) async {
    configNotifier.value = config;
    await _prefs.setString(_key, jsonEncode(config.toJson()));
  }

  /// 便捷方法：使用 copyWith 更新配置
  ///
  /// 示例:
  /// ```dart
  /// await configStore.update((c) => c.copyWith(showGrid: false));
  /// ```
  Future<void> update(
    OptionsChartConfig Function(OptionsChartConfig) updater,
  ) async {
    await updateConfig(updater(config));
  }

  /// 重置为默认配置
  Future<void> reset() async {
    await updateConfig(const OptionsChartConfig());
  }
}
