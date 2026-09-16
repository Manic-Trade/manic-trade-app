import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:finality/common/widgets/error_view.dart';
import 'package:finality/common/utils/color_scheme_extensions.dart';
import 'package:finality/common/utils/localization_extensions.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'webview_controller.dart';

class WebViewScreen extends StatelessWidget {
  final String url;
  final WebViewScreenController controller;
  final String? title;

  WebViewScreen({required this.url, this.title, super.key})
      : controller = Get.put(
          WebViewScreenController(url),
          tag: DateTime.now().millisecondsSinceEpoch.toString(),
        );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() {
          var webTitle = controller.title.value;
          if (webTitle == null) {
            return Text(title ?? context.strings.message_loading);
          } else {
            if (webTitle.isEmpty) {
              return Text(title ?? webTitle);
            } else {
              return Text(webTitle);
            }
          }
        }),
      ),
      body: Stack(
        children: [
          WebViewWidget(
            controller: controller.webViewController,
          ),
          Obx(
            () => Offstage(
              offstage: !controller.pageError.value,
              child: Container(
                color: context.colorScheme.surface,
                child: ErrorView(
                  onRetry: () => controller.refreshWeb(),
                  message: controller.errorMsg.value,
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Stack(
        children: [
          BottomAppBar(
            child: SizedBox(
              height: 56,
              child: Row(
                children: [
                  Expanded(
                    child: IconButton(
                      onPressed: () async {
                        if (await controller.webViewController.canGoBack()) {
                          controller.webViewController.goBack();
                        }
                      },
                      icon: const Icon(
                        Icons.chevron_left,
                      ),
                    ),
                  ),
                  Expanded(
                    child: IconButton(
                      onPressed: () {
                        controller.webViewController.reload();
                      },
                      icon: const Icon(
                        Icons.refresh,
                      ),
                    ),
                  ),
                  Expanded(
                    child: IconButton(
                      onPressed: () async {
                        if (await controller.webViewController.canGoForward()) {
                          controller.webViewController.goForward();
                        }
                      },
                      icon: const Icon(
                        Icons.chevron_right,
                      ),
                    ),
                  ),
                  Expanded(
                    child: IconButton(
                      onPressed: () async {
                        var url =
                            (await controller.webViewController.currentUrl()) ??
                                this.url;
                        if (url.isNotEmpty) {
                          Share.share(url);
                        }
                      },
                      icon: const Icon(
                        Icons.share,
                        size: 20,
                      ),
                    ),
                  ),
                  Expanded(
                    child: IconButton(
                      onPressed: () async {
                        var url =
                            (await controller.webViewController.currentUrl()) ??
                                this.url;
                        launchUrlString(url,
                            mode: LaunchMode.externalApplication);
                      },
                      icon: const Icon(
                        Icons.open_in_browser,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned.fill(
            top: 0,
            left: 0,
            child: Obx(
              () => Offstage(
                offstage: controller.pageLoadding.value == 0 ||
                    controller.pageLoadding.value == 100,
                child: Container(
                  alignment: Alignment.topLeft,
                  child: LinearProgressIndicator(
                    value: (controller.pageLoadding.value) / 100.0,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
