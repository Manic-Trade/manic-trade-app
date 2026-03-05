import 'dart:io';

import 'package:finality/features/utilities/web/webview_screen.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class BlockExplorerUtils {
  static Future<bool> viewTransaction(String txHashUrl) {
    if (Platform.isAndroid) {
      //如果是安卓就用应用内浏览器打开
      Get.to(() => WebViewScreen(url: txHashUrl));
      return Future.value(true);
    } else {
      return launchUrl(Uri.parse(txHashUrl));
    }
  }

  static Future<bool> viewSolanaAccountDefi(String accountAddress) {
    //https://solscan.io/account/3jvVkJKKi5hc65SHz677ueLAx1YqKfCvLgnzdXzKyYay
    if (Platform.isAndroid) {
      //如果是安卓就用应用内浏览器打开
      Get.to(() => WebViewScreen(
          url:
              "https://solscan.io/account/$accountAddress?cluster=devnet"));
      return Future.value(true);
    } else {
      return launchUrl(Uri.parse(
          "https://solscan.io/account/$accountAddress?cluster=devnet"));
    }
  }
}
