import 'dart:async';

import 'package:finality/common/utils/color_scheme_extensions.dart';
import 'package:finality/common/utils/localization_extensions.dart';
import 'package:finality/common/widgets/bouncy_nav_bar.dart';
import 'package:finality/di/injector.dart';
import 'package:finality/domain/wallet/wallet_selector.dart';
import 'package:finality/features/assets/holdings/holdings_view_model.dart';
import 'package:finality/features/highlow/trading_pairs/vm/options_trading_pairs_vm.dart';
import 'package:finality/features/main/v1/main_v1_controller.dart';
import 'package:finality/features/positions/vm/opened_positions_vm.dart';
import 'package:finality/services/turnkey/turnkey_wallet_sync_service.dart';
import 'package:finality/theme/attrs/text_color_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_scope/store_scope.dart';

class MainV1Screen extends StatefulWidget {
  const MainV1Screen({super.key});

  @override
  State<MainV1Screen> createState() => _MainV1ScreenState();
}

class _MainV1ScreenState extends State<MainV1Screen>
    with ScopedSpaceStateMixin {
  MainV1Controller get controller => Get.find<MainV1Controller>();

  StreamSubscription? _subscription;


  late final OptionsTradingPairsVM _optionsTradingPairsVM;
  late final OpenedPositionsVM _gameStatusVM;

  @override
  void initState() {
    super.initState();
    _initTurnkeySyncService();
    _optionsTradingPairsVM = space.bind(optionsTradingPairsVMProvider);
    _gameStatusVM = space.bind(openedPositionsVMProvider);
  }

  /// 初始化 Turnkey 同步服务（如果是 Turnkey 用户）
  void _initTurnkeySyncService() {
    final walletSelector = injector<WalletSelector>();
    if (walletSelector.isTurnkeyUser) {
      final syncService = injector<TurnkeyWalletSyncService>();
      syncService.startListening();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _subscription?.cancel();
  }

  void _onItemTapped(BuildContext context, int index) {
    var currentPageIndex = controller.pageIndex.value;
    if (currentPageIndex != index) {
      controller.ensurePageLoaded(index);
    } else {
      if (index == 0) {
        var holdingsViewModel = context.store.find(holdingsViewModelProvider);
        holdingsViewModel?.callRefresh();
      }
    }
    if (index == 0) {
      _gameStatusVM.chartOnTheFrontEnd.value = false;
    } else if (index == 1) {
      _gameStatusVM.chartOnTheFrontEnd.value = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, //防止键盘弹出时调整页面大小
      body: Obx(() {
        return IndexedStack(
          index: controller.pageIndex.value,
          children: controller.pages,
        );
      }),
      bottomNavigationBar: bottomNavigationBars(context),
    );
  }

  Widget bottomNavigationBars(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Divider(height: 0.4, thickness: 0.4),
        ValueListenableBuilder(
            valueListenable: _gameStatusVM.openedPositions,
            builder: (context, value, child) {
              return Obx(() => BouncyNavBar(
                    currentIndex: controller.pageIndex.value,
                    onTap: (index) => _onItemTapped(context, index),
                    items: [
                      BouncyNavItem(
                        activeIcon: Icon(
                          Icons.home_rounded,
                          color: context.colorScheme.primary,
                          size: 26,
                        ),
                        icon: Icon(
                          Icons.home_rounded,
                          color: context.textColorTheme.textColorSecondary,
                          size: 26,
                        ),
                        label: context.strings.title_home,
                        badgeCount: value.length,
                        onLongPress: () {
                          //  showWalletSelectionBottomSheet(context);
                        },
                      ),
                      BouncyNavItem(
                        activeIcon: Icon(
                          Icons.currency_exchange_rounded,
                          color: context.colorScheme.primary,
                          size: 22,
                        ),
                        icon: Icon(
                          Icons.currency_exchange_rounded,
                          color: context.textColorTheme.textColorSecondary,
                          size: 22,
                        ),
                        label: context.strings.title_trade,
                      ),
                    ],
                  ));
            }),
      ],
    );
  }
}
