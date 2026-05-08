import 'package:finality/features/activity/activity_screen.dart';
import 'package:finality/features/login/welcome_screen.dart';
import 'package:finality/features/main/main_binding.dart';
import 'package:finality/features/main/main_screen.dart';
import 'package:finality/features/settings/preferences_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static final unknownRoute = GetPage(
    name: '/notfound',
    page: () {
      // 延迟一帧执行，确保不会和其他导航冲突
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // 如果当前不在主界面，才进行导航
        if (Get.context != null) {
          Get.until((route) => route.isFirst);
        }
      });
      // 返回一个空白页面，它会被立即替换
      return const SizedBox.shrink();
    },
  );

  static final main = GetPage(
    name: Routes.main,
    participatesInRootNavigator: true,
    preventDuplicates: true,
    page: () => MainScreen(),
    binding: MainBinding(),
  );

  static final pages = [
    main,
    GetPage(
      name: Routes.welcome,
      participatesInRootNavigator: true,
      page: () => const WelcomeScreen(),
    ),
    GetPage(
      name: Routes.settings,
      page: () => const PreferencesPage(),
    ),
    GetPage(
      name: Routes.transactions,
      page: () => const ActivityScreen(),
    ),
  ];

  static void toMain() {
    Get.until((route) => route.isFirst);
  }
}
