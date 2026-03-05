import 'package:finality/common/utils/color_scheme_extensions.dart';
import 'package:finality/common/utils/haptic_feedback_utils.dart';
import 'package:finality/domain/options/entities/time_bar.dart';
import 'package:finality/theme/attrs/text_color_theme.dart';
import 'package:flutter/material.dart';
import 'package:kumi_popup_window/kumi_popup_window.dart';

class ChartTimebarPickerPopup extends StatelessWidget {
  const ChartTimebarPickerPopup({
    super.key,
    required this.currentTimeBar,
    required this.onTimeBarSelected,
    required this.allTimeBarList,
  });

  final TimeBar currentTimeBar;
  final ValueChanged<TimeBar> onTimeBarSelected;
  final List<TimeBar> allTimeBarList;

  static const int _columnCount = 4;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: context.colorScheme.outlineVariant,
          width: 0.5,
        ),
      ),
      child: IntrinsicWidth(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: _buildRows(context),
        ),
      ),
    );
  }

  List<Widget> _buildRows(BuildContext context) {
    final List<Widget> rows = [];
    for (int i = 0; i < allTimeBarList.length; i += _columnCount) {
      final rowItems = allTimeBarList.skip(i).take(_columnCount).toList();
      rows.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: rowItems.map((timeBar) {
            return _buildTimeBarItem(context, timeBar);
          }).toList(),
        ),
      );
    }
    return rows;
  }

  Widget _buildTimeBarItem(BuildContext context, TimeBar timeBar) {
    final isSelected = timeBar == currentTimeBar;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedbackUtils.selectionClick();
        onTimeBarSelected(timeBar);
      },
      child: Container(
        width: 44,
        height: 28,
        margin: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: isSelected
              ? context.colorScheme.surfaceContainerHighest
              : Colors.transparent,
          borderRadius: BorderRadius.circular(3),
        ),
        alignment: Alignment.center,
        child: Text(
          timeBar.bar,
          style: TextStyle(
            color: isSelected
                ? context.textColorTheme.textColorPrimary
                : context.textColorTheme.textColorTertiary,
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

void showChartTimebarPickerPopup(
  BuildContext context, {
  required TimeBar currentTimeBar,
  required ValueChanged<TimeBar> onTimeBarSelected,
  required List<TimeBar> allTimeBarList,
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
      child: ChartTimebarPickerPopup(
        currentTimeBar: currentTimeBar,
        onTimeBarSelected: (timeBar) {
          popup.dismiss(context);
          onTimeBarSelected(timeBar);
        },
        allTimeBarList: allTimeBarList,
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
