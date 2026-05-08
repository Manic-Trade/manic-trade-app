import 'dart:math' as math;

import 'package:finality/features/analysis/models/premium_analysis_vo.dart';
import 'package:finality/features/analysis/widgets/premium/premium_card.dart';
import 'package:finality/theme/attrs/druk_wide_font.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/material.dart';

/// 持仓时长效率卡片 — 6 根竖柱显示不同时长的胜率
///
/// 参考 Web 端 DurationBarChart:
/// - 6 根柱子（30s ~ 5m），深色渐变填充 + 边框 + neon 顶部高亮线
/// - 点击柱子后 tooltip 浮在柱子上方（带三角箭头）
/// - 非选中柱子变暗
class DurationEfficiencyCard extends StatefulWidget {
  final List<EfficiencyPointVO> items;

  const DurationEfficiencyCard({super.key, required this.items});

  @override
  State<DurationEfficiencyCard> createState() => _DurationEfficiencyCardState();
}

class _DurationEfficiencyCardState extends State<DurationEfficiencyCard>
    with SingleTickerProviderStateMixin {
  int? _selectedIndex;
  late AnimationController _entrance;

  static const _barGap = 12.0;
  static const _barAreaHeight = 140.0;
  static const _labelHeight = 24.0;
  // tooltip 区域高度（tooltip + 箭头 + 间距）
  static const _tooltipZone = 40.0;
  // 总高度
  static const _chartHeight = _tooltipZone + _barAreaHeight + _labelHeight;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _entrance.forward();
    });
  }

  @override
  void didUpdateWidget(covariant DurationEfficiencyCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) {
      _entrance.forward(from: 0);
      _selectedIndex = null;
    }
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  /// 计算每根柱子的布局参数
  _BarLayout _barLayout(double totalWidth) {
    final count = widget.items.length;
    final barWidth = (totalWidth - _barGap * (count - 1)) / count;
    return _BarLayout(barWidth: barWidth, count: count);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();

    return PremiumCard(
      borderRadius: 16,
      heroGlow: true,
      padding: const EdgeInsets.all(17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          Dimens.vGap12,
          _buildChartWithTooltip(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 2,
      children: [
        // 标题行：标题 + 右侧标签
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'DURATION EFFICIENCY',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white.withValues(alpha: 0.8),
                letterSpacing: 0.8,
                shadows: [
                  Shadow(
                    color: kPremiumOrange.withValues(alpha: 0.15),
                    blurRadius: 20,
                  ),
                ],
              ),
            ),
            // INDIVIDUAL ONLY 胶囊标签
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: kPremiumOrange.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'INDIVIDUAL ONLY',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: kPremiumOrange.withValues(alpha: 0.6),
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ],
        ),
        // 副标题
        Text(
          'Win rate by trade duration',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: kPremiumOrange.withValues(alpha: 0.3),
          ),
        ),
      ],
    );
  }

  Widget _buildChartWithTooltip() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final layout = _barLayout(totalWidth);

        return TapRegion(
          onTapOutside: _selectedIndex != null
              ? (_) => setState(() => _selectedIndex = null)
              : null,
          child: SizedBox(
            height: _chartHeight,
            child: Stack(
            clipBehavior: Clip.none,
            children: [
              // 柱状图
              Positioned(
                left: 0,
                right: 0,
                top: _tooltipZone,
                height: _barAreaHeight + _labelHeight,
                child: AnimatedBuilder(
                  animation: _entrance,
                  builder: (context, _) {
                    return GestureDetector(
                      onTapDown: (d) => _onTapDown(d, layout, totalWidth),
                      child: CustomPaint(
                        size: Size(totalWidth, _barAreaHeight + _labelHeight),
                        painter: _DurationBarPainter(
                          points: widget.items,
                          selectedIndex: _selectedIndex,
                          animProgress: CurvedAnimation(
                            parent: _entrance,
                            curve: Curves.easeOutCubic,
                          ).value,
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Tooltip（浮在柱子上方）
              if (_selectedIndex != null)
                _buildFloatingTooltip(layout, totalWidth),
            ],
          ),
          ),
        );
      },
    );
  }

  void _onTapDown(
      TapDownDetails details, _BarLayout layout, double totalWidth) {
    if (widget.items.isEmpty) return;

    final tapX = details.localPosition.dx;
    for (int i = 0; i < layout.count; i++) {
      final barLeft = i * (layout.barWidth + _barGap);
      if (tapX >= barLeft && tapX <= barLeft + layout.barWidth) {
        setState(() {
          _selectedIndex = _selectedIndex == i ? null : i;
        });
        return;
      }
    }
    setState(() => _selectedIndex = null);
  }

  Widget _buildFloatingTooltip(_BarLayout layout, double totalWidth) {
    final idx = _selectedIndex!;
    final p = widget.items[idx];
    final max = widget.items.map((p) => p.value).reduce(math.max).clamp(1, 100);
    final hPct = p.value > 0 ? math.max(p.value / max, 0.08) : 0.06;
    final barHeight = _barAreaHeight * hPct;

    // 柱子中心 X
    final barCenterX = idx * (layout.barWidth + _barGap) + layout.barWidth / 2;

    // tooltip 底部紧贴柱子顶部上方 8px
    final tooltipBottom = _tooltipZone + (_barAreaHeight - barHeight) - 8;

    // 固定宽度，足够容纳 DrukWide 字体的 "100%" + " 999 trades"
    const tooltipWidth = 140.0;
    double tooltipLeft = barCenterX - tooltipWidth / 2;
    tooltipLeft = tooltipLeft.clamp(0, totalWidth - tooltipWidth);

    // 三角箭头相对于 tooltip 的位置
    final arrowLeft = barCenterX - tooltipLeft;

    return Positioned(
      left: tooltipLeft,
      bottom: _chartHeight - tooltipBottom,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: tooltipWidth,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xF0121214),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.06),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${p.value}%',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFFFCC80),
                    shadows: [
                      Shadow(
                        color: kPremiumOrange.withValues(alpha: 0.5),
                        blurRadius: 6,
                      ),
                    ],
                  ).toDrukWide(),
                ),
                Dimens.hGap8,
                Text(
                  '${p.trades} trades',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
              ],
            ),
          ),
          // 三角箭头
          CustomPaint(
            size: const Size(8, 4),
            painter: _TooltipArrowPainter(
              offsetX: arrowLeft - tooltipWidth / 2,
            ),
          ),
        ],
      ),
    );
  }
}

/// tooltip 位置信息
class _BarLayout {
  final double barWidth;
  final int count;
  const _BarLayout({required this.barWidth, required this.count});
}

/// 三角箭头
class _TooltipArrowPainter extends CustomPainter {
  final double offsetX;
  _TooltipArrowPainter({this.offsetX = 0});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2 + offsetX - 4, 0)
      ..lineTo(size.width / 2 + offsetX, size.height)
      ..lineTo(size.width / 2 + offsetX + 4, 0)
      ..close();
    canvas.drawPath(
      path,
      Paint()..color = const Color(0xF0121214),
    );
  }

  @override
  bool shouldRepaint(covariant _TooltipArrowPainter old) =>
      old.offsetX != offsetX;
}

/// 柱状图绘制器
class _DurationBarPainter extends CustomPainter {
  final List<EfficiencyPointVO> points;
  final int? selectedIndex;
  final double animProgress;

  _DurationBarPainter({
    required this.points,
    required this.selectedIndex,
    required this.animProgress,
  });

  static const _barGap = 12.0;
  static const _labelHeight = 24.0;
  static const _barMaxHeight = 140.0;
  static const _scanLineSpacing = 2.0;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final count = points.length;
    final barWidth = (size.width - _barGap * (count - 1)) / count;
    final max = points.map((p) => p.value).reduce(math.max).clamp(1, 100);
    final barAreaBottom = size.height - _labelHeight;
    final availableHeight = math.min(_barMaxHeight, barAreaBottom);

    for (int i = 0; i < count; i++) {
      final x = i * (barWidth + _barGap);
      final isSelected = i == selectedIndex;
      final isDimmed = selectedIndex != null && !isSelected;
      final p = points[i];

      // 柱子高度
      final hPct = p.value > 0 ? math.max((p.value / max), 0.08) : 0.06;
      final barHeight = availableHeight * hPct * animProgress;
      final barTop = barAreaBottom - barHeight;
      final barRect = RRect.fromRectAndCorners(
        Rect.fromLTWH(x, barTop, barWidth, barHeight),
        topLeft: const Radius.circular(3),
        topRight: const Radius.circular(3),
      );

      final opacity = isDimmed ? 0.35 : 1.0;

      // 柱子填充 — 深色渐变
      final fillPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            const Color(0xFF0E0B04),
            const Color(0xFF151008),
            const Color(0xFF1C1508),
          ],
        ).createShader(Rect.fromLTWH(x, barTop, barWidth, barHeight));

      if (isDimmed) {
        canvas.saveLayer(
          Rect.fromLTWH(x - 1, barTop - 1, barWidth + 2, barHeight + 2),
          Paint()..color = Colors.white.withValues(alpha: opacity),
        );
      }

      canvas.drawRRect(barRect, fillPaint);

      // 边框
      canvas.drawRRect(
        barRect,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = Colors.white.withValues(alpha: 0.06),
      );

      // 顶部 neon 高亮线
      final neonColor =
          isSelected ? const Color(0xF0FFDCA0) : const Color(0x73FFB020); // 45%
      canvas.drawLine(
        Offset(x + 3, barTop),
        Offset(x + barWidth - 3, barTop),
        Paint()
          ..color = neonColor
          ..strokeWidth = 1,
      );
      // neon 光晕
      if (isSelected) {
        canvas.drawLine(
          Offset(x + 1, barTop),
          Offset(x + barWidth - 1, barTop),
          Paint()
            ..color = kPremiumOrange.withValues(alpha: 0.8)
            ..strokeWidth = 3
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
        );
        // 柱体侧面光晕
        canvas.drawRRect(
          barRect,
          Paint()
            ..color = kPremiumOrange.withValues(alpha: 0.15)
            ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 8),
        );
      }

      // CRT 扫描线纹理
      canvas.save();
      canvas.clipRRect(barRect);
      final scanPaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.2)
        ..strokeWidth = 0.5;
      for (double y = barTop; y < barAreaBottom; y += _scanLineSpacing) {
        canvas.drawLine(Offset(x, y), Offset(x + barWidth, y), scanPaint);
      }
      canvas.restore();

      if (isDimmed) {
        canvas.restore();
      }

      // X 轴标签
      final labelColor = isSelected
          ? const Color(0xB3FFCC80)
          : Colors.white.withValues(alpha: 0.2);
      final tp = TextPainter(
        text: TextSpan(
          text: p.label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: labelColor,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(x + (barWidth - tp.width) / 2, barAreaBottom + 6),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DurationBarPainter old) {
    return old.animProgress != animProgress ||
        old.selectedIndex != selectedIndex ||
        old.points != points;
  }
}
