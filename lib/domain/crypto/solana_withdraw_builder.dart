import 'package:finality/data/network/solana_rpc_service.dart';
import 'package:solana/encoder.dart';
import 'package:solana/solana.dart';

/// # Solana SPL Token Transaction Builder
///
/// Constructs unsigned Solana transactions for USDC withdrawals, including:
/// - Associated Token Account (ATA) creation (idempotent)
/// - SPL Token `TransferChecked` instructions with proper decimals
/// - Optional fee collection via a separate transfer instruction
///
/// ## Solana Transaction Anatomy
///
/// ```
/// Transaction = [num_signatures] [signatures...] [Message]
///
/// Message = Header + Account Keys + Recent Blockhash + Instructions
///
/// Each Instruction = {
///   program_id_index,   // which program to invoke
///   account_indexes[],  // accounts the instruction reads/writes
///   data[]              // instruction-specific payload
/// }
/// ```
///
/// ## Associated Token Accounts (ATAs)
///
/// On Solana, token balances are stored in separate **token accounts**, not on
/// the wallet directly. Each wallet has one ATA per token mint, derived via a
/// Program Derived Address (PDA):
///
/// ```
/// ATA = PDA([wallet_pubkey, TOKEN_PROGRAM_ID, mint_pubkey], ATA_PROGRAM_ID)
/// ```
///
/// Before transferring tokens, we must ensure the recipient's ATA exists.
/// We use `createIdempotent` which is safe to call even if the ATA already
/// exists (unlike `create` which would fail).
///
/// ## Fee Handling
///
/// Supports two modes:
/// - **Internal (deducted)**: fee is subtracted from the transfer amount
/// - **External (additional)**: fee is charged on top of the transfer amount
class SolanaWithdrawBuilder {
  final SolanaRpcService _solanaRpcService;

  // Well-known Solana program IDs (same across all clusters: devnet, mainnet).
  static const String _ataProgramId =
      'ATokenGPvbdGVxr1b2hvZbsiqW5xWH25efTNsLJA8knL';
  static const String _tokenProgramId =
      'TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA';
  static const String _systemProgramId = '11111111111111111111111111111111';

  static const String defaultFeeRecipientAddress =
      '4LidPEwYfzCwUViD3c57mzuRyzCEEpJVpvfQoSTkyk1P';

  SolanaWithdrawBuilder(this._solanaRpcService);

  /// Builds an unsigned SPL Token transfer transaction.
  ///
  /// Returns the serialized transaction bytes ready for signing by Turnkey.
  ///
  /// [amountInLamports] — Token amount in smallest unit (1 USDC = 1,000,000).
  /// [withdrawFeeAmount] — Platform fee (default: 100,000 = 0.1 USDC).
  /// [isFeeDeductedFromAmount] — Fee mode:
  ///   - `true`  (internal): send 10 USDC → recipient gets 9.9, fee = 0.1
  ///   - `false` (external): send 10 USDC → recipient gets 10.0, fee = 0.1 extra
  Future<List<int>> buildWithdrawTransaction({
    required String fromAddress,
    required String toAddress,
    required int amountInLamports,
    required String tokenAddress,
    String? feePayerAddress,
    int withdrawFeeAmount = 100000,
    bool isFeeDeductedFromAmount = true,
    String feeRecipientAddress = defaultFeeRecipientAddress,
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

  /// Constructs the instruction list for an SPL Token transfer.
  ///
  /// Uses `TransferChecked` (not `Transfer`) which requires the mint address
  /// and decimal count — this is the recommended instruction for SPL tokens
  /// as it provides an extra safety check against decimal mismatch.
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

      // 指令3：转账手续费给手续费接收地址
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

  /// Creates an ATA if it doesn't exist; no-ops if it already does.
  ///
  /// This is a manual implementation of the `CreateIdempotent` instruction
  /// (index 1) from the Associated Token Account Program. The `solana` Dart
  /// package only provides `Create` (index 0) which fails if the ATA exists.
  ///
  /// SECURITY: Idempotent creation is critical for user-facing transactions —
  /// without it, a race condition could cause the tx to fail if another
  /// transaction creates the ATA between our check and our transaction.
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

  /// Derives the Associated Token Account address for a given wallet + mint.
  ///
  /// ATA addresses are **deterministic** PDAs (Program Derived Addresses):
  /// `PDA(seeds: [owner, TOKEN_PROGRAM_ID, mint], program: ATA_PROGRAM_ID)`
  ///
  /// This means we can compute the address without any RPC call — the address
  /// is purely a function of the owner and mint public keys.
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

  /// Serializes a Message into the full unsigned transaction wire format.
  ///
  /// Solana's transaction format (v0-legacy):
  /// ```
  /// [1 byte]  num_signatures
  /// [N × 64]  signature slots (zeroed for unsigned tx)
  /// [...]     compiled message bytes
  /// ```
  ///
  /// The signing service (Turnkey) will fill in the zero'd signature slots
  /// with actual Ed25519 signatures.
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
