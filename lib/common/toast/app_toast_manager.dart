import 'dart:ui';

import 'package:finality/common/toast/app_toast_data.dart';
import 'package:finality/common/toast/app_toast_theme.dart';

abstract class AppToastPresenter {
  void show(AppToastData data);
}

class AppToastManager {
  static AppToastPresenter? _presenter;
  static AppToastTheme _theme = AppToastTheme.defaultTheme;

  AppToastManager._();

  static void registerPresenter(AppToastPresenter presenter) {
    _presenter = presenter;
  }

  static void setTheme(AppToastTheme theme) {
    _theme = theme;
  }

  static void _show(AppToastData data) {
    assert(_presenter != null, 'Must call registerPresenter first');
    _presenter?.show(data);
  }

  // -- Convenience methods --

  static void showSuccess({
    required String title,
    String? subtitle,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onTap,
  }) {
    _show(AppToastData(
      type: AppToastType.success,
      colorConfig: _theme.success,
      title: title,
      subtitle: subtitle,
      duration: duration,
      onTap: onTap,
    ));
  }

  static void showFailed({
    required String title,
    String? subtitle,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onTap,
  }) {
    _show(AppToastData(
      type: AppToastType.failed,
      colorConfig: _theme.failed,
      title: title,
      subtitle: subtitle,
      duration: duration,
      onTap: onTap,
    ));
  }

  static void showGameWon({
    required String title,
    String? subtitle,
    required String payout,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onTap,
  }) {
    _show(AppToastData(
      type: AppToastType.gameWon,
      colorConfig: _theme.gameWon,
      title: title,
      subtitle: subtitle,
      trailingText: payout,
      duration: duration,
      onTap: onTap,
    ));
  }

  static void showGameLost({
    required String title,
    String? subtitle,
    required String payout,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onTap,
  }) {
    _show(AppToastData(
      type: AppToastType.gameLost,
      colorConfig: _theme.gameLost,
      title: title,
      subtitle: subtitle,
      trailingText: payout,
      duration: duration,
      onTap: onTap,
    ));
  }

  static void showDate({
    required String title,
    String? subtitle,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onTap,
  }) {
    _show(AppToastData(
      type: AppToastType.date,
      colorConfig: _theme.date,
      title: title,
      subtitle: subtitle,
      duration: duration,
      onTap: onTap,
    ));
  }

  static void showGift({
    required String title,
    String? subtitle,
    String? payout,
    String? payoutLabel,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onTap,
  }) {
    _show(AppToastData(
      type: AppToastType.gift,
      colorConfig: _theme.gift,
      title: title,
      subtitle: subtitle,
      trailingText: payout,
      trailingLabel: payoutLabel,
      duration: duration,
      onTap: onTap,
    ));
  }

  static void showCustom({
    required AppToastColorConfig colorConfig,
    required String title,
    String? subtitle,
    String? trailingText,
    Color? trailingTextColor,
    String? trailingLabel,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onDismiss,
    VoidCallback? onTap,
  }) {
    _show(AppToastData(
      colorConfig: colorConfig,
      title: title,
      subtitle: subtitle,
      trailingText: trailingText,
      trailingTextColor: trailingTextColor,
      trailingLabel: trailingLabel,
      duration: duration,
      onDismiss: onDismiss,
      onTap: onTap,
    ));
  }
}
