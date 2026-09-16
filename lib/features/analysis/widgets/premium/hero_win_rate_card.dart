import 'package:finality/common/widgets/crt_glitch_effect.dart';
import 'package:finality/features/analysis/models/premium_analysis_vo.dart';
import 'package:finality/features/analysis/widgets/animated_counter.dart';
import 'package:finality/features/analysis/widgets/premium/premium_card.dart';
import 'package:finality/features/analysis/widgets/wr_card_header.dart';
import 'package:finality/theme/attrs/druk_wide_font.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/material.dart';

/// Hero 大号胜率展示卡
///
/// 参考 Web 端 HeroWinRateCard (premium-view.tsx L232-L400)
/// - 左对齐大号百分比数字（DrukWide + CRT Glitch）
/// - "Outperforming [X%] of traders" 文案
/// - 24 段 amber 渐变进度条（基于 percentile）
/// - 底部 amber 径向光晕
class HeroWinRateCard extends StatefulWidget {
  final SummaryMetricVO data;
  final int wins;
  final int losses;
  final int winRatePercentile;
  final VoidCallback? onShareTap;

  const HeroWinRateCard({
    super.key,
    required this.data,
    required this.wins,
    required this.losses,
    required this.winRatePercentile,
    this.onShareTap,
  });

  @override
  State<HeroWinRateCard> createState() => _HeroWinRateCardState();
}

class _HeroWinRateCardState extends State<HeroWinRateCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entrance;
  late final Animation<double> _opacity;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _opacity = CurvedAnimation(
      parent: _entrance,
      curve: const Interval(0, 0.5, curve: Curves.easeOut),
    );
    _scale = Tween<double>(begin: 0.96, end: 1.0).animate(
      CurvedAnimation(parent: _entrance, curve: Curves.easeOutCubic),
    );
    _entrance.forward();
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  int get _winRateNumber {
    final digits = widget.data.value.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(digits) ?? 0;
  }

  /// 胜率排名百分位（来自 API win_rate_percentile）
  int get _outperformPct => widget.winRatePercentile;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _entrance,
      builder: (context, child) {
        return Opacity(
          opacity: _opacity.value,
          child: Transform.scale(scale: _scale.value, child: child),
        );
      },
      child: PremiumCard(
        borderRadius: 16,
        heroGlow: true,
        child: SizedBox(
          height: 248,
          child: Stack(
            children: [
              // 底部 amber 径向光晕
              Positioned(
                bottom: -40,
                left: 0,
                right: 0,
                height: 120,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.bottomCenter,
                      radius: 1.2,
                      colors: [
                        kPremiumOrange.withValues(alpha: 0.08),
                        kPremiumOrange.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
              // 中心 amber 光晕（与 web 一致）
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(-0.1, 0),
                      radius: 0.9,
                      colors: [
                        kPremiumOrange.withValues(alpha: 0.10),
                        kPremiumOrange.withValues(alpha: 0.03),
                        Colors.transparent,
                      ],
                      stops: const [0, 0.5, 0.75],
                    ),
                  ),
                ),
              ),
              // 内容
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    Dimens.vGap16,

                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: _buildWinRateNumber(),
                      ),
                    ),
                    Dimens.vGap16,

                    // "Outperforming [X%] of traders"
                    _buildOutperformText(),
                    Dimens.vGap8,
                    _buildSegmentBar(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return WrCardHeader(onShareTap: widget.onShareTap);
  }

  /// 大号胜率数字 — 左对齐, DrukWide, #FFCC80
  Widget _buildWinRateNumber() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        AnimatedCounter(
          value: _winRateNumber,
          style: TextStyle(
            fontSize: 70,
            fontWeight: FontWeight.w700,
            color: const Color(0xFFFFCC80),
            height: 1.0,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.4),
                offset: const Offset(0, 2),
                blurRadius: 4,
              ),
              Shadow(
                color: kPremiumOrange.withValues(alpha: 0.7),
                blurRadius: 12,
              ),
              Shadow(
                color: kPremiumOrange.withValues(alpha: 0.35),
                blurRadius: 40,
              ),
              Shadow(
                color: kPremiumOrange.withValues(alpha: 0.15),
                blurRadius: 80,
              ),
            ],
          ).toDrukWide(),
          textWrapper: (text) => CrtGlitchEffect(child: text),
        ),
        Dimens.hGap8,
        Text(
          '%',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: kPremiumOrange.withValues(alpha: 0.25),
            shadows: [
              Shadow(
                color: kPremiumOrange.withValues(alpha: 0.2),
                blurRadius: 12,
              ),
            ],
          ).toDrukWide(),
        ),
      ],
    );
  }

  /// "Outperforming [X%] of traders"
  Widget _buildOutperformText() {
    return Row(
      children: [
        Text(
          'Outperforming  ',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: kPremiumOrange.withValues(alpha: 0.3),
            letterSpacing: 0.3,
          ),
        ),
        Text(
          '[$_outperformPct%]',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: kPremiumOrange.withValues(alpha: 0.6),
            letterSpacing: 1.0,
            fontFeatures: const [FontFeature.tabularFigures()],
            shadows: [
              Shadow(
                color: kPremiumOrange.withValues(alpha: 0.3),
                blurRadius: 6,
              ),
            ],
          ),
        ),
        Text(
          '  of traders',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: kPremiumOrange.withValues(alpha: 0.3),
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  /// 24 段 amber 渐变进度条（基于 percentile）
  Widget _buildSegmentBar() {
    final threshold = (_outperformPct / 100 * 24).round().clamp(0, 24);
    return _AnimatedSegmentBar(threshold: threshold);
  }
}

/// 24 段进度条，amber 渐变 + 交错入场动画
class _AnimatedSegmentBar extends StatefulWidget {
  final int threshold;

  const _AnimatedSegmentBar({required this.threshold});

  @override
  State<_AnimatedSegmentBar> createState() => _AnimatedSegmentBarState();
}

class _AnimatedSegmentBarState extends State<_AnimatedSegmentBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          children: List.generate(24, (i) {
            final isActive = i < widget.threshold;

            // amber 渐变：从纯 orange 到偏金色
            final progress = isActive && widget.threshold > 1
                ? i / (widget.threshold - 1).clamp(1, 23)
                : 0.0;
            final g = isActive ? (153 + progress * 41).round() : 153;
            final b = isActive ? (progress * 96).round() : 0;
            final activeAlpha = 0.3 + progress * 0.7;

            // 交错入场
            final segStart = (0.12 + i * 0.03).clamp(0.0, 0.8);
            final segEnd = (segStart + 0.12).clamp(0.0, 1.0);
            final t = Interval(segStart, segEnd, curve: Curves.linear)
                .transform(_controller.value);

            final color = isActive
                ? Color.fromRGBO(255, g, b, activeAlpha * t)
                : kPremiumOrange.withValues(alpha: 0.06);

            return Expanded(
              child: Container(
                height: 5,
                margin: EdgeInsets.only(right: i < 23 ? 2 : 0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(1),
                  color: color,
                  boxShadow: isActive && t > 0.5
                      ? [
                          BoxShadow(
                            color: Color.fromRGBO(
                                255, g, b, (0.2 + progress * 0.5) * t),
                            blurRadius: 3 + progress * 7,
                          ),
                        ]
                      : null,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
