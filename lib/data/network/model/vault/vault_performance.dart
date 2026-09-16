/// Vault 全局性能指标
class VaultPerformance {
  /// 总锁仓量（单位：lamports，DECIMALS = 1e9）
  final int tvl;

  /// 年化收益率（小数形式，如 1.2149 = 121.49%）
  final double apy;

  /// 最大回撤（小数形式，如 0.0004 = 0.04%）
  final double maxDrawdown;

  const VaultPerformance({
    required this.tvl,
    required this.apy,
    required this.maxDrawdown,
  });

  factory VaultPerformance.fromJson(Map<String, dynamic> json) {
    return VaultPerformance(
      tvl: (json['tvl'] as num?)?.toInt() ?? 0,
      apy: (json['apy'] as num?)?.toDouble() ?? 0,
      maxDrawdown: (json['max_drawdown'] as num?)?.toDouble() ?? 0,
    );
  }

  factory VaultPerformance.placeholder() {
    return const VaultPerformance(tvl: 0, apy: 0, maxDrawdown: 0);
  }
}
