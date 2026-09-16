import 'package:finality/common/widgets/inner_shadow_container.dart';
import 'package:finality/features/analysis/models/analysis_vo.dart';
import 'package:finality/theme/app_color_theme.dart';
import 'package:finality/theme/attrs/text_color_theme.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const _kWeekdays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
const _calendarBackground = Color(0xFF0C0C0C);
final _cellBackground =
    Color.alphaBlend(const Color(0x08FFFFFF), _calendarBackground);
const _cellBorderRadius = BorderRadius.all(Radius.circular(6));

/// Activity 热力图日历
class ActivityCalendar extends StatelessWidget {
  final List<DailyActivityVO> activities;
  final DateTime month;

  const ActivityCalendar({
    super.key,
    required this.activities,
    required this.month,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: Dimens.edgeInsetsScreenH,
      padding: Dimens.edgeInsetsA16,
      decoration: BoxDecoration(
        color: _calendarBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.04),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          Dimens.vGap16,
          _buildWeekdayRow(context),
          Dimens.vGap6,
          _buildCalendarGrid(context),
          Dimens.vGap12,
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final monthLabel = DateFormat('MMM yyyy').format(month);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Text(
              'Activity',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 0.35,
              ),
            ),
            Dimens.hGap8,
            Text(
              monthLabel,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF454545),
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
        Row(
          children: [
            _legendDot(context, context.appColors.bullish, 'Win'),
            Dimens.hGap12,
            _legendDot(context, context.appColors.bearish, 'Loss'),
          ],
        ),
      ],
    );
  }

  Widget _legendDot(BuildContext context, Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        Dimens.hGap4,
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: context.textColorTheme.textColorHelper,
          ),
        ),
      ],
    );
  }

  Widget _buildWeekdayRow(BuildContext context) {
    return Row(
      children: _kWeekdays
          .map(
            (d) => Expanded(
              child: Center(
                child: Text(
                  d,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: context.textColorTheme.textColorHelper,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildCalendarGrid(BuildContext context) {
    final weeks = _buildWeeks();
    return Column(
      children: weeks
          .map((week) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: week
                      .map((cell) =>
                          Expanded(child: _buildDayCell(context, cell)))
                      .toList(),
                ),
              ))
          .toList(),
    );
  }

  /// 将活动数据组织成周（每行 7 天），前面用 null 填充
  List<List<DailyActivityVO?>> _buildWeeks() {
    final firstDay = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final startWeekday = firstDay.weekday % 7; // Sunday = 0

    // 构建 activityMap: day -> VO
    final activityMap = <int, DailyActivityVO>{};
    for (final a in activities) {
      if (a.day > 0) activityMap[a.day] = a;
    }

    final cells = <DailyActivityVO?>[];
    // 填充月份开始前的空白
    for (var i = 0; i < startWeekday; i++) {
      cells.add(null);
    }
    // 填充每一天
    for (var day = 1; day <= daysInMonth; day++) {
      cells.add(activityMap[day] ?? DailyActivityVO.empty(day));
    }
    // 补齐最后一周的空白
    while (cells.length % 7 != 0) {
      cells.add(null);
    }

    final weeks = <List<DailyActivityVO?>>[];
    for (var i = 0; i < cells.length; i += 7) {
      weeks.add(cells.sublist(i, i + 7));
    }
    return weeks;
  }

  Widget _buildDayCell(BuildContext context, DailyActivityVO? cell) {
    if (cell == null) {
      return const SizedBox(height: 36);
    }

    final hasData = cell.hasActivity;
    final baseColor =
        cell.isWin ? context.appColors.bullish : context.appColors.bearish;
    // 颜色透明度: border/文字 0.29 ~ 1.0，外发光 blur 7~31 / alpha 0.08~0.49
    final borderAndTextAlpha = hasData ? 0.29 + cell.intensity * 0.71 : 0.0;
    final glowBlur = hasData ? 7.0 + cell.intensity * 24.0 : 0.0;
    final glowAlpha = hasData ? 0.08 + cell.intensity * 0.41 : 0.0;
    // 内发光: blur 5~21 / alpha 0.04~0.19
    final innerBlur = hasData ? 5.0 + cell.intensity * 16.0 : 0.0;
    final innerAlpha = hasData ? 0.04 + cell.intensity * 0.15 : 0.0;
    final textColor = hasData
        ? baseColor.withValues(alpha: borderAndTextAlpha)
        : context.textColorTheme.textColorHelper;

    // 无活动数据时不需要发光效果，提前返回简单 widget
    if (!hasData) {
      return Container(
        height: 40,
        margin: const EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(
          color: _cellBackground,
          borderRadius: _cellBorderRadius,
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 4, top: 4),
          child: Align(
            alignment: Alignment.topLeft,
            child: Text(
              '${cell.day}',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w400,
                height: 1,
                color: textColor,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
        color: _cellBackground,
        borderRadius: _cellBorderRadius,
        border: Border.all(color: baseColor.withValues(alpha: borderAndTextAlpha)),
        boxShadow: [
          BoxShadow(
            color: baseColor.withValues(alpha: glowAlpha),
            blurRadius: glowBlur,
          ),
        ],
      ),
      child: InnerShadowContainer(
        height: 40,
        backgroundColor: Colors.transparent,
        shape: BoxShape.rectangle,
        borderRadius: _cellBorderRadius,
        shadowColor: baseColor.withValues(alpha: innerAlpha),
        shadowBlurRadius: innerBlur,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 日期数字
            Padding(
              padding: const EdgeInsets.only(left: 4, top: 4),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  '${cell.day}',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    height: 1,
                    color: textColor,
                  ),
                ),
              ),
            ),
            // 胜率百分比
            Padding(
              padding: const EdgeInsets.only(right: 4, bottom: 4),
              child: Align(
                alignment: Alignment.bottomRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '${cell.percentage}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                        height: 1,
                      ),
                    ),
                    Text(
                      '%',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return const Text(
      'Green for wins, red for losses. The stronger the color, the more decisive the day.',
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w400,
        color: Color(0xFF454545),
        height: 1.25,
      ),
    );
  }
}
