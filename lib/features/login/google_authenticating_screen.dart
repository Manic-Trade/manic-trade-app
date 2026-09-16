import 'package:finality/common/toast/app_toast_manager.dart';
import 'package:finality/common/utils/color_scheme_extensions.dart';
import 'package:finality/common/utils/localization_extensions.dart';
import 'package:finality/common/widgets/touchable.dart';
import 'package:finality/core/error/exception_handler.dart';
import 'package:finality/core/logger.dart';
import 'package:finality/core/state/ui_state.dart';
import 'package:finality/data/network/manic_auth_data_source.dart';
import 'package:finality/data/network/model/manic/check_user_request.dart';
import 'package:finality/data/network/model/manic/check_user_response.dart';
import 'package:finality/di/injector.dart';
import 'package:finality/domain/auth/auth_exceptions.dart';
import 'package:finality/domain/auth/auth_session_coordinator.dart';
import 'package:finality/domain/auth/wallet_auth_manager.dart';
import 'package:finality/features/login/widgets/follow_x_dialog.dart';
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

/// OAuth 登录类型
enum OAuthLoginType {
  google,
  x,
  apple,
}

/// OAuth 登录认证中间页
///
/// 通用的 OAuth 认证页面，支持 Google、X 等登录方式。
/// Turnkey OAuth 完成后，在此页面完成后续流程：
/// 检查白名单 → 签名登录后端 → 同步钱包数据
class OAuthAuthenticatingScreen extends StatefulWidget {
  final String? verifiedInviteCode;
  final OAuthLoginType loginType;

  const OAuthAuthenticatingScreen({
    super.key,
    this.verifiedInviteCode,
    this.loginType = OAuthLoginType.google,
  });

  @override
  State<OAuthAuthenticatingScreen> createState() =>
      _OAuthAuthenticatingScreenState();
}

/// 保留旧名称的类型别名，兼容已有引用
typedef GoogleAuthenticatingScreen = OAuthAuthenticatingScreen;

class _OAuthAuthenticatingScreenState extends State<OAuthAuthenticatingScreen>
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
    _doLogin();
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
                _buildIcon(colorScheme),
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
                  _subtitleText,
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

  String get _subtitleText {
    switch (widget.loginType) {
      case OAuthLoginType.google:
        return 'with Google...';
      case OAuthLoginType.x:
        return 'with X...';
      case OAuthLoginType.apple:
        return 'with Apple...';
    }
  }

  Widget _buildIcon(ColorScheme colorScheme) {
    final Widget iconWidget;
    switch (widget.loginType) {
      case OAuthLoginType.google:
        iconWidget = SvgPicture.asset(
          Assets.svgsIcGoogleLoginCheck,
          width: 22.87,
          height: 23.33,
          colorFilter: ColorFilter.mode(
            colorScheme.primary,
            BlendMode.srcIn,
          ),
        );
      case OAuthLoginType.x:
        iconWidget = SvgPicture.asset(
          Assets.svgsIcLinkTwitter,
          width: 22.87,
          height: 23.33,
          colorFilter: ColorFilter.mode(
            colorScheme.primary,
            BlendMode.srcIn,
          ),
        );
      case OAuthLoginType.apple:
        iconWidget = SvgPicture.asset(
          Assets.svgsAppleLogo,
          width: 22.87,
          height: 23.33,
          colorFilter: ColorFilter.mode(
            colorScheme.primary,
            BlendMode.srcIn,
          ),
        );
    }
    return TopLogoOnLogo(child: iconWidget);
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
            onTap: _doLogin,
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

  Future<void> _doLogin() async {
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
      // 埋点：Manic 服务器登录失败
      setState(() {
        _uiState = UiState.failure(error);
      });
      _handleLoginError(error, stackTrace);
    }
  }

  void _handleLoginError(dynamic error, [StackTrace? stackTrace]) {
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
      // 刷新一次后重试一次
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
    CheckUserResponse? checkUserResponse;
    if (widget.verifiedInviteCode != null ||
        widget.loginType == OAuthLoginType.x) {
      checkUserResponse = await _checkUser(
          widget.verifiedInviteCode, turnkeySolanaAccount, turnkeyManager);
    }

    // 埋点：Turnkey 登录成功
    final tkUser = turnkeyManager.user;

    // 1. 登录我们自己的服务器
    await injector<WalletAuthManager>()
        .loginTurnkeyWallet(turnkeySolanaAccount);

    // 埋点：Manic 服务器登录成功

    // 2. 收尾：设置 userId、同步钱包、埋点 identify（OAuth 没有外部登录钱包地址）
    await injector<AuthSessionCoordinator>().finalizeTurnkeyLogin(
      TurnkeyLoginResult(
        userId: turnkeyManager.user!.userId,
        tradeWalletAddress: turnkeySolanaAccount.address,
      ),
    );

    // 3. 新 X 用户首次登录后弹一次 Follow @ManicTrade 弱提示。返回用户、其他
    // OAuth 都不弹，邀请页主动绑定 X 也不走这条路径——和 web 端 loginFollowX
    // modal 的触发条件保持一致。
    if (mounted &&
        widget.loginType == OAuthLoginType.x &&
        checkUserResponse?.userCreated == true) {
      await showFollowXDialog(context);
    }
  }

  Future<CheckUserResponse?> _checkUser(
      String? verifiedInviteCode,
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
        walletSolana == null ||
        walletEvm == null) {
      return null;
    }

    final CheckUserRequest request;
    switch (widget.loginType) {
      case OAuthLoginType.google:
        if (email == null) return null;
        request = CheckUserRequest.google(
          userId: userId,
          orgId: orgId,
          name: name,
          walletSolana: walletSolana,
          walletEvm: walletEvm,
          email: email,
          inviteCode: verifiedInviteCode!,
        );
      case OAuthLoginType.x:
        // 从 Turnkey oauthProviders 里找 X/Twitter provider，subject 即 X 数字 user id
        final xProvider =
            turnkeyProvider.user?.oauthProviders.firstWhereOrNull((p) {
          final n = p.providerName.toLowerCase();
          return n == 'x' || n == 'twitter';
        });
        final socialId = xProvider?.subject;
        var socialName = name;
        request = CheckUserRequest.x(
          userId: userId,
          orgId: orgId,
          name: name,
          walletSolana: walletSolana,
          walletEvm: walletEvm,
          inviteCode: verifiedInviteCode,
          socialId: socialId,
          socialName: socialName,
        );
      case OAuthLoginType.apple:
        request = CheckUserRequest.apple(
          userId: userId,
          orgId: orgId,
          name: name,
          walletSolana: walletSolana,
          walletEvm: walletEvm,
          inviteCode: verifiedInviteCode!,
          email: email,
        );
    }

    logger.d('[_checkUser] payload=${request.toJson()}');
    var checkUserResponse =
        await injector<ManicAuthDataSource>().checkUser(request);
    logger.d('[_checkUser] response canLogin=${checkUserResponse.canLogin}');
    if (!checkUserResponse.canLogin) {
      throw UserNotFoundException(address: turnkeySolanaAccount.address);
    }
    return checkUserResponse;
  }

  void showNotWhitelisted() {
    setState(() {
      _showNotWhiteListed = true;
    });
  }
}
