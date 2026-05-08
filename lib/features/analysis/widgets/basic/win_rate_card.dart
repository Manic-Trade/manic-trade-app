import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:finality/common/widgets/crt_glitch_effect.dart';
import 'package:finality/features/analysis/models/analysis_vo.dart';
import 'package:finality/features/analysis/widgets/animated_counter.dart';
import 'package:finality/features/analysis/widgets/basic/animated_win_loss_bar.dart';
import 'package:finality/features/analysis/widgets/wr_card_header.dart';
import 'package:finality/theme/attrs/druk_wide_font.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/material.dart';

/// 品牌橙色
const _kOrange = Color(0xFFFF9900);

/// Win Rate 卡片 — 带动画效果
///
/// 动画清单：
/// 1. Win Rate 数字递增/递减（AnimatedCounter）
/// 2. 数字区域弹簧入场（opacity + translateX）
/// 3. Total Trades 淡入
/// 4. Win/Loss 条宽度动画 + 扫光（AnimatedWinLossBar）
class WinRateCard extends StatefulWidget {
  final WinRateVO data;
  final VoidCallback? onShareTap;

  const WinRateCard({
    super.key,
    required this.data,
    this.onShareTap,
  });

  @override
  State<WinRateCard> createState() => _WinRateCardState();
}

class _WinRateCardState extends State<WinRateCard>
    with TickerProviderStateMixin {
  // 数字区域弹簧入场
  late final AnimationController _numberEntrance;
  late final Animation<double> _numberOpacity;
  late final Animation<Offset> _numberSlide;

  // Total Trades 淡入
  late final AnimationController _tradesEntrance;
  late final Animation<double> _tradesOpacity;

  @override
  void initState() {
    super.initState();

    // 数字入场：弹簧动画
    _numberEntrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _numberOpacity = CurvedAnimation(
      parent: _numberEntrance,
      curve: const Interval(0, 0.5, curve: Curves.easeOut),
    );
    _numberSlide = Tween<Offset>(
      begin: const Offset(-16, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _numberEntrance,
      curve: const _SpringCurve(stiffness: 220, damping: 22),
    ));

    // Total Trades 淡入
    _tradesEntrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _tradesOpacity = CurvedAnimation(
      parent: _tradesEntrance,
      curve: Curves.easeOut,
    );

    // 依次启动入场动画
    _numberEntrance.forward();
    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) _tradesEntrance.forward();
    });
  }

  @override
  void didUpdateWidget(covariant WinRateCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data.winRate != widget.data.winRate) {
      // 数据变化时重新播放入场动画
      _numberEntrance.forward(from: 0);
      _tradesEntrance.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _numberEntrance.dispose();
    _tradesEntrance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: Dimens.edgeInsetsScreenH,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        // 渐变边框：顶部中心较亮(0.3) → 边缘较暗(0.1)
        gradient: RadialGradient(
          center: const Alignment(0, -1),
          radius: 0.7,
          colors: [
            _kOrange.withValues(alpha: 0.3),
            _kOrange.withValues(alpha: 0.1),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: _kOrange.withValues(alpha: 0.06),
            blurRadius: 60,
          ),
          const BoxShadow(
            color: Color(0x80000000),
            blurRadius: 32,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding:
            const EdgeInsets.only(left: 1.8, right: 1.8, top: 1, bottom: 1.4),
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: const LinearGradient(
              begin: Alignment(-0.6, -0.8),
              end: Alignment(0.6, 0.8),
              colors: [
                Color(0xFF0C0A06),
                Color(0xFF0A0A0A),
                Color(0xFF080808),
              ],
              stops: [0.0, 0.4, 1.0],
            ),
          ),
          child: Stack(
            children: [
              // 左侧红橙色径向光晕 (glitch-glow)
              Positioned.fill(
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: const Alignment(-0.5, 0.0),
                        radius: 1.2,
                        colors: [
                          const Color(0xFFFF412C).withValues(alpha: 0.15),
                          const Color(0xFFFF412C).withValues(alpha: 0),
                        ],
                        stops: const [0.0, 0.55],
                      ),
                    ),
                  ),
                ),
              ),
              // 水平扫描线纹理
              Positioned.fill(
                child: CustomPaint(
                  painter: const _ScanLinesPainter(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: _buildContent(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        Dimens.vGap16,
        _buildWinRateNumber(),
        Dimens.vGap16,
        // Total Trades 带淡入
        FadeTransition(
          opacity: _tradesOpacity,
          child: _buildTotalTrades(),
        ),
        Dimens.vGap10,
        AnimatedWinLossBar(
          winBarRatio: widget.data.winBarRatio,
          wins: widget.data.wins,
          losses: widget.data.losses,
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return WrCardHeader(onShareTap: widget.onShareTap);
  }

  Widget _buildWinRateNumber() {
    return SizedBox(
      height: 100,
      child: AnimatedBuilder(
        animation: _numberEntrance,
        builder: (context, child) {
          return Opacity(
            opacity: _numberOpacity.value,
            child: Transform.translate(
              offset: _numberSlide.value,
              child: child,
            ),
          );
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            AnimatedCounter(
              value: widget.data.winRate,
              style: TextStyle(
                fontSize: 70,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFFFCC80),
                height: 1.03,
                letterSpacing: 0.8,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                  Shadow(
                    color: _kOrange.withValues(alpha: 0.7),
                    blurRadius: 12,
                  ),
                  Shadow(
                    color: _kOrange.withValues(alpha: 0.35),
                    blurRadius: 40,
                  ),
                  Shadow(
                    color: _kOrange.withValues(alpha: 0.15),
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
                color: _kOrange.withValues(alpha: 0.25),
                shadows: [
                  Shadow(
                    color: _kOrange.withValues(alpha: 0.2),
                    blurRadius: 12,
                  ),
                ],
              ).toDrukWide(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalTrades() {
    return Row(
      children: [
        Container(
          width: 2,
          height: 12,
          decoration: BoxDecoration(
            color: _kOrange.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(1),
          ),
        ),
        Dimens.hGap10,
        const Text(
          'TOTAL TRADES',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0x4DFFFFFF),
            letterSpacing: 0.8,
          ),
        ),
        Dimens.hGap10,
        Text(
          '${widget.data.totalTrades}',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: _kOrange.withValues(alpha: 0.5),
          ),
        ),
        Dimens.hGap10,
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _kOrange.withValues(alpha: 0.15),
                  _kOrange.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// 水平扫描线纹理，模拟 CRT/glitch 风格
class _ScanLinesPainter extends CustomPainter {
  const _ScanLinesPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const spacing = 3.0; // 扫描线间距
    final paint = Paint()
      ..color = const Color(0xFFFF9900).withValues(alpha: 0.04)
      ..strokeWidth = 0.5;

    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 自定义弹簧曲线，模拟 framer-motion 的 spring
class _SpringCurve extends Curve {
  final double stiffness;
  final double damping;

  const _SpringCurve({required this.stiffness, required this.damping});

  @override
  double transformInternal(double t) {
    // 临界阻尼弹簧近似
    final omega = stiffness / damping;
    return 1 - (1 + omega * t) * math.exp(-omega * t);
  }
}
