import 'package:finality/common/utils/color_scheme_extensions.dart';
import 'package:finality/common/widgets/drag_handle.dart';
import 'package:finality/common/widgets/touchable.dart';
import 'package:finality/domain/options/entities/time_bar.dart';
import 'package:finality/generated/l10n.dart';
import 'package:finality/theme/app_color_theme.dart';
import 'package:finality/theme/attrs/text_color_theme.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/context_extensions.dart';

class TimeBarSelectSheet extends StatelessWidget {
  const TimeBarSelectSheet({
    super.key,
    required this.currentTimeBar,
    required this.onTapTimeBar,
    required this.preferTimeBarList,
    required this.allTimeBarList,
  });

  final ValueListenable<TimeBar> currentTimeBar;
  final ValueChanged<TimeBar> onTapTimeBar;
  final List<TimeBar> preferTimeBarList;
  final List<TimeBar> allTimeBarList;

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
                    S.of(context).k_intervals,
                    style: context.textTheme.titleLarge?.copyWith(
                      color: context.appColors.bottomSheetTitle,
                    ),
                  ),
                  Dimens.vGap40,
                  _buildAllTimeBarList(context),
                  Dimens.vGap32,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllTimeBarList(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: currentTimeBar,
      builder: (context, value, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            const spacing = 12.0;
            const itemsPerRow = 4;
            final itemWidth =
                (constraints.maxWidth - spacing * (itemsPerRow - 1)) /
                    itemsPerRow;
            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: allTimeBarList.map((bar) {
                final selected = value == bar;
                return SizedBox(
                  width: itemWidth,
                  child: _buildTimeBarItem(context, bar, selected),
                );
              }).toList(),
            );
          },
        );
      },
    );
  }

  Widget _buildTimeBarItem(
    BuildContext context,
    TimeBar bar,
    bool selected,
  ) {
    return Touchable.plain(
      onTap: () => onTapTimeBar(bar),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: selected
              ? context.colorScheme.primary.withValues(alpha: 0.05)
              : context.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: selected
                ? context.colorScheme.primary
                : context.colorScheme.outlineVariant,
            width: selected ? 1 : 0.8,
          ),
        ),
        child: Center(
          child: Text(
            bar.bar,
            style: context.textTheme.labelMedium?.copyWith(
              color: selected
                  ? context.textColorTheme.textColorPrimary
                  : context.textColorTheme.textColorSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> showTimeBarSelectSheet(
  BuildContext context, {
  required ValueListenable<TimeBar> currentTimeBar,
  required ValueChanged<TimeBar> onTapTimeBar,
  required List<TimeBar> preferTimeBarList,
  required List<TimeBar> allTimeBarList,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    constraints: null,
    backgroundColor: Colors.transparent,
    builder: (_) => TimeBarSelectSheet(
      currentTimeBar: currentTimeBar,
      onTapTimeBar: onTapTimeBar,
      preferTimeBarList: preferTimeBarList,
      allTimeBarList: allTimeBarList,
    ),
  );
}
