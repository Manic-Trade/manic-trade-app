import 'dart:ui' as ui;

import 'package:finality/features/analysis/models/premium_analysis_vo.dart';
import 'package:finality/features/analysis/widgets/premium/premium_card.dart';
import 'package:finality/theme/attrs/druk_wide_font.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

/// 方向偏好卡片 — Higher / Lower 标签页切换
///
/// 参考 Web 端 DirectionalBiasSection:
/// - 顶部标签页切换（Higher / Lower）
/// - 大号胜率数字
/// - 30 段分离式 CRT SegmentedBar（amber 渐变 + 多层光晕）
/// - 底部指标行：Trades / Volume / Net P&L
class DirectionalBiasCard extends StatefulWidget {
  final List<BiasMetricVO> items;

  const DirectionalBiasCard({super.key, required this.items});

  @override
  State<DirectionalBiasCard> createState() => _DirectionalBiasCardState();
}

class _DirectionalBiasCardState extends State<DirectionalBiasCard>
    with SingleTickerProviderStateMixin {
  late String _activeKey;
  late AnimationController _entrance;

  @override
  void initState() {
    super.initState();
    _activeKey = widget.items.isNotEmpty ? widget.items.first.key : '';
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _entrance.forward();
  }

  @override
  void didUpdateWidget(covariant DirectionalBiasCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items && widget.items.isNotEmpty) {
      if (!widget.items.any((i) => i.key == _activeKey)) {
        _activeKey = widget.items.first.key;
      }
      _entrance.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  BiasMetricVO get _activeItem => widget.items.firstWhere(
        (i) => i.key == _activeKey,
        orElse: () => widget.items.first,
      );

  void _switchTab(String key) {
    if (key == _activeKey) return;
    setState(() => _activeKey = key);
    _entrance.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();

    return PremiumCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          Dimens.vGap20,
          _buildHeroWinRate(),
          Dimens.vGap16,
          _buildSegmentedBar(),
          Dimens.vGap16,
          _buildMetricRow(),
        ],
      ),
    );
  }

  /// 标题 + 标签页切换
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'DIRECTIONAL BIAS',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Colors.white.withValues(alpha: 0.85),
            height: 1.3,
          ),
        ),
        Dimens.hGap16,
        _buildTabSwitcher(),
      ],
    );
  }

  Widget _buildTabSwitcher() {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
        color: Colors.white.withValues(alpha: 0.02),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: widget.items.map((item) {
          final isActive = item.key == _activeKey;
          return GestureDetector(
            onTap: () => _switchTab(item.key),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: isActive
                    ? kPremiumOrange.withValues(alpha: 0.08)
                    : Colors.transparent,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    item.key == 'lower' || item.key == 'put'
                        ? RemixIcons.arrow_right_down_line
                        : RemixIcons.arrow_right_up_line,
                    size: 10,
                    color: isActive
                        ? kPremiumOrange
                        : Colors.white.withValues(alpha: 0.25),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    item.label.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: isActive
                          ? kPremiumOrange
                          : Colors.white.withValues(alpha: 0.25),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 大号胜率数字
  Widget _buildHeroWinRate() {
    final item = _activeItem;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          '${item.winRate}',
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w700,
            color: const Color(0xFFFFCC80),
            height: 1.0,
            shadows: [
              Shadow(
                color: kPremiumOrange.withValues(alpha: 0.7),
                blurRadius: 8,
              ),
              Shadow(
                color: kPremiumOrange.withValues(alpha: 0.35),
                blurRadius: 24,
              ),
            ],
          ).toDrukWide(),
        ),
        Dimens.hGap2,
        Text(
          '%',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFFFFCC80).withValues(alpha: 0.5),
            shadows: [
              Shadow(
                color: kPremiumOrange.withValues(alpha: 0.3),
                blurRadius: 6,
              ),
            ],
          ).toDrukWide(),
        ),
        Dimens.hGap6,
        Text(
          'Win Rate',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.2),
          ),
        ),
      ],
    );
  }

  /// 30 段分离式 CRT SegmentedBar
  Widget _buildSegmentedBar() {
    final item = _activeItem;
    return SizedBox(
      height: 40,
      child: AnimatedBuilder(
        animation: _entrance,
        builder: (context, _) {
          return CustomPaint(
            size: Size.infinite,
            painter: _CRTSegmentedBarPainter(
              percent: item.winRate,
              progress: CurvedAnimation(
                parent: _entrance,
                curve: Curves.easeOutCubic,
              ).value,
            ),
          );
        },
      ),
    );
  }

  /// 底部指标行：Trades / Volume / Net P&L
  Widget _buildMetricRow() {
    final item = _activeItem;
    final isPositive = item.netPnl >= 0;
    final pnlColor = isPositive ? kPremiumGreen : kPremiumRed;
    final sign = isPositive ? '+' : '-';

    return Row(
      children: [
        _metricItem('Trades', '${item.trades}'),
        _divider(),
        _metricItem('Volume', '\$${_compactNumber(item.volume)}'),
        _divider(),
        _metricItem(
          'Net P&L',
          '$sign\$${_compactNumber(item.netPnl.abs())}',
          valueColor: pnlColor,
        ),
      ],
    );
  }

  Widget _metricItem(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.8,
            color: kPremiumOrange.withValues(alpha: 0.35),
          ),
        ),
        Dimens.hGap4,
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: valueColor ?? Colors.white.withValues(alpha: 0.5),
            shadows: valueColor != null
                ? [
                    Shadow(
                        color: valueColor.withValues(alpha: 0.3), blurRadius: 6)
                  ]
                : null,
          ),
        ),
      ],
    );
  }

  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Container(
        width: 1,
        height: 12,
        color: Colors.white.withValues(alpha: 0.08),
      ),
    );
  }
}

// ==================== CRT 分段进度条 ====================

/// 30 段 CRT 风格进度条
///
/// 与 Web 端 SegmentedBar 一致：
/// - 30 个独立的段，2px 间距
/// - 填充段使用 crtSegmentColor 渐变（从暗琥珀到亮金）
/// - 3 层 bloom 光晕（blur 10px / 5px / 2.5px）
/// - 未填充段使用 rgba(255,255,255,0.06) 背景
/// - CRT 水平扫描线叠加
/// - 尾部段有亮边帽
class _CRTSegmentedBarPainter extends CustomPainter {
  final int percent;
  final double progress;

  _CRTSegmentedBarPainter({
    required this.percent,
    required this.progress,
  });

  static const _segmentCount = 30;
  static const _segmentGap = 2.0;
  static const _segmentRadius = 1.0;

  /// 移植 Web 端 crtSegmentColor(t)：从暗琥珀渐变到亮金
  Color _crtSegmentColor(double t) {
    double r, g, b;
    if (t < 0.5) {
      final lt = t / 0.5;
      r = 90 + 70 * lt;
      g = 52 + 44 * lt;
      b = 0;
    } else {
      final lt = (t - 0.5) / 0.5;
      r = 160 + 95 * lt;
      g = 96 + 112 * lt;
      b = 152 * lt;
    }
    return Color.fromARGB(255, r.round(), g.round(), b.round());
  }

  @override
  void paint(Canvas canvas, Size size) {
    final totalGaps = (_segmentCount - 1) * _segmentGap;
    final segWidth = (size.width - totalGaps) / _segmentCount;
    final filledCount =
        ((percent / 100) * _segmentCount).round().clamp(0, _segmentCount);
    // 动画控制：逐段显示
    final animFilledCount = (filledCount * progress).round();
    final fillPct = animFilledCount / _segmentCount;

    // ── 1. 光晕层（在段下面绘制） ──
    if (animFilledCount > 0) {
      final glowWidth = fillPct * size.width;

      // Bloom L1 — 宽环境光（blur 10px）
      canvas.drawRect(
        Rect.fromLTWH(-4, -8, glowWidth + 8, size.height + 16),
        Paint()
          ..shader = ui.Gradient.linear(
            Offset.zero,
            Offset(glowWidth + 8, 0),
            [
              Colors.transparent,
              const Color(0x0FFF9900), // 6%
              const Color(0x24FF9900), // 14%
              const Color(0x2EFFD098), // 18%
            ],
            [0.0, 0.2, 0.65, 1.0],
          )
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      );

      // Bloom L2 — 中等光（blur 5px）
      canvas.drawRect(
        Rect.fromLTWH(-2, -4, glowWidth + 4, size.height + 8),
        Paint()
          ..shader = ui.Gradient.linear(
            Offset.zero,
            Offset(glowWidth + 4, 0),
            [
              Colors.transparent,
              const Color(0x14FF9900), // 8%
              const Color(0x40FF9900), // 25%
              const Color(0x33FFB020), // 20%
            ],
            [0.1, 0.4, 0.8, 1.0],
          )
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );

      // Bloom L3 — 紧贴光（blur 2.5px）
      canvas.drawRect(
        Rect.fromLTWH(0, -2, glowWidth, size.height + 4),
        Paint()
          ..shader = ui.Gradient.linear(
            Offset.zero,
            Offset(glowWidth, 0),
            [
              Colors.transparent,
              const Color(0x1AFFB020), // 10%
              const Color(0x59FFB020), // 35%
              const Color(0x40FFD098), // 25%
            ],
            [0.2, 0.5, 0.9, 1.0],
          )
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5),
      );
    }

    // ── 2. 绘制各段 ──
    for (int i = 0; i < _segmentCount; i++) {
      final x = i * (segWidth + _segmentGap);
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, 0, segWidth, size.height),
        Radius.circular(
          (i == 0 || i == _segmentCount - 1) ? 3.0 : _segmentRadius,
        ),
      );

      // 背景段（未填充 / 所有段的底色）
      canvas.drawRRect(
        rect,
        Paint()..color = Colors.white.withValues(alpha: 0.06),
      );

      // 填充段
      final isFilled = i < animFilledCount;
      if (isFilled) {
        final t = animFilledCount > 1 ? i / (animFilledCount - 1) : 1.0;

        // 段颜色 — amber 渐变
        final segColor = _crtSegmentColor(t);
        canvas.drawRRect(rect, Paint()..color = segColor);

        // 段光晕（t > 0.3 时开始发光）
        if (t > 0.3) {
          final gt = (t - 0.3) / 0.7;
          final glowAlpha = (0.15 + 0.45 * gt).clamp(0.0, 1.0);
          canvas.drawRRect(
            rect,
            Paint()
              ..color = kPremiumOrange.withValues(alpha: glowAlpha)
              ..maskFilter = MaskFilter.blur(
                BlurStyle.normal,
                4 + 10 * gt,
              ),
          );
        }

        // 过曝光效果（尾部 20% 的段）
        if (t > 0.8) {
          final overAlpha = 0.08 + 0.17 * ((t - 0.8) / 0.2);
          canvas.drawRRect(
            rect,
            Paint()
              ..color = const Color(0xFFFFE0B0).withValues(alpha: overAlpha)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1),
          );
        }

        // 尾部段亮边帽
        if (i == animFilledCount - 1) {
          final capRect = RRect.fromRectAndRadius(
            Rect.fromLTWH(x + segWidth - 2, 1, 2, size.height - 2),
            const Radius.circular(1),
          );
          canvas.drawRRect(
            capRect,
            Paint()
              ..color = const Color(0xB3FFE0B0) // 70%
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
          );
        }
      }
    }

    // ── 3. CRT 水平扫描线（覆盖在填充段上方） ──
    if (animFilledCount > 0) {
      final glowWidth = fillPct * size.width;
      canvas.save();
      canvas.clipRect(Rect.fromLTWH(0, 0, glowWidth, size.height));
      final scanPaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.2)
        ..strokeWidth = 0.5;
      for (double y = 0; y < size.height; y += 2) {
        canvas.drawLine(Offset(0, y), Offset(glowWidth, y), scanPaint);
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _CRTSegmentedBarPainter old) {
    return old.percent != percent || old.progress != progress;
  }
}

String _compactNumber(double value) {
  if (value.abs() >= 1e6) return '${(value / 1e6).toStringAsFixed(1)}M';
  if (value.abs() >= 1e3) return '${(value / 1e3).toStringAsFixed(1)}K';
  return value.toStringAsFixed(0);
}
