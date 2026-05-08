import 'package:finality/common/utils/color_scheme_extensions.dart';
import 'package:finality/common/widgets/drag_handle.dart';
import 'package:finality/common/widgets/touchable.dart';
import 'package:finality/features/analysis/models/analysis_filter.dart';
import 'package:finality/theme/attrs/text_color_theme.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/context_extensions.dart';

class AnalysisModelsFilterSheet extends StatelessWidget {
  final ModeFilter selectedMode;

  const AnalysisModelsFilterSheet({
    super.key,
    required this.selectedMode,
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
                    'Modes',
                    style: context.textTheme.titleLarge?.copyWith(
                      color: const Color(0xFFD1D1D6),
                    ),
                  ),
                  Dimens.vGap40,
                  _buildGrid(context),
                   Dimens.vGap20,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(BuildContext context) {
    return Row(
      children: ModeFilter.values.map((mode) {
        final isFirst = mode == ModeFilter.values.first;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: isFirst ? 0 : 16),
            child: _buildOption(context, mode),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildOption(BuildContext context, ModeFilter mode) {
    final isSelected = selectedMode == mode;
    return Touchable.plain(
      onTap: () => Navigator.of(context).pop(mode),
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
            mode.label,
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
}

/// 显示 Modes 筛选底部弹窗
Future<ModeFilter?> showAnalysisModelsFilterSheet(
  BuildContext context, {
  required ModeFilter selectedMode,
}) {
  return showModalBottomSheet<ModeFilter>(
    backgroundColor: Colors.transparent,
    elevation: 0,
    isScrollControlled: true,
    context: context,
    builder: (_) => AnalysisModelsFilterSheet(selectedMode: selectedMode),
  );
}
