import 'dart:convert';

import 'package:finality/common/utils/color_scheme_extensions.dart';
import 'package:finality/common/widgets/touchable.dart';
import 'package:finality/core/logger.dart';
import 'package:finality/env/app_secrets.dart';
import 'package:finality/env/env_config.dart';
import 'package:finality/features/login/widgets/top_logo_on_logo.dart';
import 'package:finality/features/login/web3_login_session.dart';
import 'package:finality/features/login/web3_wallet_authenticating_screen.dart';
import 'package:finality/generated/assets.dart';
import 'package:finality/services/appkit/appkit_deep_link_handler.dart';
import 'package:finality/theme/attrs/druk_wide_font.dart';
import 'package:finality/theme/attrs/text_color_theme.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:reown_appkit/reown_appkit.dart';

/// AppKit 配置常量
class _AppKitConfig {
  _AppKitConfig._();

  static const String projectId = AppSecrets.reownProjectId;
  static const String nativeScheme = 'manic-trade-app://';
  static const String universalLink = 'https://manic.trade/wc';
  static const String appName = 'Manic.Trade';
  static const String appDescription = 'the First Momentum-based Trading Platform on Solana';
  static const String appIconUrl = 'https://www.manic.trade/favicon.png';
  static const String appUrl = 'https://manic.trade';
}

/// 页面状态
enum _PageStatus {
  /// 正在初始化 AppKit
  initializing,

  /// 初始化完成，等待连接钱包
  readyToConnect,

  /// 初始化失败
  initFailed,

  /// 已连接钱包，等待选择账户
  connected,
}

/// 连接的账户信息
class _ConnectedAccount {
  final String namespace; // 'solana' 或 'eip155'
  final String address;
  final String
      chainId; // 完整的 chainId，如 "solana:5eykt4UsFv8P8NJdTREpY1vzqKqZKvdp"
  final String displayName; // 'Solana' 或 'Ethereum'
  final String iconAsset;

  const _ConnectedAccount({
    required this.namespace,
    required this.address,
    required this.chainId,
    required this.displayName,
    required this.iconAsset,
  });

  String get shortAddress {
    if (address.length <= 12) return address;
    return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
  }
}

class Web3WalletLoginScreen extends StatefulWidget {
  final String? verifiedInviteCode;
  const Web3WalletLoginScreen({super.key, this.verifiedInviteCode});

  @override
  State<Web3WalletLoginScreen> createState() => _Web3WalletLoginScreenState();
}

class _Web3WalletLoginScreenState extends State<Web3WalletLoginScreen> {
  /// AppKit 实例
  ReownAppKitModal? _appKitModal;

  /// 页面状态
  _PageStatus _pageStatus = _PageStatus.initializing;

  /// 初始化错误信息
  String? _initError;

  /// 是否正在初始化中（防止重复初始化）
  bool _initializing = false;

  /// 连接的账户列表
  List<_ConnectedAccount> _connectedAccounts = [];

  /// 选中的账户
  _ConnectedAccount? _selectedAccount;

  @override
  void initState() {
    super.initState();
    // 页面进入后立即初始化 AppKit
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAppKit();
    });
  }

  @override
  void dispose() {
    _removeListenersAndDispose();
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
                    _buildWalletIcon(),
                    Dimens.vGap32,
                    Text(
                      _pageStatus == _PageStatus.connected
                          ? 'SELECT ACCOUNT'
                          : 'CONNECT WALLET',
                      style: DrukWideFont.textStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: textColorTheme.textColorPrimary,
                        letterSpacing: 1.5,
                      ),
                    ),
                    Dimens.vGap12,
                    Text(
                      _pageStatus == _PageStatus.connected
                          ? 'Choose an account to sign in with.'
                          : 'Connect your wallet to get started.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: textColorTheme.textColorTertiary,
                          ),
                    ),
                    Dimens.vGap32,
                    // 根据状态显示不同内容
                    _buildMainContent(colorScheme, textColorTheme),
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

  Widget _buildMainContent(
      ColorScheme colorScheme, TextColorTheme textColorTheme) {
    switch (_pageStatus) {
      case _PageStatus.initializing:
        return _buildInitializingView(textColorTheme);
      case _PageStatus.readyToConnect:
        return _buildReadyToConnectView(colorScheme, textColorTheme);
      case _PageStatus.initFailed:
        return _buildInitFailedView(colorScheme, textColorTheme);
      case _PageStatus.connected:
        return _buildConnectedView(colorScheme, textColorTheme);
    }
  }

  /// 初始化中视图
  Widget _buildInitializingView(TextColorTheme textColorTheme) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: textColorTheme.textColorTertiary,
              ),
            ),
            Dimens.hGap8,
            Text(
              'Connecting to WalletConnect...',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: textColorTheme.textColorTertiary,
                  ),
            ),
          ],
        ),
      ],
    );
  }

  /// 准备连接视图
  Widget _buildReadyToConnectView(
      ColorScheme colorScheme, TextColorTheme textColorTheme) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 16,
              color: Colors.green,
            ),
            Dimens.hGap8,
            Text(
              'Ready to connect',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.green,
                  ),
            ),
          ],
        ),
        Dimens.vGap24,
        _buildButton(
          context: context,
          colorScheme: colorScheme,
          textColorTheme: textColorTheme,
          text: 'Connect Wallet',
          onTap: _openWalletSelector,
        ),
      ],
    );
  }

  /// 初始化失败视图
  Widget _buildInitFailedView(
      ColorScheme colorScheme, TextColorTheme textColorTheme) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 16,
              color: Colors.red,
            ),
            Dimens.hGap8,
            Flexible(
              child: Text(
                _initError ?? 'Connection failed',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.red,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        Dimens.vGap24,
        _buildButton(
          context: context,
          colorScheme: colorScheme,
          textColorTheme: textColorTheme,
          text: 'Retry Connection',
          onTap: _initializeAppKit,
        ),
      ],
    );
  }

  /// 已连接视图 - 显示账户列表
  Widget _buildConnectedView(
      ColorScheme colorScheme, TextColorTheme textColorTheme) {
    return Column(
      children: [
        // 账户列表
        ..._connectedAccounts.map((account) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildAccountOption(
                colorScheme: colorScheme,
                textColorTheme: textColorTheme,
                account: account,
              ),
            )),
        Dimens.vGap12,
        // Sign In 按钮
        _buildButton(
          context: context,
          colorScheme: colorScheme,
          textColorTheme: textColorTheme,
          text: _selectedAccount != null
              ? 'Sign In with ${_selectedAccount!.displayName}'
              : 'Select an account',
          enabled: _selectedAccount != null,
          onTap: _selectedAccount != null ? _handleSignIn : null,
        ),
        Dimens.vGap12,
        // 断开连接按钮
        Touchable.plain(
          onTap: _handleDisconnect,
          child: SizedBox(
            height: 40,
            child: Center(
              child: Text(
                'Disconnect',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: textColorTheme.textColorTertiary,
                      decoration: TextDecoration.underline,
                    ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 账户选项
  Widget _buildAccountOption({
    required ColorScheme colorScheme,
    required TextColorTheme textColorTheme,
    required _ConnectedAccount account,
  }) {
    final isSelected = _selectedAccount == account;
    return Touchable.plain(
      onTap: () {
        setState(() {
          _selectedAccount = account;
        });
      },
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.surfaceContainerHigh
              : colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color:
                isSelected ? colorScheme.primary : colorScheme.outlineVariant,
            width: isSelected ? 1.5 : 0.5,
          ),
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              account.iconAsset,
              width: 24,
              height: 24,
            ),
            Dimens.hGap12,
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    account.displayName,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: textColorTheme.textColorPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  Text(
                    account.shortAddress,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: textColorTheme.textColorTertiary,
                        ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                size: 20,
                color: colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }

  /// 通用按钮
  Widget _buildButton({
    required BuildContext context,
    required ColorScheme colorScheme,
    required TextColorTheme textColorTheme,
    required String text,
    bool enabled = true,
    VoidCallback? onTap,
  }) {
    return Touchable.button(
      onTap: enabled ? onTap : null,
      child: Container(
        height: 40,
        width: double.infinity,
        decoration: BoxDecoration(
          color: enabled
              ? colorScheme.surfaceContainerHigh
              : colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: colorScheme.outlineVariant, width: 0.5),
        ),
        child: Center(
          child: Text(
            text,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: enabled
                      ? textColorTheme.textColorTertiary
                      : textColorTheme.textColorTertiary.withOpacity(0.5),
                ),
          ),
        ),
      ),
    );
  }

  Widget _buildWalletIcon() {
    return TopLogoOnLogo(
      child: SvgPicture.asset(
        Assets.svgsIcWalletLogin,
        width: 28,
        height: 28,
      ),
    );
  }

  // ============ 业务逻辑 ============

  /// 初始化 AppKit
  Future<void> _initializeAppKit() async {
    if (_appKitModal != null) {
      await _removeListenersAndDispose();
    }

    _initializing = true;

    setState(() {
      _pageStatus = _PageStatus.initializing;
      _initError = null;
      _connectedAccounts = [];
      _selectedAccount = null;
    });

    try {
      _appKitModal = ReownAppKitModal(
        context: context,
        projectId: _AppKitConfig.projectId,
        logLevel: Env.isDebug ? LogLevel.all : LogLevel.error,
        metadata: _buildPairingMetadata(),
        // 同时支持 Solana 和 Ethereum
        optionalNamespaces: {
          'solana': RequiredNamespace.fromJson({
            'chains': ['solana:5eykt4UsFv8P8NJdTREpY1vzqKqZKvdp'],
            'methods': ['solana_signMessage'],
            'events': [],
          }),
          'eip155': RequiredNamespace.fromJson({
            'chains': ['eip155:1'],
            'methods': NetworkUtils.defaultNetworkMethods['eip155']!.toList(),
            'events': NetworkUtils.defaultNetworkEvents['eip155']!.toList(),
          }),
        },
        // 顺序即在钱包选择器中的展示优先级
        featuredWalletIds: {
          '0ef262ca2a56b88d179c93a21383fee4e135bd7bc6680e5c2356ff8e38301037', // Jupiter
          'a797aa35c0fadbfc1a53e7f675162ed5226968b44a19ee3d24385c64d1d3c393', // Phantom
          '1ca0bdd4747578705b1939af023d120677c64fe6ca76add81fda36e350605e79', // Solflare
          '5d9f1395b3a8e848684848dc4147cbd05c8d54bb737eac78fe103901fe6b01a1', // OKX Wallet
          '8a0ee50d1f22f6651afcae7eb4253e52a3310b90af5daef78a8c4929a9bb99d4', // Binance Wallet
          'c57ca95b47569778a828d19178114f4db188b89b763c899ba0be274e97267d96', // MetaMask
          '38f5d18bd8522c244bdd70cb4a68e0e718865155811c043f052fb9f1c51de662', // Bitget
        },
        // Coinbase Wallet 已改名 Base App，Reown 官方明确"Coinbase connector
        // will not work with Base Wallet"，连接路径已断，从列表里彻底隐藏避免误点。
        // 注意：不能用 const set，Reown 内部会回写合并默认排除列表。
        excludedWalletIds: {
          'fd20dc426fb37566d803205b19bbc1d4096b248ac04548e3cfb6b3a38bd033aa', // Coinbase / Base App
        },
        enableAnalytics: !Env.isDebug,
        disconnectOnDispose: false,
        featuresConfig: FeaturesConfig(
          email: false,
          socials: [],
          showMainWallets: true,
        ),
      );

      await _attachListenersAndInit();

      // 注册到 Deep Link 处理器
      AppKitDeepLinkHandler.setActiveAppKitModal(_appKitModal);

      _initializing = false;

      // 检查是否已有连接的 session
      if (_appKitModal!.isConnected && _appKitModal!.session != null) {
        _handleSessionConnected(_appKitModal!.session!);
      } else {
        if (mounted) {
          setState(() {
            _pageStatus = _PageStatus.readyToConnect;
          });
        }
      }

      logger.i('Web3WalletLoginScreen: AppKit initialized successfully');
    } catch (e, stackTrace) {
      logger.e('Web3WalletLoginScreen: Failed to initialize AppKit',
          error: e, stackTrace: stackTrace);
      _initializing = false;
      if (mounted) {
        setState(() {
          _pageStatus = _PageStatus.initFailed;
          _initError = e.toString();
        });
      }
    }
  }

  /// 打开钱包选择弹窗
  Future<void> _openWalletSelector() async {
    if (_appKitModal == null || _pageStatus != _PageStatus.readyToConnect) {
      return;
    }

    try {
      await _appKitModal!.openModalView(ReownAppKitModalMainWalletsPage());
    } catch (e, stackTrace) {
      logger.e('Web3WalletLoginScreen: Failed to open wallet selector',
          error: e, stackTrace: stackTrace);
      Fluttertoast.showToast(msg: 'Failed to open wallet selector');
    }
  }

  /// 处理 session 连接成功
  void _handleSessionConnected(ReownAppKitModalSession session) {
    final namespaces = session.namespaces;
    final accounts = <_ConnectedAccount>[];

    logger.d('Web3WalletLoginScreen: Session namespaces: $namespaces');

    // 解析 Solana 账户
    if (namespaces?.containsKey('solana') == true) {
      final solanaAccounts = namespaces!['solana']!.accounts;
      if (solanaAccounts.isNotEmpty) {
        // 格式: "solana:5eykt4UsFv8P8NJdTREpY1vzqKqZKvdp:地址"
        final fullAccount = solanaAccounts.first;
        final parts = fullAccount.split(':');
        final address = parts.last;
        // chainId 格式: "solana:5eykt4UsFv8P8NJdTREpY1vzqKqZKvdp"
        final chainId = parts.length >= 2
            ? '${parts[0]}:${parts[1]}'
            : 'solana:5eykt4UsFv8P8NJdTREpY1vzqKqZKvdp';
        accounts.add(_ConnectedAccount(
          namespace: 'solana',
          address: address,
          chainId: chainId,
          displayName: 'Solana',
          iconAsset: Assets.svgsIcConnectWalletSol,
        ));
      }
    }

    // 解析 Ethereum 账户
    if (namespaces?.containsKey('eip155') == true) {
      final ethAccounts = namespaces!['eip155']!.accounts;
      if (ethAccounts.isNotEmpty) {
        // 格式: "eip155:1:地址"
        final fullAccount = ethAccounts.first;
        final parts = fullAccount.split(':');
        final address = parts.last;
        // chainId 格式: "eip155:1"
        final chainId =
            parts.length >= 2 ? '${parts[0]}:${parts[1]}' : 'eip155:1';
        accounts.add(_ConnectedAccount(
          namespace: 'eip155',
          address: address,
          chainId: chainId,
          displayName: 'Ethereum',
          iconAsset: Assets.svgsIcConnectWalletEth,
        ));
      }
    }

    if (accounts.isEmpty) {
      logger.w('Web3WalletLoginScreen: No accounts found in session');
      Fluttertoast.showToast(msg: 'No accounts found');
      return;
    }

    if (mounted) {
      setState(() {
        _connectedAccounts = accounts;
        // 如果只有一个账户，自动选中
        _selectedAccount = accounts.length == 1 ? accounts.first : null;
        _pageStatus = _PageStatus.connected;
      });
    }
  }

  /// 处理 Sign In
  Future<void> _handleSignIn() async {
    if (_selectedAccount == null || _appKitModal == null) return;
    final networkInfo = ReownAppKitModalNetworks.getNetworkInfo(
      _selectedAccount!.namespace,
      _selectedAccount!.chainId,
    );
    if (networkInfo != null) {
      _appKitModal!.selectChain(networkInfo);
    }

    // 将 appKitModal 所有权转移给 Web3LoginSession
    // 认证页面通过 session 访问，并负责最终 dispose
    _transferAppKitModalOwnership();

    // 跳转到认证页面，并等待返回
    await Get.to(() => Web3WalletAuthenticatingScreen(
          verifiedInviteCode: widget.verifiedInviteCode,
        ));

    // 从认证页返回：
    //   - 若 session 仍存在（用户中途返回，认证未完成）→ 取回 appKitModal 复用
    //   - 若 session 已被销毁（认证流程已结束）→ 重新初始化
    if (!mounted) return;
    await _reclaimOrReinitAppKit();
  }

  /// 从认证页返回后，决定是 reclaim 已有 appKitModal 还是重新初始化
  Future<void> _reclaimOrReinitAppKit() async {
    final reclaimed = Web3LoginSession.release();
    if (reclaimed == null) {
      // session 已被销毁，appKitModal 不可复用，重新走完整初始化流程
      await _initializeAppKit();
      return;
    }

    // 取回 appKitModal 所有权，重新订阅本页面的 listener（无需再 init）
    _appKitModal = reclaimed;
    AppKitDeepLinkHandler.setActiveAppKitModal(_appKitModal);
    _attachListeners();

    if (!mounted) return;
    if (_appKitModal!.isConnected && _appKitModal!.session != null) {
      _handleSessionConnected(_appKitModal!.session!);
    } else {
      // 用户在认证页可能 disconnect 过，回到等待连接状态
      setState(() {
        _connectedAccounts = [];
        _selectedAccount = null;
        _pageStatus = _PageStatus.readyToConnect;
      });
    }
  }

  /// 将 appKitModal 所有权转移给 Web3LoginSession
  /// 取消本页面的 listener 并释放引用，避免 dispose 时重复清理
  void _transferAppKitModalOwnership() {
    if (_appKitModal == null || _selectedAccount == null) return;

    // 创建共享会话，认证页面通过它访问 appKitModal
    Web3LoginSession.start(
      appKitModal: _appKitModal!,
      walletAddress: _selectedAccount!.address,
      namespace: _selectedAccount!.namespace,
      chainId: _selectedAccount!.chainId,
    );

    // 取消本页面的所有 listener
    _appKitModal!.appKit!.core.removeLogListener(_logListener);
    _appKitModal!.appKit!.core.relayClient.onRelayClientConnect
        .unsubscribe(_onRelayClientConnect);
    _appKitModal!.appKit!.core.relayClient.onRelayClientError
        .unsubscribe(_onRelayClientError);
    _appKitModal!.appKit!.core.relayClient.onRelayClientDisconnect
        .unsubscribe(_onRelayClientDisconnect);
    _appKitModal!.onModalConnect.unsubscribe(_onModalConnect);
    _appKitModal!.onModalUpdate.unsubscribe(_onModalUpdate);
    _appKitModal!.onModalNetworkChange.unsubscribe(_onModalNetworkChange);
    _appKitModal!.onModalDisconnect.unsubscribe(_onModalDisconnect);
    _appKitModal!.onModalError.unsubscribe(_onModalError);
    _appKitModal!.onSessionExpireEvent.unsubscribe(_onSessionExpired);
    _appKitModal!.onSessionUpdateEvent.unsubscribe(_onSessionUpdate);
    _appKitModal!.onSessionEventEvent.unsubscribe(_onSessionEvent);
    _appKitModal!.appKit!.core.connectivity.isOnline
        .removeListener(_connectivity);

    // 释放引用，本页面不再管理此 appKitModal
    _appKitModal = null;
  }

  /// 处理断开连接
  Future<void> _handleDisconnect() async {
    try {
      await _appKitModal?.disconnect();
    } catch (e) {
      logger.w('Web3WalletLoginScreen: disconnect error (ignored)', error: e);
    }

    if (mounted) {
      setState(() {
        _connectedAccounts = [];
        _selectedAccount = null;
        _pageStatus = _PageStatus.readyToConnect;
      });
    }
  }

  PairingMetadata _buildPairingMetadata() {
    return PairingMetadata(
      name: _AppKitConfig.appName,
      description: _AppKitConfig.appDescription,
      url: _AppKitConfig.appUrl,
      icons: [_AppKitConfig.appIconUrl],
      redirect: Redirect(
        native: _AppKitConfig.nativeScheme,
        universal: _AppKitConfig.universalLink,
        linkMode: true,
      ),
    );
  }

  // ============ AppKit 事件监听 ============

  /// 仅订阅 listener，不调用 init（reclaim 场景复用已经初始化过的 appKitModal）
  void _attachListeners() {
    _appKitModal!.appKit!.core.addLogListener(_logListener);
    _appKitModal!.onModalConnect.subscribe(_onModalConnect);
    _appKitModal!.onModalUpdate.subscribe(_onModalUpdate);
    _appKitModal!.onModalNetworkChange.subscribe(_onModalNetworkChange);
    _appKitModal!.onModalDisconnect.subscribe(_onModalDisconnect);
    _appKitModal!.onModalError.subscribe(_onModalError);
    _appKitModal!.onSessionExpireEvent.subscribe(_onSessionExpired);
    _appKitModal!.onSessionUpdateEvent.subscribe(_onSessionUpdate);
    _appKitModal!.onSessionEventEvent.subscribe(_onSessionEvent);
    _appKitModal!.appKit!.core.relayClient.onRelayClientConnect
        .subscribe(_onRelayClientConnect);
    _appKitModal!.appKit!.core.relayClient.onRelayClientError
        .subscribe(_onRelayClientError);
    _appKitModal!.appKit!.core.relayClient.onRelayClientDisconnect
        .subscribe(_onRelayClientDisconnect);
    _appKitModal!.appKit!.core.connectivity.isOnline.addListener(_connectivity);
  }

  Future<void> _attachListenersAndInit() async {
    _attachListeners();
    await _appKitModal!.init();
  }

  Future<void> _removeListenersAndDispose() async {
    if (_appKitModal == null) return;

    AppKitDeepLinkHandler.setActiveAppKitModal(null);

    _appKitModal!.appKit!.core.removeLogListener(_logListener);
    _appKitModal!.appKit!.core.relayClient.onRelayClientConnect
        .unsubscribe(_onRelayClientConnect);
    _appKitModal!.appKit!.core.relayClient.onRelayClientError
        .unsubscribe(_onRelayClientError);
    _appKitModal!.appKit!.core.relayClient.onRelayClientDisconnect
        .unsubscribe(_onRelayClientDisconnect);
    _appKitModal!.onModalConnect.unsubscribe(_onModalConnect);
    _appKitModal!.onModalUpdate.unsubscribe(_onModalUpdate);
    _appKitModal!.onModalNetworkChange.unsubscribe(_onModalNetworkChange);
    _appKitModal!.onModalDisconnect.unsubscribe(_onModalDisconnect);
    _appKitModal!.onModalError.unsubscribe(_onModalError);
    _appKitModal!.onSessionExpireEvent.unsubscribe(_onSessionExpired);
    _appKitModal!.onSessionUpdateEvent.unsubscribe(_onSessionUpdate);
    _appKitModal!.onSessionEventEvent.unsubscribe(_onSessionEvent);
    _appKitModal!.appKit!.core.connectivity.isOnline
        .removeListener(_connectivity);

    await _appKitModal!.dispose();
    _appKitModal = null;
  }

  void _logListener(String event) {
    debugPrint('[AppKit] $event');
  }

  void _connectivity() async {
    if (_appKitModal == null) return;

    final connected = _appKitModal!.appKit!.core.connectivity.isOnline.value;
    if (connected && !_appKitModal!.status.isInitialized && !_initializing) {
      logger.d('Web3WalletLoginScreen: Network reconnected, reinitializing...');
      _initializing = true;
      await _removeListenersAndDispose();
      await _initializeAppKit();
    }
  }

  void _onModalConnect(ModalConnect? event) {
    logger.d(
        'Web3WalletLoginScreen: _onModalConnect ${jsonEncode(event?.session.toJson())}');
    if (event?.session != null) {
      _handleSessionConnected(event!.session);
    }
  }

  void _onModalUpdate(ModalConnect? event) {
    logger.d('Web3WalletLoginScreen: _onModalUpdate');
    // 如果 session 更新了，重新解析账户
    if (event?.session != null && _pageStatus == _PageStatus.connected) {
      _handleSessionConnected(event!.session);
    }
  }

  void _onModalNetworkChange(ModalNetworkChange? event) {
    logger
        .d('Web3WalletLoginScreen: _onModalNetworkChange ${event?.toString()}');
  }

  void _onModalDisconnect(ModalDisconnect? event) {
    logger.d('Web3WalletLoginScreen: _onModalDisconnect');
    if (mounted) {
      setState(() {
        _connectedAccounts = [];
        _selectedAccount = null;
        _pageStatus = _PageStatus.readyToConnect;
      });
    }
  }

  void _onModalError(ModalError? event) {
    logger.e('Web3WalletLoginScreen: _onModalError ${event?.message}');
    if (event?.message.isNotEmpty == true) {
      Fluttertoast.showToast(msg: event!.message);
    }
  }

  void _onSessionExpired(SessionExpire? event) {
    logger.d('Web3WalletLoginScreen: _onSessionExpired');
    _handleDisconnect();
  }

  void _onSessionUpdate(SessionUpdate? event) {
    logger.d('Web3WalletLoginScreen: _onSessionUpdate');
    // Session 更新时，如果当前是已连接状态，重新获取账户
    if (_appKitModal?.session != null &&
        _pageStatus != _PageStatus.initializing) {
      _handleSessionConnected(_appKitModal!.session!);
    }
  }

  void _onSessionEvent(SessionEvent? event) {
    logger.d('Web3WalletLoginScreen: _onSessionEvent ${event?.name}');
  }

  void _onRelayClientConnect(EventArgs? event) {
    logger.d('Web3WalletLoginScreen: Relay connected');
  }

  void _onRelayClientError(ErrorEvent? event) {
    logger.e('Web3WalletLoginScreen: Relay error - ${event?.error}');
  }

  void _onRelayClientDisconnect(EventArgs? event) {
    logger.d('Web3WalletLoginScreen: Relay disconnected');
  }
}
