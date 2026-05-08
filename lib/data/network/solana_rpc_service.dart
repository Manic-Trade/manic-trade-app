import 'package:solana/dto.dart';
import 'package:solana/solana.dart';

/// Solana RPC 服务
/// 用于与 Solana 网络交互，发送交易等
class SolanaRpcService {
  final RpcClient _rpcClient;

  SolanaRpcService({required String rpcUrl}) : _rpcClient = RpcClient(rpcUrl);

  /// 广播已签名的交易到 Solana 网络
  ///
  /// [signedTransaction] 已签名的交易（base64 编码的字符串）
  /// [skipPreflight] 是否跳过预检，默认 false
  /// [preflightCommitment] 预检确认级别，默认 confirmed
  /// [maxRetries] 最大重试次数，默认 null（使用 RPC 节点默认值）
  ///
  /// 返回交易签名（Transaction Signature）
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

  /// 获取交易状态
  ///
  /// [signature] 交易签名
  /// 返回交易确认状态，如果交易不存在则返回 null
  Future<SignatureStatus?> getSignatureStatus(String signature) async {
    final result = await _rpcClient.getSignatureStatuses([signature]);
    final statuses = result.value;
    return statuses.isNotEmpty ? statuses.first : null;
  }

  /// 等待交易确认
  ///
  /// [signature] 交易签名
  /// [commitment] 确认级别，默认 confirmed
  /// [timeout] 超时时间，默认 30 秒
  ///
  /// 返回交易是否成功确认
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

  /// 发送交易并等待确认
  ///
  /// [signedTransaction] 已签名的交易（base64 编码的字符串）
  /// [commitment] 确认级别，默认 confirmed
  /// [timeout] 超时时间，默认 30 秒
  ///
  /// 返回交易签名，如果确认失败则抛出异常
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

  /// 获取最新的区块哈希
  ///
  /// [commitment] 确认级别，默认 finalized
  /// 返回最新的区块哈希
  Future<String> getLatestBlockhash({
    Commitment commitment = Commitment.finalized,
  }) async {
    final result = await _rpcClient.getLatestBlockhash(commitment: commitment);
    return result.value.blockhash;
  }

  /// 获取账户信息
  ///
  /// [publicKey] 账户公钥（base58 编码）
  /// 返回账户数据（字节数组），如果账户不存在则返回 null
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
