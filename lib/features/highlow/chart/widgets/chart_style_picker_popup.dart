import 'package:collection/collection.dart';
import 'package:finality/common/utils/color_scheme_extensions.dart';
import 'package:finality/common/utils/haptic_feedback_utils.dart';
import 'package:finality/features/highlow/chart/options_chart_style.dart';
import 'package:finality/theme/attrs/text_color_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kumi_popup_window/kumi_popup_window.dart';

class ChartStylePickerPopup extends StatelessWidget {
  const ChartStylePickerPopup({
    super.key,
    required this.currentChartStyle,
    required this.onChartStyleSelected,
    required this.chartStyleList,
  });

  final OptionsChartStyle currentChartStyle;
  final ValueChanged<OptionsChartStyle> onChartStyleSelected;
  final List<OptionsChartStyle> chartStyleList;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: context.colorScheme.outlineVariant,
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: chartStyleList.mapIndexed((index, style) {
          return _buildStyleItem(
              context, style, index == chartStyleList.length - 1);
        }).toList(),
      ),
    );
  }

  Widget _buildStyleItem(
      BuildContext context, OptionsChartStyle style, bool isLast) {
    final isSelected = style == currentChartStyle;
    final svgPath = style.svgPath;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedbackUtils.selectionClick();
        onChartStyleSelected(style);
      },
      child: Container(
        width: 28,
        height: 28,
        margin: isLast ? null : const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? context.colorScheme.surfaceContainerHighest
              : Colors.transparent,
          borderRadius: BorderRadius.circular(3),
        ),
        alignment: Alignment.center,
        child: SvgPicture.asset(
          svgPath,
          width: 16,
          height: 16,
          colorFilter: ColorFilter.mode(
            isSelected
                ? context.textColorTheme.textColorSecondary
                : context.textColorTheme.textColorHelper,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}

void showChartStylePickerPopup(
  BuildContext context, {
  required OptionsChartStyle currentChartStyle,
  required ValueChanged<OptionsChartStyle> onChartStyleSelected,
  required List<OptionsChartStyle> chartStyleList,
}) {
  final RenderBox renderBox = context.findRenderObject() as RenderBox;

  showPopupWindow(
    context,
    targetRenderBox: renderBox,
    gravity: KumiPopupGravity.leftTop,
    customAnimation: true,
    clickOutDismiss: true,
    clickBackDismiss: true,
    offsetX: renderBox.size.width + 8,
    duration: const Duration(milliseconds: 80),
    customPop: false,
    customPage: false,
    bgColor: Colors.black26,
    childFun: (popup) => _buildAnimateLayout(
      context,
      child: ChartStylePickerPopup(
        currentChartStyle: currentChartStyle,
        onChartStyleSelected: (style) {
          popup.dismiss(context);
          onChartStyleSelected(style);
        },
        chartStyleList: chartStyleList,
      ),
      controller: popup.controller!,
    ),
  );
}

Widget _buildAnimateLayout(
  BuildContext context, {
  required Widget child,
  required AnimationController controller,
}) {
  const curve = Curves.decelerate;

  return ScaleTransition(
    key: GlobalKey(),
    scale: Tween(begin: 0.86, end: 1.0)
        .chain(CurveTween(curve: curve))
        .animate(controller),
    child: FadeTransition(
      opacity: Tween(begin: 0.0, end: 1.0)
          .chain(CurveTween(curve: curve))
          .animate(controller),
      child: child,
    ),
  );
}
