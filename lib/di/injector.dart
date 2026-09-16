import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:finality/data/app_preferences.dart';
import 'package:finality/data/drift/options_database.dart';
import 'package:finality/data/drift/token_database.dart';
import 'package:finality/data/drift/turnkey_wallet_database.dart';
import 'package:finality/data/network/interceptor/wallet_auth_interceptor.dart';
import 'package:finality/data/network/agent_data_source.dart';
import 'package:finality/data/network/agent_service.dart';
import 'package:finality/data/network/manic_auth_data_source.dart';
import 'package:finality/data/network/manic_auth_service.dart';
import 'package:finality/data/network/manic_price_data_source.dart';
import 'package:finality/data/realtime/realtime_market_account_transport.dart';
import 'package:finality/data/network/manic_price_service.dart';
import 'package:finality/data/network/manic_trade_data_source.dart';
import 'package:finality/data/network/manic_trade_service.dart';
import 'package:finality/data/network/ua_data_source.dart';
import 'package:finality/data/network/ua_service.dart';
import 'package:finality/data/network/solana_rpc_service.dart';
import 'package:finality/data/realtime/realtime_holding_transport.dart';
import 'package:finality/data/repository/holdings_data_repository.dart';
import 'package:finality/data/repository/wallet_data_repository.dart';
import 'package:finality/data/socket/game_status_socket_client.dart';
import 'package:finality/data/socket/shared_price_stream_manager.dart';
import 'package:finality/domain/auth/auth_session_coordinator.dart';
import 'package:finality/domain/auth/user_profile_store.dart';
import 'package:finality/domain/auth/wallet_auth_manager.dart';
import 'package:finality/domain/auth/wallet_auth_store.dart';
import 'package:finality/domain/options/options_data_repository.dart';
import 'package:finality/domain/options/options_trading_pair_selector.dart';
import 'package:finality/domain/wallet/turnkey_wallet_selector.dart';
import 'package:finality/domain/wallet/user_selector.dart';
import 'package:finality/domain/wallet/wallet_selector.dart';
import 'package:finality/data/network/vault_api_client.dart';
import 'package:finality/env/env_config.dart';
import 'package:finality/features/highlow/config/high_low_settings_store.dart';
import 'package:finality/features/highlow/config/options_chart_config_store.dart';
import 'package:finality/features/highlow/config/options_settings_gulide_store.dart';
import 'package:finality/features/settings/passcode/app_lock_manager.dart';
import 'package:finality/services/app_lifecycle_service.dart';
import 'package:finality/services/turnkey/turnkey_manager.dart';
import 'package:finality/services/turnkey/turnkey_wallet_sync_service.dart';
import 'package:finality/services/wallet/token_holdings_service.dart';
import 'package:finality/services/wallet/token_position_service.dart';
import 'package:finality/services/wallet/wallet_service.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';
import 'package:talker_flutter/talker_flutter.dart';

final injector = GetIt.instance;

/// 初始化所有依赖项
Future<void> initializeDependencies() async {
  final totalStopwatch = Stopwatch()..start();

  _measureTimeSync('日志系统', _initializeLogging);
  _measureTimeSync('数据库', _initializeDatabases);
  await _measureTimeAsync('偏好设置', _initializePreferences);
  _measureTimeSync('设置存储', _initializeSettingsStores);
  _measureTimeSync('钱包基础设施', _initializeWalletInfrastructure);
  await _measureTimeAsync('Turnkey 钱包', _initializeTurnkeyWallet);
  _measureTimeSync('钱包服务', _initializeWalletServices);
  _measureTimeSync('网络服务', _initializeNetworkServices);
  _measureTimeSync('数据仓库', _initializeRepositories);
  _measureTimeSync('实时传输服务', _initializeRealtimeTransports);
  _measureTimeSync('工具服务', _initializeUtilityServices);

  totalStopwatch.stop();
  _logTime('总计', totalStopwatch.elapsedMilliseconds);
}

/// 测量同步方法的执行时间并记录
void _measureTimeSync(String name, void Function() action) {
  if (!Env.isDebug) {
    action();
    return;
  }
  final stopwatch = Stopwatch()..start();
  action();
  stopwatch.stop();
  _logTime(name, stopwatch.elapsedMilliseconds);
}

/// 测量异步方法的执行时间并记录
Future<void> _measureTimeAsync(
    String name, Future<void> Function() action) async {
  if (!Env.isDebug) {
    await action();
    return;
  }
  final stopwatch = Stopwatch()..start();
  await action();
  stopwatch.stop();
  _logTime(name, stopwatch.elapsedMilliseconds);
}

/// 记录执行时间
void _logTime(String name, int milliseconds) {
  final seconds = milliseconds / 1000;
  final timeString =
      seconds >= 1 ? '${seconds.toStringAsFixed(3)}s' : '${milliseconds}ms';
  print('⏱️  [$name] 耗时: $timeString');
}

/// 初始化数据库
void _initializeDatabases() {
  injector
      .registerLazySingleton<TurnkeyWalletDatabase>(TurnkeyWalletDatabase.new);
  injector.registerLazySingleton<OptionsDatabase>(OptionsDatabase.new);
  injector.registerLazySingleton<TokenDatabase>(TokenDatabase.new);
}

/// 初始化偏好设置存储
Future<void> _initializePreferences() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  injector.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  final preferencesWithCache = await SharedPreferencesWithCache.create(
    cacheOptions: const SharedPreferencesWithCacheOptions(allowList: null),
  );
  injector.registerSingleton<SharedPreferencesWithCache>(preferencesWithCache);
  injector
      .registerLazySingleton<AppPreferences>(() => AppPreferences(injector()));
}

/// 初始化设置存储
void _initializeSettingsStores() {
  injector.registerLazySingleton<HighLowSettingsStore>(
      () => HighLowSettingsStore(injector()));
  injector.registerLazySingleton<OptionsChartConfigStore>(
      () => OptionsChartConfigStore(injector()));
  injector.registerLazySingleton<OptionsSettingsGuideStore>(
      () => OptionsSettingsGuideStore(injector()));
}

/// 初始化钱包基础设施
void _initializeWalletInfrastructure() {
  injector.registerLazySingleton<UserSelector>(() => UserSelector(injector()));

  injector.registerLazySingleton<UserProfileStore>(
    () => UserProfileStore(injector(), injector<UserSelector>()),
  );

  injector.registerLazySingleton<OptionsTradingPairSelector>(
      () => OptionsTradingPairSelector(injector(), injector()));
}

/// 初始化 Turnkey 钱包
Future<void> _initializeTurnkeyWallet() async {
  injector.registerLazySingleton<TurnkeyManager>(() {
    final turnKeyManager = TurnkeyManager();
    turnKeyManager.initialize();
    return turnKeyManager;
  });
  injector.registerLazySingleton<TurnkeyWalletSelector>(() {
    return TurnkeyWalletSelector(injector(), injector());
  });

  // Turnkey 钱包同步服务
  injector.registerLazySingleton<TurnkeyWalletSyncService>(
    () => TurnkeyWalletSyncService(injector(), injector()),
  );
}

/// 初始化钱包服务
void _initializeWalletServices() {
  // 钱包选择器（需要在 Turnkey 初始化后注册）
  injector.registerLazySingleton<WalletSelector>(
      () => WalletSelector(injector(), injector()));

  // 钱包服务（带初始化）
  injector.registerLazySingleton<WalletService>(() {
    final service = WalletService(injector<WalletSelector>());
    service.init();
    return service;
  });

  // Token 持仓服务
  injector.registerLazySingleton<TokenHoldingsService>(() {
    final service = TokenHoldingsService(injector<WalletService>());
    service.init();
    return service;
  });

  // Token 持仓服务
  injector.registerLazySingleton<TokenPositionService>(() {
    final service = TokenPositionService(injector<TokenHoldingsService>());
    service.init();
    return service;
  });
}

/// 初始化网络服务
void _initializeNetworkServices() {
  final clearDio = createDio();

  // Manic 认证服务
  injector.registerLazySingleton<ManicAuthService>(
      () => ManicAuthService(clearDio, baseUrl: Env.config.manicApiHost));
  injector.registerLazySingleton<ManicAuthDataSource>(
      () => ManicAuthDataSource(injector()));

  // Manic 价格服务
  injector.registerLazySingleton<ManicPriceService>(
      () => ManicPriceService(clearDio, baseUrl: Env.config.manicApiHost));
  injector.registerLazySingleton<ManicPriceDataSource>(
      () => ManicPriceDataSource(injector()));
  injector.registerLazySingleton<RealtimeMarketAccountTransport>(
      () => RealtimeMarketAccountTransport(injector()));

  // 钱包认证管理器（传入 manager 而不是 provider，以支持 provider 重建）
  injector.registerLazySingleton<WalletAuthManager>(() => WalletAuthManager(
        WalletAuthStore(injector()),
        injector<ManicAuthDataSource>(),
        injector<TurnkeyManager>(),
      ));

  // 登录/登出协调器：统一收敛 3 条登录路径和 3 处登出入口的公共步骤
  injector.registerLazySingleton<AuthSessionCoordinator>(
    () => AuthSessionCoordinator(
      injector<TurnkeyManager>(),
      injector<TurnkeyWalletSyncService>(),
      injector<WalletAuthManager>(),
      injector<WalletSelector>(),
      injector<UserProfileStore>(),
    ),
  );

  // 基础网络服务
  injector.registerSingleton<Dio>(clearDio);

  // Manic 交易服务
  injector.registerLazySingleton(
    () => SharedPriceStreamManager(
      settingsStore: injector(),
      baseUrl: Env.config.manicApiHost,
      lifecycleService: injector(),
    ),
  );
  injector.registerLazySingleton(
      () => GameStatusSocketClient(
            baseUrl: Env.config.manicApiHost,
            lifecycleService: injector(),
          ));
  injector.registerSingleton(
    ManicTradeService(
      createDio(
        cookieEnabled: false,
        interceptors: [WalletAuthInterceptor(injector())],
      ),
      baseUrl: Env.config.manicApiHost,
    ),
  );
  injector.registerSingleton(ManicTradeDataSource(injector()));

  // Agent 服务
  injector.registerSingleton(
    AgentService(
      createDio(
        cookieEnabled: false,
        interceptors: [WalletAuthInterceptor(injector())],
      ),
      baseUrl: Env.config.manicApiHost,
    ),
  );
  injector.registerSingleton(AgentDataSource(injector()));

  // UA（Universal Account）跨链充值服务
  injector.registerSingleton(
    UAService(
      createDio(
        cookieEnabled: false,
        interceptors: [WalletAuthInterceptor(injector())],
      ),
      baseUrl: Env.config.uaApiHost,
    ),
  );
  injector.registerSingleton(UADataSource(injector()));

  // Solana RPC 服务
  injector.registerLazySingleton<SolanaRpcService>(
      () => SolanaRpcService(rpcUrl: Env.config.solRpcUrl));

  // Vault API 客户端
  injector.registerLazySingleton<VaultApiClient>(() {
    final vaultDio = createDio(cookieEnabled: false);
    vaultDio.options.baseUrl = Env.config.vaultApiHost;
    return VaultApiClient(vaultDio);
  });
}

/// 初始化数据仓库
void _initializeRepositories() {
  injector.registerLazySingleton(
    () => WalletDataRepository(
      injector<TokenDatabase>().tokenDao,
    ),
  );

  injector.registerLazySingleton(
    () => HoldingsDataRepository(
      tokenDao: injector<TokenDatabase>().tokenDao,
      holderDao: injector<TokenDatabase>().tokenHolderDao,
      priceDao: injector<TokenDatabase>().tokenPriceDao,
      board: injector(),
    ),
  );

  injector.registerLazySingleton(
    () => OptionsDataRepository(
      optionsDatabase: injector(),
      manicPriceDataSource: injector(),
    ),
  );
}

/// 初始化实时传输服务
void _initializeRealtimeTransports() {
  injector.registerLazySingleton(() => RealtimeHoldingTransport(injector()));
}

/// 初始化工具服务
void _initializeUtilityServices() {
  injector.registerLazySingleton(() => AppLockManager(injector()));
  injector.registerLazySingleton<AppLifecycleService>(
    AppLifecycleService.new,
    dispose: (s) => s.dispose(),
  );
}

/// 初始化日志系统
void _initializeLogging() {
  final talker = TalkerFlutter.init(
    settings: TalkerSettings(enabled: Env.isDebug),
  );
  injector.registerSingleton<Talker>(talker);
}

Dio createDio(
    {List<Interceptor> interceptors = const [], bool cookieEnabled = true}) {
  final dio = Dio();
  dio.options.connectTimeout = const Duration(seconds: 15);
  if (interceptors.isNotEmpty) {
    dio.interceptors.addAll(interceptors);
  }
  if (cookieEnabled) {
    final cookieJar = CookieJar();
    dio.interceptors.add(CookieManager(cookieJar));
  }
  if (Env.isDebug) {
    final talkerDioLogger = TalkerDioLogger(
      talker: injector(),
      settings: const TalkerDioLoggerSettings(
        printRequestHeaders: false,
        printResponseHeaders: false,
        printRequestData: true,
        printResponseData: false,
      ),
    );
    dio.interceptors.add(talkerDioLogger);
  }

  return dio;
}
