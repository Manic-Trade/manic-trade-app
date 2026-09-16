import 'package:finality/features/analysis/models/premium_analysis_vo.dart';
import 'package:finality/features/analysis/widgets/premium/premium_card.dart';
import 'package:finality/theme/attrs/druk_wide_font.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/material.dart';

/// 模式效率对比卡片 — Individual vs Unified
///
/// 移动端竖排：左侧卡 + VS 分隔 + 右侧卡，下方可选 Insight 列表
class ModeEfficiencyCard extends StatefulWidget {
  final List<BiasMetricVO> modes;
  final List<InsightMetricVO> insights;

  const ModeEfficiencyCard({
    super.key,
    required this.modes,
    this.insights = const [],
  });

  @override
  State<ModeEfficiencyCard> createState() => _ModeEfficiencyCardState();
}

class _ModeEfficiencyCardState extends State<ModeEfficiencyCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _barAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _barAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic);
    _animController.forward();
  }

  @override
  void didUpdateWidget(covariant ModeEfficiencyCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.modes != widget.modes) {
      _animController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  BiasMetricVO get _left =>
      widget.modes.isNotEmpty ? widget.modes[0] : _emptyMode('Individual');

  BiasMetricVO get _right =>
      widget.modes.length >= 2 ? widget.modes[1] : _emptyMode('Unified');

  BiasMetricVO get _best {
    if (widget.modes.isEmpty) return _left;
    return widget.modes.reduce((a, b) => a.winRate > b.winRate ? a : b);
  }

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          Dimens.vGap20,
          _buildVsComparison(),
          // if (widget.insights.isNotEmpty) ...[
          //   Dimens.vGap16,
          //   _buildInsights(),
          // ],
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MODE EFFICIENCY',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.white.withValues(alpha: 0.8),
            letterSpacing: 0.8,
            height: 21 / 14,
          ),
        ),
        Dimens.vGap4,
        Text(
          'Individual vs Unified trading mode comparison',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: kPremiumOrange.withValues(alpha: 0.3),
            height: 18 / 12,
          ),
        ),
      ],
    );
  }

  /// VS 对比核心区域
  Widget _buildVsComparison() {
    final left = _left;
    final right = _right;
    final best = _best;
    final leftIsBest = left.key == best.key;
    final rightIsBest = right.key == best.key;

    return Column(
      children: [
        // 标签行
        Row(
          children: [
            Expanded(child: _buildModeLabel(left, leftIsBest)),
            const SizedBox(width: 40), // VS 占位
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: _buildModeLabel(right, rightIsBest),
              ),
            ),
          ],
        ),
        Dimens.vGap16,
        // 胜率大数字 + VS 分隔
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                child: Column(
              children: [
                _buildWinRateNumber(left, leftIsBest),
                Dimens.vGap12,
                AnimatedBuilder(
                  animation: _barAnim,
                  builder: (context, _) {
                    return _buildProgressBar(
                      left.winRate,
                      leftIsBest,
                      Alignment.centerLeft,
                    );
                  },
                ),
                Dimens.vGap16,
                _buildDetailPanel(left, leftIsBest)
              ],
            )),
            _buildVsSeparator(),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: Column(
                  children: [
                    _buildWinRateNumber(right, rightIsBest),
                    Dimens.vGap12,
                    AnimatedBuilder(
                      animation: _barAnim,
                      builder: (context, _) {
                        return _buildProgressBar(
                          right.winRate,
                          rightIsBest,
                          Alignment.centerRight,
                        );
                      },
                    ),
                    Dimens.vGap16,
                    _buildDetailPanel(right, rightIsBest)
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildModeLabel(BiasMetricVO mode, bool isBest) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          mode.label.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
            color: isBest
                ? Colors.white.withValues(alpha: 0.6)
                : Colors.white.withValues(alpha: 0.25),
          ),
        ),
        if (isBest) ...[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              color: kPremiumOrange.withValues(alpha: 0.1),
              border: Border.all(
                color: kPremiumOrange.withValues(alpha: 0.12),
              ),
            ),
            child: Text(
              'BEST',
              style: TextStyle(
                fontSize: 7,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: kPremiumOrange.withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildWinRateNumber(BiasMetricVO mode, bool isBest) {
    final numberColor =
        isBest ? const Color(0xFFFFCC80) : Colors.white.withValues(alpha: 0.18);
    final percentColor = isBest
        ? kPremiumOrange.withValues(alpha: 0.35)
        : Colors.white.withValues(alpha: 0.1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              '${mode.winRate}',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w700,
                color: numberColor,
                height: 1.0,
                shadows: isBest
                    ? [
                        Shadow(
                            color: kPremiumOrange.withValues(alpha: 0.7),
                            blurRadius: 8),
                        Shadow(
                            color: kPremiumOrange.withValues(alpha: 0.3),
                            blurRadius: 24),
                      ]
                    : null,
              ).toDrukWide(),
            ),
            const SizedBox(width: 2),
            Text(
              '%',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: percentColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'WIN RATE',
          style: TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
            color: isBest
                ? Colors.white.withValues(alpha: 0.2)
                : Colors.white.withValues(alpha: 0.1),
          ),
        ),
      ],
    );
  }

  /// VS 分隔符
  Widget _buildVsSeparator() {
    return SizedBox(
      width: 40,
      child: Column(
        children: [
          Container(
            width: 1,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  kPremiumOrange.withValues(alpha: 0.12),
                ],
              ),
            ),
          ),
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            child: Text(
              'VS',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: kPremiumOrange.withValues(alpha: 0.25),
              ).toDrukWide(),
            ),
          ),
          Container(
            width: 1,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  kPremiumOrange.withValues(alpha: 0.12),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 进度条
  Widget _buildProgressBar(int winRate, bool isBest, Alignment alignment) {
    final progress = _barAnim.value;
    final width = (winRate / 100) * progress;

    return Column(
      crossAxisAlignment: alignment == Alignment.centerRight
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (alignment == Alignment.centerRight) ...[
              Text(
                '$winRate%',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: isBest
                      ? Colors.white.withValues(alpha: 0.35)
                      : Colors.white.withValues(alpha: 0.15),
                ),
              ),
              const SizedBox(width: 6),
            ],
            Expanded(
              child: SizedBox(
                height: 6,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: Stack(
                    children: [
                      // 背景
                      Container(
                        color: Colors.white.withValues(alpha: 0.04),
                      ),
                      // 前景
                      Align(
                        alignment: alignment,
                        child: FractionallySizedBox(
                          widthFactor: width.clamp(0, 1),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(3),
                              gradient: LinearGradient(
                                begin: alignment == Alignment.centerRight
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                end: alignment == Alignment.centerRight
                                    ? Alignment.centerLeft
                                    : Alignment.centerRight,
                                colors: isBest
                                    ? const [
                                        Color(0xFF3A1E00),
                                        Color(0xFF7A4200),
                                        Color(0xFFC06800),
                                        Color(0xFFFF9900),
                                        Color(0xFFFFB840),
                                      ]
                                    : [
                                        Colors.white.withValues(alpha: 0.04),
                                        Colors.white.withValues(alpha: 0.10),
                                      ],
                              ),
                              boxShadow: isBest
                                  ? [
                                      BoxShadow(
                                        color: kPremiumOrange.withValues(
                                            alpha: 0.4),
                                        blurRadius: 8,
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (alignment == Alignment.centerLeft) ...[
              const SizedBox(width: 6),
              Text(
                '$winRate%',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: isBest
                      ? Colors.white.withValues(alpha: 0.35)
                      : Colors.white.withValues(alpha: 0.15),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  /// 详情面板（Trades / Volume / Net P&L）
  Widget _buildDetailPanel(BiasMetricVO mode, bool isBest) {
    final isPositive = mode.netPnl >= 0;
    final pnlColor = isPositive ? kPremiumGreen : kPremiumRed;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: isBest ? null : Colors.white.withValues(alpha: 0.01),
        gradient: isBest
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  kPremiumOrange.withValues(alpha: 0.05),
                  kPremiumOrange.withValues(alpha: 0.01),
                ],
              )
            : null,
        border: Border.all(
          color: isBest
              ? kPremiumOrange.withValues(alpha: 0.12)
              : Colors.white.withValues(alpha: 0.04),
        ),
      ),
      child: Column(
        children: [
          _detailRow(
            'Trades',
            '${mode.trades}',
            isBest
                ? Colors.white.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.3),
          ),
          Dimens.vGap10,
          _detailRow(
            'Volume',
            _fmtVolume(mode.volume),
            isBest
                ? Colors.white.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.3),
          ),
          Dimens.vGap10,
          _detailRow(
            'Net P&L',
            _fmtPnl(mode.netPnl),
            pnlColor,
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.15),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  /// Insight 卡片列表
  Widget _buildInsights() {
    return Column(
      children: widget.insights.map((insight) {
        final color = switch (insight.tone) {
          MetricTone.green => kPremiumGreen,
          MetricTone.red => kPremiumRed,
          MetricTone.amber => kPremiumOrange,
        };

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: color.withValues(alpha: 0.03),
            border: Border.all(color: color.withValues(alpha: 0.08)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    insight.label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: color.withValues(alpha: 0.6),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    insight.value,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ],
              ),
              if (insight.helper.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  insight.helper,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white.withValues(alpha: 0.25),
                    height: 1.4,
                  ),
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }
}

BiasMetricVO _emptyMode(String label) => BiasMetricVO(
      key: label.toLowerCase(),
      label: label,
      winRate: 0,
      trades: 0,
      volume: 0,
      netPnl: 0,
    );

String _fmtVolume(double v) {
  if (v >= 10000) return '\$${(v / 1000).toStringAsFixed(0)}K';
  if (v >= 1000) return '\$${(v / 1000).toStringAsFixed(1)}K';
  return '\$${v.toStringAsFixed(0)}';
}

String _fmtPnl(double v) {
  final sign = v >= 0 ? '+' : '-';
  final abs = v.abs();
  if (abs >= 1e6) return '$sign\$${(abs / 1e6).toStringAsFixed(1)}M';
  if (abs >= 1e3) return '$sign\$${(abs / 1e3).toStringAsFixed(1)}K';
  return '$sign\$${abs.toStringAsFixed(0)}';
}
