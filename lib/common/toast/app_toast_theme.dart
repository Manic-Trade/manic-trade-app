import 'dart:ui';

class AppToastTheme {
  final AppToastColorConfig success;
  final AppToastColorConfig failed;
  final AppToastColorConfig gameWon;
  final AppToastColorConfig gameLost;
  final AppToastColorConfig date;
  final AppToastColorConfig gift;

  const AppToastTheme({
    required this.success,
    required this.failed,
    required this.gameWon,
    required this.gameLost,
    required this.date,
    required this.gift,
  });

  static const defaultTheme = AppToastTheme(
    success: AppToastColorConfig(primaryColor: Color(0xFF00D385)),
    failed: AppToastColorConfig(primaryColor: Color(0xFFDB8300)),
    gameWon: AppToastColorConfig(
        primaryColor: Color(0xFF00D385),
        defaultTrailingTextColor: Color(0xFF00D385)),
    gameLost: AppToastColorConfig(primaryColor: Color(0xFFFF412C)),
    date: AppToastColorConfig(primaryColor: Color(0xFFA855F7)),
    gift: AppToastColorConfig(
        primaryColor: Color(0xFF00D385),
        defaultTrailingTextColor: Color(0xFF00D385)),
  );
}

enum AppToastType {
  success,
  failed,
  gameWon,
  gameLost,
  date,
  gift,
}

class AppToastColorConfig {
  final Color primaryColor;
  final Color? defaultTrailingTextColor;

  const AppToastColorConfig({
    required this.primaryColor,
    this.defaultTrailingTextColor,
  });
}
