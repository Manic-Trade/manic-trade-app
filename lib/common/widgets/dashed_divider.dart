import 'package:flutter/material.dart';

/// A dashed line divider, API similar to [Divider].
class DashedDivider extends StatelessWidget {
  final double height;
  final double thickness;
  final double indent;
  final double endIndent;
  final Color? color;
  final double dashWidth;
  final double dashGap;
  final StrokeCap strokeCap;

  const DashedDivider({
    super.key,
    this.height = 1.0,
    this.thickness = 0.5,
    this.indent = 0,
    this.endIndent = 0,
    this.color,
    this.dashWidth = 3.0,
    this.dashGap = 2.0,
    this.strokeCap = StrokeCap.butt,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Padding(
        padding: EdgeInsets.only(left: indent, right: endIndent),
        child: CustomPaint(
          size: Size(double.infinity, thickness),
          painter: _DashedLinePainter(
            color: color ?? Theme.of(context).dividerColor,
            thickness: thickness,
            dashWidth: dashWidth,
            dashGap: dashGap,
            strokeCap: strokeCap,
          ),
        ),
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;
  final double thickness;
  final double dashWidth;
  final double dashGap;
  final StrokeCap strokeCap;

  _DashedLinePainter({
    required this.color,
    required this.thickness,
    required this.dashWidth,
    required this.dashGap,
    this.strokeCap = StrokeCap.butt,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke
      ..strokeCap = strokeCap;

    final y = size.height / 2;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, y), Offset(x + dashWidth, y), paint);
      x += dashWidth + dashGap;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter old) =>
      old.color != color ||
      old.thickness != thickness ||
      old.dashWidth != dashWidth ||
      old.dashGap != dashGap ||
      old.strokeCap != strokeCap;
}
