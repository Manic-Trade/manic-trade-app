import 'package:finality/common/widgets/touchable.dart';
import 'package:finality/generated/assets.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:remixicon/remixicon.dart';

/// 品牌橙色（与 kPremiumOrange 相同）
const kWrOrange = Color(0xFFFF9900);

/// Win Rate 卡片通用 Header
///
/// 左侧：准星图标 + "WIN RATE" 标题
/// 右侧：SHARE 按钮
class WrCardHeader extends StatelessWidget {
  final VoidCallback? onShareTap;

  const WrCardHeader({super.key, this.onShareTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(RemixIcons.crosshair_2_line,
                size: 16, color: kWrOrange.withValues(alpha: 0.5)),
            Dimens.hGap8,
            const Text(
              'WIN RATE',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: kWrOrange,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        Touchable.plain(
          onTap: onShareTap,
          child: Container(
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: kWrOrange.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(Assets.svgsRemixShareLine,
                    width: 16,
                    height: 16,
                    colorFilter: ColorFilter.mode(
                        kWrOrange.withValues(alpha: 0.6), BlendMode.srcIn)),
                Dimens.hGap8,
                Text(
                  'SHARE',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: kWrOrange.withValues(alpha: 0.6),
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
