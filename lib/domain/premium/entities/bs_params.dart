/// Black-Scholes 参数
class BSParams {
  final double spot;
  final double strike;
  final double volatility;
  final double timeYears;

  const BSParams({
    required this.spot,
    required this.strike,
    required this.volatility,
    required this.timeYears,
  });
}
