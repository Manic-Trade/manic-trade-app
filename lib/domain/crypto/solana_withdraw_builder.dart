import 'package:finality/data/network/solana_rpc_service.dart';
import 'package:solana/encoder.dart';
import 'package:solana/solana.dart';

/// Solana 交易构建器
/// 负责构建 Solana 转账交易的待签名信息
class SolanaWithdrawBuilder {
  final SolanaRpcService _solanaRpcService;

  // Solana 标准程序 ID（所有网络通用）
  static const String _ataProgramId =
      'ATokenGPvbdGVxr1b2hvZbsiqW5xWH25efTNsLJA8knL';
  static const String _tokenProgramId =
      'TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA';
  static const String _systemProgramId = '11111111111111111111111111111111';

  SolanaWithdrawBuilder(this._solanaRpcService);

  /// 构建转账交易的待签名信息
  ///
  /// [fromAddress] 发送方地址
  /// [toAddress] 接收方地址
  /// [tokenAddress] 代币地址
  /// [amountInLamports] 转账金额（lamports）
  /// [feePayer] 支付交易费用的地址（可选，默认使用发送方地址）
  /// [withdrawFeeAmount] 提币手续费金额（可选，默认为 100000 即 0.1 USDC）
  /// [isFeeDeductedFromAmount] 手续费是否内扣（可选，默认 true）
  ///   - true（内扣）：转 10，实际到账 9.9，手续费 0.1 转给收费地址，总花费 10
  ///   - false（外扣）：转 10，实际到账 10，另外转 0.1 手续费给收费地址，总花费 10.1
  /// [feeRecipientAddress] 手续费接收地址（可选，默认使用 defaultFeeRecipientAddress）
  ///
  /// 返回签名后的交易数据
  Future<List<int>> buildWithdrawTransaction({
    required String fromAddress,
    required String toAddress,
    required int amountInLamports,
    required String tokenAddress,
    String? feePayerAddress,
    int withdrawFeeAmount = 100000,
    bool isFeeDeductedFromAmount = true,
    required String feeRecipientAddress,
  }) async {
    final fromPubkey = Ed25519HDPublicKey.fromBase58(fromAddress);
    final toPubkey = Ed25519HDPublicKey.fromBase58(toAddress);
    final feePayer = feePayerAddress != null
        ? Ed25519HDPublicKey.fromBase58(feePayerAddress)
        : fromPubkey;
    // 获取最新的 blockhash
    final blockhash = await _solanaRpcService.getLatestBlockhash();
    return _buildSplTokenTransfer(
      fromPubkey: fromPubkey,
      toPubkey: toPubkey,
      feePayer: feePayer,
      blockhash: blockhash,
      tokenAddress: tokenAddress,
      amountInLamports: amountInLamports,
      withdrawFeeAmount: withdrawFeeAmount,
      isFeeDeductedFromAmount: isFeeDeductedFromAmount,
      feeRecipientAddress: feeRecipientAddress,
    );
  }

  /// 构建 SPL Token 转账交易（包含可选的手续费转账）
  /// 使用 TransferChecked 指令，需要 mint 账户和 decimals 参数
  ///
  /// [withdrawFeeAmount] 提币手续费金额（0 表示不收取手续费）
  /// [isFeeDeductedFromAmount] 手续费是否内扣
  ///   - true（内扣）：从 amountInLamports 中扣除手续费，实际到账 = amountInLamports - withdrawFeeAmount
  ///   - false（外扣）：手续费额外收取，实际到账 = amountInLamports，总花费 = amountInLamports + withdrawFeeAmount
  /// [feeRecipientAddress] 手续费接收地址
  Future<List<int>> _buildSplTokenTransfer({
    required Ed25519HDPublicKey fromPubkey,
    required Ed25519HDPublicKey toPubkey,
    required Ed25519HDPublicKey feePayer,
    required String blockhash,
    required String tokenAddress,
    required int amountInLamports,
    required int withdrawFeeAmount,
    required bool isFeeDeductedFromAmount,
    required String feeRecipientAddress,
  }) async {
    final tokenMint = Ed25519HDPublicKey.fromBase58(tokenAddress);

    // 获取发送方的 Associated Token Account (ATA)
    final fromTokenAccount =
        await _getAssociatedTokenAddress(tokenMint, fromPubkey);

    // 获取接收方的 Associated Token Account (ATA)
    final toTokenAccount =
        await _getAssociatedTokenAddress(tokenMint, toPubkey);

    // 计算实际转账金额
    // 内扣：实际到账 = 转账金额 - 手续费
    // 外扣：实际到账 = 转账金额（手续费额外收取）
    final actualTransferAmount = isFeeDeductedFromAmount
        ? amountInLamports - withdrawFeeAmount
        : amountInLamports;

    // 收集所有指令
    final instructions = <Instruction>[
      // 指令1：创建接收方的 ATA（如果不存在会创建，已存在则跳过）
      // 使用 createIdempotent 保证幂等性，避免重复创建报错
      _createAssociatedTokenAccountIdempotent(
        funder: feePayer,
        associatedTokenAddress: toTokenAccount,
        owner: toPubkey,
        mint: tokenMint,
      ),
      // 指令2：转账给目标地址
      TokenInstruction.transferChecked(
        source: fromTokenAccount,
        destination: toTokenAccount,
        owner: fromPubkey,
        amount: actualTransferAmount,
        mint: tokenMint,
        decimals: 6, // USDC 精度为 6
      ),
    ];

    // 如果有手续费，添加手续费转账指令
    if (withdrawFeeAmount > 0) {
      final feeRecipient = Ed25519HDPublicKey.fromBase58(feeRecipientAddress);
      final feeTokenAccount =
          await _getAssociatedTokenAddress(tokenMint, feeRecipient);

      // 指令3：确保手续费接收地址的 ATA 存在（幂等，不存在则创建）
      // 否则 TransferChecked 会因 destination 不是有效 token account 而报 InvalidAccountData
      instructions.add(
        _createAssociatedTokenAccountIdempotent(
          funder: feePayer,
          associatedTokenAddress: feeTokenAccount,
          owner: feeRecipient,
          mint: tokenMint,
        ),
      );

      // 指令4：转账手续费给手续费接收地址
      instructions.add(
        TokenInstruction.transferChecked(
          source: fromTokenAccount,
          destination: feeTokenAccount,
          owner: fromPubkey,
          amount: withdrawFeeAmount,
          mint: tokenMint,
          decimals: 6, // USDC 精度为 6
        ),
      );
    }

    // 构建交易消息
    final message = Message(instructions: instructions);

    // 序列化并编码
    // Message.compile() 会自动处理账户顺序：
    // 1. feePayer 会被设为第一个签名者（索引 0）
    // 2. fromPubkey (owner) 会被设为第二个签名者（索引 1，因为它在指令中被标记为签名者）
    final signaturePayload =
        _serializeUnsignedTransaction(message, blockhash, feePayer);

    return signaturePayload;
  }

  /// 创建 Associated Token Account 的幂等指令
  ///
  /// 如果 ATA 已存在，则不会重复创建（幂等）
  /// 如果 ATA 不存在，则会创建新的 ATA
  ///
  /// 这是手动实现的 createIdempotent 指令，因为 solana 包没有提供此方法
  /// 指令索引 1 = CreateIdempotent
  Instruction _createAssociatedTokenAccountIdempotent({
    required Ed25519HDPublicKey funder,
    required Ed25519HDPublicKey associatedTokenAddress,
    required Ed25519HDPublicKey owner,
    required Ed25519HDPublicKey mint,
  }) {
    final ataProgramId = Ed25519HDPublicKey.fromBase58(_ataProgramId);
    final tokenProgramId = Ed25519HDPublicKey.fromBase58(_tokenProgramId);
    final systemProgramId = Ed25519HDPublicKey.fromBase58(_systemProgramId);

    return Instruction(
      programId: ataProgramId,
      accounts: [
        AccountMeta.writeable(pubKey: funder, isSigner: true),
        AccountMeta.writeable(pubKey: associatedTokenAddress, isSigner: false),
        AccountMeta.readonly(pubKey: owner, isSigner: false),
        AccountMeta.readonly(pubKey: mint, isSigner: false),
        AccountMeta.readonly(pubKey: systemProgramId, isSigner: false),
        AccountMeta.readonly(pubKey: tokenProgramId, isSigner: false),
      ],
      // 指令索引 1 = CreateIdempotent
      data: ByteArray.u8(1),
    );
  }

  /// 获取关联的 token account 地址（Associated Token Account）
  ///
  /// [mint] 代币的 mint 地址
  /// [owner] 钱包地址
  ///
  /// 返回该钱包地址对应的 ATA 地址
  Future<Ed25519HDPublicKey> _getAssociatedTokenAddress(
    Ed25519HDPublicKey mint,
    Ed25519HDPublicKey owner,
  ) async {
    // Associated Token Account Program ID
    final ataProgramId = Ed25519HDPublicKey.fromBase58(_ataProgramId);

    // Token Program ID
    final tokenProgramId = Ed25519HDPublicKey.fromBase58(_tokenProgramId);

    // 使用 findProgramAddress 计算 PDA (Program Derived Address)
    // ATA 的 seeds 是: [owner, token_program_id, mint]
    final result = await Ed25519HDPublicKey.findProgramAddress(
      seeds: [
        owner.bytes,
        tokenProgramId.bytes,
        mint.bytes,
      ],
      programId: ataProgramId,
    );

    return result;
  }

  /// 序列化交易为完整的 unsigned Transaction
  ///
  /// Solana Transaction 格式:
  /// - 1 字节: 签名数量 (numSignatures)
  /// - numSignatures * 64 字节: 签名数组 (未签名时为零字节)
  /// - Message 字节
  List<int> _serializeUnsignedTransaction(
    Message message,
    String blockhash,
    Ed25519HDPublicKey feePayer,
  ) {
    final compiledMessage = message.compile(
      recentBlockhash: blockhash,
      feePayer: feePayer,
    );

    final messageBytes = compiledMessage.toByteArray().toList();

    // 获取需要签名的账户数量
    final numSignatures = compiledMessage.header.numRequiredSignatures;

    // 构建完整的 unsigned transaction
    final List<int> transactionBytes = [];

    // 1. 写入签名数量 (compact-u16 格式，但对于小于 128 的数字，就是 1 个字节)
    transactionBytes.add(numSignatures);

    // 2. 写入空签名占位符 (每个签名 64 字节的零)
    for (var i = 0; i < numSignatures; i++) {
      transactionBytes.addAll(List.filled(64, 0));
    }

    // 3. 写入 Message
    transactionBytes.addAll(messageBytes);

    return transactionBytes;
  }
}
