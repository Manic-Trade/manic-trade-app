import 'dart:async';

import 'package:finality/data/realtime/realtime_market_account_transport.dart';
import 'package:finality/di/injector.dart';
import 'package:finality/domain/wallet/wallet_selector.dart';
import 'package:finality/features/analysis/vm/today_win_rate_vm.dart';
import 'package:finality/features/highlow/trading_pairs/vm/options_trading_pairs_vm.dart';
import 'package:finality/features/main/main_controller.dart';
import 'package:finality/features/positions/vm/opened_positions_vm.dart';
import 'package:finality/generated/assets.dart';
import 'package:finality/services/turnkey/turnkey_wallet_sync_service.dart';
import 'package:finality/theme/attrs/text_color_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:store_scope/store_scope.dart';

import 'main_bottom_nav.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with ScopedSpaceStateMixin {
  MainController get controller => Get.find<MainController>();

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
      // 切换 Account 页面时刷新 Analysis 数据
      if (index == 2) {
        space.find(todayWinRateVMProvider)?.refreshIfNeeded();
      }
    } 
    // Trade 页面在第一个 (index == 0)
    _gameStatusVM.chartOnTheFrontEnd.value = (index == 0);

    // Trade(0) 和 Positions(1) 需要 MarketAccount 轮询，其余页面暂停
    final transport = injector<RealtimeMarketAccountTransport>();
    if (index <= 1) {
      transport.resume();
    } else {
      transport.pause();
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
    final unselectedColor = context.textColorTheme.textColorHelper;
    const selectedFilter = ColorFilter.mode(Color(0xFFDB8300), BlendMode.srcIn);
    final unselectedFilter = ColorFilter.mode(unselectedColor, BlendMode.srcIn);

    return Obx(() => MainBottomNav(
          currentIndex: controller.pageIndex.value,
          onTap: (index) => _onItemTapped(context, index),
          items: [
            MainBottomNavItem(
              activeIcon: SvgPicture.asset(
                Assets.svgsMainBottonNavTrade,
                width: 24,
                height: 24,
                colorFilter: selectedFilter,
              ),
              icon: SvgPicture.asset(
                Assets.svgsMainBottonNavTrade,
                width: 24,
                height: 24,
                colorFilter: unselectedFilter,
              ),
              label: 'Trade',
              glowBlurRadius: 6,
            ),
            MainBottomNavItem(
              activeIcon: SvgPicture.asset(
                Assets.svgsMainBottonNavPositions,
                width: 24,
                height: 24,
                colorFilter: selectedFilter,
              ),
              icon: SvgPicture.asset(
                Assets.svgsMainBottonNavPositions,
                width: 24,
                height: 24,
                colorFilter: unselectedFilter,
              ),
              label: 'Positions',
              glowBlurRadius: 3,
            ),
            MainBottomNavItem(
              activeIcon: SvgPicture.asset(
                Assets.svgsMainBottonNavAccount,
                width: 24,
                height: 24,
                colorFilter: selectedFilter,
              ),
              icon: SvgPicture.asset(
                Assets.svgsMainBottonNavAccount,
                width: 24,
                height: 24,
                colorFilter: unselectedFilter,
              ),
              label: 'Account',
              glowBlurRadius: 3,
            ),
          ],
        ));
  }
}
