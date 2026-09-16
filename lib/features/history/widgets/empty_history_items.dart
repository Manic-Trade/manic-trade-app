import 'package:finality/generated/assets.dart';
import 'package:finality/theme/attrs/text_color_theme.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

/// 活跃仓位为空时的占位组件
///
/// 设计稿：居中图标 + "No active positions" + "Go to Trade" 按钮
class EmptyHistoryItems extends StatelessWidget {
  final String message;
  const EmptyHistoryItems({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
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
              message,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.2142,
                color: context.textColorTheme.textColorHelper,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
