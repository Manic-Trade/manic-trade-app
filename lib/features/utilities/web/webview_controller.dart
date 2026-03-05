import 'dart:io';

import 'package:get/get.dart';
import 'package:finality/theme/color_schemes.g.dart';
import 'package:finality/core/logger.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreenController extends GetxController {
  final String url;

  WebViewScreenController(this.url);

  final WebViewController webViewController = WebViewController();
  RxnString title = RxnString();
  var pageLoadding = 0.obs;

  /// 页面错误
  var pageError = false.obs;

  /// 错误信息
  var errorMsg = "".obs;

  @override
  void onInit() {
    initWebView();
    super.onInit();
  }

  void initWebView() async {
    webViewController.setJavaScriptMode(JavaScriptMode.unrestricted);
    webViewController.setBackgroundColor(
        Get.isDarkMode ? darkColorScheme.surface : lightColorScheme.surface);
    webViewController.setNavigationDelegate(
      NavigationDelegate(
        onProgress: (int progress) async {
          pageLoadding.value = progress;
          title.value = (await webViewController.getTitle());
        },
        onPageStarted: (String url) {
          pageError.value = false;
        },
        onPageFinished: (String url) async {
          pageError.value = false;
        },
        onWebResourceError: (WebResourceError error) {
          logger.d(error.description);
          if (error.isForMainFrame == true) {
            if (Platform.isIOS && error.errorCode == -999) {
              return;
            }
            errorMsg(error.description);
            pageError.value = true;
            pageLoadding.value = 100;
          }
        },
        onNavigationRequest: (NavigationRequest request) {
          var uri = Uri.parse(request.url);
          logger.d(request.url);
          if (uri.scheme == "https" || uri.scheme == "http") {
            return NavigationDecision.navigate;
          }

          return NavigationDecision.prevent;
        },
      ),
    );

    webViewController.loadRequest(Uri.parse(url));

    /// TODO 无法加载Mixed Content
    /// 19年的问题了，Flutter还没解决...
    /// https://github.com/flutter/flutter/issues/43595
  }

  void refreshWeb() {
    if (pageError.value) {
      webViewController.loadRequest(Uri.parse(url));
    } else {
      webViewController.reload();
    }
  }
}
