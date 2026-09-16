import 'package:finality/common/toast/app_toast_manager.dart';
import 'package:finality/common/utils/color_scheme_extensions.dart';
import 'package:finality/common/utils/haptic_feedback_utils.dart';
import 'package:finality/common/utils/localization_extensions.dart';
import 'package:finality/common/widgets/primary_async_button.dart';
import 'package:finality/common/widgets/touchable.dart';
import 'package:finality/core/error/exception_handler.dart';
import 'package:finality/core/logger.dart';
import 'package:finality/di/injector.dart';
import 'package:finality/domain/auth/auth_exceptions.dart';
import 'package:finality/features/login/access_restricted_screen.dart';
import 'package:finality/features/login/email_login_screen.dart';
import 'package:finality/features/login/google_authenticating_screen.dart';
import 'package:finality/features/login/web3_wallet_login_screen.dart';
import 'package:finality/features/login/widgets/invite_code_layout.dart';
import 'package:finality/features/login/widgets/top_logo_on_logo.dart';
import 'package:finality/generated/assets.dart';
import 'package:finality/routes/app_pages.dart';
import 'package:finality/services/turnkey/turnkey_external_browser_oauth.dart';
import 'package:finality/services/turnkey/turnkey_manager.dart';
import 'package:finality/services/turnkey/turnkey_wallet_sync_service.dart';
import 'package:finality/theme/app_color_theme.dart';
import 'package:finality/theme/attrs/druk_wide_font.dart';
import 'package:finality/theme/attrs/text_color_theme.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:remixicon/remixicon.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class LoginRootScreen extends StatefulWidget {
  /// 是否需要先填写邀请码
  final bool requireInviteCode;

  const LoginRootScreen({
    super.key,
    this.requireInviteCode = false,
  });

  @override
  State<LoginRootScreen> createState() => _LoginRootScreenState();
}

class _LoginRootScreenState extends State<LoginRootScreen> {
  late final _turnkeyWalletSyncService = injector<TurnkeyWalletSyncService>();
  late final turnkeyManager = injector<TurnkeyManager>();

  final ValueNotifier<bool> _isGoogleLoggingNotifier = ValueNotifier(false);
  bool get isGoogleLogging => _isGoogleLoggingNotifier.value;

  /// 邀请码是否已验证通过
  late bool _inviteCodeVerified;

  /// 验证通过的邀请码
  String? _verifiedInviteCode;

  @override
  void initState() {
    super.initState();
    // 如果不需要邀请码，直接标记为已验证
    _inviteCodeVerified = !widget.requireInviteCode;
    _initTurnkey();
  }

  _initTurnkey() async {
    try {
      await _turnkeyWalletSyncService.readyTurnkeyProvider();
    } catch (e) {
      logger.e('WelcomeScreen: initTurnkey failed', error: e);
    }
    turnkeyManager.clearAllSessions().ignore();
  }

  @override
  void dispose() {
    _isGoogleLoggingNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textColorTheme = context.textColorTheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded,
              color: textColorTheme.textColorTertiary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          LayoutBuilder(builder: (context, constraints) {
            var maxHeight = constraints.maxHeight;
            var topOffset = maxHeight * 0.27;
            return SingleChildScrollView(
              child: Padding(
                padding: Dimens.edgeInsetsScreenH,
                child: Align(
                  alignment: Alignment.center,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 313),
                    child: Column(
                      children: [
                        SizedBox(
                          height: topOffset,
                        ),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: _inviteCodeVerified
                              ? _buildLoginLayout(context)
                              : InviteCodeLayout(
                                  key: const ValueKey('invite_code'),
                                  onVerified: _onInviteCodeVerified,
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
          if (_inviteCodeVerified && widget.requireInviteCode)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.only(
                    top: Dimens.statusBarHeight + kToolbarHeight),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Dimens.vGap16,
                    _buildInviteCodeVerified(context),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInviteCodeVerified(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.only(left: 8.0, right: 12.0, top: 8.0, bottom: 8.0),
      decoration: BoxDecoration(
        color: context.appColors.bullish.withValues(alpha: 0.1),
        borderRadius: BorderRadius.only(
            topRight: Radius.circular(20), bottomRight: Radius.circular(20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Invite verified",
            style: context.textTheme.bodySmall?.copyWith(
              fontSize: 10,
              color: context.appColors.bullish,
            ),
          ),
          Dimens.hGap4,
          Icon(
            Icons.check,
            size: 12,
            color: context.appColors.bullish,
          ),
        ],
      ),
    );
  }

  void _onInviteCodeVerified(String code) {
    setState(() {
      _verifiedInviteCode = code;
      _inviteCodeVerified = true;
    });
  }

  Widget _buildLoginLayout(BuildContext context) {
    final textColorTheme = context.textColorTheme;

    return Column(
      key: const ValueKey('login'),
      children: [
        TopLogoOnLogo(
          child: SvgPicture.asset(
            Assets.svgsIcEmailLogin,
            width: 28,
            height: 28,
          ),
        ),
        Dimens.vGap32,
        Text(
          'LOGIN',
          style: DrukWideFont.textStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textColorTheme.textColorPrimary,
            letterSpacing: 1.5,
          ),
        ),
        Dimens.vGap12,
        Text(
          'Please select a login method to continue.',
          textAlign: TextAlign.center,
          style: context.textTheme.bodyLarge?.copyWith(
            color: textColorTheme.textColorTertiary,
          ),
        ),
        Dimens.vGap32,
        _buildAppleLoginButton(context),
        Dimens.vGap20,
        _buildGoogleLoginButton(context),
        Dimens.vGap20,
        _buildXLoginButton(context),
        Dimens.vGap20,
        _buildOtherDivider(context),
        Dimens.vGap20,
        _buildOtherLoginButton(
            context,
            'Continue with Email',
            Icon(
              RemixIcons.mail_line,
              size: 16,
              color: context.colorScheme.onPrimary,
            ),
            clickToEmailLogin),
        Dimens.vGap20,
        _buildOtherLoginButton(
            context,
            'Continue with Wallet',
            Icon(
              RemixIcons.wallet_line,
              size: 16,
              color: context.colorScheme.onPrimary,
            ),
            clickToWalletLogin),
        Dimens.vGap32,
        Dimens.safeBottomSpace,
      ],
    );
  }

  Widget _buildAppleLoginButton(BuildContext context) {
    return _buildSocialLoginButton(
      context,
      iconAsset: Assets.svgsAppleLogo,
      tintIcon: true,
      label: 'Continue with Apple',
      method: 'apple',
      failedTitle: 'Apple login failed',
      onLogin: appleLogin,
    );
  }

  Widget _buildGoogleLoginButton(BuildContext context) {
    //TODO: 需要适配多主题
    return _buildSocialLoginButton(
      context,
      iconAsset: Assets.svgsIcGoogleLogin,
      tintIcon: false,
      label: 'Continue with Google',
      method: 'google',
      failedTitle: 'Google login failed',
      onLogin: googleLogin,
    );
  }

  Widget _buildXLoginButton(BuildContext context) {
    return _buildSocialLoginButton(
      context,
      iconAsset: Assets.svgsXLogo,
      tintIcon: true,
      label: 'Continue with X',
      method: 'x',
      failedTitle: 'X login failed',
      onLogin: xLogin,
    );
  }

  /// 通用的第三方登录按钮（Apple/Google/X 共用样式）
  Widget _buildSocialLoginButton(
    BuildContext context, {
    required String iconAsset,
    required bool tintIcon,
    required String label,
    required String method,
    required String failedTitle,
    required Future<void> Function() onLogin,
  }) {
    return Touchable.button(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 345),
        child: SizedBox(
          width: double.infinity,
          height: 40,
          child: PrimaryAsyncButton(
            showError: false,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            //这里这么设置会使用 roboto 字体 和设计稿保持一致
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  iconAsset,
                  width: 20,
                  height: 20,
                  colorFilter: tintIcon
                      ? const ColorFilter.mode(Colors.black, BlendMode.srcIn)
                      : null,
                ),
                Dimens.hGap10,
                Text(label),
              ],
            ),
            onError: (e) {
              AppToastManager.showFailed(title: failedTitle);
              return true;
            },
            onPressed: () async {
              HapticFeedbackUtils.lightImpact();
              await onLogin();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildOtherDivider(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: 345,
      ),
      child: SizedBox(
        width: double.infinity,
        child: Row(children: [
          Expanded(
              child: Container(
            height: 0.5,
            color: context.colorScheme.outlineVariant,
          )),
          Dimens.hGap40,
          Text('OR',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w400,
                color: context.textColorTheme.textColorTertiary,
              )),
          Dimens.hGap40,
          Expanded(
              child: Container(
            height: 0.5,
            color: context.colorScheme.outlineVariant,
          )),
        ]),
      ),
    );
  }

  Widget _buildOtherLoginButton(
      BuildContext context, String title, Widget icon, VoidCallback onPressed) {
    return ValueListenableBuilder(
        valueListenable: _isGoogleLoggingNotifier,
        builder: (context, isGoogleLogging, child) {
          return IgnorePointer(
            ignoring: isGoogleLogging,
            child: Touchable.button(
                onTap: onPressed,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 345,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: Container(
                      decoration: BoxDecoration(
                        color: context.colorScheme.primary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            icon,
                            Dimens.hGap10,
                            Text(title,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0,
                                  color: context.colorScheme.onPrimary,
                                  height: 1,
                                )),
                          ],
                        ),
                      ),
                    ),
                  ),
                )),
          );
        });
  }

  void clickToEmailLogin() {
    if (isGoogleLogging) return;
    Get.to(() => EmailLoginScreen(
          verifiedInviteCode: _verifiedInviteCode,
        ));
  }

  /// 点击 Web3 钱包登录
  ///
  /// 流程：
  /// 1. 初始化 AppKit 并打开钱包选择界面
  /// 2. 用户选择并连接钱包
  /// 3. 获取钱包地址后跳转到认证页面
  /// 4. 使用外部钱包签名登录 Turnkey
  /// 5. 使用 Turnkey 钱包签名登录我们的服务端
  Future<void> clickToWalletLogin() async {
    if (isGoogleLogging) return;
    Get.to(() => Web3WalletLoginScreen(
          verifiedInviteCode: _verifiedInviteCode,
        ));
  }

  Future<void> googleLogin() async {
    _isGoogleLoggingNotifier.value = true;
    try {
      await _turnkeyWalletSyncService.readyTurnkeyProvider();
      turnkeyManager.clearAllSessions().ignore();
      // if(Platform.isAndroid){
      //   await turnkeyManager.handleGoogleOAuthNative();
      // } else {
      //   await turnkeyManager.handleGoogleOAuth();
      // }
      await turnkeyManager.handleGoogleOAuthNative();
      Get.to(() => OAuthAuthenticatingScreen(
            verifiedInviteCode: _verifiedInviteCode,
            loginType: OAuthLoginType.google,
          ));
    } on GoogleSignInException catch (e, stackTrace) {
      // 用户主动取消，静默处理
      if (e.code == GoogleSignInExceptionCode.canceled) return;
      _handleGoogleLoginError(e, stackTrace);
    } on UserNotFoundException {
      // 用户不在白名单
      if (mounted) showNotWhitelisted();
    } catch (error, stackTrace) {
      _handleGoogleLoginError(error, stackTrace);
    } finally {
      // 统一在 finally 中重置状态，避免遗漏
      if (mounted) {
        _isGoogleLoggingNotifier.value = false;
      }
    }
  }

  Future<void> xLogin() async {
    try {
      await _turnkeyWalletSyncService.readyTurnkeyProvider();
      turnkeyManager.clearAllSessions().ignore();
      if (!mounted) return;
      await turnkeyManager.handleXOAuth();
      Get.to(() => OAuthAuthenticatingScreen(
            verifiedInviteCode: _verifiedInviteCode,
            loginType: OAuthLoginType.x,
          ));
    } on OAuthCanceledException {
      // 用户从浏览器返回但未完成授权，静默处理
    } on UserNotFoundException {
      // 用户不在白名单
      if (mounted) showNotWhitelisted();
    } catch (error, stackTrace) {
      _handleGoogleLoginError(error, stackTrace);
    }
  }

  Future<void> appleLogin() async {
    try {
      await _turnkeyWalletSyncService.readyTurnkeyProvider();
      turnkeyManager.clearAllSessions().ignore();
      // 两端统一走 Turnkey 浏览器 OAuth（Services ID），保证 aud 一致，
      // 避免 iOS 原生流 aud=Bundle ID 与 Android/Web aud=Services ID
      // 在 Turnkey 后端被识别为两个不同账户
      if (!mounted) return;
      await turnkeyManager.handleAppleOAuth();
      Get.to(() => OAuthAuthenticatingScreen(
            verifiedInviteCode: _verifiedInviteCode,
            loginType: OAuthLoginType.apple,
          ));
    } on OAuthCanceledException {
      // 用户从浏览器返回但未完成授权，静默处理
    } on SignInWithAppleAuthorizationException catch (e) {
      // 用户取消，静默处理
      if (e.code == AuthorizationErrorCode.canceled) return;
      _handleGoogleLoginError(e);
    } on UserNotFoundException {
      if (mounted) showNotWhitelisted();
    } catch (error, stackTrace) {
      _handleGoogleLoginError(error, stackTrace);
    }
  }

  void _handleGoogleLoginError(dynamic error, [StackTrace? stackTrace]) {
    logger.e('Login failed', error: error, stackTrace: stackTrace);
    if (!mounted) return;
    // Android 未检测到兼容 Chrome Custom Tabs 的浏览器时，Turnkey OAuth 会失败，给出友好提示
    if (_isNoBrowserForOAuthError(error)) {
      AppToastManager.showFailed(
        title: context.strings.message_login_failed,
        subtitle: context.strings.message_no_browser_for_oauth,
      );
      return;
    }
    // 使用 ErrorHandler 获取用户友好的错误信息
    final message = ErrorHandler.getMessage(context, error);
    AppToastManager.showFailed(
      title: context.strings.message_login_failed,
      subtitle: message,
    );
  }

  /// 判定是否为 Android 无可用 Custom Tabs 浏览器导致的 OAuth 失败
  bool _isNoBrowserForOAuthError(dynamic error) {
    final text = error.toString();
    if (error is PlatformException &&
        (error.code == 'ChromeBrowserManager' ||
            (error.message ?? '').contains('ChromeCustomTabs is not available'))) {
      return true;
    }
    return text.contains('ChromeCustomTabs is not available');
  }

  void showNotWhitelisted() {
    if (!mounted) return;
    Get.to(() => AccessRestrictedScreen());
  }

  void toMain() {
    Get.offAllNamed(Routes.main);
  }
}
