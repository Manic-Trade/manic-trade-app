import 'package:flutter/material.dart';

import '../../generated/l10n.dart';

extension LocalizationUtils on BuildContext {
  S get strings => S.of(this);
}

extension LocaleDisplayExtension on Locale? {
  String displayName(BuildContext context) {
    var locale = this;
    if (locale != null) {
      if (locale.languageCode == "en") {
        return "English";
      } else if (locale.languageCode == "zh") {
        return "简体中文";
      }
    }
    return context.strings.follow_system;
  }
}

class LocaleDisplayUtil {
  static String languageCodeDisplayName(
      BuildContext context, String languageCode) {
    if (languageCode == "en") {
      return "English";
    } else if (languageCode == "zh") {
      return "简体中文";
    }
    return context.strings.follow_system;
  }
}

extension ThemeModeDisplayUtils on ThemeMode {
  String displayName(BuildContext context) {
    var themeMode = this;
    switch (themeMode) {
      case ThemeMode.light:
        return context.strings.theme_light;
      case ThemeMode.dark:
        return context.strings.theme_dark;
      case ThemeMode.system:
        return context.strings.follow_system;
    }
  }
}
