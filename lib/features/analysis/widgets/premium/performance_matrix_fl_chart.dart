import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:finality/features/analysis/models/analysis_filter.dart';
import 'package:finality/features/analysis/models/premium_analysis_vo.dart';
import 'package:finality/features/analysis/widgets/premium/premium_card.dart';
import 'package:flutter/material.dart';

/// fl_chart 实现的双轴复合图表（Volume 柱 + 累积 P&L 折线）
///
/// 使用 Stack[BarChart + LineChart] 实现双轴效果。
/// CRT 特效简化为选中柱的亮色渐变（fl_chart 不支持 MaskFilter.blur）。
class PerformanceMatrixFlChart extends StatefulWidget {
  final List<PerformancePointVO> points;
  final TimeRange timeRange;

  const PerformanceMatrixFlChart({
    super.key,
    required this.points,
    required this.timeRange,
  });

  @override
  State<PerformanceMatrixFlChart> createState() =>
      _PerformanceMatrixFlChartState();
}

class _PerformanceMatrixFlChartState extends State<PerformanceMatrixFlChart> {
  int? _touchedIndex;
  bool _showData = false;

  List<double> get _cumPnl {
    final result = <double>[];
    double sum = 0;
    for (final p in widget.points) {
      sum += p.pnl;
      result.add(sum);
    }
    return result;
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) setState(() => _showData = true);
    });
  }

  @override
  void didUpdateWidget(covariant PerformanceMatrixFlChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.points != widget.points) {
      _touchedIndex = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.points.isEmpty) return _buildEmpty();

    final points = widget.points;
    final cumPnl = _cumPnl;
    final n = points.length;

    final maxVol = points.map((p) => p.volume).fold(1.0, math.max);
    final pnlAbs = cumPnl.map((v) => v.abs()).fold(1.0, math.max);

    final pnlStep = _niceStep(pnlAbs, 2);
    final volStep = _niceStep(maxVol, 3);
    final pnlPadding = pnlAbs * 1.18;

    int peakIdx = 0;
    for (int i = 1; i < cumPnl.length; i++) {
      if (cumPnl[i] > cumPnl[peakIdx]) peakIdx = i;
    }

    final hasSelection = _touchedIndex != null;

    const leftReserved = 40.0;
    const rightReserved = 34.0;
    const topReserved = 20.0;
    const bottomReserved = 24.0;
    const animDuration = Duration(milliseconds: 800);
    const animCurve = Cubic(0.22, 1, 0.36, 1);

    Widget emptyTitle(double value, TitleMeta meta) => const SizedBox();

    final lineBarData = LineChartBarData(
      spots: List.generate(
        n,
        (i) => FlSpot(i.toDouble(), _showData ? cumPnl[i] : 0),
      ),
      isCurved: false,
      gradient: const LinearGradient(
        colors: [Color(0xFFFF9E1A), Color(0xFFFFC260), Color(0xFFFF9E1A)],
      ),
      barWidth: 2,
      shadow: Shadow(
        color: const Color(0xFFFF9E1A).withValues(alpha: 0.3),
        blurRadius: 4,
      ),
      belowBarData: BarAreaData(
        show: true,
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x26FFB020), Color(0x00FFB020)],
        ),
      ),
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) {
          final isActive = index == _touchedIndex;
          final isPeak = index == peakIdx;
          return FlDotCirclePainter(
            radius: isActive ? 3 : 2,
            color: const Color(0xFF030303),
            strokeColor: isActive
                ? Colors.white
                : isPeak
                    ? const Color(0xFFFFD173)
                    : const Color(0xFFFFB020),
            strokeWidth: isActive
                ? 2
                : isPeak
                    ? 1.25
                    : 1,
          );
        },
      ),
    );

    return SizedBox(
      height: 280,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final chartWidth =
              constraints.maxWidth - leftReserved - rightReserved;
          final slotW = chartWidth / n;
          final barW = math.min(24.0, slotW * 0.55);

          // 用 TextPainter 测量最宽 label，确保相邻 label 间距 >= 16px
          const labelStyle = TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.8,
          );
          // today 时取时间部分，与实际显示一致
          final isToday = widget.timeRange == TimeRange.today;
          final displayLabels = isToday
              ? points.map((p) =>
                  p.label.contains(' ') ? p.label.split(' ').last : p.label)
              : points.map((p) => p.label);
          final maxLabelText =
              displayLabels.reduce((a, b) => a.length >= b.length ? a : b);
          final labelPainter = TextPainter(
            text: TextSpan(text: maxLabelText, style: labelStyle),
            textDirection: TextDirection.ltr,
          )..layout();
          final labelW = labelPainter.width;
          // 最少间隔几个点才能保证 label 不重叠（文字宽度 + 16px 间距）
          final minStep = math.max(1, ((labelW + 16) / slotW).ceil());
          // 首尾固定，中间均匀分布
          final maxIntervals = n <= 1 ? 0 : ((n - 1) / minStep).floor();
          final visibleIndices = <int>{};
          if (maxIntervals <= 0) {
            visibleIndices.addAll([0, n - 1]);
          } else {
            final evenStep = (n - 1) / maxIntervals;
            for (int k = 0; k <= maxIntervals; k++) {
              visibleIndices.add((k * evenStep).round());
            }
          }

          return Stack(
            children: [
              // ═══ Volume 柱状图（底层） ═══
              BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceEvenly,
                  maxY: maxVol * 1.1,
                  minY: 0,
                  barGroups: List.generate(n, (i) {
                    final isSelected = _touchedIndex == i;
                    final vol = points[i].volume;
                    final isEmpty = vol == 0;

                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: _showData ? (isEmpty ? maxVol * 0.015 : vol) : 0,
                          width: barW,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(
                              n > 16
                                  ? math.min(3.0, barW / 5)
                                  : math.min(6.0, barW / 3),
                            ),
                          ),
                          gradient: isSelected
                              ? const LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    Color(0xFF5A3400),
                                    Color(0xFFA06000),
                                    Color(0xFFFFD098),
                                  ],
                                )
                              : LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: hasSelection
                                      ? [
                                          Color.fromRGBO(10, 10, 10,
                                              isEmpty ? 0.15 : 0.38),
                                          Color.fromRGBO(20, 20, 20,
                                              isEmpty ? 0.15 : 0.38),
                                        ]
                                      : [
                                          Color.fromRGBO(
                                              10, 10, 10, isEmpty ? 0.25 : 0.7),
                                          Color.fromRGBO(
                                              20, 20, 20, isEmpty ? 0.25 : 0.7),
                                        ],
                                ),
                        ),
                      ],
                    );
                  }),
                  titlesData: FlTitlesData(
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: topReserved,
                        getTitlesWidget: emptyTitle,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: bottomReserved,
                        getTitlesWidget: emptyTitle,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: leftReserved,
                        getTitlesWidget: emptyTitle,
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: rightReserved,
                        interval: volStep,
                        getTitlesWidget: (value, meta) {
                          if (value < 0 || value > maxVol * 1.05) {
                            return const SizedBox();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Text(
                              _fmtVolAxis(value),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withValues(alpha: 0.2),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barTouchData: BarTouchData(enabled: false),
                ),
                duration: animDuration,
                curve: animCurve,
              ),

              // ═══ P&L 折线图（顶层） ═══
              LineChart(
                LineChartData(
                  minX: -0.5,
                  maxX: n - 0.5,
                  minY: -pnlPadding,
                  maxY: pnlPadding,
                  lineBarsData: [lineBarData],
                  titlesData: FlTitlesData(
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: topReserved,
                        getTitlesWidget: emptyTitle,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: leftReserved,
                        interval: pnlStep,
                        getTitlesWidget: (value, meta) {
                          if (value.abs() > pnlAbs * 1.01) {
                            return const SizedBox();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(
                              _fmtPnlAxis(value),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFFFF9E1A)
                                    .withValues(alpha: 0.4),
                              ),
                              textAlign: TextAlign.right,
                            ),
                          );
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: rightReserved,
                        getTitlesWidget: emptyTitle,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: bottomReserved,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          final i = value.round();
                          if (i < 0 || i >= n || (value - i).abs() > 0.01) {
                            return const SizedBox();
                          }
                          if (!visibleIndices.contains(i)) {
                            return const SizedBox();
                          }
                          // today 时只显示时间部分（HH:00）
                          final rawLabel = points[i].label;
                          final displayLabel =
                              widget.timeRange == TimeRange.today &&
                                      rawLabel.contains(' ')
                                  ? rawLabel.split(' ').last
                                  : rawLabel;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              displayLabel,
                              style: labelStyle.copyWith(
                                color: Colors.white.withValues(alpha: 0.25),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  gridData: FlGridData(
                    show: false,
                    drawVerticalLine: false,
                    horizontalInterval: pnlStep,
                    getDrawingHorizontalLine: (value) => const FlLine(
                      color: Color(0x0FFF9900),
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineTouchData: LineTouchData(
                    touchSpotThreshold: double.infinity,
                    handleBuiltInTouches: true,
                    touchCallback: (event, response) {
                      final isEnd = event is FlTapUpEvent ||
                          event is FlPanEndEvent ||
                          event is FlLongPressEnd;
                      final newIndex = isEnd
                          ? null
                          : response?.lineBarSpots?.firstOrNull?.spotIndex;
                      if (newIndex != _touchedIndex) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) {
                            setState(() => _touchedIndex = newIndex);
                          }
                        });
                      }
                    },
                    getTouchedSpotIndicator: (barData, spotIndexes) {
                      return spotIndexes.map((_) {
                        return TouchedSpotIndicatorData(
                          FlLine(
                            color: Colors.white.withValues(alpha: 0.12),
                            strokeWidth: 1,
                            dashArray: [3, 3],
                          ),
                          const FlDotData(show: false),
                        );
                      }).toList();
                    },
                    touchTooltipData: LineTouchTooltipData(
                      fitInsideHorizontally: true,
                      fitInsideVertically: true,
                      getTooltipColor: (_) => const Color(0xEB121214),
                      tooltipRoundedRadius: 8,
                      tooltipBorder: BorderSide(
                        color: Colors.white.withValues(alpha: 0.06),
                      ),
                      tooltipPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final i = spot.spotIndex;
                          final pnlVal = cumPnl[i];
                          final isProfit = pnlVal >= 0;
                          final pnlStr =
                              '${isProfit ? "+" : "−"}\$${_compactNumber(pnlVal.abs())}';
                          final volStr =
                              '\$${_compactNumber(points[i].volume)}';
                          return LineTooltipItem(
                            'P&L ',
                            TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.4),
                            ),
                            children: [
                              TextSpan(
                                text: pnlStr,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isProfit ? kPremiumGreen : kPremiumRed,
                                ),
                              ),
                              TextSpan(
                                text: '  Vol ',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white.withValues(alpha: 0.4),
                                ),
                              ),
                              TextSpan(
                                text: volStr,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
                duration: animDuration,
                curve: animCurve,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmpty() {
    return PremiumCard(
      child: SizedBox(
        height: 280,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Text(
              'No performance data available',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.25),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── 工具函数 ──

double _niceStep(double max, int targetTicks) {
  if (max <= 0) return 1;
  final rough = max / targetTicks;
  final mag =
      math.pow(10, (math.log(rough) / math.ln10).floorToDouble()).toDouble();
  final r = rough / mag;
  final nice = r <= 1.5
      ? 1
      : r <= 3
          ? 2
          : r <= 7
              ? 5
              : 10;
  return nice * mag;
}

String _fmtPnlAxis(double v) {
  final a = v.abs();
  final sign = v < 0
      ? '-'
      : v > 0
          ? '+'
          : '';
  if (a >= 1e6) return '$sign\$${(a / 1e6).toStringAsFixed(1)}M';
  if (a >= 1e3) return '$sign\$${(a / 1e3).toStringAsFixed(0)}K';
  if (a == 0) return '\$0';
  return '$sign\$${a.round()}';
}

String _fmtVolAxis(double v) {
  if (v >= 1e6) return '\$${(v / 1e6).toStringAsFixed(1)}M';
  if (v >= 1e3) return '\$${(v / 1e3).toStringAsFixed(0)}K';
  return '\$${v.round()}';
}

String _compactNumber(double value) {
  if (value >= 1e6) return '${(value / 1e6).toStringAsFixed(1)}M';
  if (value >= 1e3) return '${(value / 1e3).toStringAsFixed(1)}K';
  return value.toStringAsFixed(0);
}
