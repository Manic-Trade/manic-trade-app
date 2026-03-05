import 'package:solana/dto.dart';
import 'package:solana/solana.dart';

/// # Solana JSON-RPC Service
///
/// Provides a typed Dart interface over the [Solana JSON-RPC API](https://solana.com/docs/rpc).
///
/// ## Commitment Levels
///
/// Solana has three confirmation levels (fastest → safest):
///
/// | Level       | Meaning |
/// |-------------|---------|
/// | `processed` | Transaction has been received by the leader node |
/// | `confirmed` | Supermajority of validators have confirmed (< 1s) |
/// | `finalized` | Block is rooted and irreversible (~12s) |
///
/// For trading, we use `confirmed` as the default — it provides fast feedback
/// with >99.9% finality guarantee. Only use `finalized` for high-value
/// withdrawals where absolute certainty is required.
///
/// ## Transaction Lifecycle
///
/// ```
/// sendTransaction()           → signature (tx submitted to leader)
///     ↓
/// confirmTransaction()        → bool (poll until confirmed or timeout)
///     ↓
/// sendAndConfirmTransaction() → signature (combines both steps)
/// ```
class SolanaRpcService {
  final RpcClient _rpcClient;

  SolanaRpcService({required String rpcUrl}) : _rpcClient = RpcClient(rpcUrl);

  /// Broadcasts a signed transaction to the Solana network.
  ///
  /// The transaction must be base64-encoded (Solana RPC's wire format).
  /// Returns a **transaction signature** (base58 string) that can be used
  /// to track the transaction on [Solana Explorer](https://explorer.solana.com/).
  ///
  /// [skipPreflight] – When true, skips the RPC node's simulation check.
  ///   Useful for time-sensitive trades where you accept the risk of failure
  ///   in exchange for lower latency.
  /// [preflightCommitment] – Simulation commitment level (default: confirmed).
  /// [maxRetries] – RPC-level retry count (null = node default, usually 5).
  Future<String> sendTransaction(
    String signedTransaction, {
    bool skipPreflight = false,
    Commitment preflightCommitment = Commitment.confirmed,
    int? maxRetries,
  }) async {
    final signature = await _rpcClient.sendTransaction(
      signedTransaction,
      preflightCommitment: preflightCommitment,
      skipPreflight: skipPreflight,
      maxRetries: maxRetries,
    );
    return signature;
  }

  /// Queries the confirmation status of a transaction by its signature.
  /// Returns null if the transaction hasn't been seen by the RPC node yet.
  Future<SignatureStatus?> getSignatureStatus(String signature) async {
    final result = await _rpcClient.getSignatureStatuses([signature]);
    final statuses = result.value;
    return statuses.isNotEmpty ? statuses.first : null;
  }

  /// Polls for transaction confirmation until the desired commitment level
  /// is reached or the timeout expires.
  ///
  /// Polls every 500ms. Returns `true` if confirmed at or above the
  /// requested [commitment] level, `false` on timeout or transaction error.
  ///
  /// DESIGN: We use polling instead of WebSocket subscription for simplicity.
  /// Solana's `signatureSubscribe` WebSocket is an alternative for lower
  /// latency, but polling is more reliable across different RPC providers.
  Future<bool> confirmTransaction(
    String signature, {
    Commitment commitment = Commitment.confirmed,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final startTime = DateTime.now();

    while (DateTime.now().difference(startTime) < timeout) {
      final status = await getSignatureStatus(signature);
      if (status != null) {
        // 检查是否有错误
        if (status.err != null) {
          return false;
        }
        // 检查确认状态
        final confirmationStatus = status.confirmationStatus;
        if (commitment == Commitment.processed) {
          return true;
        } else if (commitment == Commitment.confirmed) {
          return confirmationStatus == Commitment.confirmed ||
              confirmationStatus == Commitment.finalized;
        } else if (commitment == Commitment.finalized) {
          return confirmationStatus == Commitment.finalized;
        }
      }
      // 等待一段时间后重试
      await Future.delayed(const Duration(milliseconds: 500));
    }

    return false;
  }

  /// Convenience method: sends a transaction and waits for confirmation.
  ///
  /// Combines [sendTransaction] + [confirmTransaction] into a single call.
  /// Throws [SolanaTransactionException] if confirmation times out or fails.
  Future<String> sendAndConfirmTransaction(
    String signedTransaction, {
    Commitment commitment = Commitment.confirmed,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final signature = await sendTransaction(
      signedTransaction,
      preflightCommitment: commitment,
    );

    final confirmed = await confirmTransaction(
      signature,
      commitment: commitment,
      timeout: timeout,
    );

    if (!confirmed) {
      throw SolanaTransactionException(
        signature: signature,
        message: 'Transaction confirmation timeout or failed',
      );
    }

    return signature;
  }

  /// Fetches the latest blockhash, required for every Solana transaction.
  ///
  /// Solana transactions include a recent blockhash to prevent replay attacks
  /// and enforce a ~60-second TTL. Default commitment is `finalized` because
  /// using a non-finalized blockhash risks the block being rolled back.
  Future<String> getLatestBlockhash({
    Commitment commitment = Commitment.finalized,
  }) async {
    final result = await _rpcClient.getLatestBlockhash(commitment: commitment);
    return result.value.blockhash;
  }

  /// Reads raw account data from the Solana blockchain.
  ///
  /// Used to fetch on-chain state (e.g. MarketAccount data for the pricing
  /// engine). The returned bytes can be deserialized using Borsh.
  Future<List<int>?> getAccountInfo(String publicKey) async {
    final result = await _rpcClient.getAccountInfo(
      publicKey,
      encoding: Encoding.base64,
    );

    final account = result.value;
    if (account == null) {
      return null;
    }

    final data = account.data;
    if (data is BinaryAccountData) {
      return data.data;
    }

    return null;
  }

  /// 获取 RPC 客户端（用于高级操作）
  RpcClient get rpcClient => _rpcClient;
}

/// Solana 交易异常
class SolanaTransactionException implements Exception {
  final String signature;
  final String message;

  SolanaTransactionException({
    required this.signature,
    required this.message,
  });

  @override
  String toString() =>
      'SolanaTransactionException: $message (signature: $signature)';
}
