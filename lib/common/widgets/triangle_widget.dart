import 'package:flutter/material.dart';

class TriangleWidget extends StatelessWidget {
  final Color color;
  final double width;
  final double height;
  final bool isHorizontal; // 是否水平
  final bool pointingUp; //垂直时： 是否向上 水平时： 是否向左
  final double offset;

  const TriangleWidget({
    super.key,
    required this.color,
    this.width = 10,
    this.height = 5,
    this.isHorizontal = false,
    this.pointingUp = true,
    this.offset = 0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: TrianglePainter(
        color: color,
        isHorizontal: isHorizontal,
        pointingStart: pointingUp,
        offset: offset,
      ),
    );
  }
}

class TrianglePainter extends CustomPainter {
  final Color color;
  final bool isHorizontal;
  final bool pointingStart;
  final double offset;

  TrianglePainter({
    required this.color,
    required this.isHorizontal,
    required this.pointingStart,
    required this.offset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    if (isHorizontal) {
      if (pointingStart) {
        path.moveTo(size.width, 0); // 右上角
        path.lineTo(size.width, size.height); // 右下角
        path.lineTo(0, size.height / 2 + offset); // 左边顶点
      } else {
        path.moveTo(0, 0); // 左上角
        path.lineTo(0, size.height); // 左下角
        path.lineTo(size.width, size.height / 2 + offset); // 右边顶点
      }
    } else {
      if (pointingStart) {
        path.moveTo(0, size.height); // 左下角
        path.lineTo(size.width / 2 + offset, 0); // 顶部顶点
        path.lineTo(size.width, size.height); // 右下角
      } else {
        path.moveTo(0, 0); // 左上角
        path.lineTo(size.width, 0); // 右上角
        path.lineTo(size.width / 2 + offset, size.height); // 底部顶点
      }
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant TrianglePainter oldDelegate) {
    return color != oldDelegate.color ||
        isHorizontal != oldDelegate.isHorizontal ||
        pointingStart != oldDelegate.pointingStart ||
        offset != oldDelegate.offset;
  }
}
