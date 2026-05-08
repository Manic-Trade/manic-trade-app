import 'package:flutter/widgets.dart';

/// 渐变边框容器
/// 用 CustomPaint 在 child 外层绘制渐变描边，支持圆角。
class GradientBorderBox extends StatelessWidget {
  const GradientBorderBox({
    super.key,
    required this.child,
    required this.gradient,
    this.borderRadius = BorderRadius.zero,
    this.strokeWidth = 1.0,
  });

  final Widget child;
  final Gradient gradient;
  final BorderRadius borderRadius;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GradientBorderPainter(
        gradient: gradient,
        borderRadius: borderRadius,
        strokeWidth: strokeWidth,
      ),
      child: child,
    );
  }
}

class _GradientBorderPainter extends CustomPainter {
  const _GradientBorderPainter({
    required this.gradient,
    required this.borderRadius,
    required this.strokeWidth,
  });

  final Gradient gradient;
  final BorderRadius borderRadius;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = borderRadius.toRRect(rect);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..shader = gradient.createShader(rect);
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(_GradientBorderPainter oldDelegate) =>
      gradient != oldDelegate.gradient ||
      borderRadius != oldDelegate.borderRadius ||
      strokeWidth != oldDelegate.strokeWidth;
}
