import 'package:finality/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NavigationHelper {
  NavigationHelper._();

  static void toMain(BuildContext context) {
    if (Get.context != null && context.mounted) {
      Get.until((route) => route.isFirst);
    }
  }

  static void exitTransactionProcess(BuildContext context) {
    if (Get.context != null && context.mounted) {
      Get.until((route) => !RouteNames.transactionProcessRoutes
          .contains(route.settings.name));
    }
  }


}
