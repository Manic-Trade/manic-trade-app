/// Vault 交易生成响应（genStakeTx / genWithdrawTx / genCancelWithdrawTx / genUserClaimTx）
class VaultTxResponse {
  /// Base64 编码的未签名交易
  final String base64Tx;

  /// 额外数据，签名后需回传
  final String extraData;

  /// 签名数据，签名后需回传
  final String signData;

  const VaultTxResponse({
    required this.base64Tx,
    required this.extraData,
    required this.signData,
  });

  factory VaultTxResponse.fromJson(Map<String, dynamic> json) {
    return VaultTxResponse(
      base64Tx: json['base64_tx'] as String? ?? '',
      extraData: json['extra_data'] as String? ?? '',
      signData: json['sign_data'] as String? ?? '',
    );
  }
}
