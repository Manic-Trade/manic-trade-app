import 'dart:ui';

import 'package:finality/common/toast/app_toast_data.dart';
import 'package:finality/common/toast/app_toast_theme.dart';

abstract class AppToastPresenter {
  void show(AppToastData data);
  void update(String id, AppToastData data);
  void dismiss(String id);
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

  // -- Loading toast 相关方法 --

  /// 显示 loading toast，返回 id 用于后续 update/dismiss
  ///
  /// [timeout] 超时时间，超时后 toast 自动消失，默认 30 秒，防止忘记关闭
  /// [dismissibleAfter] 多少秒后允许用户手动关闭，为 null 时一直不可手动关闭
  static String showLoading({
    required String title,
    String? subtitle,
    Duration timeout = const Duration(seconds: 30),
    Duration? dismissibleAfter,
  }) {
    final id = 'toast_${DateTime.now().millisecondsSinceEpoch}';
    _show(AppToastData(
      id: id,
      type: AppToastType.loading,
      colorConfig: _theme.loading,
      title: title,
      subtitle: subtitle,
      duration: timeout,
      dismissibleAfter: dismissibleAfter,
    ));
    return id;
  }

  /// 更新指定 id 的 toast 内容
  static void update(String id, AppToastData data) {
    _presenter?.update(id, data);
  }

  /// 关闭指定 id 的 toast
  static void dismiss(String id) {
    _presenter?.dismiss(id);
  }

  /// 将 loading toast 更新为成功
  static void updateToSuccess(String id, {required String title, String? subtitle}) {
    update(id, AppToastData(
      id: id,
      type: AppToastType.success,
      colorConfig: _theme.success,
      title: title,
      subtitle: subtitle,
      duration: const Duration(seconds: 5),
    ));
  }

  /// 将 loading toast 更新为失败
  static void updateToFailed(String id, {required String title, String? subtitle}) {
    update(id, AppToastData(
      id: id,
      type: AppToastType.failed,
      colorConfig: _theme.failed,
      title: title,
      subtitle: subtitle,
      duration: const Duration(seconds: 5),
    ));
  }
}
