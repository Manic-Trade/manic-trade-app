import 'package:finality/common/toast/app_toast_data.dart';
import 'package:finality/common/toast/app_toast_manager.dart';
import 'package:finality/common/toast/custom/custom_toast_builder.dart';
import 'package:finality/common/utils/navigator_provider.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class ToastificationPresenter implements AppToastPresenter {
  @override
  void show(AppToastData data) {
    final overlayState = NavigatorProvider.currentState?.overlay;
    if (overlayState == null) return;

    toastification.showCustom(
      overlayState: overlayState,
      autoCloseDuration: data.duration,
      alignment: Alignment.topCenter,
      builder: (context, item) {
        return CustomToastBuilder(item: item, data: data);
      },
    );
  }
}
