import 'dart:io';

import 'package:finality/data/app_preferences.dart';
import 'package:finality/di/injector.dart';
import 'package:flutter/services.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:finality/core/logger.dart';

class HapticFeedbackUtils {
  /// 提供跨平台的震动反馈功能
  ///
  /// [type] - iOS平台下的震动类型，Android平台不使用此参数
  /// [amplitude] - Android平台下的震动强度 (1-255)，默认值25
  /// [duration] - Android平台下的震动持续时间(毫秒)，默认值50ms
  ///
  /// iOS平台使用 Haptics 提供的系统震动反馈
  /// Android平台使用 Vibration 包提供的自定义震动反馈
  static Future<void> vibrate(HapticsType type) async {
    if (!isEnabled) return;
    try {
      final isIOS = Platform.isIOS;
      if (isIOS) {
        final canVibrate = await Haptics.canVibrate();
        if (canVibrate) {
          await Haptics.vibrate(type);
        }
      } else {
        switch (type) {
          case HapticsType.medium:
            await HapticFeedback.mediumImpact();
            break;
          case HapticsType.heavy:
            await HapticFeedback.heavyImpact();
            break;
          case HapticsType.success:
            await HapticFeedback.heavyImpact();
            break;
          case HapticsType.warning:
            await HapticFeedback.heavyImpact();
            break;
          case HapticsType.error:
            await HapticFeedback.heavyImpact();
            break;
          case HapticsType.selection:
            await HapticFeedback.selectionClick();
            break;
          default:
            await HapticFeedback.lightImpact();
            break;
        }
      }
    } catch (e) {
      logger.e(e);
    }
  }

  static Future<void> willRefresh() async {
    if (!isEnabled) return;
    try {
      final isIOS = Platform.isIOS;
      if (isIOS) {
        final canVibrate = await Haptics.canVibrate();
        if (canVibrate) {
          await Haptics.vibrate(HapticsType.soft);
        }
      } else {
        await HapticFeedback.mediumImpact();
      }
    } catch (e) {
      logger.e(e);
    }
  }

  static bool get isEnabled => injector<AppPreferences>().hapticFeedbackEnabled;

  static Future<void> vibrate2() async {
    if (!isEnabled) return;
    return await HapticFeedback.vibrate();
  }

  static Future<void> lightImpact() async {
    if (!isEnabled) return;
    return await HapticFeedback.lightImpact();
  }

  static Future<void> mediumImpact() async {
    if (!isEnabled) return;
    return await HapticFeedback.mediumImpact();
  }

  static Future<void> heavyImpact() async {
    if (!isEnabled) return;
    return await HapticFeedback.heavyImpact();
  }

  static Future<void> selectionClick() async {
    if (!isEnabled) return;
    return await HapticFeedback.selectionClick();
  }

  static Future<void> vibration(HapticsType type) async {
    if (!isEnabled) return;
    try {
      final canVibrate = await Haptics.canVibrate();
      if (canVibrate) {
        await Haptics.vibrate(type);
      }
    } catch (e) {
      logger.e(e);
    }
  }
}
