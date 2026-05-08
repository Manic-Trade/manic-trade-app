import 'dart:math';

/// 2D OpenSimplex 噪声（简化版），用于生成平滑的伪随机值
/// 返回值范围大致在 [-1, 1]
class SimplexNoise {
  SimplexNoise([int seed = 0]) {
    final rng = Random(seed);
    // Fisher-Yates shuffle
    for (var i = _perm.length - 1; i > 0; i--) {
      final j = rng.nextInt(i + 1);
      final tmp = _perm[i];
      _perm[i] = _perm[j];
      _perm[j] = tmp;
    }
    for (var i = 0; i < 256; i++) {
      _perm[256 + i] = _perm[i];
    }
  }

  final _perm = List<int>.generate(512, (i) => i < 256 ? i : 0);

  // 2D gradients
  static const _grad2 = [
    [1.0, 1.0], [-1.0, 1.0], [1.0, -1.0], [-1.0, -1.0],
    [1.0, 0.0], [-1.0, 0.0], [0.0, 1.0], [0.0, -1.0],
  ];

  static const _f2 = 0.5 * (1.7320508075688772 - 1.0); // (sqrt(3)-1)/2
  static const _g2 = (3.0 - 1.7320508075688772) / 6.0; // (3-sqrt(3))/6

  double noise2D(double x, double y) {
    final s = (x + y) * _f2;
    final i = (x + s).floor();
    final j = (y + s).floor();
    final t = (i + j) * _g2;

    final x0 = x - (i - t);
    final y0 = y - (j - t);

    int i1, j1;
    if (x0 > y0) {
      i1 = 1;
      j1 = 0;
    } else {
      i1 = 0;
      j1 = 1;
    }

    final x1 = x0 - i1 + _g2;
    final y1 = y0 - j1 + _g2;
    final x2 = x0 - 1.0 + 2.0 * _g2;
    final y2 = y0 - 1.0 + 2.0 * _g2;

    final ii = i & 255;
    final jj = j & 255;

    double n0 = 0, n1 = 0, n2 = 0;

    var t0 = 0.5 - x0 * x0 - y0 * y0;
    if (t0 >= 0) {
      t0 *= t0;
      final gi = _perm[ii + _perm[jj]] % 8;
      n0 = t0 * t0 * (_grad2[gi][0] * x0 + _grad2[gi][1] * y0);
    }

    var t1 = 0.5 - x1 * x1 - y1 * y1;
    if (t1 >= 0) {
      t1 *= t1;
      final gi = _perm[ii + i1 + _perm[jj + j1]] % 8;
      n1 = t1 * t1 * (_grad2[gi][0] * x1 + _grad2[gi][1] * y1);
    }

    var t2 = 0.5 - x2 * x2 - y2 * y2;
    if (t2 >= 0) {
      t2 *= t2;
      final gi = _perm[ii + 1 + _perm[jj + 1]] % 8;
      n2 = t2 * t2 * (_grad2[gi][0] * x2 + _grad2[gi][1] * y2);
    }

    return 70.0 * (n0 + n1 + n2);
  }
}
