import 'dart:convert';
import 'dart:typed_data';

import 'package:finality/core/logger.dart';
import 'package:solana_mobile_client/solana_mobile_client.dart';
import 'package:turnkey_sdk_flutter/turnkey_sdk_flutter.dart';

/// # MWA Solana Wallet Adapter
///
/// Bridges the **Solana Mobile Wallet Adapter (MWA)** client with Turnkey's
/// [SolanaWalletInterface], enabling Turnkey authentication via a locally
/// connected Solana wallet app (e.g. Phantom, Solflare).
///
/// ## How It Works
///
/// When Turnkey needs to verify wallet ownership, it asks the wallet to sign a
/// challenge message. This class delegates that signing request to the MWA
/// client, which in turn forwards it to the wallet app running on the same
/// device. The wallet app prompts the user for approval, signs the message
/// with the wallet's private key, and returns the signature back through MWA.
///
/// ## Usage
///
/// ```dart
/// // After establishing an MWA session and authorizing:
/// final wallet = MWASolanaWallet(
///   client: mwaClient,            // from scenario.start()
///   address: base58Address,       // from authResult.publicKey
///   publicKeyBytes: authResult.publicKey,
/// );
///
/// // Pass to Turnkey for authentication:
/// await turnkeyManager.loginOrSignUpWithWallet(wallet: wallet);
/// ```
///
/// ## Important Notes
///
/// - The MWA session must remain open while this wallet is in use. Closing
///   the `LocalAssociationScenario` will invalidate the `client`.
/// - Each `signMessage` call triggers a user approval prompt in the wallet app.
/// - Signatures and public keys are returned as hex strings to match Turnkey's
///   expected format.
class MWASolanaWallet implements SolanaWalletInterface {
  /// The MWA client obtained from `LocalAssociationScenario.start()`.
  /// Used to send signing requests to the connected wallet app.
  final MobileWalletAdapterClient _client;

  /// The wallet's Solana address (base58-encoded Ed25519 public key).
  final String _address;

  /// Raw bytes of the wallet's Ed25519 public key (32 bytes).
  /// Used as the signing identity when calling `client.signMessages()`.
  final Uint8List _publicKeyBytes;

  MWASolanaWallet({
    required MobileWalletAdapterClient client,
    required String address,
    required Uint8List publicKeyBytes,
  })  : _client = client,
        _address = address,
        _publicKeyBytes = publicKeyBytes;

  @override
  WalletType get type => WalletType.solana;

  @override
  String get address => _address;

  /// Returns the wallet's public key as a hex string.
  ///
  /// Solana public keys are 32-byte Ed25519 keys. While Solana addresses use
  /// base58 encoding, Turnkey expects hex format for cryptographic operations.
  @override
  Future<String> getPublicKey() async {
    return _publicKeyBytes
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join();
  }

  /// Signs a message using the connected wallet app via MWA.
  ///
  /// ### Flow:
  /// 1. Encode the [message] string to UTF-8 bytes
  /// 2. Send the bytes to the wallet app via `client.signMessages()`
  /// 3. The wallet app prompts the user for approval
  /// 4. On approval, the wallet signs with its Ed25519 private key
  /// 5. Return the 64-byte Ed25519 signature as a hex string
  ///
  /// ### MWA API Details:
  /// - `signMessages` accepts a list of messages and a list of signer addresses
  /// - Each message is signed by the corresponding address
  /// - The result contains `signedMessages`, each with a list of `signatures`
  /// - We use a single message + single address, so we take `first.first`
  @override
  Future<String> signMessage(String message) async {
    logger.d('MWASolanaWallet: Signing message: $message');

    // Encode the message string to raw bytes for signing.
    final messageBytes = Uint8List.fromList(utf8.encode(message));

    // Request the wallet app to sign the message.
    // The `addresses` parameter specifies which wallet account should sign.
    final result = await _client.signMessages(
      messages: [messageBytes],
      addresses: [_publicKeyBytes],
    );

    // Extract the Ed25519 signature (64 bytes) and convert to hex.
    final signature = result.signedMessages.first.signatures.first;
    final signatureHex =
        signature.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

    logger.d('MWASolanaWallet: Signature hex: $signatureHex');
    return signatureHex;
  }
}
