import 'package:finality/common/utils/color_scheme_extensions.dart';
import 'package:finality/common/widgets/touchable.dart';
import 'package:finality/domain/options/entities/time_bar.dart';
import 'package:finality/features/highlow/chart/options_chart_style.dart';
import 'package:finality/features/highlow/chart/widgets/chart_style_picker_popup.dart';
import 'package:finality/features/highlow/chart/widgets/chart_timebar_picker_popup.dart';
import 'package:finality/features/highlow/config/high_low_settings_store.dart';
import 'package:finality/theme/attrs/text_color_theme.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// 图表设置垂直菜单
/// 放在图表左下角，包含图表样式切换和时间区间选择
class ChartSettingVerticalMenu extends StatelessWidget {
  const ChartSettingVerticalMenu({
    super.key,
    required this.chartStyleNotifier,
    required this.onChartStyleSelected,
    required this.currentTimeBar,
    required this.onTapTimeBar,
  });

  /// 当前图表样式
  final ValueListenable<OptionsChartStyle> chartStyleNotifier;

  /// 图表样式选择回调
  final ValueChanged<OptionsChartStyle> onChartStyleSelected;

  /// 当前时间周期
  final ValueListenable<TimeBar> currentTimeBar;

  /// 时间周期点击回调
  final ValueChanged<TimeBar> onTapTimeBar;

  List<TimeBar> get allTimeBarList => HighLowSettingsStore.allTimeBarList;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildChartStyleButton(context),
        Dimens.vGap8,
        _buildTimeBarButton(context),
      ],
    );
  }

  Widget _buildChartStyleButton(BuildContext context) {
    return Builder(builder: (buttonContext) {
      return _buildItemButton(context,
          child: ValueListenableBuilder<OptionsChartStyle>(
            valueListenable: chartStyleNotifier,
            builder: (context, chartStyle, child) {
              final svgPath = chartStyle.svgPath;

              return SvgPicture.asset(
                svgPath,
                width: 12.5,
                height: 12.5,
                colorFilter: ColorFilter.mode(
                  context.textColorTheme.textColorSecondary,
                  BlendMode.srcIn,
                ),
              );
            },
          ),
          onTap: () => _showChartStylePickerPopup(buttonContext));
    });
  }

  void _showChartStylePickerPopup(BuildContext context) {
    showChartStylePickerPopup(
      context,
      currentChartStyle: chartStyleNotifier.value,
      onChartStyleSelected: onChartStyleSelected,
      chartStyleList: OptionsChartStyle.values,
    );
  }

  Widget _buildTimeBarButton(BuildContext context) {
    return Builder(builder: (buttonContext) {
      return _buildItemButton(context,
          child: ValueListenableBuilder<TimeBar>(
            valueListenable: currentTimeBar,
            builder: (context, timeBar, child) {
              return Text(
                timeBar.bar,
                style: TextStyle(
                  color: context.textColorTheme.textColorSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              );
            },
          ), onTap: () {
        _showTimeBarPickerPopup(buttonContext);
      });
    });
  }

  Widget _buildItemButton(BuildContext context,
      {required Widget child, required VoidCallback onTap}) {
    return Touchable.plain(
      shrinkScaleFactor: 0.86,
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: context.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(4),
          border:
              Border.all(color: context.colorScheme.outlineVariant, width: 0.4),
        ),
        child: Center(child: child),
      ),
    );
  }

  void _showTimeBarPickerPopup(BuildContext context) {
    showChartTimebarPickerPopup(
      context,
      currentTimeBar: currentTimeBar.value,
      onTimeBarSelected: onTapTimeBar,
      allTimeBarList: allTimeBarList,
    );
  }
}
