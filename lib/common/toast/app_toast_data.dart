import 'dart:ui';

import 'package:finality/common/toast/app_toast_theme.dart';


class AppToastData {
  final AppToastType? type;
  final AppToastColorConfig colorConfig;

  final String title;
  final String? subtitle;

  final String? trailingText;
  final Color? trailingTextColor;
  final String? trailingLabel;

  final Duration duration;
  final VoidCallback? onDismiss;
  final VoidCallback? onTap;

  const AppToastData({
    this.type,
    required this.colorConfig,
    required this.title,
    this.subtitle,
    this.trailingText,
    this.trailingTextColor,
    this.trailingLabel,
    this.duration = const Duration(seconds: 3),
    this.onDismiss,
    this.onTap,
  });

  Color? get resolvedTrailingTextColor =>
      trailingTextColor ?? colorConfig.defaultTrailingTextColor;
}
