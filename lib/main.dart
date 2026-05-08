import 'dart:async';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:finality/common/constants/constants.dart';
import 'package:finality/common/toast/app_toast_manager.dart';
import 'package:finality/common/toast/toastification_presenter.dart';
import 'package:finality/common/utils/haptic_feedback_utils.dart';
import 'package:finality/common/utils/navigator_provider.dart';
import 'package:finality/common/widgets/easy_refresh_footer.dart';
import 'package:finality/core/logger.dart';
import 'package:finality/data/app_preferences.dart';
import 'package:finality/domain/wallet/wallet_selector.dart';
import 'package:finality/routes/app_pages.dart';
import 'package:finality/services/appkit/appkit_deep_link_handler.dart';
import 'package:finality/services/turnkey/turnkey_manager.dart';
import 'package:finality/theme/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_swipe_action_cell/core/swipe_action_navigator_observer.dart';
import 'package:get/get.dart';
import 'package:lifecycle/lifecycle.dart';
import 'package:store_scope/store_scope.dart';
import 'package:toastification/toastification.dart';

import 'di/injector.dart';
import 'env/env_config.dart';
import 'generated/l10n.dart';

void main() async {
  runZonedGuarded(() async {
    await _initializeApp();
  }, (error, stackTrace) async {
    // 尝试让 TurnkeyManager 处理错误（如认证失败等）
    if (injector.isRegistered<TurnkeyManager>()) {
      final handled =
          injector<TurnkeyManager>().handleTurnkeyError(error, stackTrace);
      if (handled) return;
    }

    if (Env.isDebug) {
      logger.e('main.dart: Uncaught app exception',
          error: error, stackTrace: stackTrace);
      //injector<Talker>().handle(error, stackTrace, 'Uncaught app exception');
    } else {
      // 错误上报
    }
  });
}

Future<void> _initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Env.init();
  // 尽早初始化 Deep Link 监听器（在依赖注入之前）
  AppKitDeepLinkHandler.initListener();

  await initializeDependencies();
  //强制竖屏
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  //设置状态栏为透明
  await AppStyles.init();
  EasyRefresh.defaultHeaderBuilder = () => CupertinoHeader(
      userWaterDrop: false, hapticFeedback: HapticFeedbackUtils.isEnabled);
  EasyRefresh.defaultFooterBuilder =
      () => ListRefreshFooter(position: IndicatorPosition.behind);

  runApp(
      StoreScope(child: MyApp(initialRoute: await _determineInitialRoute())));
}

Future<String> _determineInitialRoute() async {
  WalletSelector walletSelector = injector<WalletSelector>();
  var hasUserAndWallet = await walletSelector.hasUserAndWallet();
  if (hasUserAndWallet) {
    return Routes.main;
  }
  return Routes.welcome;
}

class MyApp extends StatefulWidget {
  final String initialRoute;
  const MyApp({required this.initialRoute, super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    AppToastManager.registerPresenter(ToastificationPresenter());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// 拦截系统 deep link 触发的 pushRoute。
  ///
  /// iOS/Android 收到 `manic-trade-app://` 回调时，Flutter engine 除了把 URL
  /// 转发给 `app_links` 插件（Turnkey SDK 监听的地方），**还会**把它作为
  /// pushRoute 事件塞进 Navigator。GetX 路由表里没有这种 query-only 的
  /// 路径，会跳到 unknownRoute `/notfound` 然后立刻 close，连带把当前
  /// 登录页一起 pop，表现为“授权成功后页面莫名其妙被关掉”。
  ///
  /// 这里返回 true 表示我们已经处理了，阻止 Navigator 继续响应。
  @override
  Future<bool> didPushRouteInformation(RouteInformation routeInformation) {
    final uri = routeInformation.uri.toString();
    if (uri.startsWith('manic-trade-app:') ||
        uri.contains('manic-trade-app://')) {
      return Future.value(true);
    }
    return super.didPushRouteInformation(routeInformation);
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: const Size(393, 852),
        minTextAdapt: true,
        splitScreenMode: true,
        fontSizeResolver: FontSizeResolvers.radius,
        builder: (context, child) {
          return ToastificationWrapper(
            child: GetMaterialApp(
              debugShowCheckedModeBanner: Env.isDebug,
              navigatorKey: NavigatorProvider.navigatorKey,
              title: Constants.appName,
              builder: (context, child) {
                child = EasyLoading.init()(context, child);
                child = FlutterSmartDialog.init(
                  builder: (context, child) {
                    return child ?? const SizedBox.shrink();
                  },
                )(context, child);
                // 在 debug 模式下添加悬浮按钮
                if (Env.isDebug) {
                  // child = FloatingDraggableWidget(
                  //     autoAlign: true,
                  //     mainScreenWidget: child,
                  //     floatingWidget: FloatingActionButton(
                  //       onPressed: () {
                  //         Get.to(() => TalkerScreen(talker: injector()));
                  //       },
                  //       child: const Icon(Icons.bug_report_outlined),
                  //     ),
                  //     floatingWidgetWidth: 36,
                  //     floatingWidgetHeight: 36,
                  //     dy: 350);
                }
                // 禁用字体缩放
                return MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(textScaler: TextScaler.linear(1.0)),
                  child: child,
                );
              },
              theme: AppStyles.lightTheme(context),
              darkTheme: AppStyles.darkTheme(context),
              initialRoute: widget.initialRoute,
              getPages: AppPages.pages,
              unknownRoute: AppPages.unknownRoute,
              locale: injector<AppPreferences>().locale,
              localeListResolutionCallback: (locale, supportedLocales) {
                return injector<AppPreferences>().locale;
              },
              defaultTransition: Transition.native,
              localizationsDelegates: const [
                S.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate
              ],
              supportedLocales: S.delegate.supportedLocales,
              fallbackLocale: const Locale('en', 'US'),
              themeMode: injector<AppPreferences>().themeMode,
              navigatorObservers: [
                defaultLifecycleObserver,
                SwipeActionNavigatorObserver(),
              ],
            ),
          );
        });
  }
}
