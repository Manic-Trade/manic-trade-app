enum OptionsTimeMode {
  /// 定时器模式-每次结算时间不一样
  timer('Individual'),

  /// 时钟模式-统一到一个时间点结算，多次结算会集中在同一个时间点结算
  clock('Unified');

  final String label;

  const OptionsTimeMode(this.label);
}
