import 'package:finality/common/utils/color_scheme_extensions.dart';
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
import 'package:finality/features/login/access_restricted_screen.dart';
import 'package:finality/features/login/widgets/top_logo_on_logo.dart';
import 'package:finality/generated/assets.dart';
import 'package:finality/routes/app_pages.dart';
import 'package:finality/services/mwa/mwa_solana_wallet.dart';
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
import 'package:solana/base58.dart';
import 'package:solana_mobile_client/solana_mobile_client.dart';
import 'package:turnkey_sdk_flutter/turnkey_sdk_flutter.dart';

/// # MWA Wallet Login Screen
///
/// Demonstrates how to use the **Solana Mobile Wallet Adapter (MWA)** protocol
/// (`solana_mobile_client` package) to authenticate users via a locally
/// installed Solana wallet app (e.g. Phantom, Solflare).
///
/// ## What is MWA?
///
/// Mobile Wallet Adapter is part of the **Solana Mobile Stack (SMS)**. Unlike
/// browser-based dApps that use wallet-standard browser extensions, mobile dApps
/// need a different mechanism to communicate with wallet apps on the same device.
/// MWA establishes a **local association session** between your dApp and the
/// wallet app over a local transport (no network required).
///
/// ## Authentication Flow Overview
///
/// ```
///  ┌──────────┐   MWA Session    ┌──────────────┐
///  │  dApp    │ ◄──────────────► │ Wallet App   │
///  │ (this)   │   authorize()    │ (e.g. Phantom│)
///  └────┬─────┘                  └──────────────┘
///       │
///       │  wallet public key
///       ▼
///  ┌──────────┐   signMessage()  ┌──────────────┐
///  │ Turnkey  │ ◄──────────────► │ Wallet App   │
///  │  Auth    │   (via MWA)      │              │
///  └────┬─────┘                  └──────────────┘
///       │
///       │  Turnkey session + custodial wallet
///       ▼
///  ┌──────────┐
///  │  Manic   │   JWT login
///  │  Server  │
///  └──────────┘
/// ```
///
/// ### Step-by-step:
/// 1. **Check availability** – Verify a compatible wallet app is installed.
/// 2. **Create local session** – `LocalAssociationScenario.create()` sets up
///    the MWA transport layer.
/// 3. **Start activity** – Launch the wallet app's authorization UI.
/// 4. **Authorize** – Request permission to access the user's public key.
/// 5. **Sign message** – Use the wallet to sign a Turnkey authentication payload.
/// 6. **Close session** – Release the MWA connection.
/// 7. **Backend login** – Authenticate with the Manic Trade server using Turnkey
///    custodial wallet credentials.
///
/// ## Key Dependencies
///
/// - `solana_mobile_client` – Dart bindings for the MWA protocol
/// - `solana` (base58) – Base58 encoding for Solana addresses
/// - `turnkey_sdk_flutter` – Turnkey wallet-as-a-service for custodial wallets
class MwaWalletLoginScreen extends StatefulWidget {
  /// Optional pre-verified invite code for whitelist gating.
  final String? verifiedInviteCode;

  const MwaWalletLoginScreen({super.key, this.verifiedInviteCode});

  @override
  State<MwaWalletLoginScreen> createState() => _MwaWalletLoginScreenState();
}

class _MwaWalletLoginScreenState extends State<MwaWalletLoginScreen> {
  // -- Dependencies ----------------------------------------------------------

  late final _turnkeyManager = injector<TurnkeyManager>();
  late final _turnkeyWalletSyncService = injector<TurnkeyWalletSyncService>();

  // -- State -----------------------------------------------------------------

  /// Tracks the current screen state: initial → loading → success / failure.
  UiState _uiState = UiState.initial();

  // ==========================================================================
  // UI
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    final textColorTheme = context.textColorTheme;
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
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
        final topOffset = constraints.maxHeight * 0.27;
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
                    TopLogoOnLogo(
                      child: SvgPicture.asset(
                        Assets.svgsIcWalletLogin,
                        width: 28,
                        height: 28,
                      ),
                    ),
                    Dimens.vGap32,
                    Text(
                      'CONNECT WALLET',
                      style: DrukWideFont.textStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: textColorTheme.textColorPrimary,
                        letterSpacing: 1.5,
                      ),
                    ),
                    Dimens.vGap12,
                    Text(
                      'Connect your Solana wallet to sign in.',
                      textAlign: TextAlign.center,
                      style: context.textTheme.bodyLarge?.copyWith(
                        color: textColorTheme.textColorTertiary,
                      ),
                    ),
                    Dimens.vGap32,
                    _buildContent(context),
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

  /// Renders the appropriate widget based on the current [UiState]:
  /// - **initial**: show the "Connect" button
  /// - **loading**: show a spinner while waiting for wallet approval
  /// - **failure**: show an error message with a retry button
  /// - **success**: empty (navigation already handled)
  Widget _buildContent(BuildContext context) {
    return _uiState.buildWidget(
      onInitial: (_) => _buildConnectButton(context),
      onLoading: (_) => _buildLoadingView(context),
      onFailure: (f) => _buildErrorView(context, f.throwable ?? Exception('Unknown error')),
      onSuccess: (_) => const SizedBox.shrink(),
    );
  }

  Widget _buildConnectButton(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Touchable.button(
      onTap: _connectWallet,
      child: SizedBox(
        width: double.infinity,
        height: 40,
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Text(
              'Connect Mobile Wallet',
              style: context.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: colorScheme.onPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingView(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: context.colorScheme.primary,
          ),
        ),
        Dimens.vGap12,
        Text(
          'Waiting for wallet approval...',
          style: context.textTheme.bodySmall?.copyWith(
            color: context.textColorTheme.textColorTertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorView(BuildContext context, Object error) {
    final message = ErrorHandler.getMessage(context, error);
    return Column(
      children: [
        Text(
          message,
          textAlign: TextAlign.center,
          style: context.textTheme.bodySmall?.copyWith(color: Colors.red),
        ),
        Dimens.vGap16,
        _buildConnectButton(context),
      ],
    );
  }

  // ==========================================================================
  // MWA Wallet Connection Logic
  // ==========================================================================

  /// Initiates the full MWA wallet connection and login flow.
  ///
  /// This is the **core method** demonstrating `solana_mobile_client` usage.
  /// It manages the entire lifecycle of an MWA session – from checking wallet
  /// availability to closing the session after signing is complete.
  ///
  /// ### Error Handling
  ///
  /// The `scenario` variable is tracked outside the try-block so it can be
  /// properly closed in both the catch and the normal exit path. Failing to
  /// close the session will leave the wallet app in a hanging state.
  Future<void> _connectWallet() async {
    setState(() {
      _uiState = UiState.loading();
    });

    // Keep a reference to the scenario so we can close it on error.
    LocalAssociationScenario? scenario;
    try {
      // ----------------------------------------------------------------------
      // Step 1: Check if a compatible Solana wallet app is installed.
      //
      // `LocalAssociationScenario.isAvailable()` queries the system for apps
      // that support the MWA protocol (via Android intent filters).
      // On iOS this will always return false as MWA is Android-only.
      // ----------------------------------------------------------------------
      final available = await LocalAssociationScenario.isAvailable();
      if (!available) {
        throw Exception(
            'No Solana wallet found on this device.\nPlease install Phantom or another Solana wallet app.');
      }

      // Clear stale Turnkey sessions before opening the wallet to reduce
      // latency after the user approves in the wallet app.
      await _turnkeyManager.clearAllSessions();

      // ----------------------------------------------------------------------
      // Step 2: Create a local MWA association session.
      //
      // This allocates the underlying transport (a local socket) that will be
      // used to communicate with the wallet app. No network is involved –
      // everything happens on-device.
      // ----------------------------------------------------------------------
      scenario = await LocalAssociationScenario.create();

      // ----------------------------------------------------------------------
      // Step 3: Start the wallet app and establish the MWA connection.
      //
      // `startActivityForResult(null)` launches the wallet app's MWA activity.
      // `scenario.start()` waits for the wallet to connect back.
      //
      // We use `Future.any` to race these two futures: if the user dismisses
      // the wallet (activity finishes first), we throw immediately instead of
      // waiting for a connection that will never come.
      // ----------------------------------------------------------------------
      final activityFuture = scenario.startActivityForResult(null);
      final client = await Future.any<MobileWalletAdapterClient>([
        scenario.start(),
        activityFuture.then<MobileWalletAdapterClient>(
          (_) => throw Exception('Wallet was dismissed. Please try again.'),
        ),
      ]);

      // ----------------------------------------------------------------------
      // Step 4: Request authorization from the wallet.
      //
      // `client.authorize()` prompts the user in the wallet app to approve
      // this dApp. On success, we receive:
      //   - `authResult.publicKey` – the wallet's Ed25519 public key (bytes)
      //   - `authResult.authToken`  – a reusable token for future sessions
      //   - `authResult.accounts`   – list of authorized accounts
      //
      // The `identityUri`, `iconUri`, and `identityName` are displayed in the
      // wallet's approval dialog so the user knows which dApp is requesting
      // access.
      // ----------------------------------------------------------------------
      final authResult = await client.authorize(
        identityUri: Uri.parse('https://manic.trade'),
        iconUri: Uri.parse('favicon.png'),
        identityName: 'Manic Trade',
        cluster: 'mainnet-beta',
      );
      if (authResult == null) {
        throw Exception('Wallet authorization was cancelled or failed.');
      }

      // ----------------------------------------------------------------------
      // Step 5: Derive the Solana address from the public key.
      //
      // Solana addresses are simply the base58-encoded Ed25519 public key.
      // The `solana` package provides the `base58encode` utility for this.
      // ----------------------------------------------------------------------
      final address = base58encode(authResult.publicKey);
      logger.d('MwaWalletLoginScreen: Authorized wallet: $address');

      // ----------------------------------------------------------------------
      // Step 6: Wrap the MWA client as a SolanaWalletInterface.
      //
      // `MWASolanaWallet` adapts the MWA client to Turnkey's wallet interface,
      // allowing Turnkey to request message signing through the connected
      // wallet app. See `mwa_solana_wallet.dart` for implementation details.
      // ----------------------------------------------------------------------
      final wallet = MWASolanaWallet(
        client: client,
        address: address,
        publicKeyBytes: authResult.publicKey,
      );

      // ----------------------------------------------------------------------
      // Step 7: Authenticate with Turnkey using the connected wallet.
      //
      // Turnkey provides wallet-as-a-service. This step proves wallet ownership
      // by signing a challenge message, then creates or retrieves a Turnkey
      // sub-organization and custodial wallet for this user.
      //
      // Under the hood, `loginOrSignUpWithWallet` will call
      // `wallet.signMessage()` which triggers another approval in the wallet
      // app via MWA.
      // ----------------------------------------------------------------------
      await _turnkeyManager.loginOrSignUpWithWallet(wallet: wallet);

      // ----------------------------------------------------------------------
      // Step 8: Close the MWA session.
      //
      // IMPORTANT: Always close the scenario when you're done. This releases
      // the local transport and signals the wallet app that the session is
      // over. We null out the reference so the catch block won't double-close.
      // ----------------------------------------------------------------------
      await scenario.close();
      scenario = null;

      // ----------------------------------------------------------------------
      // Step 9: Complete server-side authentication.
      //
      // Now that we have a valid Turnkey session, authenticate with the Manic
      // Trade backend and sync wallet data (balances, accounts, etc.).
      // ----------------------------------------------------------------------
      await _loginManicTrade(mwaWalletAddress: address);

      // Navigate to the main screen on success.
      if (mounted) Get.offAllNamed(Routes.main);
    } on UserNotFoundException {
      // User's wallet is not on the allowlist – show a restricted access screen.
      await scenario?.close();
      if (mounted) _showNotWhitelisted();
    } catch (e, stackTrace) {
      // Ensure the MWA session is closed on any error to avoid leaked resources.
      await scenario?.close();
      logger.e('MwaWalletLoginScreen: Connection failed',
          error: e, stackTrace: stackTrace);
      if (mounted) {
        setState(() {
          _uiState = UiState.failure(e);
        });
      }
    }
  }

  // ==========================================================================
  // Server Authentication
  // ==========================================================================

  /// Authenticates with the Manic Trade backend after Turnkey auth succeeds.
  ///
  /// This method:
  /// 1. Initializes the Turnkey provider (loads keys, session, etc.)
  /// 2. Locates the Turnkey custodial wallet's Solana account
  /// 3. Checks user eligibility (whitelist) if an invite code was provided
  /// 4. Performs JWT-based login with the Manic Trade server
  /// 5. Syncs wallet data and starts the real-time sync listener
  Future<void> _loginManicTrade({required String mwaWalletAddress}) async {
    await _turnkeyWalletSyncService.readyTurnkeyProvider();

    // Find the Manic Trade wallet in Turnkey. If not found on first attempt,
    // refresh wallet list from Turnkey API and try again.
    var manicTradeWallet =
        TurnkeyWalletUtils.findManicTradeWallet(_turnkeyManager);
    if (manicTradeWallet == null) {
      await _turnkeyManager.refreshWallets();
      manicTradeWallet =
          TurnkeyWalletUtils.findManicTradeWallet(_turnkeyManager);
      if (manicTradeWallet == null) {
        throw Exception('Manic trade wallet not found after Turnkey auth.');
      }
    }

    // Extract the Solana account from the Turnkey custodial wallet.
    final solanaAccount = manicTradeWallet.accounts
        .where((a) => a.addressFormat == v1AddressFormat.address_format_solana)
        .firstOrNull;
    if (solanaAccount == null) {
      throw Exception('Solana account not found in Turnkey wallet.');
    }

    // Verify invite code and whitelist eligibility (if applicable).
    if (widget.verifiedInviteCode != null) {
      await _checkUser(
        widget.verifiedInviteCode!,
        solanaAccount,
        mwaWalletAddress,
      );
    }

    // Perform server login and start wallet data sync.
    await injector<WalletAuthManager>().loginTurnkeyWallet(solanaAccount);
    injector<WalletSelector>()
        .setTurnkeyUserId(_turnkeyManager.user!.userId);
    await _turnkeyWalletSyncService.forceSync();
    _turnkeyWalletSyncService.startListening();
  }

  /// Validates the user's eligibility by checking the invite code and wallet
  /// addresses against the Manic Trade server's whitelist.
  Future<void> _checkUser(
    String verifiedInviteCode,
    v1WalletAccount turnkeySolanaAccount,
    String mwaWalletAddress,
  ) async {
    final userId = _turnkeyManager.user?.userId;
    final orgId = _turnkeyManager.session?.organizationId;
    final name = _turnkeyManager.user?.userName;

    final manicTradeWallet =
        TurnkeyWalletUtils.findManicTradeWallet(_turnkeyManager);
    final walletSolana = manicTradeWallet?.accounts
        .firstWhereOrNull(
            (a) => a.addressFormat == v1AddressFormat.address_format_solana)
        ?.address;
    final walletEvm = manicTradeWallet?.accounts
        .firstWhereOrNull(
            (a) => a.addressFormat == v1AddressFormat.address_format_ethereum)
        ?.address;

    if (userId == null ||
        orgId == null ||
        name == null ||
        walletSolana == null ||
        walletEvm == null) {
      return;
    }

    final checkUserResponse =
        await injector<ManicAuthDataSource>().checkUser(
      CheckUserRequest.wallet(
        userId: userId,
        orgId: orgId,
        name: name,
        walletSolana: walletSolana,
        walletEvm: walletEvm,
        wallet: mwaWalletAddress,
        inviteCode: verifiedInviteCode,
      ),
    );
    if (!checkUserResponse.canLogin) {
      throw UserNotFoundException(address: turnkeySolanaAccount.address);
    }
  }

  void _showNotWhitelisted() {
    Get.to(() => AccessRestrictedScreen());
  }
}
