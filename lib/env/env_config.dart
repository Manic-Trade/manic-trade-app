import 'package:equatable/equatable.dart';

class EnvConfig extends Equatable {
  final String envName;
  final String manicApiHost;
  final String solRpcUrl;
  final bool canTraded;
  final bool canShowDebugSetting;
  final String usdcMint;

  /// 二元期权合约 Program ID
  final String binaryOptionProgramId;

  const EnvConfig({
    required this.envName,
    required this.manicApiHost,
    required this.solRpcUrl,
    this.canTraded = true,
    this.canShowDebugSetting = false,
    required this.usdcMint,
    required this.binaryOptionProgramId,
  });

  @override
  List<Object?> get props => [
        envName,
        canTraded,
        manicApiHost,
        usdcMint,
        binaryOptionProgramId,
      ];
}

class Env {
  Env._internal();

  static const String _envKey = "APP_ENV";
  static const String _envKeyDebugSetting = "DEBUG_SETTING";
  static const String _envNameDebug = "debug";
  static const String _envNameRelease = "release";
  static const String _envNameAppStore = "appstore";

  static const String _appEnv =
      String.fromEnvironment(_envKey, defaultValue: _envNameRelease);
  static const bool _debugSetting =
      String.fromEnvironment(_envKeyDebugSetting, defaultValue: "false") ==
          "true";

  static const _debug = EnvConfig(
    envName: _envNameDebug,
    manicApiHost: "https://bo-server-api-stg.manic.trade",
    solRpcUrl: "https://api.devnet.solana.com",
    canTraded: true,
    canShowDebugSetting: true,
    usdcMint: "CgQBiuuLBFMo1kMMMFtRxB254kv54BVvVHVLC35cpaXK",
    binaryOptionProgramId: "HF1uuMHBmtaCYqhFx2wCFYhkAim8uLaxpMUeWmeTXtD9",
  );

  static const _release = EnvConfig(
    envName: _envNameRelease,
    manicApiHost: "https://bo-server-api-stg.manic.trade",
    solRpcUrl: "https://api.devnet.solana.com",
    canTraded: true,
    canShowDebugSetting: _debugSetting,
    usdcMint: "CgQBiuuLBFMo1kMMMFtRxB254kv54BVvVHVLC35cpaXK",
    binaryOptionProgramId: "HF1uuMHBmtaCYqhFx2wCFYhkAim8uLaxpMUeWmeTXtD9",
  );

  static const _appStore = EnvConfig(
    envName: _envNameRelease,
    manicApiHost: "https://bo-server-api-stg.manic.trade",
    solRpcUrl: "https://api.devnet.solana.com",
    canTraded: false,
    canShowDebugSetting: false,
    usdcMint: "CgQBiuuLBFMo1kMMMFtRxB254kv54BVvVHVLC35cpaXK",
    binaryOptionProgramId: "HF1uuMHBmtaCYqhFx2wCFYhkAim8uLaxpMUeWmeTXtD9",
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
