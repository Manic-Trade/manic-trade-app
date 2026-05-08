/// Vault 图表数据点（用于 TVL 和 APY 历史）
class VaultChartPoint {
  /// 日期标签（格式化后的字符串）
  final String date;

  /// 值（TVL 为美元金额，APY 为百分比）
  final double value;

  /// 原始时间戳（Unix 秒）
  final int timestamp;

  const VaultChartPoint({
    required this.date,
    required this.value,
    required this.timestamp,
  });
}
