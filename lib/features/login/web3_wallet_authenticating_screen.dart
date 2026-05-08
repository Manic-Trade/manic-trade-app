import 'dart:async';

import 'package:finality/common/utils/color_scheme_extensions.dart';
import 'package:finality/common/widgets/touchable.dart';
import 'package:finality/core/error/exception_handler.dart';
import 'package:finality/core/logger.dart';
import 'package:finality/core/state/ui_state.dart';
import 'package:finality/data/network/manic_auth_data_source.dart';
import 'package:finality/data/network/model/manic/check_user_request.dart';
import 'package:finality/di/injector.dart';
import 'package:finality/domain/auth/auth_exceptions.dart';
import 'package:finality/domain/auth/auth_session_coordinator.dart';
import 'package:finality/domain/auth/wallet_auth_manager.dart';
import 'package:finality/features/login/web3_login_session.dart';
import 'package:finality/features/login/widgets/not_white_listed_layout.dart';
import 'package:finality/features/login/widgets/top_logo_on_logo.dart';
import 'package:finality/generated/assets.dart';
import 'package:finality/routes/app_pages.dart';
import 'package:finality/services/appkit/appkit_ethereum_wallet.dart';
import 'package:finality/services/appkit/appkit_solana_wallet.dart';
import 'package:finality/services/turnkey/turnkey_manager.dart';
import 'package:finality/services/turnkey/turnkey_wallet_sync_service.dart';
import 'package:finality/services/turnkey/turnkey_wallet_utils.dart';
import 'package:finality/theme/app_color_theme.dart';
import 'package:finality/theme/attrs/druk_wide_font.dart';
import 'package:finality/theme/attrs/text_color_theme.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:turnkey_sdk_flutter/turnkey_sdk_flutter.dart';

/// Web3 钱包认证页面
///
/// 用于处理使用外部 Web3 钱包（如 Phantom）登录 Turnkey 的流程：
/// 1. 使用外部钱包签名登录 Turnkey
/// 2. Turnkey 创建/获取托管钱包
/// 3. 使用 Turnkey 托管钱包签名登录我们的服务端
class Web3WalletAuthenticatingScreen extends StatefulWidget {
  final String? verifiedInviteCode;

  const Web3WalletAuthenticatingScreen({
    super.key,
    this.verifiedInviteCode,
  });

  @override
  State<Web3WalletAuthenticatingScreen> createState() =>
      _Web3WalletAuthenticatingScreenState();
}

/// 钱包"未呼出"的短超时。
///
/// 调起外部钱包成功 → 本 app 会进入 paused/inactive 生命周期。
/// 若超过此时长仍未离开前台，视为钱包根本没被呼出
/// （未安装、scheme 未注册、用户拒绝跳转等），直接失败让用户尽快重试。
const Duration _kWalletLaunchTimeout = Duration(seconds: 10);

/// 钱包签名步骤的整体超时。
///
/// 钱包已呼出但用户未在钱包内确认签名（或确认后从未返回 app）的兜底，
/// 防止 UI 一直卡在 loading。
const Duration _kWalletAuthTimeout = Duration(seconds: 90);

/// app 从后台切回前台后的"宽限期"。
///
/// 用户从钱包返回 app 时，签名结果可能仍在被 SDK 通过 deeplink 处理；
/// 给一个短暂的 grace 让正常流程完成，超过此时间还没收到结果则视为用户取消。
const Duration _kResumeGracePeriod = Duration(seconds: 8);

/// 钱包未被呼出（未检测到 app 切到后台）专用异常，用于跟普通超时区分错误提示。
class _WalletLaunchTimeoutException implements Exception {
  const _WalletLaunchTimeoutException();
  @override
  String toString() => 'Wallet app was not launched';
}

/// 用户从钱包返回 app 但未完成签名（取消 / 拒绝 / 关闭钱包）专用异常。
class _WalletAuthCancelledException implements Exception {
  const _WalletAuthCancelledException();
  @override
  String toString() => 'Wallet auth cancelled';
}

class _Web3WalletAuthenticatingScreenState
    extends State<Web3WalletAuthenticatingScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _progressController;

  /// 当前认证流程中是否检测到 app 离开前台（== 钱包被成功呼出）
  bool _appPausedDuringAuth = false;

  /// 短超时定时器：监督钱包是否成功呼出
  Timer? _walletLaunchWatchdog;

  /// app 从后台返回前台后的 grace 定时器：grace 内仍未拿到签名结果则视为用户取消
  Timer? _resumeGraceTimer;

  /// 取消当前认证流程的回调（由 [_runWalletAuthWithTimeouts] 注册，
  /// 用户点击 Stop 按钮时调用，以 [_WalletAuthCancelledException] 终结流程）
  VoidCallback? _onAuthCancelled;

  /// grace 时间到后展示 Stop 按钮，让用户主动结束已经卡住的签名流程
  bool _canCancel = false;

  late final _turnkeyWalletSyncService = injector<TurnkeyWalletSyncService>();
  late final turnkeyManager = injector<TurnkeyManager>();
  late final _session = Web3LoginSession.current!;
  UiState<void> _uiState = UiState.loading();

  bool _showNotWhiteListed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _startAuthentication();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _walletLaunchWatchdog?.cancel();
    _resumeGraceTimer?.cancel();
    _progressController.dispose();
    Web3LoginSession.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      // 离开前台 == 钱包 app 被成功呼出，并取消可能存在的 grace
      _appPausedDuringAuth = true;
      _resumeGraceTimer?.cancel();
      _resumeGraceTimer = null;
      return;
    }
    // 回到前台：若之前切走过（钱包呼出过），启动 grace。
    // grace 到期后不直接判错，而是显示 Stop 按钮，让用户自己决定要不要取消。
    if (_appPausedDuringAuth) {
      _resumeGraceTimer?.cancel();
      _resumeGraceTimer = Timer(_kResumeGracePeriod, () {
        if (mounted && _uiState.isLoading && _onAuthCancelled != null) {
          setState(() {
            _canCancel = true;
          });
        }
      });
    }
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
                _buildWalletIcon(colorScheme),
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
                  'with Web3 Wallet...',
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: textColorTheme.textColorTertiary,
                  ),
                ),
                Dimens.vGap8,
                Text(
                  _formatAddress(_session.walletAddress),
                  style: context.textTheme.bodySmall?.copyWith(
                    color: textColorTheme.textColorHelper,
                    fontFamily: 'monospace',
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

  Widget _buildWalletIcon(ColorScheme colorScheme) {
    return TopLogoOnLogo(
      child: SvgPicture.asset(
        Assets.svgsIcWalletLogin,
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
            'Please approve the signature request in your wallet.',
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.textColorTheme.textColorHelper,
            ),
          ),
          if (_canCancel) ...[
            Dimens.vGap16,
            Touchable.button(
              onTap: () => _onAuthCancelled?.call(),
              child: Container(
                height: 40,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: context.colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                      color: context.colorScheme.outlineVariant, width: 0.5),
                ),
                child: Center(
                  child: Text(
                    'Stop',
                    style: context.textTheme.labelMedium?.copyWith(
                      color: context.textColorTheme.textColorTertiary,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      );
    } else {
      return Column(
        children: [
          Text(
            'Authentication failed. Try again, or reconnect your wallet if it keeps failing.',
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.appColors.bearish,
            ),
          ),
          Dimens.vGap16,
          Touchable.button(
            onTap: _startAuthentication,
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
          Dimens.vGap16,
          // 重连入口：当 session 已 stale（如 SDK 返回 empty result）时，
          // Try Again 还会再失败，引导用户走 disconnect → 重新连接钱包流程
          Touchable.plain(
            onTap: _handleReconnect,
            child: SizedBox(
              height: 40,
              child: Center(
                child: Text(
                  'Reconnect Wallet',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.textColorTheme.textColorTertiary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }
  }

  /// 重新连接钱包：断开当前 stale session，跳回 LoginScreen
  /// LoginScreen 的 reclaim 会发现 isConnected=false 自动进入 readyToConnect 状态
  Future<void> _handleReconnect() async {
    try {
      await _session.appKitModal.disconnect();
    } catch (e, s) {
      logger.w('Web3WalletAuthenticatingScreen: disconnect on reconnect failed',
          error: e, stackTrace: s);
    }
    if (mounted) Navigator.of(context).pop();
  }

  Widget _buildProgressBar(ColorScheme colorScheme) {
    const double indicatorWidth = 104;
    return AnimatedBuilder(
      animation: _progressController,
      builder: (context, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final trackWidth = constraints.maxWidth;
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

  /// 用两层超时包装钱包签名调用：
  ///   - 短超时（[_kWalletLaunchTimeout]）：5s 内 app 必须切到后台，否则视为
  ///     钱包未被呼出（抛 [_WalletLaunchTimeoutException]）
  ///   - 长超时（[_kWalletAuthTimeout]）：整体兜底超时（抛 [TimeoutException]）
  ///
  /// 注意：超时后原 [operation] future 不会被真正取消，其后续结果会被丢弃。
  Future<T> _runWalletAuthWithTimeouts<T>(Future<T> Function() operation) {
    _appPausedDuringAuth = false;
    _walletLaunchWatchdog?.cancel();
    _resumeGraceTimer?.cancel();
    _resumeGraceTimer = null;
    if (_canCancel) {
      _canCancel = false;
    }

    final completer = Completer<T>();
    operation().then(
      (value) {
        if (!completer.isCompleted) completer.complete(value);
      },
      onError: (Object error, StackTrace stackTrace) {
        if (!completer.isCompleted) completer.completeError(error, stackTrace);
      },
    );

    _walletLaunchWatchdog = Timer(_kWalletLaunchTimeout, () {
      if (!_appPausedDuringAuth && !completer.isCompleted) {
        completer.completeError(const _WalletLaunchTimeoutException());
      }
    });

    // 注册取消回调：grace 触发时若 future 仍未完成则以"已取消"终结
    _onAuthCancelled = () {
      if (!completer.isCompleted) {
        completer.completeError(const _WalletAuthCancelledException());
      }
    };

    return completer.future.timeout(_kWalletAuthTimeout).whenComplete(() {
      _walletLaunchWatchdog?.cancel();
      _walletLaunchWatchdog = null;
      _resumeGraceTimer?.cancel();
      _resumeGraceTimer = null;
      _onAuthCancelled = null;
      if (mounted && _canCancel) {
        setState(() {
          _canCancel = false;
        });
      } else {
        _canCancel = false;
      }
    });
  }

  /// 开始认证流程
  Future<void> _startAuthentication() async {
    if (!_uiState.isLoading) {
      setState(() {
        _uiState = UiState.loading();
      });
    }

    try {
      // 必须先确保 TurnkeyProvider 初始化完成（Hive 等依赖就绪），
      // 再清理旧 session，否则 clearAllSessions 可能因 Hive 未就绪而失败
      await turnkeyManager.ensureInitialized();
      await turnkeyManager.clearAllSessions();

      // 1. 根据 namespace 创建对应的钱包实例
      final wallet = _createWalletForNamespace();

      // 2. 使用外部钱包登录/注册 Turnkey
      // 涉及钱包 app 跳转 + 用户签名，iOS 上若未呼出钱包 / 用户立即返回 / 未确认签名
      // 都会让 future 一直 pending。这里用两层超时：
      //   - 短超时：5s 内 app 必须切到后台（== 钱包被成功呼出），否则视为没呼出
      //   - 长超时：整体 90s 兜底，防止呼出后用户始终未确认
      logger.d(
          'Web3WalletAuthenticatingScreen: Starting Turnkey auth with ${_session.namespace} wallet...');
      final result = await _runWalletAuthWithTimeouts(
        () => turnkeyManager.loginOrSignUpWithWallet(wallet: wallet),
      );
      logger.d(
          'Web3WalletAuthenticatingScreen: Turnkey auth result: ${result.publicKey}');

      // 埋点：Turnkey 登录成功（钱包登录传 connected wallet 地址）
      final tkUser = turnkeyManager.user;

      logger.d(
          'Web3WalletAuthenticatingScreen: Turnkey auth completed, action: ${result.action}');

      // 验证 session 和 stamper key pair 状态
      final session = turnkeyManager.session;
      logger.d(
          'Web3WalletAuthenticatingScreen: session publicKey=${session?.publicKey}, '
          'authState=${turnkeyManager.authState}');

      // 3. 登录我们自己的服务端
      await _loginManicTrade(turnkeyManager);

      // 4. 跳转到主页
      if (mounted) {
        Get.offAllNamed(Routes.main);
      }
    } on UserNotFoundException {
      // 用户不在白名单
      if (mounted) showNotWhitelisted();
    } on _WalletLaunchTimeoutException catch (error, stackTrace) {
      // 短超时：未检测到 app 切到后台，视为钱包未被呼出
      logger.w('Web3WalletAuthenticatingScreen: wallet app was not launched',
          error: error, stackTrace: stackTrace);
      if (!mounted) return;
      setState(() {
        _uiState = UiState.failure(error);
      });
      Fluttertoast.showToast(
          msg:
              'Could not open your wallet app. Make sure it is installed and try again.');
    } on _WalletAuthCancelledException catch (error, stackTrace) {
      // app 已从钱包返回前台，但 grace 内仍未拿到签名结果 → 视为用户取消
      logger.w('Web3WalletAuthenticatingScreen: wallet auth cancelled by user',
          error: error, stackTrace: stackTrace);
      if (!mounted) return;
      setState(() {
        _uiState = UiState.failure(error);
      });
      Fluttertoast.showToast(
          msg: 'Authentication cancelled. Tap Try Again to retry.');
    } on TimeoutException catch (error, stackTrace) {
      // 长超时：钱包已呼出但用户始终未确认签名
      logger.w('Web3WalletAuthenticatingScreen: wallet auth timed out',
          error: error, stackTrace: stackTrace);
      if (!mounted) return;
      setState(() {
        _uiState = UiState.failure(error);
      });
      Fluttertoast.showToast(
          msg:
              'Wallet did not respond. Please confirm in your wallet and try again.');
    } catch (error, stackTrace) {
      // 埋点：Manic 服务器登录失败
      setState(() {
        _uiState = UiState.failure(error);
      });
      _handleAuthError(error, stackTrace);
    }
  }

  /// 根据 namespace 创建对应的钱包实例
  WalletInterface _createWalletForNamespace() {
    switch (_session.namespace) {
      case 'solana':
        return AppKitSolanaWallet(
          appKitModal: _session.appKitModal,
          walletAddress: _session.walletAddress,
          chainId: _session.chainId,
        );
      case 'eip155':
        return AppKitEthereumWallet(
          appKitModal: _session.appKitModal,
          walletAddress: _session.walletAddress,
          chainId: _session.chainId,
        );
      default:
        throw UnsupportedError(
            'Unsupported namespace: ${_session.namespace}. Only "solana" and "eip155" are supported.');
    }
  }

  /// 登录 Manic Trade 服务端
  Future<void> _loginManicTrade(TurnkeyManager turnkeyManager) async {
    await _turnkeyWalletSyncService.readyTurnkeyProvider();

    var manicTradeWallet =
        TurnkeyWalletUtils.findManicTradeWallet(turnkeyManager);
    if (manicTradeWallet == null) {
      // 刷新一次后重试
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

    // 1. 检查用户（绑定邀请码）
    if (widget.verifiedInviteCode != null) {
      await _checkUser(
          widget.verifiedInviteCode!, turnkeySolanaAccount, turnkeyManager);
    }

    // 2. 登录我们自己的服务器
    await injector<WalletAuthManager>()
        .loginTurnkeyWallet(turnkeySolanaAccount);

    // 埋点：Manic 服务器登录成功

    // 3. 收尾：设置 userId、写入外部钱包地址、同步钱包、埋点 identify
    await injector<AuthSessionCoordinator>().finalizeTurnkeyLogin(
      TurnkeyLoginResult(
        userId: turnkeyManager.user!.userId,
        tradeWalletAddress: turnkeySolanaAccount.address,
        loginWalletAddress: _session.walletAddress,
      ),
    );
  }

  Future<void> _checkUser(
      String verifiedInviteCode,
      v1WalletAccount turnkeySolanaAccount,
      TurnkeyManager turnkeyProvider) async {
    var userId = turnkeyProvider.user?.userId;
    var orgId = turnkeyProvider.session?.organizationId;
    var name = turnkeyProvider.user?.userName;

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
      return;
    }

    var checkUserResponse = await injector<ManicAuthDataSource>().checkUser(
        CheckUserRequest.wallet(
            userId: userId,
            orgId: orgId,
            name: name,
            walletSolana: walletSolana,
            walletEvm: walletEvm,
            wallet: _session.walletAddress,
            inviteCode: verifiedInviteCode));
    if (!checkUserResponse.canLogin) {
      throw UserNotFoundException(address: turnkeySolanaAccount.address);
    }
  }

  void _handleAuthError(dynamic error, [StackTrace? stackTrace]) {
    logger.e('Web3 wallet auth failed', error: error, stackTrace: stackTrace);
    if (!mounted) return;
    final message = ErrorHandler.getMessage(context, error);
    Fluttertoast.showToast(msg: message);
  }

  void showNotWhitelisted() {
    setState(() {
      _showNotWhiteListed = true;
    });
  }

  /// 格式化钱包地址显示
  String _formatAddress(String address) {
    if (address.length <= 12) return address;
    return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
  }
}
