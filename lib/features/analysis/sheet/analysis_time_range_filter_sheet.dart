import 'package:finality/common/utils/color_scheme_extensions.dart';
import 'package:finality/common/widgets/drag_handle.dart';
import 'package:finality/common/widgets/touchable.dart';
import 'package:finality/features/analysis/models/analysis_filter.dart';
import 'package:finality/theme/attrs/text_color_theme.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/context_extensions.dart';

class AnalysisTimeRangeFilterSheet extends StatelessWidget {
  final TimeRange selectedTimeRange;

  const AnalysisTimeRangeFilterSheet({
    super.key,
    required this.selectedTimeRange,
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
                    'Time Range',
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
      children: TimeRange.values.map((range) {
        final isFirst = range == TimeRange.values.first;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: isFirst ? 0 : 16),
            child: _buildOption(context, range),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildOption(BuildContext context, TimeRange range) {
    final isSelected = selectedTimeRange == range;
    return Touchable.plain(
      onTap: () => Navigator.of(context).pop(range),
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
            range.label,
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

/// 显示 Time Range 筛选底部弹窗
Future<TimeRange?> showAnalysisTimeRangeFilterSheet(
  BuildContext context, {
  required TimeRange selectedTimeRange,
}) {
  return showModalBottomSheet<TimeRange>(
    backgroundColor: Colors.transparent,
    elevation: 0,
    isScrollControlled: true,
    context: context,
    builder: (_) =>
        AnalysisTimeRangeFilterSheet(selectedTimeRange: selectedTimeRange),
  );
}
