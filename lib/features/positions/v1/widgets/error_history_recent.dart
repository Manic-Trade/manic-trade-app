import 'package:finality/common/utils/color_scheme_extensions.dart';
import 'package:finality/common/widgets/touchable.dart';
import 'package:finality/theme/attrs/text_color_theme.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/material.dart';
import 'package:finality/common/utils/localization_extensions.dart';
import 'package:get/get_utils/src/extensions/context_extensions.dart';

class ErrorHistoryRecent extends StatelessWidget {
  final Function()? onRetry;
  final String? message;

  const ErrorHistoryRecent({this.onRetry, this.message, super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 300),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Dimens.vGap16,
            Icon(
              Icons.error,
              size: 56,
              color: context.textColorTheme.textColorHelper,
            ),
            Dimens.vGap8,
            Text(
              message ?? context.strings.error_default,
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
              onTap: onRetry,
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
                    context.strings.action_retry,
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
