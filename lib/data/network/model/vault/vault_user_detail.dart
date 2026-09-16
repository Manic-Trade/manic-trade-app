/// 用户 Vault 持仓详情
class VaultUserDetail {
  /// 总余额（单位：lamports，DECIMALS = 1e9）
  final int totalBalance;

  /// 总收益
  final int earnings;

  /// 24小时收益
  final int earning24h;

  const VaultUserDetail({
    required this.totalBalance,
    required this.earnings,
    required this.earning24h,
  });

  factory VaultUserDetail.fromJson(Map<String, dynamic> json) {
    return VaultUserDetail(
      totalBalance: (json['total_balance'] as num?)?.toInt() ?? 0,
      earnings: (json['earnings'] as num?)?.toInt() ?? 0,
      earning24h: (json['earning_24h'] as num?)?.toInt() ?? 0,
    );
  }

  /// 占位数据，用于骨架屏
  factory VaultUserDetail.placeholder() {
    return const VaultUserDetail(
      totalBalance: 0,
      earnings: 0,
      earning24h: 0,
    );
  }
}
