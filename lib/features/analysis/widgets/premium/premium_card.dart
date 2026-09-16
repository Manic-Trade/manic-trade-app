import 'package:flutter/material.dart';

/// 品牌橙色
const kPremiumOrange = Color(0xFFFF9900);

/// 正向绿
const kPremiumGreen = Color(0xFF00D385);

/// 负向红
const kPremiumRed = Color(0xFFFF412C);

/// Premium 通用 CRT 风格卡片容器
///
/// 包含：深色渐变背景 + amber 边框 + 顶部高亮线 + 扫描线纹理
class PremiumCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;

  /// 是否使用 hero 级别的光晕（更强的 boxShadow）
  final bool heroGlow;

  const PremiumCard({
    super.key,
    required this.child,
    this.borderRadius = 14,
    this.padding,
    this.heroGlow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: kPremiumOrange.withValues(alpha: heroGlow ? 0.1 : 0.08),
        ),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0C0A06),
            Color(0xFF0A0A0A),
            Color(0xFF080808),
          ],
          stops: [0.0, 0.5, 1.0],
        ),
        boxShadow: heroGlow
            ? [
                BoxShadow(
                  color: kPremiumOrange.withValues(alpha: 0.06),
                  blurRadius: 60,
                ),
                const BoxShadow(
                  color: Color(0x80000000),
                  blurRadius: 32,
                  offset: Offset(0, 8),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 24,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // 扫描线纹理
          Positioned.fill(
            child: CustomPaint(painter: const PremiumScanLinesPainter()),
          ),
          // 顶部 1px amber 高亮线
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 1,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    kPremiumOrange.withValues(alpha: 0),
                    kPremiumOrange.withValues(alpha: 0.12),
                    kPremiumOrange.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          // 内容
          if (padding != null) Padding(padding: padding!, child: child) else child,
        ],
      ),
    );
  }
}

/// CRT 扫描线纹理
class PremiumScanLinesPainter extends CustomPainter {
  const PremiumScanLinesPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const spacing = 3.0;
    final paint = Paint()
      ..color = kPremiumOrange.withValues(alpha: 0.03)
      ..strokeWidth = 0.5;

    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
