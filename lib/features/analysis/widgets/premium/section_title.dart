import 'package:finality/theme/attrs/druk_wide_font.dart';
import 'package:flutter/material.dart';

/// BEHAVIOR / EXPOSURE / RHYTHM 等区域的分段标题
///
/// 大写字母，带颜色条和可选右侧插槽
class PremiumSectionTitle extends StatelessWidget {
  final String title;

  const PremiumSectionTitle({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFFFFCC80),
            letterSpacing: 0.8,
          ).toDrukWide(),
        ));
  }
}
