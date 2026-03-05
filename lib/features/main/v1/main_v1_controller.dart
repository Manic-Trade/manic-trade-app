import 'package:finality/data/app_preferences.dart';
import 'package:finality/di/injector.dart';
import 'package:finality/features/assets/holdings/holdings_page.dart';
import 'package:finality/features/highlow/options_trade_page.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class MainV1Controller extends GetxController {
  final pageIndex = 0.obs;
  final List<Widget> pages = [
    HoldingsPage(),
    Dimens.emptyBox,
  ];

  final appPreferences = injector<AppPreferences>();

  @override
  void onInit() {
    super.onInit();
    _onWakeLockEnabledChanged();
    appPreferences.wakeLockEnabledNotifier
        .addListener(_onWakeLockEnabledChanged);
  }

  void _onWakeLockEnabledChanged() {
    if (injector<AppPreferences>().wakeLockEnabled) {
      WakelockPlus.enable();
    } else {
      WakelockPlus.disable();
    }
  }

  void goToTrade() {
    ensurePageLoaded(1);
  }

  void ensurePageLoaded(int index) {
    if (_shouldRebuildPage(index) || pages[index] == Dimens.emptyBox) {
      pages[index] = _buildPage(index);
    }
    pageIndex.value = index;
  }

  // 判断是否需要重建页面
  bool _shouldRebuildPage(int index) {
    return false; // 仅在CommunitiesPage需要重建时返回true
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return HoldingsPage();
      case 1:
        return const OptionsTradePage();
    }
    throw Exception("Invalid page index: $index");
  }

  @override
  void onClose() {
    WakelockPlus.disable();
    injector<AppPreferences>()
        .wakeLockEnabledNotifier
        .removeListener(_onWakeLockEnabledChanged);
    super.onClose();
  }
}
