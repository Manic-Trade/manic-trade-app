enum TimerDuration {
  s30(30, '30 sec'),
  m1(60, '1 min'),
  m2(120, '2 min'),
  m3(180, '3 min'),
  m4(240, '4 min'),
  m5(300, '5 min');

  final int seconds;
  final String label;
  const TimerDuration(this.seconds, this.label);
}

// enum ClockDuration {
//   m1(60, '1 min'),
//   m2(120, '2 min'),
//   m3(180, '3 min'),
//   m4(240, '4 min'),
//   m5(300, '5 min'),
//   m6(360, '6 min');

//   final int seconds;
//   final String label;
//   const ClockDuration(this.seconds, this.label);
// }
