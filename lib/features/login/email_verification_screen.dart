import 'dart:async';

import 'package:finality/common/toast/app_toast_manager.dart';
import 'package:finality/common/utils/color_scheme_extensions.dart';
import 'package:finality/common/widgets/touchable.dart';
import 'package:finality/common/widgets/upper_case_text_formatter.dart';
import 'package:finality/core/logger.dart';
import 'package:finality/core/state/ui_state.dart';
import 'package:finality/data/network/manic_auth_data_source.dart';
import 'package:finality/data/network/model/manic/check_user_request.dart';
import 'package:finality/di/injector.dart';
import 'package:finality/domain/auth/auth_exceptions.dart';
import 'package:finality/domain/auth/wallet_auth_manager.dart';
import 'package:finality/domain/wallet/wallet_selector.dart';
import 'package:finality/features/login/widgets/not_white_listed_layout.dart';
import 'package:finality/features/login/widgets/top_logo_on_logo.dart';
import 'package:finality/generated/assets.dart';
import 'package:finality/routes/app_pages.dart';
import 'package:finality/services/turnkey/turnkey_manager.dart';
import 'package:finality/services/turnkey/turnkey_wallet_sync_service.dart';
import 'package:finality/services/turnkey/turnkey_wallet_utils.dart';
import 'package:finality/theme/attrs/druk_wide_font.dart';
import 'package:finality/theme/attrs/text_color_theme.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard;
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import 'package:turnkey_sdk_flutter/turnkey_sdk_flutter.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String email;
  final String otpId;
  final String? verifiedInviteCode;

  const EmailVerificationScreen({
    super.key,
    required this.email,
    required this.otpId,
    this.verifiedInviteCode,
  });

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen>
    with WidgetsBindingObserver {
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  Timer? _timer;
  int _countdown = 59;
  bool _canResend = false;
  UiState<void> _uiState = UiState.success(null);
  late String _currentOtpId;

  /// 是否正在重新发送验证码
  bool _isResending = false;
  bool _showNotWhiteListed = false;

  /// 是否曾经进入过后台（用于判断是否需要检查剪贴板）
  bool _hasBeenInBackground = false;

  /// 已经自动粘贴过的内容集合，避免重复粘贴
  final Set<String> _pastedContents = {};

  /// 验证码正则：6位大写字母+数字
  static final _otpRegex = RegExp(r'^[A-Z0-9]{6}$');

  @override
  void initState() {
    super.initState();
    _currentOtpId = widget.otpId;
    _startCountdown();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      // App 进入后台，标记一下
      _hasBeenInBackground = true;
    } else if (state == AppLifecycleState.resumed && _hasBeenInBackground) {
      // 从后台回到前台，且之前确实进入过后台，才检查剪贴板
      _hasBeenInBackground = false;
      _checkClipboardOnResume();
    }
  }

  /// App 从后台恢复时检查剪贴板
  Future<void> _checkClipboardOnResume() async {
    // 如果正在加载或已经输入完成，不处理
    if (_uiState.isLoading || _pinController.text.length == 6) {
      return;
    }

    try {
      // 先检查剪贴板是否有内容（iOS 上不会弹窗）
      final hasContent = await Clipboard.hasStrings();
      if (!hasContent) {
        return;
      }

      // 有内容才读取（iOS 上会弹窗）
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      final content = data?.text?.trim();

      // 检查是否匹配验证码格式，且没有粘贴过
      if (content != null &&
          _otpRegex.hasMatch(content) &&
          !_pastedContents.contains(content)) {
        // 记录已粘贴的内容
        _pastedContents.add(content);
        // 自动填入验证码
        _pinController.setText(content);
      }
    } catch (e) {
      // 剪贴板读取失败，忽略
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pinController.dispose();
    _focusNode.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    setState(() {
      _countdown = 59;
      _canResend = false;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 1) {
        setState(() {
          _countdown--;
        });
      } else {
        setState(() {
          _canResend = true;
        });
        timer.cancel();
      }
    });
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
        body: _showNotWhiteListed
            ? NotWhiteListedLayout()
            : _buildContent(context));
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
                    'CHECK INBOX',
                    style: DrukWideFont.textStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColorTheme.textColorPrimary,
                      letterSpacing: 1.5,
                    ),
                  ),
                  Dimens.vGap12,
                  Text(
                    'We\'ve sent a 6-digit verification code to your email address.',
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
      autofocus: false,
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
      inputFormatters: [UpperCaseTextFormatter()],
      onCompleted: _handleVerify,
    );
  }

  Widget _buildResendButton(
      ColorScheme colorScheme, TextColorTheme textColorTheme) {
    if (!_canResend) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          'Resend Code (${_countdown}s)',
          style: context.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w400,
            fontSize: 14,
            color: textColorTheme.textColorHelper,
            height: 1.5,
          ),
        ),
      );
    }
    if (_isResending) {
      Text(
        'Resending...',
        style: context.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w400,
          fontSize: 14,
          color: textColorTheme.textColorHelper,
          height: 1.5,
        ),
      );
    }
    return Touchable.button(
      onTap: _handleResend,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          'Resend Code',
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

  Future<void> _handleResend() async {
    if (!_canResend) return;
    setState(() {
      _isResending = true;
    });
    try {
      final turnkeyManager = injector<TurnkeyManager>();
      final newOtpId = await turnkeyManager.initOtp(
        otpType: OtpType.Email,
        contact: widget.email,
      );
      _startCountdown();
      setState(() {
        _isResending = false;
        _currentOtpId = newOtpId;
      });
      AppToastManager.showSuccess(
        title: 'Verification code sent',
      );
    } catch (e) {
      logger.e('Failed to resend OTP', error: e);
      AppToastManager.showFailed(
        title: 'Failed to resend code',
      );
      setState(() {
        _isResending = false;
      });
    }
  }

  Future<void> _handleVerify(String code) async {
    setState(() {
      _uiState = UiState.loading();
    });
    var turnkeyProvider = injector<TurnkeyManager>();
    try {
      //TODO 后面可以考虑优化，如果turnkey登录成功了，那重试的时候可以不用在登录了，只重试登录manic trade
      await turnkeyProvider.clearAllSessions();
      await turnkeyProvider.loginOrSignUpWithOtp(
          otpCode: code.toUpperCase(),
          otpId: _currentOtpId,
          contact: widget.email,
          otpType: OtpType.Email);

      try {
        await _loginManicTrade(turnkeyProvider);
      } catch (error, stackTrace) {
        if (error is UserNotFoundException) {
          await turnkeyProvider.clearAllSessions();
          showNotWhitelisted();
          return;
        }
        logger.e('Login failed', error: error, stackTrace: stackTrace);
      }
      Get.offAllNamed(Routes.main);
    } catch (e) {
      _pinController.clear();
      setState(() {
        _uiState = UiState.failure(e);
      });

      if (mounted) {
        AppToastManager.showFailed(
          title: 'Verification failed',
        );
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          _focusNode.requestFocus();
        });
      }
    }
  }

  Future<void> _loginManicTrade(TurnkeyManager turnkeyProvider) async {
    var manicTradeWallet =
        TurnkeyWalletUtils.findManicTradeWallet(turnkeyProvider);
    if (manicTradeWallet == null) {
      throw Exception('Manic trade wallet not found');
    }
    var turnkeySolanaAccount = manicTradeWallet.accounts.firstWhereOrNull(
        (a) => a.addressFormat == v1AddressFormat.address_format_solana);
    if (turnkeySolanaAccount == null) {
      throw Exception("Solana account not found in Turnkey wallet");
    }

    if (widget.verifiedInviteCode != null) {
      await _checkUser(
          widget.verifiedInviteCode!, turnkeySolanaAccount, turnkeyProvider);
    }

    // 1. 登录我们自己的服务器
    await injector<WalletAuthManager>()
        .loginTurnkeyWallet(turnkeySolanaAccount);

    // 2. 设置当前用户 ID
    final userId = turnkeyProvider.user!.userId;
    injector<WalletSelector>().setTurnkeyUserId(userId);

    // 3. 同步 Turnkey 钱包数据到本地数据库，并开启监听
    final syncService = injector<TurnkeyWalletSyncService>();
    await syncService.forceSync();
    syncService.startListening();
  }

  Future<void> _checkUser(
      String verifiedInviteCode,
      v1WalletAccount turnkeySolanaAccount,
      TurnkeyManager turnkeyProvider) async {
    var userId = turnkeyProvider.user?.userId;
    var orgId = turnkeyProvider.session?.organizationId;
    var name = turnkeyProvider.user?.userName;
    var email = turnkeyProvider.user?.userEmail;

    var manicTradeWallet =
        TurnkeyWalletUtils.findManicTradeWallet(turnkeyProvider);
    var walletSolana = manicTradeWallet?.accounts
        .firstWhereOrNull((element) =>
            element.addressFormat == v1AddressFormat.address_format_solana)
        ?.address;
    var walletEvm = manicTradeWallet?.accounts
        .firstWhereOrNull((element) =>
            element.addressFormat == v1AddressFormat.address_format_ethereum)
        ?.address;
    if (userId == null ||
        orgId == null ||
        name == null ||
        email == null ||
        walletSolana == null ||
        walletEvm == null) {
      return;
    }

    var checkUserResponse = await injector<ManicAuthDataSource>().checkUser(
        CheckUserRequest.email(
            userId: userId,
            orgId: orgId,
            name: name,
            walletSolana: walletSolana,
            walletEvm: walletEvm,
            email: email,
            inviteCode: verifiedInviteCode));
    if (!checkUserResponse.canLogin) {
      throw UserNotFoundException(address: turnkeySolanaAccount.address);
    }
  }

  void showNotWhitelisted() {
    setState(() {
      _showNotWhiteListed = true;
    });
  }
}
