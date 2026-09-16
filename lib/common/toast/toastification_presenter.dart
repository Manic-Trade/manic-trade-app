import 'package:finality/common/toast/app_toast_data.dart';
import 'package:finality/common/toast/app_toast_manager.dart';
import 'package:finality/common/toast/custom/custom_toast_builder.dart';
import 'package:finality/common/utils/navigator_provider.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class ToastificationPresenter implements AppToastPresenter {
  final Map<String, ToastificationItem> _activeToasts = {};

  @override
  void show(AppToastData data) {
    final overlayState = NavigatorProvider.currentState?.overlay;
    if (overlayState == null) return;

    final item = toastification.showCustom(
      overlayState: overlayState,
      autoCloseDuration: data.duration,
      alignment: Alignment.topCenter,
      builder: (context, item) {
        return CustomToastBuilder(item: item, data: data);
      },
    );

    // 如果有 id，记录映射
    if (data.id != null) {
      _activeToasts[data.id!] = item;
    }
  }

  @override
  void update(String id, AppToastData data) {
    // 先关闭旧的，再显示新的（toastification 不支持原地更新）
    dismiss(id);
    show(data);
  }

  @override
  void dismiss(String id) {
    final item = _activeToasts.remove(id);
    if (item != null) {
      toastification.dismiss(item);
    }
  }
}
