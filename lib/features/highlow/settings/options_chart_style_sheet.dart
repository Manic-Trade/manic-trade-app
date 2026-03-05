import 'package:finality/common/utils/color_scheme_extensions.dart';
import 'package:finality/common/widgets/drag_handle.dart';
import 'package:finality/common/widgets/touchable.dart';
import 'package:finality/domain/options/entities/time_bar.dart';
import 'package:finality/features/highlow/chart/options_chart_style.dart';
import 'package:finality/theme/app_color_theme.dart';
import 'package:finality/theme/attrs/text_color_theme.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get_utils/src/extensions/context_extensions.dart';

class OptionsChartStyleSheet extends StatelessWidget {
  final ValueListenable<OptionsChartStyle> chartStyleNotifier;
  final ValueListenable<TimeBar> currentTimeBar;
  final List<OptionsChartStyle> chartStyleList;
  final ValueChanged<OptionsChartStyle> onChartStyleSelected;

  const OptionsChartStyleSheet({
    super.key,
    required this.chartStyleNotifier,
    required this.currentTimeBar,
    required this.chartStyleList,
    required this.onChartStyleSelected,
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
                    'Chart Style',
                    style: context.textTheme.titleLarge?.copyWith(
                      color: context.appColors.bottomSheetTitle,
                    ),
                  ),
                  Dimens.vGap40,
                  _buildStyleGrid(context),
                  Dimens.vGap32,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStyleGrid(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 16.0;
        const itemsPerRow = 2;
        final itemWidth =
            (constraints.maxWidth - spacing * (itemsPerRow - 1)) / itemsPerRow;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: chartStyleList.map((style) {
            return SizedBox(
              width: itemWidth,
              child: ValueListenableBuilder(
                  valueListenable: chartStyleNotifier,
                  builder: (context, value, child) {
                    return _buildStyleOption(context, style, value);
                  }),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildStyleOption(BuildContext context, OptionsChartStyle style,
      OptionsChartStyle currentChartStyle) {
    final isSelected = style == currentChartStyle;
    final svgPath = style.svgPath;
    final label = style.getLabel(context);

    return Touchable.plain(
      onTap: () {
        onChartStyleSelected(style);
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              svgPath,
              width: 16,
              height: 16,
              colorFilter: ColorFilter.mode(
                isSelected
                    ? context.textColorTheme.textColorPrimary
                    : context.textColorTheme.textColorSecondary,
                BlendMode.srcIn,
              ),
            ),
            Dimens.hGap8,
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: context.textTheme.labelLarge?.copyWith(
                    color: isSelected
                        ? context.textColorTheme.textColorPrimary
                        : context.textColorTheme.textColorSecondary,
                  ),
                ),
                if (!isSelected && style == OptionsChartStyle.candles)
                  ValueListenableBuilder(
                      valueListenable: currentTimeBar,
                      builder: (context, value, child) {
                        if (value != TimeBar.s1) {
                          return Dimens.emptyBox;
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            'Switch to 5s',
                            style: context.textTheme.bodySmall?.copyWith(
                              fontSize: 10,
                              color: context.textColorTheme.textColorTertiary,
                            ),
                          ),
                        );
                      }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void showOptionsChartStyleSheet(
  BuildContext context, {
  required ValueListenable<OptionsChartStyle> chartStyleNotifier,
  required ValueListenable<TimeBar> currentTimeBar,
  required ValueChanged<OptionsChartStyle> onChartStyleSelected,
  List<OptionsChartStyle> chartStyleList = OptionsChartStyle.values,
}) {
  showModalBottomSheet(
    backgroundColor: Colors.transparent,
    elevation: 0,
    isScrollControlled: true,
    context: context,
    builder: (_) => OptionsChartStyleSheet(
      chartStyleNotifier: chartStyleNotifier,
      currentTimeBar: currentTimeBar,
      chartStyleList: chartStyleList,
      onChartStyleSelected: onChartStyleSelected,
    ),
  );
}
