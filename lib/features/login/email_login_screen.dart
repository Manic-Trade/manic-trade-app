import 'package:async_button_builder/async_button_builder.dart';
import 'package:email_validator/email_validator.dart';
import 'package:finality/common/toast/app_toast_manager.dart';
import 'package:finality/common/utils/color_scheme_extensions.dart';
import 'package:finality/common/widgets/touchable.dart';
import 'package:finality/core/error/exception_handler.dart';
import 'package:finality/core/logger.dart';
import 'package:finality/di/injector.dart';
import 'package:finality/features/login/email_verification_screen.dart';
import 'package:finality/features/login/widgets/top_logo_on_logo.dart';
import 'package:finality/generated/assets.dart';
import 'package:finality/services/turnkey/turnkey_manager.dart';
import 'package:finality/theme/attrs/druk_wide_font.dart';
import 'package:finality/theme/attrs/text_color_theme.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:turnkey_sdk_flutter/turnkey_sdk_flutter.dart';

class EmailLoginScreen extends StatefulWidget {
  final String? verifiedInviteCode;
  const EmailLoginScreen({super.key, this.verifiedInviteCode});

  @override
  State<EmailLoginScreen> createState() => _EmailLoginScreenState();
}

class _EmailLoginScreenState extends State<EmailLoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textColorTheme = context.textColorTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
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
      body: LayoutBuilder(builder: (context, constraints) {
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
                    SizedBox(height: topOffset),
                    _buildEmailIcon(colorScheme),
                    Dimens.vGap32,
                    Text(
                      'ENTER EMAIL',
                      style: DrukWideFont.textStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: textColorTheme.textColorPrimary,
                        letterSpacing: 1.5,
                      ),
                    ),
                    Dimens.vGap12,
                    Text(
                      'We\'ll send a verification code to this address to verify your identity.',
                      textAlign: TextAlign.center,
                      style: context.textTheme.bodyLarge?.copyWith(
                        color: textColorTheme.textColorTertiary,
                      ),
                    ),
                    Dimens.vGap32,
                    _buildEmailInput(colorScheme, textColorTheme),
                    Dimens.vGap24,
                    _buildSendCodeButton(context, colorScheme, textColorTheme),
                    Dimens.vGap32,
                    Dimens.safeBottomSpace,
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildEmailIcon(ColorScheme colorScheme) {
    return TopLogoOnLogo(
      child: SvgPicture.asset(
        Assets.svgsIcEmailLogin,
        width: 28,
        height: 28,
      ),
    );
  }

  Widget _buildEmailInput(
      ColorScheme colorScheme, TextColorTheme textColorTheme) {
    final borderRadius = BorderRadius.circular(4);
    final border = OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: BorderSide(
        color: colorScheme.outlineVariant,
        width: 0.5,
      ),
    );
    final focusedBorder = OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: BorderSide(
        color: colorScheme.outline,
        width: 0.5,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email Address',
          style: context.textTheme.labelSmall?.copyWith(
            color: textColorTheme.textColorTertiary,
          ),
        ),
        Dimens.vGap4,
        TextField(
          controller: _emailController,
          enabled: !_isSending,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          style: TextStyle(
            fontSize: 14,
            color: textColorTheme.textColorPrimary,
          ),
          maxLines: 1,
          cursorColor: textColorTheme.textColorPrimary,
          decoration: InputDecoration(
            hintText: 'name@example.com',
            constraints: const BoxConstraints(minHeight: 0, maxHeight: 40),
            hintStyle: TextStyle(
              fontSize: 14,
              color: textColorTheme.textColorHelper.withValues(alpha: 0.5),
            ),
            filled: true,
            fillColor: colorScheme.surfaceContainerHigh,
            border: border,
            enabledBorder: border,
            focusedBorder: focusedBorder,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 0,
            ),
          ),
          onSubmitted: (_) => _handleNext(),
        ),
      ],
    );
  }

  Widget _buildSendCodeButton(BuildContext context, ColorScheme colorScheme,
      TextColorTheme textColorTheme) {
    return AsyncButtonBuilder(
      showSuccess: false,
      showError: false,
      duration: const Duration(milliseconds: 250),
      buttonState:
          _isSending ? const ButtonState.loading() : const ButtonState.idle(),
      onPressed: _handleNext,
      loadingWidget: SizedBox(
        height: 16,
        width: 16,
        child: CircularProgressIndicator(
          color: textColorTheme.textColorTertiary,
        ),
      ),
      builder: (context, child, callback, _) {
        return Touchable.button(
          onTap: callback,
          child: Container(
            height: 40,
            width: double.infinity,
            decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(6),
                border:
                    Border.all(color: colorScheme.outlineVariant, width: 0.5)),
            child: child,
          ),
        );
      },
      child: Text(
        'Send Code',
        style: context.textTheme.labelSmall?.copyWith(
          color: textColorTheme.textColorTertiary,
        ),
      ),
    );
  }

  Future<void> _handleNext() async {
    final email = _emailController.text.trim();
    if (!checkEmail(email)) {
      return;
    }
    setState(() {
      _isSending = true;
    });
    try {
      var otpId = await _sendVerificationCode(email);
      setState(() {
        _isSending = false;
      });
      Get.to(() => EmailVerificationScreen(
            email: email,
            otpId: otpId,
            verifiedInviteCode: widget.verifiedInviteCode,
          ));
    } catch (e, stackTrace) {
      logger.e('Failed to send verification code',
          error: e, stackTrace: stackTrace);
      setState(() {
        _isSending = false;
      });

      if (mounted) {
        _handleSendCodeError(e, stackTrace);
      }
    }
  }

  void _handleSendCodeError(dynamic error, [StackTrace? stackTrace]) {
    if (error is TurnkeyRequestError) {
      if (error.code == 3) {
        //验证码发送过于频繁
        AppToastManager.showFailed(
          title: 'Send code failed',
          subtitle: 'The verification code has been sent too many times, please wait and try again.',
        );
        return;
      }
    }

    AppToastManager.showFailed(
      title: 'Send code failed',
      subtitle: ErrorHandler.getMessage(context, error),
    );
  }

  Future<String> _sendVerificationCode(String email) async {
    var turnkeyManager = injector<TurnkeyManager>();
    await turnkeyManager.clearAllSessions();
    var otpId =
        await turnkeyManager.initOtp(otpType: OtpType.Email, contact: email);

    return otpId;
  }

  bool checkEmail(String email) {
    if (email.isEmpty) {
      //  Fluttertoast.showToast(msg: 'Please enter your email');
      return false;
    }
    if (!EmailValidator.validate(email)) {
      Get.snackbar(
        "Send code failed",
        'Please enter a valid email',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.red.withOpacity(0.9),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return false;
    }
    return true;
  }
}
