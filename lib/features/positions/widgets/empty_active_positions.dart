import 'package:finality/common/utils/color_scheme_extensions.dart';
import 'package:finality/common/widgets/touchable.dart';
import 'package:finality/generated/assets.dart';
import 'package:finality/theme/attrs/text_color_theme.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

/// 活跃仓位为空时的占位组件
///
/// 设计稿：居中图标 + "No active positions" + "Go to Trade" 按钮
class EmptyActivePositions extends StatelessWidget {
  final VoidCallback onGoToTrade;

  const EmptyActivePositions({super.key, required this.onGoToTrade});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Dimens.vGap4,
          // 图标
          SvgPicture.asset(
            Assets.svgsEmptyPositionsPic,
            width: 40,
            height: 40,
            color: context.textColorTheme.textColorHelper,
          ),
          Dimens.vGap8,
          // 文字
          Text(
            'No active positions',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.2142,
              color: context.textColorTheme.textColorHelper,
            ),
          ),
          Dimens.vGap20,
          // Go to Trade 按钮
          Touchable.plain(
            onTap: onGoToTrade,
            child: Container(
              height: 40,
              width: double.infinity,
              decoration: BoxDecoration(
                color: context.colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: context.colorScheme.outlineVariant,
                  width: 0.5,
                ),
              ),
              child: Center(
                child: Text(
                  'Go to Trade',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: context.textColorTheme.textColorTertiary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
