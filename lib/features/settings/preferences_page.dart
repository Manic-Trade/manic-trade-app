import 'package:finality/common/constants/app_links.dart';
import 'package:finality/common/utils/localization_extensions.dart';
import 'package:finality/di/injector.dart';
import 'package:finality/domain/auth/wallet_auth_manager.dart';
import 'package:finality/domain/wallet/wallet_selector.dart';
import 'package:finality/features/feedback/feed_back_screen.dart';
import 'package:finality/features/settings/widgets/preferences_item.dart';
import 'package:finality/features/settings/widgets/preferences_section_title.dart';
import 'package:finality/features/settings/widgets/wallet_item.dart';
import 'package:finality/features/utilities/web/webview_screen.dart';
import 'package:finality/routes/app_pages.dart';
import 'package:finality/services/turnkey/turnkey_manager.dart';
import 'package:finality/services/turnkey/turnkey_wallet_sync_service.dart';
import 'package:finality/services/wallet/wallet_service.dart';
import 'package:finality/theme/attrs/text_color_theme.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

class PreferencesPage extends StatelessWidget {
  const PreferencesPage({super.key});

  WalletService get _walletService => injector<WalletService>();
  TurnkeyManager get _turnkeyManager => injector<TurnkeyManager>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.strings.title_settings),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Dimens.vGap8,
            ValueListenableBuilder(
                valueListenable: _walletService.walletAccounts,
                builder: (context, walletAccounts, child) {
                  if (walletAccounts == null) {
                    return const SizedBox();
                  }
                  var userEmail = _turnkeyManager.user?.userEmail;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      WalletItem(
                        avatar: walletAccounts.wallet.avatar,
                        name: userEmail ?? walletAccounts.wallet.name,
                        address: walletAccounts.accounts.first.address,
                        showArrow: false,
                      ),
                      Dimens.vGap8,
                      Divider(),
                      Dimens.vGap8,
                    ],
                  );
                }),
            // Dimens.vGap20,
            // PreferencesSectionTitle(title: context.strings.title_preferences),
            // PreferencesItem(
            //   title: context.strings.title_theme,
            //   trailing: StreamBuilder<ThemeMode>(
            //       stream: injector<AppPreferences>().streamThemeMode(),
            //       builder: (context, snapshot) {
            //         var themeMode = snapshot.data ?? ThemeMode.system;
            //         return PreferencesItem.buildTrailingText(
            //             context, themeMode.displayName(context));
            //       }),
            //   onTap: () {
            //     Get.to(() => const ThemeSettingScreen());
            //   },
            // ),
            // PreferencesItem(
            //   title: context.strings.title_language_setting,
            //   trailing: StreamBuilder<Locale?>(
            //       stream: injector<AppPreferences>().streamLocale(),
            //       initialData: injector<AppPreferences>().locale,
            //       builder: (context, snapshot) {
            //         var currentLocaleCode = Intl.getCurrentLocale();
            //         return PreferencesItem.buildTrailingText(
            //             context,
            //             LocaleDisplayUtil.languageCodeDisplayName(
            //                 context, currentLocaleCode));
            //       }),
            //   onTap: () {
            //     Get.to(() => const LanguageSettingScreen());
            //   },
            // ),
            /*     PreferencesItem(
              title: context.strings.title_haptics,
              showArrow: false,
              onTap: () {
                injector<AppPreferences>().hapticFeedbackEnabled =
                    !injector<AppPreferences>().hapticFeedbackEnabled;
              },
              trailing: ValueListenableBuilder<bool>(
                  valueListenable:
                      injector<AppPreferences>().hapticFeedbackEnabledNotifier,
                  builder: (context, value, child) {
                    return AdvancedSwitch(
                      activeColor: context.colorScheme.primary,
                      inactiveColor: const Color(0xFFA1A6AB),
                      initialValue: value,
                      onChanged: (open) {
                        injector<AppPreferences>().hapticFeedbackEnabled = open;
                      },
                    );
                  }),
            ),
            PreferencesItem(
              title: context.strings.title_screen_auto_lock,
              showArrow: false,
              onTap: () {
                injector<AppPreferences>().wakeLockEnabled =
                    !injector<AppPreferences>().wakeLockEnabled;
              },
              trailing: ValueListenableBuilder<bool>(
                  valueListenable:
                      injector<AppPreferences>().wakeLockEnabledNotifier,
                  builder: (context, value, child) {
                    return AdvancedSwitch(
                      activeColor: context.colorScheme.primary,
                      inactiveColor: const Color(0xFFA1A6AB),
                      initialValue: value,
                      onChanged: (open) {
                        injector<AppPreferences>().wakeLockEnabled = open;
                      },
                    );
                  }),
            ),
            PreferencesItem(
              title: context.strings.title_preference_first_macp,
              showArrow: false,
              onTap: () {
                var appPreferences = injector<AppPreferences>();
                appPreferences.basedOnMarketCap =
                    !appPreferences.basedOnMarketCap;
              },
              trailing: ValueListenableBuilder<bool>(
                  valueListenable:
                      injector<AppPreferences>().basedOnMarketCapNotifier,
                  builder: (context, value, child) {
                    return AdvancedSwitch(
                      activeColor: context.colorScheme.primary,
                      inactiveColor: const Color(0xFFA1A6AB),
                      initialValue: value,
                      onChanged: (open) {
                        injector<AppPreferences>().basedOnMarketCap = open;
                        injector<KlineSettingsStore>().klineBasedMCap = open;
                      },
                    );
                  }),
            ),*/
            Dimens.vGap20,
            PreferencesSectionTitle(
              title: context.strings.title_about,
            ),
            PreferencesItem(
              title: context.strings.title_terms_of_use,
              onTap: () {
                _openWeb(AppLinks.urlTermsOfUse);
              },
            ),
            PreferencesItem(
              title: context.strings.title_privacy_policy,
              onTap: () {
                _openWeb(AppLinks.urlPrivacy);
              },
            ),
            PreferencesItem(
              title: context.strings.feedback_title,
              onTap: () {
                Get.to(() => const FeedBackScreen());
              },
            ),
            PreferencesItem(
              title: context.strings.title_logout,
              onTap: () => _showLogoutConfirmDialog(context),
            ),
            Center(
              child: Column(
                children: [
                  Dimens.vGap40,
                  FutureBuilder<PackageInfo>(
                      future: PackageInfo.fromPlatform(),
                      builder: (context, snapshot) {
                        var packageInfo = snapshot.data;
                        if (packageInfo == null) {
                          return const SizedBox();
                        }
                        return Text(
                            context.strings
                                .format_version(packageInfo.version)
                                .toUpperCase(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: context.textColorTheme.textColorSecondary,
                            ));
                      }),
                  Dimens.vGap40,
                ],
              ),
            ),
            Dimens.safeBottomSpace
          ],
        ),
      ),
    );
  }

  void _openWeb(String url) {
    Get.to(() => WebViewScreen(url: url));
  }

  void _showLogoutConfirmDialog(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          context.strings.title_logout,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        content: Text(
          context.strings.message_signout_sure,
          style: TextStyle(
            fontSize: 14,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              context.strings.cancel,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _logout();
            },
            child: Text(
              context.strings.action_confirm,
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    // 1. 停止 Turnkey 同步服务监听
    injector<TurnkeyWalletSyncService>().stopListening();

    // 2. 清除 Turnkey 会话
    await injector<TurnkeyManager>().clearAllSessions();

    // 3. 清除服务器认证
    await injector<WalletAuthManager>().logoutAllWallets();

    // 4. 清除用户选择
    injector<WalletSelector>().clearSelectedUser();

    // 5. 跳转到欢迎页
    Get.offAllNamed(Routes.welcome);
  }
}
