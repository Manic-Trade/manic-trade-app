import 'dart:io';

import 'package:finality/common/constants/app_links.dart';
import 'package:finality/features/utilities/web/webview_screen.dart';
import 'package:finality/generated/assets.dart';
import 'package:finality/theme/attrs/text_color_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class ChartPriceSourceMark extends StatelessWidget {
  const ChartPriceSourceMark({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: '',
      elevation: 16,
      offset: const Offset(0, 24),
      color: Color(0xFF2D2D2D),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: BorderSide(
          color: Color(0xFF3B3B3B),
          width: 0.5,
        ),
      ),
      constraints: const BoxConstraints(maxWidth: 96, minWidth: 96),
      padding: EdgeInsets.zero,
      menuPadding: EdgeInsets.zero,
      onSelected: (value) {
        _toPriceSourcePage(context);
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'price_source',
          height: 32,
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            'Price Source',
            maxLines: 1,
            style: TextStyle(
                fontSize: 12,
                height: 1,
                decoration: TextDecoration.underline,
                decorationColor: context.textColorTheme.textColorTertiary,
                fontWeight: FontWeight.w400,
                color: context.textColorTheme.textColorTertiary),
          ),
        ),
      ],
      child: Image.asset(
        Assets.pythLogoOnChart,
        width: 59.51,
        height: 14,
      ),
    );
  }

  void _toPriceSourcePage(BuildContext context) {
    if (Platform.isAndroid) {
      //如果是安卓就用应用内浏览器打开
      Get.to(() => WebViewScreen(url: AppLinks.urlPriceSource));
    } else {
      launchUrl(Uri.parse(AppLinks.urlPriceSource));
    }
  }
}
