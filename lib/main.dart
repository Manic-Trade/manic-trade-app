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
    }
  });
}

Future<void> _initializeApp() async {
  Env.init();
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDependencies();
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
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

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
    AppToastManager.registerPresenter(ToastificationPresenter());
 
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
                SwipeActionNavigatorObserver()
              ],
            ),
          );
        });
  }
}
