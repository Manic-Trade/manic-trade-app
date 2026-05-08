import 'dart:ui';

import 'package:finality/common/toast/app_toast_theme.dart';


class AppToastData {
  final String? id;
  final AppToastType? type;
  final AppToastColorConfig colorConfig;

  final String title;
  final String? subtitle;

  final String? trailingText;
  final Color? trailingTextColor;
  final String? trailingLabel;

  /// 自动关闭时长，为 null 时 toast 不会自动消失（用于 loading 类型）
  final Duration? duration;

  /// 多少秒后才允许用户手动关闭（显示关闭按钮 + 启用滑动关闭）
  /// 为 null 时根据类型决定：loading 默认不可关闭，其他默认可关闭
  final Duration? dismissibleAfter;

  final VoidCallback? onDismiss;
  final VoidCallback? onTap;

  const AppToastData({
    this.id,
    this.type,
    required this.colorConfig,
    required this.title,
    this.subtitle,
    this.trailingText,
    this.trailingTextColor,
    this.trailingLabel,
    this.duration = const Duration(seconds: 3),
    this.dismissibleAfter,
    this.onDismiss,
    this.onTap,
  });

  Color? get resolvedTrailingTextColor =>
      trailingTextColor ?? colorConfig.defaultTrailingTextColor;
}
