import 'package:finality/common/widgets/touchable.dart';
import 'package:finality/generated/assets.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

/// Active 计数徽章，点击切换 LivePositionBar 的横向展开/收起
class CountItem extends StatelessWidget {
  const CountItem({
    super.key,
    required this.count,
    required this.isBarExpanded,
    this.onToggle,
  });

  final int count;

  /// bar 是否横向展开（显示所有 items）
  final bool isBarExpanded;

  /// 切换展开/收起
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Touchable.plain(
      onTap: onToggle,
      child: Container(
        height: 30,
        padding:
            const EdgeInsets.only(left: 8.5, right: 4.5, top: 0.5, bottom: 0.5),
        decoration: BoxDecoration(
          borderRadius: Dimens.radius6,
          color: colorScheme.surfaceContainerHigh,
          border: Border.all(color: colorScheme.outline, width: 0.5),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 15,
              offset: Offset(0, 10),
              spreadRadius: -3,
            ),
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 6,
              offset: Offset(0, 4),
              spreadRadius: -4,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Active',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            Dimens.hGap4,
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colorScheme.primary,
              ),
            ),
            Dimens.hGap4,
            // 箭头图标：展开时朝左（旋转180度），收起时朝右
            Transform.rotate(
              angle: isBarExpanded ? 3.14159 : 0,
              child: SvgPicture.asset(
                Assets.svgsIcArrowRightCommonSmall,
                width: 12,
                height: 12,
                colorFilter: ColorFilter.mode(
                  colorScheme.onSurfaceVariant,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
