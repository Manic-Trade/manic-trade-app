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
import 'package:finality/features/login/mwa_wallet_login_screen.dart';
import 'package:finality/features/login/widgets/invite_code_layout.dart';
import 'package:finality/features/login/widgets/top_logo_on_logo.dart';
import 'package:finality/generated/assets.dart';
import 'package:finality/routes/app_pages.dart';
import 'package:finality/services/turnkey/turnkey_manager.dart';
import 'package:finality/services/turnkey/turnkey_wallet_sync_service.dart';
import 'package:finality/theme/app_color_theme.dart';
import 'package:finality/theme/attrs/druk_wide_font.dart';
import 'package:finality/theme/attrs/text_color_theme.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
        Dimens.vGap32,
        _buildGoogleLoginButton(context),
        Dimens.vGap20,
        _buildOtherDivider(context),
        Dimens.vGap20,
        _buildOtherLoginButton(
            context,
            'Continue with Email',
            SvgPicture.asset(Assets.svgsIcEmailLogin, width: 20, height: 20),
            clickToEmailLogin),
        Dimens.vGap20,
        _buildOtherLoginButton(
            context,
            'Continue with Wallet',
            SvgPicture.asset(Assets.svgsIcWalletLogin, width: 20, height: 20),
            clickToWalletLogin),
        Dimens.vGap32,
        Dimens.safeBottomSpace,
      ],
    );
  }

  Widget _buildGoogleLoginButton(BuildContext context) {
    //TODO: 需要适配多主题
    return Touchable.button(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 345,
        ),
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
                SvgPicture.asset(Assets.svgsIcGoogleLogin,
                    width: 20, height: 20),
                Dimens.hGap10,
                Text(
                  'Continue with Google',
                ),
              ],
            ),
            onError: (e) {
              AppToastManager.showFailed(
                title: 'Google login failed',
              );
              return true;
            },
            onPressed: () async {
              HapticFeedbackUtils.lightImpact();
              await googleLogin();
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
            color: Colors.white24,
          )),
          Dimens.hGap40,
          Text('OR',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: context.textColorTheme.textColorTertiary,
              ).toDrukWide()),
          Dimens.hGap40,
          Expanded(
              child: Container(
            height: 0.5,
            color: Colors.white24,
          )),
        ]),
      ),
    );
  }

  Widget _buildOtherLoginButton(
      BuildContext context, String title, Widget icon, VoidCallback onPressed) {
    var colorPrimary = context.colorScheme.primary;
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
                        color: const Color(0xFF211400), //TODO: 需要适配多主题
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: colorPrimary,
                            offset: Offset(0, 0),
                            blurRadius: 12,
                            spreadRadius: 0,
                            blurStyle: BlurStyle.inner,
                            inset: true,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          icon,
                          Dimens.hGap10,
                          Text(title,
                              style: context.textTheme.labelMedium?.copyWith(
                                color: colorPrimary,
                              )),
                        ],
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

  /// 点击 Solana Mobile Wallet Adapter 登录
  ///
  /// 流程：
  /// 1. 通过 MWA 协议连接设备上的 Solana 钱包 App（如 Phantom）
  /// 2. 用户在钱包 App 中授权
  /// 3. 使用钱包签名登录 Turnkey
  /// 4. 使用 Turnkey 托管钱包签名登录我们的服务端
  Future<void> clickToWalletLogin() async {
    if (isGoogleLogging) return;
    Get.to(() => MwaWalletLoginScreen(
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
      Get.to(() => GoogleAuthenticatingScreen(
            verifiedInviteCode: _verifiedInviteCode,
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

  void _handleGoogleLoginError(dynamic error, [StackTrace? stackTrace]) {
    logger.e('Login failed', error: error, stackTrace: stackTrace);
    if (!mounted) return;
    // 使用 ErrorHandler 获取用户友好的错误信息
    final message = ErrorHandler.getMessage(context, error);
    //Fluttertoast.showToast(msg: message);
    AppToastManager.showFailed(
      title: context.strings.message_login_failed,
      subtitle: message,
    );
  }

  void showNotWhitelisted() {
    if (!mounted) return;
    Get.to(() => AccessRestrictedScreen());
  }

  void toMain() {
    Get.offAllNamed(Routes.main);
  }
}
