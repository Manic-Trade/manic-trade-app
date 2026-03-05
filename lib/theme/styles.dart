import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:finality/theme/app_text_themes.dart';
import 'package:finality/theme/attrs/clash_display_font.dart';
import 'package:finality/theme/attrs/text_color_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'color_schemes.g.dart';

part 'app_widget_styles.dart';

class AppStyles {
  AppStyles._internal();

  static AndroidDeviceInfo? _androidInfo;

  static Future<void> init() async {
    if (Platform.isAndroid) {
      var deviceInfoPlugin = DeviceInfoPlugin();
      _androidInfo = await deviceInfoPlugin.androidInfo;
    }
    if (_androidInfo != null) {
      var sdkInt = _androidInfo!.version.sdkInt;
      if (sdkInt > 29) {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      }
    }
  }

  static ThemeData theme(BuildContext context) =>
      context.isDarkMode ? darkTheme(context) : lightTheme(context);

  static ThemeData lightTheme(BuildContext context) {
    final defaultTextTheme = Theme.of(context).textTheme;
    final clashDisplayTextTheme = ClashDisplayFont.textTheme(defaultTextTheme);
    final textTheme = AppTextThemes.apply(
        clashDisplayTextTheme, lightTextColorTheme.textColorPrimary);
    return ThemeData(
      useMaterial3: true,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: _pageTransitionsThemeBuilders,
      ),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      splashFactory: NoSplash.splashFactory,
      fontFamily: ClashDisplayFont.fontFamily,
      textTheme: textTheme,
      extensions: [lightTextColorTheme, lightAppColorTheme],
      colorScheme: lightColorScheme,
      brightness: Brightness.light,
      outlinedButtonTheme: AppWidgetStyles.outlinedButton(lightColorScheme),
      textButtonTheme: AppWidgetStyles.textButton(lightColorScheme),
      filledButtonTheme: AppWidgetStyles.filledButton(lightColorScheme),
      radioTheme: AppWidgetStyles.radio(lightColorScheme),
      appBarTheme: AppWidgetStyles.appBar(
        colorScheme: lightColorScheme,
        textTheme: textTheme,
        textColorTheme: lightTextColorTheme,
        isDark: false,
      ),
      dividerTheme: AppWidgetStyles.divider(lightColorScheme, false),
      actionIconTheme: ActionIconThemeData(
        backButtonIconBuilder: (context) {
          return Icon(
            Icons.arrow_back_rounded,
          );
        },
      ),
      tabBarTheme:
          AppWidgetStyles.tabBar(lightColorScheme, lightTextColorTheme),
    );
  }

  static ThemeData darkTheme(BuildContext context) {
    final defaultTextTheme = Theme.of(context).textTheme;
    final clashDisplayTextTheme = ClashDisplayFont.textTheme(defaultTextTheme);
    final textTheme =
        AppTextThemes.apply(clashDisplayTextTheme, darkColorScheme.onSurface);
    return ThemeData(
      useMaterial3: true,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: _pageTransitionsThemeBuilders,
      ),
      fontFamily: ClashDisplayFont.fontFamily,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      splashFactory: NoSplash.splashFactory,
      textTheme: textTheme,
      extensions: [
        darkTextColorTheme,
        darkAppColorTheme,
        SkeletonizerConfigData.dark(
          effect: const ShimmerEffect(
            baseColor: Color(0xFF242424),
            highlightColor: Color(0xFF363636),
          ),
        ),
      ],
      colorScheme: darkColorScheme,
      brightness: Brightness.dark,
      outlinedButtonTheme: AppWidgetStyles.outlinedButton(darkColorScheme),
      textButtonTheme: AppWidgetStyles.textButton(darkColorScheme),
      filledButtonTheme: AppWidgetStyles.filledButton(darkColorScheme),
      radioTheme: AppWidgetStyles.radio(darkColorScheme),
      appBarTheme: AppWidgetStyles.appBar(
        colorScheme: darkColorScheme,
        textTheme: textTheme,
        textColorTheme: darkTextColorTheme,
        isDark: true,
      ),
      actionIconTheme: ActionIconThemeData(
        backButtonIconBuilder: (context) {
          return Icon(
            Icons.arrow_back_rounded,
          );
        },
      ),
      dividerTheme: AppWidgetStyles.divider(darkColorScheme, true),
      tabBarTheme: AppWidgetStyles.tabBar(darkColorScheme, darkTextColorTheme),
    );
  }

  static SystemUiOverlayStyle immersiveSystemUiOverlayStyle(
    BuildContext context, {
    bool? isDark,
    bool systemNavigationBarContrastEnforced = true,
  }) {
    return _immersiveSystemUiOverlayStyle(isDark ?? context.isDarkMode,
        systemNavigationBarContrastEnforced:
            systemNavigationBarContrastEnforced);
  }

  static SystemUiOverlayStyle _immersiveSystemUiOverlayStyle(bool isDark,
      {bool systemNavigationBarContrastEnforced = true}) {
    var androidInfo = _androidInfo;
    if (androidInfo != null) {
      var sdkInt = androidInfo.version.sdkInt;
      if (sdkInt < 29) {
        return SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness:
                isDark ? Brightness.light : Brightness.dark,
            systemNavigationBarColor:
                isDark ? darkColorScheme.surface : lightColorScheme.surface,
            systemNavigationBarIconBrightness:
                isDark ? Brightness.light : Brightness.dark);
      }
    }
    var surface = isDark ? darkColorScheme.surface : lightColorScheme.surface;
    return SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        //ios
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: systemNavigationBarContrastEnforced
            ? surface.withValues(alpha: 0.68)
            : Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarContrastEnforced:
            systemNavigationBarContrastEnforced,
        systemNavigationBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark);
  }

  static const Map<TargetPlatform, PageTransitionsBuilder>
      _pageTransitionsThemeBuilders = <TargetPlatform, PageTransitionsBuilder>{
    TargetPlatform.android: ZoomPageTransitionsBuilder(),
    TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
    TargetPlatform.windows: ZoomPageTransitionsBuilder(),
    TargetPlatform.linux: ZoomPageTransitionsBuilder(),
  };
}
