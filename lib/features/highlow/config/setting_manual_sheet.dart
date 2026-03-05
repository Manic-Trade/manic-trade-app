import 'package:finality/common/utils/color_scheme_extensions.dart';
import 'package:finality/common/widgets/drag_handle.dart';
import 'package:finality/theme/app_color_theme.dart';
import 'package:finality/theme/attrs/text_color_theme.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/context_extensions.dart';

class SettingManualSheet extends StatelessWidget {
  final String title;
  final String description;
  final Widget? image;

  const SettingManualSheet({
    super.key,
    required this.title,
    required this.description,
    this.image,
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
                  Dimens.vGap16,
                  image ?? Dimens.emptyBox,
                  Dimens.vGap16,
                  Text(
                    description,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.textColorTheme.textColorTertiary,
                    ),
                  ),
                  Dimens.vGap16,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 显示 Duration 选择底部弹窗
Future<void> showSettingManualSheet(
  BuildContext context, {
  required String title,
  required String description,
  Widget? image,
}) {
  return showModalBottomSheet<void>(
    backgroundColor: Colors.transparent,
    elevation: 0,
    isScrollControlled: true,
    context: context,
    builder: (_) => SettingManualSheet(
      title: title,
      description: description,
      image: image,
    ),
  );
}
