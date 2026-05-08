import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:finality/features/analysis/models/premium_analysis_vo.dart';
import 'package:finality/features/analysis/widgets/premium/premium_card.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/material.dart';

/// 时间分析卡片 — Hourly(24柱) / Weekly(7柱) 标签页切换
///
/// 参考 Web 端 TimeAnalysisCard + CRTBarChart:
/// - 标签页切换：Hourly / Weekly
/// - CRT 光束柱状图（amber 渐变 + 顶部亮帽）
/// - 点击**任意 slot 区域**即可选中（不只是光束本身）
/// - tooltip 从柱子顶部延伸竖线 + 圆点，气泡在圆点旁边
class TimeAnalysisCard extends StatefulWidget {
  final List<EfficiencyPointVO> hourly;
  final List<EfficiencyPointVO> weekday;

  const TimeAnalysisCard({
    super.key,
    required this.hourly,
    required this.weekday,
  });

  @override
  State<TimeAnalysisCard> createState() => _TimeAnalysisCardState();
}

class _TimeAnalysisCardState extends State<TimeAnalysisCard>
    with SingleTickerProviderStateMixin {
  _TimeTab _activeTab = _TimeTab.hourly;
  int? _selectedIndex;
  late AnimationController _entrance;

  // 布局常量（与 Web 端 CRTBarChart 对齐）
  static const _lineTopPad = 36.0; // 竖线向上延伸的空间
  static const _barAreaHeight = 72.0; // 柱子区域高度
  static const _labelHeight = 18.0; // X 轴标签高度
  static const _chartHeight = _lineTopPad + _barAreaHeight + _labelHeight;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _entrance.forward();
    });
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  List<EfficiencyPointVO> get _activePoints =>
      _activeTab == _TimeTab.hourly ? widget.hourly : widget.weekday;

  bool get _isCompact => _activeTab == _TimeTab.hourly;

  void _switchTab(_TimeTab tab) {
    if (tab == _activeTab) return;
    setState(() {
      _activeTab = tab;
      _selectedIndex = null;
    });
    _entrance.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      borderRadius: 16,
      heroGlow: true,
      padding: const EdgeInsets.all(17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          Dimens.vGap12,
          _buildChartArea(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TIME ANALYSIS',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white.withValues(alpha: 0.8),
                letterSpacing: 0.8,
                height: 21 / 14,
              ),
            ),
            Dimens.vGap2,
            Text(
              _activeTab == _TimeTab.hourly
                  ? 'Win rate across 24 hours'
                  : 'Win rate across weekdays',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: kPremiumOrange.withValues(alpha: 0.3),
                height: 18 / 12,
              ),
            ),
          ],
        ),
        _buildTabSwitcher(),
      ],
    );
  }

  Widget _buildTabSwitcher() {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
        color: Colors.white.withValues(alpha: 0.02),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 2,
        children: _TimeTab.values.map((tab) {
          final isActive = tab == _activeTab;
          return GestureDetector(
            onTap: () => _switchTab(tab),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: isActive
                    ? kPremiumOrange.withValues(alpha: 0.08)
                    : Colors.transparent,
              ),
              child: Text(
                tab.label.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  height: 15 / 10,
                  color: isActive
                      ? kPremiumOrange
                      : kPremiumOrange.withValues(alpha: 0.3),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildChartArea() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final points = _activePoints;
        if (points.isEmpty) return const SizedBox.shrink();

        final slotWidth = totalWidth / points.length;

        return TapRegion(
          onTapOutside: _selectedIndex != null
              ? (_) => setState(() => _selectedIndex = null)
              : null,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (d) {
              final idx =
                  (d.localPosition.dx / slotWidth).floor().clamp(0, points.length - 1);
              setState(() {
                _selectedIndex = _selectedIndex == idx ? null : idx;
              });
            },
            child: SizedBox(
              height: _chartHeight,
              child: AnimatedBuilder(
                animation: _entrance,
                builder: (context, _) {
                  return CustomPaint(
                    size: Size(totalWidth, _chartHeight),
                    painter: _CRTBeamChartPainter(
                      points: points,
                      selectedIndex: _selectedIndex,
                      animProgress: CurvedAnimation(
                        parent: _entrance,
                        curve: Curves.easeOutCubic,
                      ).value,
                      compact: _isCompact,
                      lineTopPad: _lineTopPad,
                      barAreaHeight: _barAreaHeight,
                      labelHeight: _labelHeight,
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

enum _TimeTab {
  hourly('Hourly'),
  weekday('Weekday');

  final String label;
  const _TimeTab(this.label);
}

// ==================== 完整 CRT 光束图表绘制器 ====================

/// 集光束柱状图 + 竖线 + 圆点 + tooltip 于一体的 CustomPainter
///
/// 与 Web 端 CRTBarChart 对齐：
/// - 柱子最小高度 6%（即使无数据）
/// - 选中后：竖线（从柱顶到顶部区域）+ 顶端圆点 + 旁边 tooltip 气泡
/// - 所有 X 轴标签都显示
class _CRTBeamChartPainter extends CustomPainter {
  final List<EfficiencyPointVO> points;
  final int? selectedIndex;
  final double animProgress;
  final bool compact;
  final double lineTopPad;
  final double barAreaHeight;
  final double labelHeight;

  _CRTBeamChartPainter({
    required this.points,
    required this.selectedIndex,
    required this.animProgress,
    required this.compact,
    required this.lineTopPad,
    required this.barAreaHeight,
    required this.labelHeight,
  });

  static const _dotSize = 10.0;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final count = points.length;
    final barAreaBottom = lineTopPad + barAreaHeight;
    final slotWidth = size.width / count;
    final beamWidth = compact ? 5.0 : 8.0;
    final max = points.map((p) => p.value).reduce(math.max).clamp(1, 100);

    // ── 1. 绘制所有光束 ──
    for (int i = 0; i < count; i++) {
      final p = points[i];
      final centerX = slotWidth * i + slotWidth / 2;
      final isSelected = i == selectedIndex;
      final isDimmed = selectedIndex != null && !isSelected;
      final isWinning = p.value >= 50;

      // 与 Web 一致：最小 6%
      final hPct = math.max((p.value / max) * 100, 6) / 100;
      final h = barAreaHeight * hPct * animProgress;
      final barTop = barAreaBottom - h;
      final barLeft = centerX - beamWidth / 2;

      final beamRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(barLeft, barTop, beamWidth, h),
        Radius.circular(beamWidth / 2),
      );

      // 渐变颜色
      final colors = isSelected
          ? (isWinning
              ? [
                  const Color(0x4DFF9900),
                  const Color(0xB3FFB020),
                  const Color(0xF2FFDCA0),
                ]
              : [
                  Colors.white.withValues(alpha: 0.15),
                  Colors.white.withValues(alpha: 0.4),
                  Colors.white.withValues(alpha: 0.7),
                ])
          : (isWinning
              ? [
                  const Color(0x26FF9900),
                  const Color(0x80FF9900),
                  const Color(0xB3FFC878),
                ]
              : [
                  Colors.white.withValues(alpha: 0.04),
                  Colors.white.withValues(alpha: 0.12),
                  Colors.white.withValues(alpha: 0.25),
                ]);

      final beamPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: colors,
        ).createShader(Rect.fromLTWH(barLeft, barTop, beamWidth, h));

      if (isDimmed) {
        canvas.saveLayer(
          Rect.fromLTWH(barLeft - 4, barTop - 4, beamWidth + 8, h + 8),
          Paint()..color = Colors.white.withValues(alpha: 0.3),
        );
      }

      // 光束外发光（选中态）
      if (isSelected) {
        final glowColor = isWinning
            ? kPremiumOrange.withValues(alpha: 0.2)
            : Colors.white.withValues(alpha: 0.08);
        canvas.drawRRect(
          beamRect,
          Paint()
            ..color = glowColor
            ..maskFilter =
                MaskFilter.blur(BlurStyle.normal, beamWidth + 6),
        );
      }

      canvas.drawRRect(beamRect, beamPaint);

      // 顶部亮帽
      if (h > beamWidth) {
        final capColors = isSelected
            ? (isWinning
                ? [const Color(0xFFFFC878), const Color(0x99FFB020)]
                : [
                    Colors.white.withValues(alpha: 0.9),
                    Colors.white.withValues(alpha: 0.3),
                  ])
            : (isWinning
                ? [const Color(0xCCFFC878), const Color(0x4DFF9900)]
                : [
                    Colors.white.withValues(alpha: 0.4),
                    Colors.white.withValues(alpha: 0.1),
                  ]);
        final capPaint = Paint()
          ..shader = RadialGradient(colors: capColors).createShader(
            Rect.fromCircle(
              center: Offset(centerX, barTop),
              radius: beamWidth / 2,
            ),
          );
        canvas.drawCircle(Offset(centerX, barTop), beamWidth / 2, capPaint);

        // 亮帽光晕（选中）
        if (isSelected) {
          canvas.drawCircle(
            Offset(centerX, barTop),
            beamWidth + 4,
            Paint()
              ..color = (isWinning ? kPremiumOrange : Colors.white)
                  .withValues(alpha: 0.15)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
          );
        }
      }

      if (isDimmed) {
        canvas.restore();
      }

      // X 轴标签 — 所有标签都显示
      final tp = TextPainter(
        text: TextSpan(
          text: p.label,
          style: TextStyle(
            fontSize: compact ? 8 : 10,
            color: isSelected
                ? const Color(0xB3FFCC80)
                : Colors.white.withValues(alpha: 0.3),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(centerX - tp.width / 2, barAreaBottom + 3),
      );
    }

    // ── 2. 绘制选中态的竖线 + 圆点 + tooltip ──
    if (selectedIndex != null) {
      _paintTooltipOverlay(canvas, size, slotWidth, max);
    }
  }

  void _paintTooltipOverlay(
    Canvas canvas,
    Size size,
    double slotWidth,
    int max,
  ) {
    final idx = selectedIndex!;
    final p = points[idx];
    final centerX = slotWidth * idx + slotWidth / 2;
    final hPct = math.max((p.value / max) * 100, 6) / 100;
    final barTop = (lineTopPad + barAreaHeight) - barAreaHeight * hPct * animProgress;

    // 竖线范围：从柱顶到 lineTopPad 区域的上部
    final lineTop = 6.0;
    final lineBottom = barTop;

    // 竖线光晕
    canvas.drawLine(
      Offset(centerX, lineTop),
      Offset(centerX, lineBottom),
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(centerX, lineBottom),
          Offset(centerX, lineTop),
          [
            kPremiumOrange.withValues(alpha: 0.5),
            kPremiumOrange.withValues(alpha: 0.08),
          ],
        )
        ..strokeWidth = 6
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // 竖线实线
    canvas.drawLine(
      Offset(centerX, lineTop),
      Offset(centerX, lineBottom),
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(centerX, lineBottom),
          Offset(centerX, lineTop),
          [
            kPremiumOrange.withValues(alpha: 0.9),
            kPremiumOrange.withValues(alpha: 0.25),
          ],
        )
        ..strokeWidth = 2,
    );

    // 顶端圆点
    final dotCenter = Offset(centerX, lineTop);
    final dotR = _dotSize / 2;
    // 外发光
    canvas.drawCircle(
      dotCenter,
      dotR + 6,
      Paint()
        ..color = kPremiumOrange.withValues(alpha: 0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    // 填充
    canvas.drawCircle(
      dotCenter,
      dotR,
      Paint()
        ..shader = RadialGradient(
          colors: [const Color(0xFFFFB020), kPremiumOrange],
          stops: const [0.3, 1.0],
        ).createShader(Rect.fromCircle(center: dotCenter, radius: dotR)),
    );
    // 描边
    canvas.drawCircle(
      dotCenter,
      dotR,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = const Color(0xB3FFDCA0),
    );

    // ── tooltip 气泡 ──
    // 与 Web 一致：左边缘柱子 (i<=2) tooltip 放在圆点右侧，其余放左侧
    final isLeftEdge = idx <= 2;
    final tooltipText1 = '${p.value}%';
    final tooltipText2 = '${p.trades} trades';

    // 气泡内文字（同时用于测量宽度和绘制）
    final valueTp = TextPainter(
      text: TextSpan(
        text: tooltipText1,
        style: TextStyle(
          fontFamily: 'DrukWide',
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: const Color(0xFFFFCC80),
          shadows: [
            Shadow(
              color: kPremiumOrange.withValues(alpha: 0.5),
              blurRadius: 6,
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final tradesTp = TextPainter(
      text: TextSpan(
        text: tooltipText2,
        style: TextStyle(
          fontSize: 10,
          color: Colors.white.withValues(alpha: 0.3),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final bubbleW = valueTp.width + 8 + tradesTp.width + 20; // 内容 + gap + padding
    final bubbleH = 28.0;
    final bubbleR = 8.0;

    // 气泡位置
    final bubbleY = lineTop - dotR - 14 - bubbleH / 2;
    double bubbleX;
    if (isLeftEdge) {
      bubbleX = centerX + dotR + 4;
    } else {
      bubbleX = centerX - dotR - 4 - bubbleW;
    }
    // 防止超出边界
    bubbleX = bubbleX.clamp(0, size.width - bubbleW);

    final bubbleRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(bubbleX, bubbleY, bubbleW, bubbleH),
      Radius.circular(bubbleR),
    );

    // 气泡背景
    canvas.drawRRect(
      bubbleRect,
      Paint()..color = const Color(0xEB121214),
    );
    // 气泡边框
    canvas.drawRRect(
      bubbleRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = Colors.white.withValues(alpha: 0.08),
    );
    // 气泡阴影
    canvas.drawRRect(
      bubbleRect,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    // 重绘背景（阴影上面）
    canvas.drawRRect(
      bubbleRect,
      Paint()..color = const Color(0xEB121214),
    );
    canvas.drawRRect(
      bubbleRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = Colors.white.withValues(alpha: 0.08),
    );

    // 绘制气泡内文字
    valueTp.paint(
      canvas,
      Offset(bubbleX + 10, bubbleY + (bubbleH - valueTp.height) / 2),
    );
    tradesTp.paint(
      canvas,
      Offset(
        bubbleX + 10 + valueTp.width + 8,
        bubbleY + (bubbleH - tradesTp.height) / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant _CRTBeamChartPainter old) {
    return old.animProgress != animProgress ||
        old.selectedIndex != selectedIndex ||
        old.points != points ||
        old.compact != compact;
  }
}
