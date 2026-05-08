import 'package:finality/common/utils/color_scheme_extensions.dart';
import 'package:finality/common/widgets/touchable.dart';
import 'package:finality/generated/assets.dart';
import 'package:finality/theme/attrs/text_color_theme.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

/// 已结算仓位加载失败时的占位组件
///
/// 设计稿：居中图标 + "Loading error. Tap to refresh." + "Retry" 按钮
class ErrorSettledPositions extends StatelessWidget {
  final Function()? onRetry;
  final String? message;

  const ErrorSettledPositions({this.onRetry, this.message, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Dimens.vGap4,
          SvgPicture.asset(
            Assets.svgsErrorNetworkPic,
            width: 40,
            height: 40,
            color: context.textColorTheme.textColorHelper,
          ),
          Dimens.vGap8,
          Text(
            message ?? 'Loading error. Tap to refresh.',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.2142,
              color: context.textColorTheme.textColorHelper,
            ),
          ),
          Dimens.vGap20,
          Touchable.plain(
            onTap: onRetry,
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
                  'Retry',
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
