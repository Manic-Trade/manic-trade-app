import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:finality/common/utils/color_scheme_extensions.dart';
import 'package:finality/common/utils/localization_extensions.dart';

import '../../data/app_preferences.dart';
import '../../di/injector.dart';

class ThemeSettingScreen extends StatefulWidget {
  const ThemeSettingScreen({super.key});

  @override
  State<ThemeSettingScreen> createState() => _ThemeSettingScreenState();
}

class _ThemeSettingScreenState extends State<ThemeSettingScreen> {
  @override
  Widget build(BuildContext context) {
    var currentMode = injector<AppPreferences>().themeMode;
    var colorPrimary = context.colorScheme.primary;
    var textColorPrimary = context.colorScheme.onSurface;
    return Scaffold(
      appBar: AppBar(title: Text(context.strings.title_theme)),
      body: ListView(
        children: [
          _buildItem(context, ThemeMode.system, currentMode, textColorPrimary,
              colorPrimary),
          _buildItem(context, ThemeMode.light, currentMode, textColorPrimary,
              colorPrimary),
          _buildItem(context, ThemeMode.dark, currentMode, textColorPrimary,
              colorPrimary),
        ],
      ),
    );
  }

  _buildItem(BuildContext context, ThemeMode themeMode, ThemeMode currentMode,
      Color color, Color selectedColor) {
    return ListTile(
      title: Text(themeMode.displayName(context),
          style: currentMode == themeMode
              ? context.textTheme.labelLarge?.copyWith(color: selectedColor)
              : context.textTheme.labelLarge?.copyWith(color: color)),
      trailing: currentMode == themeMode
          ? Icon(
              Icons.check,
              color: selectedColor,
            )
          : null,
      onTap: () {
        _updateTheme(themeMode);
      },
    );
  }

  _updateTheme(ThemeMode themeMode) {
    injector<AppPreferences>().themeMode = themeMode;
    Navigator.pop(context);
    Get.changeThemeMode(themeMode);
  }
}
