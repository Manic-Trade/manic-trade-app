/// 时间范围筛选
enum TimeRange {
  today('today', 'Today', 'Today'),
  sevenDays('7d', '7D', 'Past 7 Days'),
  thirtyDays('30d', '30D', 'Past 30 Days');

  final String value;
  final String label;
  /// 用于分享卡片的展示文案
  final String shareLabel;
  const TimeRange(this.value, this.label, this.shareLabel);
}

/// 交易模式筛选
enum ModeFilter {
  all('all', 'All Modes'),
  individual('individual', 'Individual'),
  unified('unified', 'Unified');

  final String value;
  final String label;
  const ModeFilter(this.value, this.label);
}
