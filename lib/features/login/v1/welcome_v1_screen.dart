import 'package:finality/common/constants/app_links.dart';
import 'package:finality/common/toast/app_toast_manager.dart';
import 'package:finality/common/utils/color_scheme_extensions.dart';
import 'package:finality/common/utils/haptic_feedback_utils.dart';
import 'package:finality/common/utils/localization_extensions.dart';
import 'package:finality/common/widgets/clickable_text_part.dart';
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
import 'package:finality/features/utilities/web/webview_screen.dart';
import 'package:finality/generated/assets.dart';
import 'package:finality/routes/app_pages.dart';
import 'package:finality/services/turnkey/turnkey_manager.dart';
import 'package:finality/services/turnkey/turnkey_wallet_sync_service.dart';
import 'package:finality/theme/attrs/clash_display_font.dart';
import 'package:finality/theme/attrs/druk_wide_font.dart';
import 'package:finality/theme/attrs/text_color_theme.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

class WelcomeV1Screen extends StatefulWidget {
  const WelcomeV1Screen({super.key});

  @override
  State<WelcomeV1Screen> createState() => _WelcomeV1ScreenState();
}

class _WelcomeV1ScreenState extends State<WelcomeV1Screen>
    with WidgetsBindingObserver {
  late VideoPlayerController _videoController;
  final ValueNotifier<bool> _isVideoInitialized = ValueNotifier(false);
  late final TapGestureRecognizer _applyWhitelistRecognizer;

  late final _turnkeyWalletSyncService = injector<TurnkeyWalletSyncService>();
  late final turnkeyManager = injector<TurnkeyManager>();

  final ValueNotifier<bool> _isGoogleLoggingNotifier = ValueNotifier(false);
  bool get isGoogleLogging => _isGoogleLoggingNotifier.value;

  static const String _verifiedInviteCode = 'NFdNu0';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _applyWhitelistRecognizer = TapGestureRecognizer()
      ..onTap = _clickToTApplyForWhitelist;
    _initVideoPlayer();
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

  void _initVideoPlayer() async {
    _videoController = VideoPlayerController.asset(Assets.videoWelcome);
    try {
      await _videoController.initialize();
      _videoController.setLooping(true);
      _videoController.setVolume(0);
      _videoController.play();
      _isVideoInitialized.value = true;
    } catch (e) {
      logger.e('WelcomeScreen: Video initialization failed', error: e);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // When the app returns to the foreground, ensure the video continues playing
    if (state == AppLifecycleState.resumed &&
        _isVideoInitialized.value &&
        !_videoController.value.isPlaying) {
      _videoController.play();
    }
  }

  @override
  void didUpdateWidget(covariant WelcomeV1Screen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Ensure the video plays when the page is visible, sometimes the page gets reused
    if (_isVideoInitialized.value && !_videoController.value.isPlaying) {
      _videoController.play();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Ensure the video plays when the page is visible
    if (_isVideoInitialized.value && !_videoController.value.isPlaying) {
      _videoController.play();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _applyWhitelistRecognizer.dispose();
    _isVideoInitialized.dispose();
    _videoController.dispose();
    _isGoogleLoggingNotifier.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: true,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: true,
        ),
        body: Stack(
          fit: StackFit.expand,
          children: [
            // 视频背景
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: ValueListenableBuilder(
                    valueListenable: _isVideoInitialized,
                    builder: (context, value, child) {
                      if (!value) {
                        return const SizedBox.shrink();
                      }
                      return SizedBox(
                        width: _videoController.value.size.width,
                        height: _videoController.value.size.height,
                        child: VideoPlayer(_videoController),
                      );
                    }),
              ),
            ),
            // 渐变遮罩
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x99211400), // rgba(33, 20, 0, 0.6)
                    Color(0xE6180F00), // rgba(24, 15, 0, 0.9)
                    Color(0xFF0F0900), // #0F0900
                  ],
                  stops: [0.0, 0.5161, 1.0],
                ),
              ),
            ),
            // 前景内容
            SafeArea(
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: Dimens.edgeInsetsH16,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset(
                              Assets.svgsAppLogo,
                              width: 56,
                              height: 52.54,
                            ),
                            Dimens.vGap32,
                            Text(
                              'MANIC TRADE',
                              textAlign: TextAlign.center,
                              style: DrukWideFont.textStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                height: 1.0, // line-height: 100%
                                letterSpacing: 1.5,
                              ),
                            ),
                            Dimens.vGap12,
                            Text(
                              'ALPHA TESTING',
                              style: context.textTheme.titleSmall?.copyWith(
                                color: context.colorScheme.primary,
                              ),
                            ),
                            Dimens.vGap12,
                            ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxWidth: 345,
                              ),
                              child: RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  style: context.textTheme.bodyLarge?.copyWith(
                                    color: context
                                        .textColorTheme.textColorTertiary,
                                    height: 1.25,
                                  ),
                                  children: [
                                    const TextSpan(
                                      text:
                                          'Thanks for your interest. Alpha is open to whitelisted users. Apply for whitelist access\u00A0',
                                    ),
                                    TextSpan(
                                      text: 'here',
                                      style: TextStyle(
                                        color: const Color(0xFFD9D9D9),
                                        decoration: TextDecoration.underline,
                                        decorationColor: const Color(
                                            0xFFD9D9D9), //TODO: 需要适配多主题
                                      ),
                                      recognizer: _applyWhitelistRecognizer,
                                    ),
                                    const TextSpan(text: '.'),
                                  ],
                                ),
                              ),
                            ),
                            Dimens.vGap32,
                            _buildGoogleLoginButton(context),
                            Dimens.vGap20,
                            _buildOtherDivider(context),
                            Dimens.vGap20,
                            _buildOtherLoginButton(
                                context,
                                'Continue with Email',
                                SvgPicture.asset(Assets.svgsIcEmailLogin,
                                    width: 20, height: 20),
                                clickToEmailLogin),
                            Dimens.vGap20,
                            _buildOtherLoginButton(
                                context,
                                'Continue with Wallet',
                                SvgPicture.asset(Assets.svgsIcWalletLogin,
                                    width: 20, height: 20),
                                clickToWalletLogin),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Dimens.vGap16,
                  _buildTermsService(context),
                  Dimens.vGap16,
                  Dimens.safeBottomSpace
                ],
              ),
            ),
          ],
        ));
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
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
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

  Widget _buildTermsService(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        maxWidth: 250,
      ),
      padding: Dimens.edgeInsetsH16,
      child: ClickableTextWidget(
        fullText: context.strings.terms_service_full,
        clickableParts: [
          ClickableTextPart(
            text: context.strings.terms_service_link,
            onTap: _clickToTermsOfUse,
          ),
          ClickableTextPart(
            text: context.strings.privacy_policy_link,
            onTap: _clickToPrivacy,
          ),
        ],
        baseStyle: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 12,
          height: 1.25,
          color: context.textColorTheme.textColorHelper,
        ).toClashDisplay(),
        linkStyle: TextStyle(
          color: context.textColorTheme.textColorTertiary,
          fontSize: 12,
          height: 1.25,
          fontWeight: FontWeight.w400,
        ).toClashDisplay(),
        textAlign: TextAlign.center,
      ),
    );
  }

  void _clickToTApplyForWhitelist() {
    if (isGoogleLogging) return;
    HapticFeedbackUtils.lightImpact();
    launchUrl(
      Uri.parse(AppLinks.urlApplyForWhitelist),
      mode: LaunchMode.externalApplication,
    );
  }

  void _clickToTermsOfUse() {
    if (isGoogleLogging) return;
    HapticFeedbackUtils.lightImpact();
    openWeb(AppLinks.urlTermsOfUse);
  }

  void _clickToPrivacy() {
    if (isGoogleLogging) return;
    HapticFeedbackUtils.lightImpact();
    openWeb(AppLinks.urlPrivacy);
  }

  void clickToEmailLogin() {
    if (isGoogleLogging) return;
    Get.to(() => EmailLoginScreen(
          verifiedInviteCode: _verifiedInviteCode,
        ));
  }

  /// 点击 Web3 钱包登录 (MWA)
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

  void openWeb(String url) async {
    Get.to(() => WebViewScreen(url: url));
  }
}
