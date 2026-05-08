import 'package:finality/data/app_preferences.dart';
import 'package:finality/di/injector.dart';
import 'package:finality/features/highlow/options_trade_page.dart';
import 'package:finality/features/positions/positions_page.dart';
import 'package:finality/features/user/user_page.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class MainController extends GetxController {
  final pageIndex = 0.obs; // 默认选中 Trade 页面
  final List<Widget> pages = [
    const OptionsTradePage(), // Trade
    Dimens.emptyBox, // Positions
    Dimens.emptyBox, // Account
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
    ensurePageLoaded(0);
  }

  void goToAccount() {
    ensurePageLoaded(2);
  }

  void ensurePageLoaded(int index) {
    if (_shouldRebuildPage(index) || pages[index] == Dimens.emptyBox) {
      pages[index] = _buildPage(index);
    }
    pageIndex.value = index;
  }

  bool _shouldRebuildPage(int index) {
    return false;
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return const OptionsTradePage();
      case 1:
        return const PositionsPage();
      case 2:
        return UserPage();
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
