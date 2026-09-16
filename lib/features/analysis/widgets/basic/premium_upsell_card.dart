import 'dart:ui' as ui;

import 'package:finality/common/utils/color_scheme_extensions.dart';
import 'package:finality/common/widgets/electric_border.dart';
import 'package:finality/common/widgets/touchable.dart';
import 'package:finality/generated/assets.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

const _kFeatures = [
  'Track Equity Growth',
  'Master Market Bias',
  'Optimize Expiry Timing',
  'Identify Top Assets',
];

/// Pro Analytics 推广卡片
class PremiumUpsellCard extends StatelessWidget {
  /// 点击 CTA 按钮回调。当前版本用于打开 VIP 解锁 sheet（邀请 / 充值二选一）。
  final VoidCallback? onDepositTap;

  const PremiumUpsellCard({
    super.key,
    this.onDepositTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElectricBorder(
      displacement: 3.0,
      borderWidth: 1,
      glowRadius: 10.0,
      glowOpacity: 0.57,
      overflowPadding: 16,
      noiseFrequency: 0.025,
      child: CustomPaint(
        painter: _UpsellCardBgPainter(),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: OverflowBox(
                        maxWidth: 36,
                        maxHeight: 36,
                        child: SvgPicture.asset(
                          Assets.svgsIcUnlockProAnalytics,
                          width: 36,
                          height: 36,
                        ),
                      ),
                    ),
                    Dimens.hGap8,
                    const Text(
                      'Unlock Pro Analytics',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              Dimens.vGap8,
              // 特性列表（2列）
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: _buildFeatureGrid(),
              ),
              Dimens.vGap16,
              Touchable.plain(
                onTap: onDepositTap,
                child: SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: Container(
                    decoration: BoxDecoration(
                      color: context.colorScheme.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text(
                        'Become VIP 1 to Unlock',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _featureItem(_kFeatures[0])),
            Dimens.hGap10,
            Expanded(child: _featureItem(_kFeatures[1])),
          ],
        ),
        Dimens.vGap4,
        Row(
          children: [
            Expanded(child: _featureItem(_kFeatures[2])),
            Dimens.hGap10,
            Expanded(child: _featureItem(_kFeatures[3])),
          ],
        ),
      ],
    );
  }

  Widget _featureItem(String text) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 4,
          decoration: BoxDecoration(
            color: const Color(0xFFE06B00),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE06B00).withValues(alpha: 0.6),
                blurRadius: 3,
              ),
            ],
          ),
        ),
        Dimens.hGap6,
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.35),
            ),
          ),
        ),
      ],
    );
  }
}

/// 绘制卡片背景：#121111 底色 + 右下角和左上角的径向橙色光晕
class _UpsellCardBgPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(16),
    );
    canvas.save();
    canvas.clipRRect(rrect);

    // 底色
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFF121111),
    );

    // 右下角径向光晕
    final brGradient = ui.Gradient.radial(
      Offset(size.width * 0.96, size.height * 0.83),
      size.width * 0.55,
      [
        const Color(0x40FF8525), // rgba(255,135,37,0.25)
        const Color(0x20CE6A18), // rgba(206,106,24,0.125)
        const Color(0x009D4C0A), // rgba(157,76,10,0)
      ],
      [0.0, 0.5, 1.0],
    );
    canvas.drawRect(
      Offset.zero & size,
      Paint()..shader = brGradient,
    );

    // 左上角径向光晕
    final tlGradient = ui.Gradient.radial(
      Offset(size.width * 0.08, size.height * 0.27),
      size.width * 0.45,
      [
        const Color(0x409D4C0A), // rgba(157,76,10,0.25)
        const Color(0x009D4C0A), // rgba(157,76,10,0)
      ],
      [0.0, 1.0],
    );
    canvas.drawRect(
      Offset.zero & size,
      Paint()..shader = tlGradient,
    );

    // 渐变边框
    // linear-gradient(90.57deg, #F2BE09 0.5%, #E06B00 18.63%, #E06B00 66.77%, #F2BE09 99.94%)
    canvas.restore(); // 先还原 clip，边框绘制在最上层
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..shader = ui.Gradient.linear(
        Offset.zero,
        Offset(size.width, 0),
        const [
          Color(0xFFF2BE09),
          Color(0xFFE06B00),
          Color(0xFFE06B00),
          Color(0xFFF2BE09),
        ],
        const [0.005, 0.1863, 0.6677, 0.9994],
      );
    final borderRRect = RRect.fromRectAndRadius(
      const Offset(1, 1) & Size(size.width - 2, size.height - 2),
      const Radius.circular(15),
    );

    // 发光层1: blur(4px)，模拟 web 端中等模糊光晕
    final glow1 = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4)
      ..shader = ui.Gradient.linear(
        Offset.zero,
        Offset(size.width, 0),
        const [
          Color(0xFFF2BE09),
          Color(0xFFE06B00),
          Color(0xFFE06B00),
          Color(0xFFF2BE09),
        ],
        const [0.005, 0.1863, 0.6677, 0.9994],
      );
    canvas.drawRRect(borderRRect, glow1);

    // 发光层2: blur(1px)，让边框边缘柔和
    final glow2 = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1)
      ..color = const Color(0xFFE06B00).withValues(alpha: 0.6);
    canvas.drawRRect(borderRRect, glow2);

    // 实线边框（最上层，保持清晰）
    canvas.drawRRect(borderRRect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
