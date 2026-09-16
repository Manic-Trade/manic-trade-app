import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:finality/features/analysis/models/premium_analysis_vo.dart';
import 'package:finality/features/analysis/widgets/premium/premium_card.dart';
import 'package:flutter/material.dart';

/// CustomPainter 实现的双轴复合图表（Volume 柱 + 累积 P&L 折线）
///
/// 完全手绘，包含 CRT bloom 多层光晕、自定义 tooltip 等全部特效。
class PerformanceMatrixPainterChart extends StatefulWidget {
  final List<PerformancePointVO> points;

  const PerformanceMatrixPainterChart({super.key, required this.points});

  @override
  State<PerformanceMatrixPainterChart> createState() =>
      _PerformanceMatrixPainterChartState();
}

class _PerformanceMatrixPainterChartState
    extends State<PerformanceMatrixPainterChart>
    with SingleTickerProviderStateMixin {
  int? _selectedIndex;
  late final AnimationController _entrance;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _entrance.forward();
    });
  }

  @override
  void didUpdateWidget(covariant PerformanceMatrixPainterChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.points != widget.points) {
      _selectedIndex = null;
    }
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  List<double> get _cumPnl {
    final result = <double>[];
    double sum = 0;
    for (final p in widget.points) {
      sum += p.pnl;
      result.add(sum);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.points.isEmpty) return _buildEmpty();

    return PremiumCard(
      child: SizedBox(
        height: 280,
        child: AnimatedBuilder(
          animation: _entrance,
          builder: (context, _) {
            return LayoutBuilder(
              builder: (context, constraints) {
                return GestureDetector(
                  onTapDown: (details) => _handleTap(details, constraints),
                  child: CustomPaint(
                    size: Size(constraints.maxWidth, 280),
                    painter: _PerformanceMatrixPainter(
                      points: widget.points,
                      cumPnl: _cumPnl,
                      selectedIndex: _selectedIndex,
                      animProgress: CurvedAnimation(
                        parent: _entrance,
                        curve: const Cubic(0.22, 1, 0.36, 1),
                      ).value,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _handleTap(TapDownDetails details, BoxConstraints constraints) {
    final points = widget.points;
    if (points.isEmpty) return;

    const pl = 50.0;
    const pr = 44.0;
    final cW = constraints.maxWidth - pl - pr;
    final slotW = cW / points.length;
    final tapX = details.localPosition.dx - pl;

    if (tapX < 0 || tapX > cW) {
      setState(() => _selectedIndex = null);
      return;
    }

    final index = (tapX / slotW).floor().clamp(0, points.length - 1);
    setState(() => _selectedIndex = _selectedIndex == index ? null : index);
  }

  Widget _buildEmpty() {
    return PremiumCard(
      child: SizedBox(
        height: 280,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Text(
              'No performance data available',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.25),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// CustomPainter
// ══════════════════════════════════════════════════════════════════

class _PerformanceMatrixPainter extends CustomPainter {
  final List<PerformancePointVO> points;
  final List<double> cumPnl;
  final int? selectedIndex;
  final double animProgress;

  _PerformanceMatrixPainter({
    required this.points,
    required this.cumPnl,
    required this.selectedIndex,
    required this.animProgress,
  });

  static const _pl = 50.0;
  static const _pr = 44.0;
  static const _pt = 20.0;
  static const _pb = 24.0;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final n = points.length;
    final cW = size.width - _pl - _pr;
    final cH = size.height - _pt - _pb;
    final slotW = cW / n;
    final barW = math.min(24.0, slotW * 0.55);

    final maxVol = points.map((p) => p.volume).fold(1.0, math.max);
    final pnlAbs = cumPnl.map((v) => v.abs()).fold(1.0, math.max);

    final pnlMidY = _pt + cH / 2;
    double pnlY(double v) => pnlMidY - (v / pnlAbs) * (cH / 2) * 0.85;
    double volBarH(double v) => v == 0 ? 4.0 : (v / maxVol) * cH;
    double bx(int i) => _pl + i * slotW + (slotW - barW) / 2;
    double cx(int i) => _pl + i * slotW + slotW / 2;

    final pnlTicks = _niceTicksPnl(pnlAbs, 2);
    final volTicks = _niceTicksVol(maxVol, 3);

    _drawGrid(canvas, size, pnlTicks, pnlY);
    _drawPnlAxis(canvas, pnlTicks, pnlY);
    _drawVolAxis(canvas, size, cH, volTicks, maxVol);
    _drawVolumeBars(canvas, cH, n, slotW, barW, maxVol, bx, volBarH);

    if (selectedIndex != null) {
      _drawSelectedBarCrt(canvas, cH, barW, bx, volBarH);
      _drawHoverLine(canvas, cx(selectedIndex!), cH);
    }

    _drawPnlComposite(canvas, size, n, slotW, cH, pnlY, cx);
    _drawDataPoints(canvas, n, cumPnl, cx, pnlY);
    _drawXAxis(canvas, size, n, cx);

    if (selectedIndex != null) {
      _drawTooltip(canvas, size, cx, pnlY);
    }
  }

  void _drawGrid(Canvas canvas, Size size, List<double> ticks,
      double Function(double) pnlY) {
    final guidePaint = Paint()
      ..color = const Color(0x0FFF9900)
      ..strokeWidth = 1;
    final shadowPaint = Paint()
      ..color = const Color(0x4D000000)
      ..strokeWidth = 1;

    for (final tick in ticks) {
      final y = pnlY(tick);
      if (y < _pt - 5 || y > size.height - _pb + 5) continue;
      canvas.drawLine(Offset(_pl, y), Offset(size.width - _pr, y), guidePaint);
      canvas.drawLine(
          Offset(_pl, y + 2), Offset(size.width - _pr, y + 2), shadowPaint);
    }
  }

  void _drawPnlAxis(
      Canvas canvas, List<double> ticks, double Function(double) pnlY) {
    for (final tick in ticks) {
      final y = pnlY(tick);
      if (y < _pt - 5 || y > _pt + (280 - _pt - _pb) + 5) continue;
      final tp = TextPainter(
        text: TextSpan(
          text: _fmtPnlAxis(tick),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: const Color(0xFFFF9E1A).withValues(alpha: 0.4),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(_pl - tp.width - 8, y - tp.height / 2));
    }
  }

  void _drawVolAxis(Canvas canvas, Size size, double cH, List<double> ticks,
      double maxVol) {
    for (final tick in ticks) {
      final y = _pt + cH - (tick / maxVol) * cH;
      if (y < _pt - 5 || y > _pt + cH + 5) continue;
      final tp = TextPainter(
        text: TextSpan(
          text: _fmtVolAxis(tick),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.2),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(size.width - _pr + 8, y - tp.height / 2));
    }
  }

  void _drawVolumeBars(
    Canvas canvas,
    double cH,
    int n,
    double slotW,
    double barW,
    double maxVol,
    double Function(int) bx,
    double Function(double) volBarH,
  ) {
    for (int i = 0; i < n; i++) {
      final h = volBarH(points[i].volume) * animProgress;
      final barTop = _pt + cH - h;
      final x = bx(i);
      final isEmpty = points[i].volume == 0;

      double opacity;
      if (selectedIndex == null) {
        opacity = isEmpty ? 0.25 : 1.0;
      } else if (selectedIndex == i) {
        opacity = 0.15;
      } else {
        opacity = isEmpty ? 0.15 : 0.55;
      }

      final rx = n > 16 ? math.min(3.0, barW / 5) : math.min(6.0, barW / 3);
      final rect = RRect.fromRectAndCorners(
        Rect.fromLTWH(x, barTop, barW, h),
        topLeft: Radius.circular(rx),
        topRight: Radius.circular(rx),
      );

      final barPaint = Paint()
        ..shader = ui.Gradient.linear(
          Offset(x, _pt + cH),
          Offset(x, barTop),
          [const Color(0xB30A0A0A), const Color(0xB3141414)],
        );

      canvas.save();
      canvas.saveLayer(
          rect.outerRect, Paint()..color = Color.fromRGBO(0, 0, 0, opacity));
      canvas.drawRRect(rect, barPaint);
      canvas.restore();
      canvas.restore();
    }
  }

  void _drawSelectedBarCrt(
    Canvas canvas,
    double cH,
    double barW,
    double Function(int) bx,
    double Function(double) volBarH,
  ) {
    final i = selectedIndex!;
    final h = volBarH(points[i].volume) * animProgress;
    final barTop = _pt + cH - h;
    final x = bx(i);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x - 6, barTop - 6, barW + 12, h + 12),
        const Radius.circular(10),
      ),
      Paint()
        ..color = kPremiumOrange.withValues(alpha: 0.14)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x - 3, barTop - 3, barW + 6, h + 6),
        const Radius.circular(8),
      ),
      Paint()
        ..color = kPremiumOrange.withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x - 1, barTop - 1, barW + 2, h + 2),
        const Radius.circular(7),
      ),
      Paint()
        ..color = const Color(0xFFFFB020).withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5),
    );

    final crtRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(x, barTop, barW, h),
      const Radius.circular(6),
    );
    canvas.drawRRect(
      crtRect,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(x, _pt + cH),
          Offset(x, barTop),
          [
            const Color(0xFF5A3400),
            const Color(0xFFA06000),
            const Color(0xFFFFD098),
          ],
          [0.0, 0.5, 1.0],
        ),
    );

    final scanPaint = Paint()
      ..color = const Color(0x40000000)
      ..strokeWidth = 1;
    canvas.save();
    canvas.clipRRect(crtRect);
    for (double y = barTop; y < barTop + h; y += 3) {
      canvas.drawLine(Offset(x, y), Offset(x + barW, y + 1), scanPaint);
    }
    canvas.restore();

    final overH = math.min(h * 0.25, 40.0);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x, barTop, barW, overH),
        const Radius.circular(6),
      ),
      Paint()
        ..color = const Color(0x40FFE0B0)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5),
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x + 2, barTop + 1, barW - 4, 2),
        const Radius.circular(1),
      ),
      Paint()..color = const Color(0xB3FFE0B0),
    );
  }

  void _drawHoverLine(Canvas canvas, double x, double cH) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..strokeWidth = 1;
    const dashLen = 3.0;
    for (double y = _pt; y < _pt + cH; y += dashLen * 2) {
      canvas.drawLine(
        Offset(x, y),
        Offset(x, math.min(y + dashLen, _pt + cH)),
        paint,
      );
    }
  }

  void _drawPnlComposite(
    Canvas canvas,
    Size size,
    int n,
    double slotW,
    double cH,
    double Function(double) pnlY,
    double Function(int) cx,
  ) {
    if (cumPnl.length < 2) return;

    final linePath = Path();
    final areaPath = Path();
    final bottomY = _pt + cH;

    final visibleCount = (animProgress * n).ceil().clamp(1, n);

    final firstX = cx(0);
    final firstY = pnlY(cumPnl[0]);
    linePath.moveTo(firstX, firstY);
    areaPath.moveTo(firstX, bottomY);
    areaPath.lineTo(firstX, firstY);

    double lastX = firstX;
    for (int i = 1; i < visibleCount; i++) {
      final x = cx(i);
      final y = pnlY(cumPnl[i]);
      linePath.lineTo(x, y);
      areaPath.lineTo(x, y);
      lastX = x;
    }
    areaPath.lineTo(lastX, bottomY);
    areaPath.close();

    final areaRect = Rect.fromLTWH(_pl, _pt, size.width - _pl - _pr, cH);
    canvas.save();
    canvas.clipRect(areaRect);

    canvas.drawPath(
      areaPath,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(0, _pt),
          Offset(0, bottomY),
          [const Color(0x26FFB020), const Color(0x00FFB020)],
        ),
    );

    canvas.drawPath(
      linePath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..color = const Color(0xFFFF9E1A).withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    canvas.drawPath(
      linePath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..shader = ui.Gradient.linear(
          Offset(_pl, 0),
          Offset(size.width - _pr, 0),
          [
            const Color(0xFFFF9E1A),
            const Color(0xFFFFC260),
            const Color(0xFFFF9E1A),
          ],
          [0.0, 0.5, 1.0],
        ),
    );

    canvas.restore();
  }

  void _drawDataPoints(
    Canvas canvas,
    int n,
    List<double> cumPnl,
    double Function(int) cx,
    double Function(double) pnlY,
  ) {
    final visibleCount = (animProgress * n).ceil().clamp(0, n);
    int peakIdx = 0;
    for (int i = 1; i < cumPnl.length; i++) {
      if (cumPnl[i] > cumPnl[peakIdx]) peakIdx = i;
    }

    for (int i = 0; i < visibleCount; i++) {
      final x = cx(i);
      final y = pnlY(cumPnl[i]);
      final isActive = i == selectedIndex;
      final isPeak = i == peakIdx;

      if (isActive) {
        canvas.drawCircle(
          Offset(x, y),
          12,
          Paint()
            ..color = const Color(0xFFFFB020).withValues(alpha: 0.4)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
        );
      }

      canvas.drawCircle(
        Offset(x, y),
        isActive ? 7 : 5,
        Paint()..color = const Color(0xFF030303),
      );

      canvas.drawCircle(
        Offset(x, y),
        isActive ? 7 : 5,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = isActive
              ? 4
              : isPeak
                  ? 3.5
                  : 3
          ..color = isActive
              ? Colors.white
              : isPeak
                  ? const Color(0xFFFFD173)
                  : const Color(0xFFFFB020),
      );
    }
  }

  void _drawXAxis(Canvas canvas, Size size, int n, double Function(int) cx) {
    // 根据实际绘图区域宽度动态计算标签间隔
    final cW = size.width - _pl - _pr;
    final maxLabels = (cW / 45).floor().clamp(1, n);
    final labelEvery = (n / maxLabels).ceil();

    for (int i = 0; i < n; i++) {
      if (i % labelEvery != 0) continue;
      final x = cx(i);
      final tp = TextPainter(
        text: TextSpan(
          text: points[i].label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.25),
            letterSpacing: 0.8,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, size.height - _pb + 6));
    }
  }

  void _drawTooltip(
    Canvas canvas,
    Size size,
    double Function(int) cx,
    double Function(double) pnlY,
  ) {
    final i = selectedIndex!;
    final ptData = points[i];
    final pnlVal = cumPnl[i];
    final isProfit = pnlVal >= 0;
    final x = cx(i);
    final y = pnlY(pnlVal);

    final pnlStr = '${isProfit ? "+" : "−"}\$${_compactNumber(pnlVal.abs())}';
    final volStr = '\$${_compactNumber(ptData.volume)}';

    final pnlTp = TextPainter(
      text:
          TextSpan(text: 'P&L $pnlStr', style: const TextStyle(fontSize: 11)),
      textDirection: TextDirection.ltr,
    )..layout();
    final volTp = TextPainter(
      text:
          TextSpan(text: 'Vol $volStr', style: const TextStyle(fontSize: 11)),
      textDirection: TextDirection.ltr,
    )..layout();

    final tooltipW = pnlTp.width + volTp.width + 60;
    const tooltipH = 28.0;
    const arrowH = 5.0;

    var tx = x - tooltipW / 2;
    tx = tx.clamp(_pl, size.width - _pr - tooltipW);
    final ty = y - tooltipH - arrowH - 8;

    final bgRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(tx, ty, tooltipW, tooltipH),
      const Radius.circular(8),
    );
    canvas.drawRRect(bgRect, Paint()..color = const Color(0xEB121214));
    canvas.drawRRect(
      bgRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = Colors.white.withValues(alpha: 0.06),
    );

    final arrowPath = Path()
      ..moveTo(x - 5, ty + tooltipH)
      ..lineTo(x, ty + tooltipH + arrowH)
      ..lineTo(x + 5, ty + tooltipH)
      ..close();
    canvas.drawPath(arrowPath, Paint()..color = const Color(0xEB121214));

    var contentX = tx + 10.0;
    final contentY = ty + tooltipH / 2;

    canvas.drawCircle(
      Offset(contentX + 3, contentY),
      3,
      Paint()..color = const Color(0xFFFFB020),
    );
    contentX += 10;

    _drawText(canvas, 'P&L ', contentX, contentY,
        Colors.white.withValues(alpha: 0.4), 11);
    contentX += 26;

    _drawText(canvas, pnlStr, contentX, contentY,
        isProfit ? kPremiumGreen : kPremiumRed, 12, FontWeight.w600);
    contentX += pnlTp.width - 10;

    contentX += 8;
    canvas.drawLine(
      Offset(contentX, ty + 7),
      Offset(contentX, ty + tooltipH - 7),
      Paint()..color = Colors.white.withValues(alpha: 0.06),
    );
    contentX += 8;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(contentX, contentY - 3, 6, 6),
        const Radius.circular(1),
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.2),
    );
    contentX += 10;

    _drawText(canvas, 'Vol ', contentX, contentY,
        Colors.white.withValues(alpha: 0.4), 11);
    contentX += 22;

    _drawText(canvas, volStr, contentX, contentY,
        Colors.white.withValues(alpha: 0.7), 12, FontWeight.w600);
  }

  void _drawText(Canvas canvas, String text, double x, double centerY,
      Color color, double fontSize,
      [FontWeight weight = FontWeight.w500]) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(fontSize: fontSize, fontWeight: weight, color: color),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(x, centerY - tp.height / 2));
  }

  // ── 工具函数 ──

  static List<double> _niceTicksPnl(double pnlAbs, int targetTicks) {
    final step = _niceStep(pnlAbs, targetTicks);
    final ticks = <double>[];
    for (double t = -(pnlAbs / step).ceil() * step;
        t <= pnlAbs * 1.01;
        t += step) {
      final rounded = t.roundToDouble();
      if (ticks.isEmpty || rounded != ticks.last) ticks.add(rounded);
    }
    return ticks;
  }

  static List<double> _niceTicksVol(double maxVol, int targetTicks) {
    final step = _niceStep(maxVol, targetTicks);
    final ticks = <double>[];
    for (double t = 0; t <= maxVol * 1.05; t += step) {
      ticks.add(t.roundToDouble());
    }
    return ticks;
  }

  static double _niceStep(double max, int targetTicks) {
    if (max <= 0) return 1;
    final rough = max / targetTicks;
    final mag =
        math.pow(10, (math.log(rough) / math.ln10).floorToDouble()).toDouble();
    final r = rough / mag;
    final nice = r <= 1.5
        ? 1
        : r <= 3
            ? 2
            : r <= 7
                ? 5
                : 10;
    return nice * mag;
  }

  static String _fmtPnlAxis(double v) {
    final a = v.abs();
    final sign = v < 0
        ? '-'
        : v > 0
            ? '+'
            : '';
    if (a >= 1e6) return '$sign\$${(a / 1e6).toStringAsFixed(1)}M';
    if (a >= 1e3) return '$sign\$${(a / 1e3).toStringAsFixed(0)}K';
    if (a == 0) return '\$0';
    return '$sign\$${a.round()}';
  }

  static String _fmtVolAxis(double v) {
    if (v >= 1e6) return '\$${(v / 1e6).toStringAsFixed(1)}M';
    if (v >= 1e3) return '\$${(v / 1e3).toStringAsFixed(0)}K';
    return '\$${v.round()}';
  }

  @override
  bool shouldRepaint(covariant _PerformanceMatrixPainter old) {
    return old.animProgress != animProgress ||
        old.selectedIndex != selectedIndex ||
        old.points != points;
  }
}

String _compactNumber(double value) {
  if (value >= 1e6) return '${(value / 1e6).toStringAsFixed(1)}M';
  if (value >= 1e3) return '${(value / 1e3).toStringAsFixed(1)}K';
  return value.toStringAsFixed(0);
}
