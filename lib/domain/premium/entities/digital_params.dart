/// 数字期权参数
class DigitalParams {
  double spot;
  double barrier;
  double volatility;
  double vegaBuffer;
  double timeYears;

  DigitalParams({
    required this.spot,
    required this.barrier,
    required this.volatility,
    required this.vegaBuffer,
    required this.timeYears,
  });

  DigitalParams copyWith({
    double? spot,
    double? barrier,
    double? volatility,
    double? vegaBuffer,
    double? timeYears,
  }) {
    return DigitalParams(
      spot: spot ?? this.spot,
      barrier: barrier ?? this.barrier,
      volatility: volatility ?? this.volatility,
      vegaBuffer: vegaBuffer ?? this.vegaBuffer,
      timeYears: timeYears ?? this.timeYears,
    );
  }
}
