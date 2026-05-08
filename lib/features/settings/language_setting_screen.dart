import 'dart:ui' as ui;

import 'package:finality/common/widgets/touchable.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:finality/common/utils/color_scheme_extensions.dart';
import 'package:finality/common/utils/localization_extensions.dart';
import 'package:finality/data/app_preferences.dart';
import 'package:finality/theme/attrs/text_color_theme.dart';
import 'package:intl/intl.dart';

import '../../di/injector.dart';
import '../../generated/l10n.dart';

class LanguageSettingScreen extends StatelessWidget {
  const LanguageSettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var currentLocaleCode = Intl.getCurrentLocale();
    var colorPrimary = context.colorScheme.primary;
    var textColorPrimary = context.textColorTheme.textColorPrimary;
    return Scaffold(
      appBar: AppBar(title: Text(context.strings.title_language_setting)),
      body: ListView(
        children: [
          _buildItem(context, const Locale.fromSubtags(languageCode: "en"),
              currentLocaleCode, textColorPrimary, colorPrimary),
          _buildItem(context, const Locale.fromSubtags(languageCode: "zh"),
              currentLocaleCode, textColorPrimary, colorPrimary),
        ],
      ),
    );
  }

  _buildItem(BuildContext context, Locale locale, String currentLocaleCode,
      Color color, Color selectedColor) {
    return Touchable(
      onTap: () {
        _updateLocale(context, locale);
      },
      child: ListTile(
        title: Text(locale.displayName(context),
            style: currentLocaleCode == locale.languageCode
                ? context.textTheme.labelLarge?.copyWith(color: selectedColor)
                : context.textTheme.labelLarge?.copyWith(color: color)),
        trailing: currentLocaleCode == locale.languageCode
            ? Icon(
                Icons.check,
                color: selectedColor,
              )
            : null,
      ),
    );
  }

  _updateLocale(BuildContext context, Locale? locale) {
    injector<AppPreferences>().locale = locale;
    if (locale != null) {
      S.load(locale);
      Get.updateLocale(locale);
    } else {
      var sysLocal = ui.window.locale;
      S.load(sysLocal);
      Get.updateLocale(sysLocal);
    }
    Navigator.pop(context);
  }
}
