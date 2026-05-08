import 'dart:math' as math;
import 'dart:ui';

import 'package:finality/features/analysis/models/premium_analysis_vo.dart';
import 'package:finality/features/analysis/widgets/premium/premium_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const _kWeekdays = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];
const _kCellGap = 6.0;
const _kCellBorderRadius = BorderRadius.all(Radius.circular(4));

/// Premium 模式的赢率热力图月历
class PremiumCalendarGrid extends StatefulWidget {
  final List<PremiumDailyActivityVO> activities;

  const PremiumCalendarGrid({super.key, required this.activities});

  @override
  State<PremiumCalendarGrid> createState() => _PremiumCalendarGridState();
}

class _PremiumCalendarGridState extends State<PremiumCalendarGrid> {
  /// 当前选中的日期（用于显示 tooltip）
  String? _activeDate;

  /// Overlay 相关
  OverlayEntry? _overlayEntry;

  /// 每个格子的 GlobalKey，用于定位 tooltip
  final Map<String, GlobalKey> _cellKeys = {};

  /// 父级滚动监听，滚动时自动关闭 tooltip
  ScrollPosition? _parentScrollPosition;

  /// 从活动数据推断月份，默认当前月
  DateTime get _month {
    for (final a in widget.activities) {
      final date = DateTime.tryParse(a.date);
      if (date != null) return DateTime(date.year, date.month, 1);
    }
    final now = DateTime.now();
    return DateTime(now.year, now.month, 1);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _parentScrollPosition?.removeListener(_dismissTooltip);
    _parentScrollPosition = Scrollable.maybeOf(context)?.position;
    _parentScrollPosition?.addListener(_dismissTooltip);
  }

  @override
  void dispose() {
    _parentScrollPosition?.removeListener(_dismissTooltip);
    _removeOverlay();
    super.dispose();
  }

  void _dismissTooltip() {
    if (_activeDate == null) return;
    _removeOverlay();
    setState(() => _activeDate = null);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _onCellTap(PremiumDailyActivityVO cell) {
    if (!cell.hasActivity) {
      _removeOverlay();
      setState(() => _activeDate = null);
      return;
    }

    if (_activeDate == cell.date) {
      // 再次点击关闭
      _removeOverlay();
      setState(() => _activeDate = null);
      return;
    }

    _removeOverlay();
    setState(() => _activeDate = cell.date);

    // 延迟一帧等 setState 完成后再创建 overlay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showTooltip(cell);
    });
  }

  void _showTooltip(PremiumDailyActivityVO cell) {
    final key = _cellKeys[cell.date];
    if (key == null) return;
    final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final cellSize = renderBox.size;
    final cellOffset = renderBox.localToGlobal(Offset.zero);
    final overlay = Overlay.of(context);
    final screenSize = MediaQuery.of(context).size;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return _CalendarTooltipOverlay(
          cell: cell,
          cellOffset: cellOffset,
          cellSize: cellSize,
          screenSize: screenSize,
          onDismiss: () {
            _removeOverlay();
            setState(() => _activeDate = null);
          },
        );
      },
    );
    overlay.insert(_overlayEntry!);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 20),
        _buildWeekdayRow(),
        const SizedBox(height: 6),
        _buildCalendarGrid(),
      ],
    );
  }

  /// 标题行: "Daily Heatmap | month" + 渐变图例
  Widget _buildHeader() {
    final label = DateFormat('MMM yyyy').format(_month);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              'Daily Heatmap',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
                color: Colors.white.withValues(alpha: 0.3),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '|',
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                color: Colors.white.withValues(alpha: 0.2),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
                color: Colors.white.withValues(alpha: 0.3),
              ),
            ),
          ],
        ),
        // 渐变图例
        _buildLegend(),
      ],
    );
  }

  /// Loss [红...绿] Profit 渐变图例
  Widget _buildLegend() {
    final legends = [
      (kPremiumRed.withValues(alpha: 0.70), true),
      (kPremiumRed.withValues(alpha: 0.35), false),
      (kPremiumRed.withValues(alpha: 0.10), false),
      (kPremiumGreen.withValues(alpha: 0.10), false),
      (kPremiumGreen.withValues(alpha: 0.35), false),
      (kPremiumGreen.withValues(alpha: 0.70), true),
    ];
    const labelStyle = TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.8,
      color: Color.fromRGBO(255, 255, 255, 0.3),
    );
    return Container(
      height: 26,
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 1),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('LOSS', style: labelStyle),
          const SizedBox(width: 8),
          ...legends.asMap().entries.map((entry) {
            final (color, hasGlow) = entry.value;
            return Padding(
              padding: EdgeInsets.only(
                  right: entry.key < legends.length - 1 ? 4 : 0),
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: hasGlow
                      ? [
                          BoxShadow(
                              color: color.withValues(alpha: 0.5),
                              blurRadius: 6)
                        ]
                      : null,
                ),
              ),
            );
          }),
          const SizedBox(width: 8),
          const Text('PROFIT', style: labelStyle),
        ],
      ),
    );
  }

  Widget _buildWeekdayRow() {
    return Row(
      children: _kWeekdays.map((d) {
        return Expanded(
          child: Center(
            child: Text(
              d,
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: Colors.white.withValues(alpha: 0.2),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCalendarGrid() {
    final weeks = _buildWeeks();
    return Column(
      children: weeks.map((week) {
        return Padding(
          padding: const EdgeInsets.only(bottom: _kCellGap),
          child: Row(
            children: week.map((cell) {
              return Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: _kCellGap / 2),
                  child: _buildDayCell(cell),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }

  /// 将活动数据组织成周（每行 7 天，周日起始），前面用 null 填充
  List<List<PremiumDailyActivityVO?>> _buildWeeks() {
    final month = _month;
    final firstDay = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    // 周日 = 0
    final startWeekday = firstDay.weekday % 7;

    final activityMap = <int, PremiumDailyActivityVO>{};
    for (final a in widget.activities) {
      if (a.day > 0) activityMap[a.day] = a;
    }

    final cells = <PremiumDailyActivityVO?>[];
    for (var i = 0; i < startWeekday; i++) {
      cells.add(null);
    }
    for (var day = 1; day <= daysInMonth; day++) {
      cells.add(activityMap[day] ??
          PremiumDailyActivityVO(
            date: DateFormat('yyyy-MM-dd')
                .format(DateTime(month.year, month.month, day)),
            day: day,
            hasActivity: false,
            isWin: false,
            percentage: 0,
            trades: 0,
            volume: 0,
            netPnl: 0,
            intensity: 0,
          ));
    }
    while (cells.length % 7 != 0) {
      cells.add(null);
    }

    final weeks = <List<PremiumDailyActivityVO?>>[];
    for (var i = 0; i < cells.length; i += 7) {
      weeks.add(cells.sublist(i, i + 7));
    }
    return weeks;
  }

  Widget _buildDayCell(PremiumDailyActivityVO? cell) {
    if (cell == null) {
      return const AspectRatio(aspectRatio: 1);
    }

    // 确保有 key 以定位 tooltip
    _cellKeys.putIfAbsent(cell.date, () => GlobalKey());
    final cellKey = _cellKeys[cell.date]!;

    final hasActivity = cell.hasActivity;
    final isActive = _activeDate == cell.date && hasActivity;

    // 颜色计算（对齐 web 端 getCellColor）
    final baseColor = cell.isWin ? kPremiumGreen : kPremiumRed;
    final intensity = hasActivity
        ? math
            .min(math.pow((cell.percentage - 50).abs() / 50.0, 1.4), 1.0)
            .toDouble()
        : 0.0;

    Color bgColor;
    Color borderColor;
    List<BoxShadow>? shadows;

    if (hasActivity) {
      final fillA = 0.10 + intensity * 0.60;
      final borderA = 0.15 + intensity * 0.65;
      bgColor = baseColor.withValues(alpha: fillA);
      borderColor = baseColor.withValues(alpha: borderA);

      // glow 效果
      final glowShadows = <BoxShadow>[];
      if (intensity > 0.1) {
        glowShadows.add(BoxShadow(
          color: baseColor.withValues(alpha: intensity * 0.45),
          blurRadius: 6 + intensity * 18,
        ));
      }
      if (intensity > 0.4) {
        glowShadows.add(BoxShadow(
          color: baseColor.withValues(alpha: intensity * 0.25),
          blurRadius: 20 + intensity * 24,
        ));
      }

      // 选中态增强 glow
      if (isActive) {
        glowShadows.addAll([
          BoxShadow(
            color: baseColor.withValues(alpha: 0.6),
            blurRadius: 12,
          ),
          BoxShadow(
            color: baseColor.withValues(alpha: 0.35),
            blurRadius: 28,
          ),
        ]);
        borderColor = baseColor.withValues(alpha: 0.9);
      }

      shadows = glowShadows.isEmpty ? null : glowShadows;
    } else {
      bgColor = Colors.white.withValues(alpha: 0.03);
      borderColor = Colors.white.withValues(alpha: 0.06);
    }

    return GestureDetector(
      onTap: () => _onCellTap(cell),
      child: AspectRatio(
        key: cellKey,
        aspectRatio: 1,
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: _kCellBorderRadius,
            border: Border.all(
              color: borderColor,
              width: isActive ? 1.5 : 1,
            ),
            boxShadow: shadows,
          ),
          child: Stack(
            children: [
              // 扫描线叠加层（CRT 横纹效果）
              if (hasActivity)
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: _kCellBorderRadius,
                    child: CustomPaint(
                      painter: _ScanlinePainter(
                        color: Colors.black.withValues(alpha: 0.18),
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 日期数字
                    Text(
                      '${cell.day}',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w400,
                        color: Colors.white
                            .withValues(alpha: hasActivity ? 0.25 : 0.12),
                        height: 1,
                      ),
                    ),
                    // 胜率百分比（仅有活动时显示）
                    if (hasActivity)
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '${cell.percentage}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: baseColor.withValues(alpha: 0.8),
                                height: 1,
                              ),
                            ),
                            Text(
                              '%',
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w600,
                                color: baseColor.withValues(alpha: 0.8),
                                height: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tooltip 浮层（通过 Overlay 浮在所有布局之上）
class _CalendarTooltipOverlay extends StatelessWidget {
  final PremiumDailyActivityVO cell;
  final Offset cellOffset;
  final Size cellSize;
  final Size screenSize;
  final VoidCallback onDismiss;

  const _CalendarTooltipOverlay({
    required this.cell,
    required this.cellOffset,
    required this.cellSize,
    required this.screenSize,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final rgb = cell.isWin ? kPremiumGreen : kPremiumRed;
    final cellCenterX = cellOffset.dx + cellSize.width / 2;

    // tooltip 宽度估算
    const tooltipWidth = 200.0;
    const tooltipHeight = 80.0;
    const arrowSize = 6.0;
    const gap = 4.0;

    // 默认显示在上方
    bool showAbove = cellOffset.dy - tooltipHeight - arrowSize - gap > 0;
    final tooltipY = showAbove
        ? cellOffset.dy - tooltipHeight - arrowSize - gap
        : cellOffset.dy + cellSize.height + arrowSize + gap;

    // 水平居中，但不超出屏幕
    var tooltipX = cellCenterX - tooltipWidth / 2;
    tooltipX = tooltipX.clamp(8.0, screenSize.width - tooltipWidth - 8.0);

    // 箭头在 tooltip 中的相对 x 位置
    final arrowX = (cellCenterX - tooltipX).clamp(12.0, tooltipWidth - 12.0);

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onDismiss,
      child: SizedBox.expand(
        child: Stack(
          children: [
            Positioned(
              left: tooltipX,
              top: tooltipY,
              width: tooltipWidth,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!showAbove) _buildArrow(arrowX, rgb, pointUp: true),
                  _buildTooltipBody(rgb),
                  if (showAbove) _buildArrow(arrowX, rgb, pointUp: false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArrow(double arrowX, Color rgb, {required bool pointUp}) {
    return SizedBox(
      height: 6,
      child: Stack(
        children: [
          Positioned(
            left: arrowX - 6,
            child: CustomPaint(
              size: const Size(12, 6),
              painter: _ArrowPainter(
                color: rgb.withValues(alpha: 0.25),
                pointUp: pointUp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTooltipBody(Color rgb) {
    final dateLabel = _formatTooltipDate(cell.date);
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: rgb.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: rgb.withValues(alpha: 0.25)),
            boxShadow: [
              BoxShadow(
                color: rgb.withValues(alpha: 0.15),
                blurRadius: 12,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // 扫描线叠加层（白色横纹）
              Positioned.fill(
                child: Opacity(
                  opacity: 0.7,
                  child: CustomPaint(
                    painter: _ScanlinePainter(
                      color: Colors.white.withValues(alpha: 0.06),
                    ),
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 日期
                    Text(
                      dateLabel,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Win Rate | Trades | Vol
                    Row(
                      children: [
                        // Win Rate
                        Expanded(
                          child: _buildTooltipStat(
                            label: 'Win Rate',
                            value: '${cell.percentage}%',
                            valueColor: rgb.withValues(alpha: 0.9),
                            isHighlight: true,
                          ),
                        ),
                        _buildDivider(),
                        // Trades
                        Expanded(
                          child: _buildTooltipStat(
                            label: 'Trades',
                            value: '${cell.trades}',
                            valueColor: Colors.white.withValues(alpha: 0.6),
                          ),
                        ),
                        _buildDivider(),
                        // Volume
                        Expanded(
                          child: _buildTooltipStat(
                            label: 'Vol',
                            value:
                                '\$${cell.volume.round().toStringAsFixed(0)}',
                            valueColor: Colors.white.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTooltipStat({
    required String label,
    required String value,
    required Color valueColor,
    bool isHighlight = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 7,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            color: Colors.white.withValues(alpha: 0.25),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: isHighlight ? 14 : 12,
            fontWeight: isHighlight ? FontWeight.w700 : FontWeight.w600,
            color: valueColor,
            height: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 28,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: Colors.white.withValues(alpha: 0.1),
    );
  }

  String _formatTooltipDate(String dateStr) {
    final date = DateTime.tryParse(dateStr);
    if (date == null) return dateStr;
    return DateFormat('MMM d').format(date);
  }
}

/// 扫描线绘制（CRT 横纹效果）
/// 每隔 [spacing] 像素绘制 1px 的水平线
class _ScanlinePainter extends CustomPainter {
  final Color color;

  const _ScanlinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    // 每 2px 画 1px 横线，模拟 CRT 扫描线
    for (var y = 0.0; y < size.height; y += 2.0) {
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, 1), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ScanlinePainter oldDelegate) =>
      color != oldDelegate.color;
}

/// 三角箭头绘制
class _ArrowPainter extends CustomPainter {
  final Color color;
  final bool pointUp;

  const _ArrowPainter({required this.color, required this.pointUp});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();
    if (pointUp) {
      path.moveTo(0, size.height);
      path.lineTo(size.width / 2, 0);
      path.lineTo(size.width, size.height);
    } else {
      path.moveTo(0, 0);
      path.lineTo(size.width / 2, size.height);
      path.lineTo(size.width, 0);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ArrowPainter oldDelegate) =>
      color != oldDelegate.color || pointUp != oldDelegate.pointUp;
}
