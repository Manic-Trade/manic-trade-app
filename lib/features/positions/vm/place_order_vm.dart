import 'dart:convert';
import 'dart:math';

import 'package:finality/data/network/manic_trade_data_source.dart';
import 'package:finality/data/network/model/manic/open_position_response.dart';
import 'package:finality/data/network/solana_rpc_service.dart';
import 'package:finality/di/injector.dart';
import 'package:finality/domain/options/entities/options_time_mode.dart';
import 'package:finality/services/turnkey/turnkey_manager.dart';
import 'package:finality/services/wallet/wallet_service.dart';
import 'package:flutter/foundation.dart';
import 'package:hex/hex.dart';
import 'package:solana/base58.dart';
import 'package:store_scope/store_scope.dart';
import 'package:turnkey_sdk_flutter/turnkey_sdk_flutter.dart';

/// Generates a cryptographically secure, unique position ID.
///
/// Uses 32 random bytes encoded as base58 — the same format used by the
/// web client, ensuring cross-platform compatibility when querying positions.
String generatePositionId() {
  final random = Random.secure();
  final bytes = List<int>.generate(32, (_) => random.nextInt(256));
  return base58encode(bytes);
}

final placeOrderVMProvider = ViewModelProvider<PlaceOrderVM>((ref) {
  return PlaceOrderVM(
    injector<ManicTradeDataSource>(),
    injector<WalletService>(),
    injector<TurnkeyManager>(),
    injector<SolanaRpcService>(),
  );
});

/// # Place Order ViewModel
///
/// Manages the complete lifecycle of opening a binary option position on Solana:
///
/// 1. **API Request** – Send order parameters to the Manic Trade server, which
///    constructs an unsigned Solana transaction containing the Anchor program
///    instruction for the binary options smart contract.
///
/// 2. **Transaction Signing** – Sign the transaction using Turnkey's custodial
///    wallet. The private key never leaves Turnkey's secure enclave.
///
/// 3. **Solana Broadcast** – Submit the signed transaction to a Solana RPC node
///    for on-chain execution.
///
/// ## USDC Precision
///
/// All on-chain amounts use USDC's 6-decimal precision:
/// `1 USDC = 1,000,000 lamports`. The UI displays human-readable amounts
/// (e.g. "5.00 USDC") and this VM converts to lamports before the API call.
///
/// ## Order Modes
///
/// - **Rolling (Timer)** – Duration-based expiry (e.g. 60 seconds from now)
/// - **Single (Fixed)** – Expires at a specific wall-clock time
class PlaceOrderVM extends ViewModel {
  final ManicTradeDataSource _dataSource;
  final WalletService _walletService;
  final TurnkeyManager _turnkeyManager;
  final SolanaRpcService _solanaRpcService;

  PlaceOrderVM(
    this._dataSource,
    this._walletService,
    this._turnkeyManager,
    this._solanaRpcService,
  );

  /// Whether an order is being placed
  final ValueNotifier<bool> isLoading = ValueNotifier(false);

  /// Place an order (unified entry point)
  /// [asset] Asset name (e.g. btc)
  /// [isHigh] true = HIGHER (call), false = LOWER (put)
  Future<OpenPositionResponse?> openPosition({
    required OptionsTimeMode expiryType,
    required int durationSeconds,
    required DateTime? settleTime,
    required double payoutMultiplier,
    required double amount,
    required String asset,
    required bool isHigh,
    String? positionId,
  }) async {
    if (isLoading.value) return null;

    isLoading.value = true;

    try {
      // amount needs to be multiplied by 10^6 (USDC precision)
      final int amountInt = (amount * 1000000).toInt();

      if (expiryType == OptionsTimeMode.timer) {
        return await _openRollingPosition(
          amount: amountInt,
          asset: asset,
          isHigh: isHigh,
          duration: durationSeconds,
          targetMultiplier: payoutMultiplier,
          positionId: positionId,
        );
      } else {
        return await _openSinglePosition(
          amount: amountInt,
          asset: asset,
          isHigh: isHigh,
          settleTime: settleTime!,
          targetMultiplier: payoutMultiplier,
          positionId: positionId,
        );
      }
    } catch (e) {
      debugPrint('Failed to open position: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  /// Place order in Rolling mode
  Future<OpenPositionResponse> _openRollingPosition({
    required int amount,
    required String asset,
    required bool isHigh,
    required int duration,
    required double targetMultiplier,
    String? positionId,
  }) async {
    // end_time: current timestamp + duration (seconds)
    final endTime = (DateTime.now().millisecondsSinceEpoch ~/ 1000) + duration;

    final response = await _dataSource.openRollingPosition(
      amount: amount,
      asset: asset,
      isHigh: isHigh,
      duration: duration,
      endTime: endTime,
      targetMultiplier: targetMultiplier,
      positionId: positionId,
    );
    debugPrint('Rolling position opened: ${response.toJson()}');
    return response;
  }

  /// Place order in Single mode
  Future<OpenPositionResponse> _openSinglePosition({
    required int amount,
    required String asset,
    required bool isHigh,
    required DateTime settleTime,
    required double targetMultiplier,
    String? positionId,
  }) async {
    // For Single mode, endTime uses the user-selected settleTime
    final endTime = settleTime.millisecondsSinceEpoch ~/ 1000;
    // duration is calculated as the difference between settleTime and current time
    final duration = endTime - (DateTime.now().millisecondsSinceEpoch ~/ 1000);

    final response = await _dataSource.openSinglePosition(
      amount: amount,
      asset: asset,
      isHigh: isHigh,
      duration: duration,
      endTime: endTime,
      targetMultiplier: targetMultiplier,
      positionId: positionId,
    );
    debugPrint('Single position opened: ${response.toJson()}');
    return response;
  }

  @override
  void dispose() {
    isLoading.dispose();
    super.dispose();
  }

  /// Signs a Solana transaction using Turnkey's custodial wallet.
  ///
  /// The transaction bytes (hex-encoded) are sent to Turnkey's API, which
  /// signs them in a secure enclave and returns the signed result.
  ///
  /// SECURITY: The user's private key is generated and stored entirely within
  /// Turnkey's infrastructure. The app never has access to raw private keys.
  Future<v1SignTransactionResult> signTransaction(String transaction) async {
    var walletAccounts = _walletService.walletAccounts.value;
    if (walletAccounts == null) {
      throw Exception('No wallet accounts found');
    }

    var solanaAccount = walletAccounts.getSolanaAccount();
    if (solanaAccount == null) {
      throw Exception('No solana account found');
    }

    var response = await _turnkeyManager.signTransaction(
      signWith: solanaAccount.address,
      unsignedTransaction: transaction,
      type: v1TransactionType.transaction_type_solana,
    );

    return response;
  }

  /// Broadcasts a signed transaction to the Solana network.
  ///
  /// Converts the hex-encoded signed transaction to base64 (Solana RPC's
  /// expected format) and submits it via `sendTransaction`.
  ///
  /// Returns the **transaction signature** — a base58-encoded 64-byte Ed25519
  /// signature that uniquely identifies this transaction on-chain. This can be
  /// used to look up the transaction on Solana Explorer.
  Future<String> broadcastTransaction(String signedTransactionHex) async {
    final base64Tx = _hexToBase64(signedTransactionHex);
    return await _solanaRpcService.sendTransaction(base64Tx);
  }

  /// Broadcast transaction and wait for confirmation
  ///
  /// [signedTransactionHex] Signed transaction (hex-encoded)
  /// [timeout] Timeout duration, default 30 seconds
  /// Returns transaction signature
  Future<String> sendTransaction(String signedTransactionHex) async {
    final base64Tx = _hexToBase64(signedTransactionHex);
    return await _solanaRpcService.sendTransaction(
      base64Tx,
    );
  }

  /// Convert hex string to base64 encoding
  String _hexToBase64(String hexString) {
    final bytes = Uint8List.fromList(HEX.decode(hexString));
    return base64Encode(bytes);
  }
}
