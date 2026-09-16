import 'package:finality/common/utils/color_scheme_extensions.dart';
import 'package:finality/common/utils/haptic_feedback_utils.dart';
import 'package:finality/common/widgets/drag_handle.dart';
import 'package:finality/common/widgets/touchable.dart';
import 'package:finality/domain/options/entities/options_time_mode.dart';
import 'package:finality/theme/app_color_theme.dart';
import 'package:finality/theme/attrs/text_color_theme.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/context_extensions.dart';

class InputExpiryTypeSheet extends StatefulWidget {
  final OptionsTimeMode initialExpiryType;

  const InputExpiryTypeSheet({
    super.key,
    required this.initialExpiryType,
  });

  @override
  State<InputExpiryTypeSheet> createState() => _InputExpiryTypeSheetState();
}

class _InputExpiryTypeSheetState extends State<InputExpiryTypeSheet> {
  late OptionsTimeMode _selectedType;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialExpiryType;
  }

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
                    'Expiry Type',
                    style: context.textTheme.titleLarge?.copyWith(
                      color: context.appColors.bottomSheetTitle,
                    ),
                  ),
                  Dimens.vGap8,
                  Text(
                    _selectedType == OptionsTimeMode.timer
                        ? 'Each trade settles independently based on its own specific timeline.'
                        : 'All active trades settle simultaneously at a shared, specific point in time.',
                    style: context.textTheme.labelMedium?.copyWith(
                      color: context.textColorTheme.textColorQuaternary,
                    ),
                  ),
                  Dimens.vGap40,
                  _buildOptionsRow(context),
                  Dimens.vGap32,
                  _buildConfirmButton(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionsRow(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildOption(context, OptionsTimeMode.timer)),
        Dimens.hGap16,
        Expanded(child: _buildOption(context, OptionsTimeMode.clock)),
      ],
    );
  }

  Widget _buildOption(BuildContext context, OptionsTimeMode type) {
    final isSelected = _selectedType == type;
    return Touchable.plain(
      onTap: () {
        setState(() => _selectedType = type);
      },
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: isSelected
              ? context.colorScheme.primary.withValues(alpha: 0.05)
              : context.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected
                ? context.colorScheme.primary
                : context.colorScheme.outlineVariant,
            width: isSelected ? 1 : 0.8,
          ),
        ),
        child: Center(
          child: Text(
            type.label,
            style: context.textTheme.labelLarge?.copyWith(
              color: isSelected
                  ? context.textColorTheme.textColorPrimary
                  : context.textColorTheme.textColorSecondary,
            ),
          ),
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
            Navigator.of(context).pop(_selectedType);
          },
          style: FilledButton.styleFrom(
            backgroundColor: context.colorScheme.primary,
            foregroundColor: context.colorScheme.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          child: Text(
            'Confirm',
            style: context.textTheme.labelMedium?.copyWith(
              color: context.colorScheme.onPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

/// 显示 Expiry Type 选择底部弹窗
Future<OptionsTimeMode?> showExpiryTypeSheet(
  BuildContext context, {
  required OptionsTimeMode initialExpiryType,
}) {
  return showModalBottomSheet<OptionsTimeMode>(
    backgroundColor: Colors.transparent,
    elevation: 0,
    isScrollControlled: true,
    context: context,
    builder: (_) => InputExpiryTypeSheet(
      initialExpiryType: initialExpiryType,
    ),
  );
}
