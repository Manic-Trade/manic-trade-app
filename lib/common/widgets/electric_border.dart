import 'dart:math';

import 'package:finality/common/utils/simplex_noise.dart';
import 'package:flutter/material.dart';

/// 电流特效边框 —— 在子 Widget 周围绘制带噪声扭曲的发光边框
///
/// 用法:
/// ```dart
/// ElectricBorder(
///   borderRadius: 16,
///   child: YourCard(...),
/// )
/// ```
class ElectricBorder extends StatefulWidget {
  final Widget child;

  /// 圆角半径
  final double borderRadius;

  /// 电流颜色
  final Color color;

  /// 噪声位移幅度（越大越"狂野"）
  final double displacement;

  /// 边框宽度
  final double borderWidth;

  /// 外发光模糊半径
  final double glowRadius;

  /// 外发光颜色不透明度
  final double glowOpacity;

  /// 动画周期（一轮噪声滚动的时长）
  final Duration animationDuration;

  /// 噪声频率（越小波浪越大越少，越大波浪越密越小）
  final double noiseFrequency;

  /// 外部 padding（为电流扭曲留出空间，避免被裁切）
  final double overflowPadding;

  const ElectricBorder({
    super.key,
    required this.child,
    this.borderRadius = 16,
    this.color = const Color(0xFFE06B00),
    this.displacement = 6.0,
    this.borderWidth = 2.0,
    this.glowRadius = 8.0,
    this.glowOpacity = 0.5,
    this.noiseFrequency = 0.04,
    this.animationDuration = const Duration(seconds: 4),
    this.overflowPadding = 10.0,
  });

  @override
  State<ElectricBorder> createState() => _ElectricBorderState();
}

class _ElectricBorderState extends State<ElectricBorder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final _noise1 = SimplexNoise(42);
  final _noise2 = SimplexNoise(137);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pad = widget.overflowPadding;
    return Padding(
      // 为电流溢出留空间
      padding: EdgeInsets.all(pad),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            foregroundPainter: _ElectricBorderPainter(
              progress: _controller.value,
              noise1: _noise1,
              noise2: _noise2,
              borderRadius: widget.borderRadius,
              color: widget.color,
              displacement: widget.displacement,
              borderWidth: widget.borderWidth,
              glowRadius: widget.glowRadius,
              glowOpacity: widget.glowOpacity,
              noiseFrequency: widget.noiseFrequency,
            ),
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}

class _ElectricBorderPainter extends CustomPainter {
  final double progress;
  final SimplexNoise noise1;
  final SimplexNoise noise2;
  final double borderRadius;
  final Color color;
  final double displacement;
  final double borderWidth;
  final double glowRadius;
  final double glowOpacity;
  final double noiseFrequency;

  _ElectricBorderPainter({
    required this.progress,
    required this.noise1,
    required this.noise2,
    required this.borderRadius,
    required this.color,
    required this.displacement,
    required this.borderWidth,
    required this.glowRadius,
    required this.glowOpacity,
    required this.noiseFrequency,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    // 沿圆角矩形路径采样点
    final points = _sampleRoundedRect(rrect, stepSize: 2.0);
    if (points.isEmpty) return;

    // 对每个点做噪声位移
    final time = progress * 2 * pi;
    final displaced = <Offset>[];
    for (var i = 0; i < points.length; i++) {
      final p = points[i];
      final normal = _normalAt(points, i);

      // 两层噪声叠加，模拟 web 端多层 feTurbulence 合成
      final n1 = noise1.noise2D(
        p.dx * noiseFrequency + cos(time) * 2,
        p.dy * noiseFrequency + sin(time) * 2,
      );
      final n2 = noise2.noise2D(
        p.dx * noiseFrequency * 1.5 + sin(time * 0.7) * 3,
        p.dy * noiseFrequency * 1.5 + cos(time * 0.7) * 3,
      );

      final d = (n1 + n2 * 0.6) * displacement;
      displaced.add(Offset(p.dx + normal.dx * d, p.dy + normal.dy * d));
    }

    // 构建平滑路径
    final path = _buildSmoothPath(displaced);

    // 第 1 层：外发光（宽模糊）
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth + 4
      ..color = color.withValues(alpha: glowOpacity)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, glowRadius);
    canvas.drawPath(path, glowPaint);

    // 第 2 层：中等发光
    final midGlowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth + 2
      ..color = color.withValues(alpha: glowOpacity * 0.8)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawPath(path, midGlowPaint);

    // 第 3 层：核心边框线
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..color = color;
    canvas.drawPath(path, borderPaint);

    // 第 4 层：毛刺/纤维层 —— 多条带高频随机抖动的细线，模拟毛线质感
    final fuzzRng = Random(progress.hashCode);
    for (var layer = 0; layer < 3; layer++) {
      final fuzzPath = Path();
      final normal0 = _normalAt(displaced, 0);
      final j0 = (fuzzRng.nextDouble() - 0.5) * 4.0;
      fuzzPath.moveTo(
        displaced[0].dx + normal0.dx * j0,
        displaced[0].dy + normal0.dy * j0,
      );
      for (var i = 1; i < displaced.length; i++) {
        final p = displaced[i];
        final normal = _normalAt(displaced, i);
        final jitter = (fuzzRng.nextDouble() - 0.5) * 4.0;
        fuzzPath.lineTo(
          p.dx + normal.dx * jitter,
          p.dy + normal.dy * jitter,
        );
      }
      fuzzPath.close();

      final fuzzPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..color = color.withValues(alpha: 0.45);
      canvas.drawPath(fuzzPath, fuzzPaint);
    }
  }

  /// 沿 RRect 的边缘等距采样点
  List<Offset> _sampleRoundedRect(RRect rrect, {double stepSize = 2.0}) {
    // 用 Path 的 computeMetrics 来精确采样
    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return [];

    final result = <Offset>[];
    for (final metric in metrics) {
      final length = metric.length;
      var dist = 0.0;
      while (dist < length) {
        final tangent = metric.getTangentForOffset(dist);
        if (tangent != null) {
          result.add(tangent.position);
        }
        dist += stepSize;
      }
    }
    return result;
  }

  /// 计算点 i 处的外法线方向（单位向量）
  Offset _normalAt(List<Offset> points, int i) {
    final prev = points[(i - 1 + points.length) % points.length];
    final next = points[(i + 1) % points.length];
    final tangent = next - prev;
    final len = tangent.distance;
    if (len < 0.001) return Offset.zero;
    // 法线 = 切线旋转 -90°（朝外）
    return Offset(tangent.dy / len, -tangent.dx / len);
  }

  /// 将点集构建为平滑闭合路径
  Path _buildSmoothPath(List<Offset> pts) {
    if (pts.length < 3) return Path();

    final path = Path();
    path.moveTo(pts[0].dx, pts[0].dy);
    for (var i = 1; i < pts.length; i++) {
      path.lineTo(pts[i].dx, pts[i].dy);
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(_ElectricBorderPainter old) => old.progress != progress;
}
