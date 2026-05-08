import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EnvConfig extends Equatable {
  final String envName;
  final String manicApiHost;
  final String uaApiHost;
  final String solRpcUrl;
  final bool isTradingEnabled;
  final bool devMode;
  final String usdcMint;
  final String vaultApiHost;

  /// 邀请链接模板，用 `{code}` 作为邀请码占位符
  final String inviteLinkTemplate;

  const EnvConfig({
    required this.envName,
    required this.manicApiHost,
    required this.uaApiHost,
    required this.solRpcUrl,
    this.isTradingEnabled = true,
    this.devMode = false,
    required this.usdcMint,
    required this.vaultApiHost,
    required this.inviteLinkTemplate,
  });

  /// 根据邀请码生成完整邀请链接
  String getInviteLink(String inviteCode) {
    return inviteLinkTemplate.replaceFirst('{code}', inviteCode);
  }

  @override
  List<Object?> get props => [
        envName,
        manicApiHost,
        uaApiHost,
        solRpcUrl,
        isTradingEnabled,
        devMode,
        usdcMint,
        vaultApiHost,
        inviteLinkTemplate,
      ];
}

class Env {
  Env._internal();

  static const String _envKey = "APP_ENV";
  static const String _envKeyDevMode = "DEV_MODE";

  static const String _envNameDebug = "debug";
  static const String _envNameAlpha = "alpha";
  static const String _envNameRelease = "release";

  static const String _storedEnvKey = "STORED_ENV";

  static const String _appEnv =
      String.fromEnvironment(_envKey, defaultValue: _envNameRelease);
  static const bool _devMode =
      String.fromEnvironment(_envKeyDevMode, defaultValue: "false") == "true";

  static const _debug = EnvConfig(
    envName: _envNameDebug,
    manicApiHost: "https://bo-server-api-stg.manic.trade",
    uaApiHost: "https://account-api-stg.manic.trade",
    solRpcUrl: "https://api.devnet.solana.com",
    isTradingEnabled: true,
    devMode: true,
    usdcMint: "J5aGYt9mKyfCfnA2ikUP8RVYyTWBUvuT6YwwPcDGqrnT",
    vaultApiHost: "https://vault-wallet-backend-staging.sonic.game",
    inviteLinkTemplate:
        "https://manic-trade-web.vercel.app/register?ref={code}",
  );

  static const _alpha = EnvConfig(
    envName: _envNameAlpha,
    manicApiHost: "https://bo-server-api-alpha.manic.trade",
    uaApiHost: "https://account-api-alpha.manic.trade",
    solRpcUrl: "https://api.devnet.solana.com",
    isTradingEnabled: true,
    devMode: true,
    usdcMint: "8UGiar4EN1H5FVMKi2uQNKURb2AwXaPR3b6fULyvQkaa",
    vaultApiHost: "https://vault-wallet-backend-alpha.manic.trade",
    inviteLinkTemplate: "https://alpha.manic.trade/register?ref={code}",
  );

  static const _release = EnvConfig(
    envName: _envNameRelease,
    manicApiHost: "https://bo-server-api-alpha.manic.trade",
    uaApiHost: "https://account-api-alpha.manic.trade",
    solRpcUrl: "https://api.devnet.solana.com",
    isTradingEnabled: true,
    devMode: _devMode,
    usdcMint: "8UGiar4EN1H5FVMKi2uQNKURb2AwXaPR3b6fULyvQkaa",
    vaultApiHost: "https://vault-wallet-backend-alpha.manic.trade",
    inviteLinkTemplate: "https://alpha.manic.trade/register?ref={code}",
  );

  static const allEnvConfigs = [_debug, _alpha, _release];

  static EnvConfig? _config;

  static EnvConfig get config {
    _config ??= _getConfigFromEnv(_appEnv);
    return _config!;
  }

  static bool get isDebug => _config == _debug;

  static Future<void> init() async {
    if (_appEnv == _envNameRelease && !_devMode) {
      _config = _release;
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final storedEnv = prefs.getString(_storedEnvKey);
    if (storedEnv != null) {
      _config = _getConfigFromEnv(storedEnv);
    } else {
      _config = _getConfigFromEnv(_appEnv);
    }
  }

  static EnvConfig _getConfigFromEnv(String envName) {
    switch (envName) {
      case Env._envNameDebug:
        return _debug;
      case Env._envNameAlpha:
        return _alpha;
      case Env._envNameRelease:
        return _release;
      default:
        return _defaultConfig;
    }
  }

  static EnvConfig get _defaultConfig {
    return _release;
  }

  /// 当前包的默认环境（由编译时参数决定）
  static EnvConfig get buildConfig => _getConfigFromEnv(_appEnv);

  static Future<void> switchEnv(EnvConfig? newConfig) async {
    // 正式包且非开发者模式，不允许切换环境
    if (_appEnv == _envNameRelease && !_devMode) return;

    if (_config == newConfig) return;
    final prefs = await SharedPreferences.getInstance();
    if (newConfig != null) {
      _config = newConfig;
      await prefs.setString(_storedEnvKey, newConfig.envName);
    } else {
      _config = _getConfigFromEnv(_appEnv);
      await prefs.remove(_storedEnvKey);
    }
  }
}
