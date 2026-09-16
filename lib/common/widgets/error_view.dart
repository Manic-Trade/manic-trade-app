import 'package:finality/common/utils/color_scheme_extensions.dart';
import 'package:finality/common/widgets/touchable.dart';
import 'package:finality/theme/attrs/text_color_theme.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../generated/assets.dart';

class ErrorView extends StatelessWidget {
  final Function()? onRetry;
  final String? message;
  final Color? buttonBackgroundColor;

  const ErrorView(
      {this.onRetry, this.message, this.buttonBackgroundColor, super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: Dimens.edgeInsetsA16,
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
            Dimens.vGap14,
            Text(
              message ?? 'Loading error. Tap to retry.',
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
                width: 144,
                decoration: BoxDecoration(
                  color: buttonBackgroundColor ??
                      context.colorScheme.surfaceContainerHigh,
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
      ),
    );
  }
}
