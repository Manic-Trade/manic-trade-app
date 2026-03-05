import 'package:finality/common/utils/color_scheme_extensions.dart';
import 'package:finality/common/utils/localization_extensions.dart';
import 'package:finality/common/widgets/no_thumb_scroll_behavior.dart';
import 'package:finality/common/widgets/touchable.dart';
import 'package:finality/common/widgets/wide_screen_mixin.dart';
import 'package:finality/di/injector.dart';
import 'package:finality/domain/options/entities/time_bar.dart';
import 'package:finality/features/highlow/chart/options_chart_style.dart';
import 'package:finality/features/highlow/chart/widgets/timebar_select_sheet.dart';
import 'package:finality/features/highlow/config/high_low_settings_store.dart';
import 'package:finality/features/highlow/config/options_settings_gulide_store.dart';
import 'package:finality/features/highlow/settings/options_chart_settings_sheet.dart';
import 'package:finality/generated/assets.dart';
import 'package:finality/theme/app_color_theme.dart';
import 'package:finality/theme/attrs/text_color_theme.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

/// 独立的时间周期选择栏组件（不依赖 FlexiKlineController）
/// 用于 deriv_chart 库的 K 线图
class ChartSettingBar extends StatefulWidget {
  const ChartSettingBar({
    super.key,
    required this.currentTimeBar,
    required this.onTapTimeBar,
    required this.chartStyleNotifier,
    required this.onChartStyleSelected,
    this.showMoreTimeBar = true,
  });

  /// 当前时间周期
  final ValueListenable<TimeBar> currentTimeBar;

  /// 时间周期点击回调
  final ValueChanged<TimeBar> onTapTimeBar;

  /// 当前图表样式
  final ValueListenable<OptionsChartStyle> chartStyleNotifier;

  /// 图表样式选择回调
  final ValueChanged<OptionsChartStyle> onChartStyleSelected;

  /// 是否显示更多时间周期按钮
  final bool showMoreTimeBar;

  @override
  State<ChartSettingBar> createState() => _ChartSettingBarState();
}

class _ChartSettingBarState extends State<ChartSettingBar>
    with WideScreenMixin {
  late final OptionsSettingsGuideStore _chartSettingGuideStore = injector();

  @override
  void dispose() {
    timeBarSettingBtnStatus.dispose();
    super.dispose();
  }

  List<TimeBar> get allTimeBarList => HighLowSettingsStore.allTimeBarList;
  List<TimeBar> get preferTimeBarList => HighLowSettingsStore.preferTimeBarList;

  bool isPreferTimeBar(TimeBar bar) => preferTimeBarList.contains(bar);

  List<TimeBar> get showTimeBarList {
    return wideScreen ? allTimeBarList : preferTimeBarList;
  }

  final timeBarSettingBtnStatus = ValueNotifier(false);

  Future<void> onTapTimeBarSetting() async {
    timeBarSettingBtnStatus.value = true;
    await _showTimeBarSelectSheet(context);
    timeBarSettingBtnStatus.value = false;
  }

  Future<void> _showTimeBarSelectSheet(BuildContext context) async {
    await showTimeBarSelectSheet(context, currentTimeBar: widget.currentTimeBar,
        onTapTimeBar: (bar) {
      Navigator.of(context).pop();
      widget.onTapTimeBar(bar);
    }, preferTimeBarList: preferTimeBarList, allTimeBarList: allTimeBarList);
  }

  @override
  Widget build(BuildContext context) {
    return buildSettingBar(context);
  }

  Widget buildSettingBar(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ScrollConfiguration(
              behavior: NoThumbScrollBehavior().copyWith(scrollbars: false),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: _buildTimeBarList(
                  context,
                  timerBarList: showTimeBarList,
                ),
              ),
            ),
          ),
        ),
        // 图表类型切换按钮
        _buildChartStyleButton(context),
        Dimens.hGap8,
        _buildSettingsButton(context),
        Dimens.hGap12,
      ],
    );
  }

  Widget _buildTimeBarList(
    BuildContext context, {
    required List<TimeBar> timerBarList,
  }) {
    return ValueListenableBuilder<TimeBar>(
      valueListenable: widget.currentTimeBar,
      builder: (context, value, child) {
        return Row(children: [
          ...timerBarList.map((bar) {
            final selected = value == bar;
            return Touchable.plain(
              onTap: () => widget.onTapTimeBar(bar),
              child: Container(
                key: ValueKey(bar),
                alignment: AlignmentDirectional.center,
                decoration: BoxDecoration(
                  color: selected
                      ? context.colorScheme.surfaceContainerHighest
                      : null,
                  borderRadius: BorderRadius.circular(3),
                ),
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                margin: const EdgeInsetsDirectional.symmetric(horizontal: 2),
                child: Text(
                  bar.bar,
                  style: TextStyle(
                    color: selected
                        ? context.textColorTheme.textColorSecondary
                        : context.textColorTheme.textColorTertiary,
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            );
          }),
          if (widget.showMoreTimeBar)
            ValueListenableBuilder<TimeBar>(
              valueListenable: widget.currentTimeBar,
              builder: (context, value, child) {
                final showMore = isPreferTimeBar(value);
                return Touchable.plain(
                  onTap: onTapTimeBarSetting,
                  child: Container(
                    alignment: AlignmentDirectional.center,
                    decoration: BoxDecoration(
                      color: !showMore
                          ? context.colorScheme.surfaceContainerHighest
                          : null,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    padding: const EdgeInsetsDirectional.only(
                      start: 8,
                      end: 2,
                      top: 4,
                      bottom: 4,
                    ),
                    margin:
                        const EdgeInsetsDirectional.symmetric(horizontal: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          showMore ? context.strings.more : value.bar,
                          style: TextStyle(
                            color: !showMore
                                ? context.textColorTheme.textColorSecondary
                                : context.textColorTheme.textColorTertiary,
                            fontSize: 12,
                            fontWeight:
                                !showMore ? FontWeight.w600 : FontWeight.w500,
                          ),
                        ),
                        ValueListenableBuilder(
                          valueListenable: timeBarSettingBtnStatus,
                          builder: (context, value, child) {
                            return RotationTransition(
                              turns: AlwaysStoppedAnimation(value ? 0.5 : 0),
                              child: Icon(
                                Icons.arrow_drop_down,
                                size: 16,
                                color: !showMore
                                    ? context.textColorTheme.textColorSecondary
                                    : context.textColorTheme.textColorTertiary,
                              ),
                            );
                          },
                        )
                      ],
                    ),
                  ),
                );
              },
            )
        ]);
      },
    );
  }

  /// 构建图表类型切换按钮
  Widget _buildChartStyleButton(BuildContext context) {
    return Touchable.iconButton(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: ValueListenableBuilder(
          valueListenable: widget.chartStyleNotifier,
          builder: (context, chartStyle, child) {
            return SvgPicture.asset(
              chartStyle.svgPath,
              width: 16,
              height: 16,
              colorFilter: ColorFilter.mode(
                context.textColorTheme.textColorSecondary,
                BlendMode.srcIn,
              ),
            );
          },
        ),
      ),
      onTap: () {
        var currentChartStyle = widget.chartStyleNotifier.value;
        if (widget.currentTimeBar.value == TimeBar.s1) {
          var index = OptionsChartStyle.lineStyles.indexOf(currentChartStyle);
          var nextChartStyle = index == OptionsChartStyle.lineStyles.length - 1
              ? OptionsChartStyle.lineStyles[0]
              : OptionsChartStyle.lineStyles[index + 1];
          widget.onChartStyleSelected(nextChartStyle);
        } else {
          var index = OptionsChartStyle.values.indexOf(currentChartStyle);
          var nextChartStyle = index == OptionsChartStyle.values.length - 1
              ? OptionsChartStyle.values[0]
              : OptionsChartStyle.values[index + 1];
          widget.onChartStyleSelected(nextChartStyle);
        }

        // showOptionsChartStyleSheet(
        //   context,
        //   chartStyleNotifier: widget.chartStyleNotifier,
        //   currentTimeBar: widget.currentTimeBar,
        //   onChartStyleSelected: widget.onChartStyleSelected,
        // );
      },
    );
  }

  Widget _buildSettingsButton(BuildContext context) {
    return Touchable.iconButton(
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            SvgPicture.asset(
              Assets.svgsIcSettingsChart,
              width: 16,
              height: 16,
              colorFilter: ColorFilter.mode(
                context.textColorTheme.textColorSecondary,
                BlendMode.srcIn,
              ),
            ),
            ValueListenableBuilder(
                valueListenable: _chartSettingGuideStore
                    .showBadgeNotifier(OptionsGuidePoint.doubleClickOrder),
                builder: (context, value, child) {
                  if (!value) return Dimens.emptyBox;
                  return Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: context.appColors.bearish,
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                }),
          ],
        ),
      ),
      onTap: () {
        showOptionsChartSettingsSheet(context);
      },
    );
  }
}
