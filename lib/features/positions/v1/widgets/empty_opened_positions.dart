import 'package:finality/common/utils/color_scheme_extensions.dart';
import 'package:finality/common/widgets/touchable.dart';
import 'package:flutter/material.dart';
import 'package:finality/common/utils/localization_extensions.dart';
import 'package:finality/theme/attrs/text_color_theme.dart';
import 'package:finality/theme/dimens.dart';
import 'package:get/get.dart';

class EmptyOpenedPositions extends StatelessWidget {
  final VoidCallback onGoToTrade;
  const EmptyOpenedPositions({super.key, required this.onGoToTrade});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 300),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Dimens.vGap16,
            Icon(
              Icons.swap_calls,
              size: 56,
              color: context.textColorTheme.textColorHelper,
            ),
            Dimens.vGap8,
            Text(
              context.strings.empty_message_holding_tokens,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: context.textColorTheme.textColorHelper,
                fontSize: 15,
                letterSpacing: 0,
              ),
            ),
            Dimens.vGap16,
            Touchable.plain(
              onTap: onGoToTrade,
              child: Container(
                height: 40,
                width: double.infinity,
                decoration: BoxDecoration(
                    color: context.colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                        color: context.colorScheme.outlineVariant, width: 0.5)),
                child: Center(
                  child: Text(
                    'Go to Trade',
                    style: context.textTheme.labelSmall?.copyWith(
                      color: context.textColorTheme.textColorTertiary,
                    ),
                  ),
                ),
              ),
            ),
            Dimens.vGap20,
          ],
        ),
      ),
    );
  }
}
