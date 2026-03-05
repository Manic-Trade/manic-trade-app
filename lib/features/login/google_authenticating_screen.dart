import 'package:finality/common/toast/app_toast_manager.dart';
import 'package:finality/common/utils/color_scheme_extensions.dart';
import 'package:finality/common/utils/localization_extensions.dart';
import 'package:finality/common/widgets/touchable.dart';
import 'package:finality/core/error/exception_handler.dart';
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
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:turnkey_sdk_flutter/turnkey_sdk_flutter.dart';

class GoogleAuthenticatingScreen extends StatefulWidget {
  final String? verifiedInviteCode;
  const GoogleAuthenticatingScreen({super.key, this.verifiedInviteCode});

  @override
  State<GoogleAuthenticatingScreen> createState() =>
      _GoogleAuthenticatingScreenState();
}

class _GoogleAuthenticatingScreenState extends State<GoogleAuthenticatingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;

  late final _turnkeyWalletSyncService = injector<TurnkeyWalletSyncService>();
  late final turnkeyManager = injector<TurnkeyManager>();
  UiState<void> _uiState = UiState.loading();

  bool _showNotWhiteListed = false;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    googleLogin();
  }

  @override
  void dispose() {
    _progressController.dispose();
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
      body:
          _showNotWhiteListed ? NotWhiteListedLayout() : _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textColorTheme = context.textColorTheme;
    return LayoutBuilder(builder: (context, constraints) {
      var maxHeight = constraints.maxHeight;
      var topOffset = maxHeight * 0.27;
      return Padding(
        padding: Dimens.edgeInsetsScreenH,
        child: Align(
          alignment: Alignment.center,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 313),
            child: Column(
              children: [
                SizedBox(height: topOffset),
                _buildGoogleIcon(colorScheme),
                Dimens.vGap32,
                Text(
                  'AUTHENTICATING',
                  style: DrukWideFont.textStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColorTheme.textColorPrimary,
                    letterSpacing: 1.5,
                  ),
                ),
                Dimens.vGap12,
                Text(
                  'with Google...',
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: textColorTheme.textColorTertiary,
                  ),
                ),
                Dimens.vGap32,
                _buildErrorOrLoading(context, _uiState),
                Dimens.vGap32,
                Dimens.safeBottomSpace
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildGoogleIcon(ColorScheme colorScheme) {
    return TopLogoOnLogo(
      child: SvgPicture.asset(
        Assets.svgsIcGoogleLoginCheck,
        width: 22.87,
        height: 23.33,
      ),
    );
  }

  Widget _buildErrorOrLoading(BuildContext context, UiState<void> uiState) {
    if (uiState.isLoading) {
      return Column(
        children: [
          _buildProgressBar(context.colorScheme),
          Dimens.vGap24,
          Text(
            'This may take a moment.',
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.textColorTheme.textColorHelper,
            ),
          ),
        ],
      );
    } else {
      return Column(
        children: [
          Touchable.button(
            onTap: googleLogin,
            child: Container(
              height: 40,
              width: double.infinity,
              decoration: BoxDecoration(
                  color: context.colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                      color: context.colorScheme.outlineVariant, width: 0.5)),
              child: Center(
                child: Text(
                  'Try Again',
                  style: context.textTheme.labelMedium?.copyWith(
                    color: context.textColorTheme.textColorTertiary,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }
  }

  Widget _buildProgressBar(ColorScheme colorScheme) {
    const double indicatorWidth = 104;
    return AnimatedBuilder(
      animation: _progressController,
      builder: (context, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final trackWidth = constraints.maxWidth;
            // 从 -indicatorWidth 开始（完全在左边外面）到 trackWidth 结束（完全在右边外面）
            final totalDistance = trackWidth + indicatorWidth;
            final position =
                -indicatorWidth + totalDistance * _progressController.value;

            return ClipRect(
              child: Container(
                height: 1,
                width: double.infinity,
                color: const Color(0xFF1F1F1F),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      left: position,
                      child: Container(
                        width: indicatorWidth,
                        height: 1,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Color(0xFF1F1F1F),
                              Color(0xFFDB8300),
                              Color(0xFFDB8300),
                              Color(0xFF1F1F1F),
                            ],
                            stops: [0.0, 0.399, 0.6154, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> googleLogin() async {
    if (!_uiState.isLoading) {
      setState(() {
        _uiState = UiState.loading();
      });
    }
    try {
      await _loginManicTrade(turnkeyManager);
      if (mounted) {
        Get.offAllNamed(Routes.main);
      }
    } on UserNotFoundException {
      // 用户不在白名单
      if (mounted) showNotWhitelisted();
    } catch (error, stackTrace) {
      setState(() {
        _uiState = UiState.failure(error);
      });
      _handleGoogleLoginError(error, stackTrace);
    }
  }

  void _handleGoogleLoginError(dynamic error, [StackTrace? stackTrace]) {
    logger.e('Login failed', error: error, stackTrace: stackTrace);
    if (!mounted) return;
    // 使用 ErrorHandler 获取用户友好的错误信息
    final message = ErrorHandler.getMessage(context, error);
    AppToastManager.showFailed(
      title: context.strings.message_login_failed,
      subtitle: message,
    );
  }

  Future<void> _loginManicTrade(TurnkeyManager turnkeyManager) async {
    await _turnkeyWalletSyncService.readyTurnkeyProvider();
    var manicTradeWallet =
        TurnkeyWalletUtils.findManicTradeWallet(turnkeyManager);
    if (manicTradeWallet == null) {
      //刷新一次后后重试一次
      await turnkeyManager.refreshWallets();
      manicTradeWallet =
          TurnkeyWalletUtils.findManicTradeWallet(turnkeyManager);
      if (manicTradeWallet == null) {
        throw Exception('Manic trade wallet not found');
      }
    }
    var turnkeySolanaAccount = manicTradeWallet.accounts.firstWhereOrNull(
        (a) => a.addressFormat == v1AddressFormat.address_format_solana);
    if (turnkeySolanaAccount == null) {
      throw Exception("Solana account not found in Turnkey wallet");
    }
    if (widget.verifiedInviteCode != null) {
      await _checkUser(
          widget.verifiedInviteCode!, turnkeySolanaAccount, turnkeyManager);
    }
    // 1. 登录我们自己的服务器
    await injector<WalletAuthManager>()
        .loginTurnkeyWallet(turnkeySolanaAccount);

    // 2. 设置当前用户 ID
    final userId = turnkeyManager.user!.userId;
    injector<WalletSelector>().setTurnkeyUserId(userId);

    // 3. 同步 Turnkey 钱包数据到本地数据库，并开启监听
    await _turnkeyWalletSyncService.forceSync();
    _turnkeyWalletSyncService.startListening();
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
        CheckUserRequest.google(
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
