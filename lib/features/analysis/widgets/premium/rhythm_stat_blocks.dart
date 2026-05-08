import 'package:finality/features/analysis/models/premium_analysis_vo.dart';
import 'package:finality/features/analysis/widgets/premium/premium_card.dart';
import 'package:flutter/material.dart';

/// RHYTHM 统计块（Longest Streak / Best Trading Day / Daily Average）
///
/// 竖排布局，对齐 web 端手机视图的 flex-col gap-12
class RhythmStatBlocks extends StatelessWidget {
  final RhythmStatsVO stats;

  const RhythmStatBlocks({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Longest Streak
        _RhythmStatBlock(
          label: 'Longest Streak',
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${stats.longestWinStreak}',
                style: TextStyle(
                  fontFamily: 'DrukWide',
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withValues(alpha: 0.55),
                  height: 1,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Trades',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Best Trading Day
        _RhythmStatBlock(
          label: 'Best Trading Day',
          child: _buildBestDay(),
        ),
        const SizedBox(height: 24),

        // Daily Average
        _RhythmStatBlock(
          label: 'Daily Average',
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                stats.dailyAverage,
                style: TextStyle(
                  fontFamily: 'DrukWide',
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withValues(alpha: 0.55),
                  height: 1,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Trades / Day',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBestDay() {
    final label = stats.bestTradingDayLabel;
    if (label == null || label == '-') {
      return Text(
        '—',
        style: TextStyle(
          fontFamily: 'DrukWide',
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: Colors.white.withValues(alpha: 0.55),
          height: 1,
        ),
      );
    }

    final pnl = stats.bestTradingDayPnl;
    final pnlColor = (pnl != null && pnl >= 0) ? kPremiumGreen : kPremiumRed;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'DrukWide',
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Colors.white.withValues(alpha: 0.55),
            height: 1,
          ),
        ),
        if (pnl != null) ...[
          const SizedBox(height: 8),
          Text(
            '${pnl >= 0 ? '+' : '-'}\$${pnl.abs().toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: pnlColor,
              shadows: [
                Shadow(
                  color: pnlColor.withValues(alpha: 0.3),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// 单个统计块：label + 分割线 + 内容
///
/// 对齐 web 端 RhythmStatBlock 组件结构
class _RhythmStatBlock extends StatelessWidget {
  final String label;
  final Widget child;

  const _RhythmStatBlock({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // label
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: Colors.white.withValues(alpha: 0.3),
          ),
        ),
        const SizedBox(height: 8),
        // 分割线（rhythm-seam）
        Container(
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withValues(alpha: 0.08),
                Colors.white.withValues(alpha: 0.03),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        // 内容
        child,
      ],
    );
  }
}
