import 'package:finality/common/utils/color_scheme_extensions.dart';
import 'package:finality/common/utils/haptic_feedback_utils.dart';
import 'package:finality/common/utils/localization_extensions.dart';
import 'package:finality/common/widgets/drag_handle.dart';
import 'package:finality/common/widgets/touchable.dart';
import 'package:finality/theme/app_color_theme.dart';
import 'package:finality/theme/attrs/text_color_theme.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/context_extensions.dart';

class FunctionDescriptionSheet extends StatelessWidget {
  final String title;
  final String description;
  const FunctionDescriptionSheet({
    super.key,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        border: Border(
          top: BorderSide(
            color: context.colorScheme.outlineVariant,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const DragHandle(),
            Padding(
              padding: Dimens.edgeInsetsA16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.textTheme.titleLarge?.copyWith(
                      color: context.appColors.bottomSheetTitle,
                    ),
                  ),
                  Dimens.vGap32,
                  Text(
                    description,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.textColorTheme.textColorTertiary,
                    ),
                  ),
                  Dimens.vGap32,
                  // Confirm 按钮
                  _buildConfirmButton(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmButton(BuildContext context) {
    return Touchable.button(
      child: SizedBox(
        width: double.infinity,
        height: 40,
        child: FilledButton(
          onPressed: () {
            HapticFeedbackUtils.lightImpact();
            Navigator.of(context).pop();
          },
          style: FilledButton.styleFrom(
            backgroundColor: context.colorScheme.primary,
            foregroundColor: context.colorScheme.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          child: Text(
            context.strings.action_ok,
            style: context.textTheme.labelMedium?.copyWith(
              color: context.colorScheme.onPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

/// 显示 Duration 选择底部弹窗
Future<void> showFunctionDescriptionSheet(
  BuildContext context, {
  required String title,
  required String description,
}) {
  return showModalBottomSheet<void>(
    backgroundColor: Colors.transparent,
    elevation: 0,
    isScrollControlled: true,
    context: context,
    builder: (_) => FunctionDescriptionSheet(
      title: title,
      description: description,
    ),
  );
}
