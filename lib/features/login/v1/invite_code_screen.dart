import 'dart:async';

import 'package:finality/common/toast/app_toast_manager.dart';
import 'package:finality/common/utils/color_scheme_extensions.dart';
import 'package:finality/common/widgets/touchable.dart';
import 'package:finality/core/error/exception_handler.dart';
import 'package:finality/core/logger.dart';
import 'package:finality/core/state/ui_state.dart';
import 'package:finality/data/network/manic_auth_data_source.dart';
import 'package:finality/di/injector.dart';
import 'package:finality/features/login/login_root_screen.dart';
import 'package:finality/features/login/widgets/top_logo_on_logo.dart';
import 'package:finality/generated/assets.dart';
import 'package:finality/theme/attrs/druk_wide_font.dart';
import 'package:finality/theme/attrs/text_color_theme.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';

class InviteCodeScreen extends StatefulWidget {
  const InviteCodeScreen({
    super.key,
  });

  @override
  State<InviteCodeScreen> createState() => _InviteCodeScreenState();
}

class _InviteCodeScreenState extends State<InviteCodeScreen> {
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  UiState<void> _uiState = UiState.success(null);

  late final ManicAuthDataSource _remote = injector<ManicAuthDataSource>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _pinController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: context.textColorTheme.textColorTertiary,
        ),
        body: _buildContent(context));
  }

  Widget _buildContent(BuildContext content) {
    final colorScheme = context.colorScheme;
    final textColorTheme = context.textColorTheme;

    return LayoutBuilder(builder: (context, constraints) {
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
                    'INVITE CODE',
                    style: DrukWideFont.textStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColorTheme.textColorPrimary,
                      letterSpacing: 1.5,
                    ),
                  ),
                  Dimens.vGap12,
                  Text(
                    'Please enter your invitation code to access the platform.',
                    textAlign: TextAlign.center,
                    style: context.textTheme.bodyLarge?.copyWith(
                      color: textColorTheme.textColorTertiary,
                    ),
                  ),
                  Dimens.vGap32,
                  _buildPinInput(colorScheme, textColorTheme),
                  Dimens.vGap16,
                  _buildErrorOrLoading(context, _uiState),
                  Dimens.vGap32,
                  Dimens.safeBottomSpace,
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildEmailIcon(ColorScheme colorScheme) {
    return TopLogoOnLogo(
      child: SvgPicture.asset(
        Assets.svgsIcEmailLoginCheck,
        width: 28,
        height: 28,
      ),
    );
  }

  Widget _buildPinInput(
      ColorScheme colorScheme, TextColorTheme textColorTheme) {
    final defaultPinTheme = PinTheme(
      width: 40,
      height: 40,
      textStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textColorTheme.textColorPrimary,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: colorScheme.outlineVariant,
          width: 0.5,
        ),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: textColorTheme.textColorPrimary,
          width: 0.5,
        ),
      ),
    );

    return Pinput(
      length: 6,
      controller: _pinController,
      focusNode: _focusNode,
      autofocus: true,
      enabled: !_uiState.isLoading,
      showCursor: false,
      isCursorAnimationEnabled: false,
      defaultPinTheme: defaultPinTheme,
      focusedPinTheme: focusedPinTheme,
      submittedPinTheme: defaultPinTheme,
      pinAnimationType: PinAnimationType.fade,
      separatorBuilder: (index) {
        if (index == 2) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Container(
              width: 6,
              height: 1,
              color: colorScheme.outlineVariant,
            ),
          );
        }
        return const SizedBox(width: 8);
      },
      keyboardType: TextInputType.visiblePassword,
      textCapitalization: TextCapitalization.characters,
      onCompleted: _handleVerify,
    );
  }

  Widget _buildResendButton(
      ColorScheme colorScheme, TextColorTheme textColorTheme) {
    return Touchable.button(
      onTap: () {
        Clipboard.getData(Clipboard.kTextPlain).then((value) {
          var text = value?.text;
          if (text != null) {
            _pinController.text = text;
          }
        });
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          'Paste Code',
          style: context.textTheme.labelMedium?.copyWith(
            color: textColorTheme.textColorTertiary,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorOrLoading(
    BuildContext context,
    UiState<void> uiState,
  ) {
    if (uiState.isLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
              height: 16,
              width: 16,
              child: CircularProgressIndicator(
                color: context.textColorTheme.textColorTertiary,
              )),
        ),
      );
    } else {
      return _buildResendButton(context.colorScheme, context.textColorTheme);
    }
  }

  Future<void> _handleVerify(String code) async {
    setState(() {
      _uiState = UiState.loading();
    });
    try {
      var response = await _remote.checkInviteCode(code);
      if (response.valid) {
        //关闭当前页面
        Get.to(() => const LoginRootScreen());
      } else {
        if (mounted) {
          showError(Exception('Invalid invite code'),
              ErrorHandler.getMessage(context, "Invalid invite code"));
        }
      }
    } catch (error) {
      logger.e('Check invite code failed', error: error);
      if (mounted) {
        showError(error, ErrorHandler.getMessage(context, error));
      }
    }
  }

  void showError(dynamic error, String message) {
    _pinController.clear();
    setState(() {
      _uiState = UiState.failure(error);
    });
    if (mounted) {
      AppToastManager.showFailed(
        title: message,
      );
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        _focusNode.requestFocus();
      });
    }
  }
}
