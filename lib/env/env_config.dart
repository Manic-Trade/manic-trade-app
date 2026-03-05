import 'package:equatable/equatable.dart';

class EnvConfig extends Equatable {
  final String envName;
  final String manicApiHost;
  final String solRpcUrl;
  final String usdcMint;

  const EnvConfig({
    required this.envName,
    required this.manicApiHost,
    required this.solRpcUrl,
    required this.usdcMint,
  });

  @override
  List<Object?> get props => [
        envName,
        manicApiHost,
        usdcMint,
      ];
}

class Env {
  Env._internal();

  static const String _envKey = "APP_ENV";
  static const String _envNameDebug = "debug";
  static const String _envNameRelease = "release";
  static const String _envNameAppStore = "appstore";

  static const String _appEnv =
      String.fromEnvironment(_envKey, defaultValue: _envNameRelease);

  static const _debug = EnvConfig(
    envName: _envNameDebug,
    manicApiHost: "https://bo-server-api-stg.manic.trade",
    solRpcUrl: "https://api.devnet.solana.com",
    usdcMint: "J5aGYt9mKyfCfnA2ikUP8RVYyTWBUvuT6YwwPcDGqrnT",
  );

  static const _release = EnvConfig(
    envName: _envNameRelease,
    manicApiHost: "https://bo-server-api-stg.manic.trade",
    solRpcUrl: "https://api.devnet.solana.com",
    usdcMint: "J5aGYt9mKyfCfnA2ikUP8RVYyTWBUvuT6YwwPcDGqrnT",
  );

  static const _appStore = EnvConfig(
    envName: _envNameRelease,
    manicApiHost: "https://bo-server-api-stg.manic.trade",
    solRpcUrl: "https://api.devnet.solana.com",
    usdcMint: "J5aGYt9mKyfCfnA2ikUP8RVYyTWBUvuT6YwwPcDGqrnT",
  );

  static EnvConfig? _config;

  static EnvConfig get config {
    if (_config == null) {
      init();
    }
    return _config!;
  }

  static bool get isDebug => _config == _debug;

  static void init() {
    switch (_appEnv) {
      case Env._envNameDebug:
        _config = _debug;
        break;
      case Env._envNameRelease:
        _config = _release;
        break;
      case Env._envNameAppStore:
        _config = _appStore;
        break;
    }
  }
}
