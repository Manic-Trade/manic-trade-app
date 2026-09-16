import 'package:finality/features/analysis/models/premium_analysis_vo.dart';
import 'package:finality/features/analysis/widgets/premium/premium_card.dart';
import 'package:finality/generated/assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

// Web: textShadow: "0 0 6px rgba(255,153,0,0.1)"
const _kAmberTextShadow = [
  Shadow(color: Color.fromRGBO(255, 153, 0, 0.1), blurRadius: 6),
];

/// 最近交易水平滚动条（CRT 风格 Marquee）
///
/// 参考 Web 端 InlineTradeTape (premium-view.tsx L554-L707)
/// - 左侧 "Trades" 标签 + amber 脉冲圆点
/// - 每条：方向箭头 + 资产名 + PnL 金额
/// - CSS marquee 无限滚动
class TradeTapeBar extends StatefulWidget {
  final List<TradeTapeVO> items;

  const TradeTapeBar({super.key, required this.items});

  @override
  State<TradeTapeBar> createState() => _TradeTapeBarState();
}

class _TradeTapeBarState extends State<TradeTapeBar>
    with SingleTickerProviderStateMixin {
  late final ScrollController _scrollController;
  late final AnimationController _animController;

  static const _scrollSpeed = 30.0; // px/s

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) => _startScrolling());
  }

  void _startScrolling() {
    if (!mounted || !_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    if (maxScroll <= 0) return;

    final durationMs = (maxScroll / _scrollSpeed * 1000).round();
    _animController.duration = Duration(milliseconds: durationMs);

    _animController.addListener(() {
      if (!_scrollController.hasClients) return;
      final max = _scrollController.position.maxScrollExtent;
      _scrollController.jumpTo(_animController.value * max);
    });

    _animController.repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return _buildEmpty();

    // 复制一份实现无缝循环
    final doubled = [...widget.items, ...widget.items];

    return IgnorePointer(
      ignoring: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: _TapeCrtShell(
          child: Row(
            children: [
              // "Trades" 标签
              _buildTradesLabel(),
              // 分隔线
              Container(
                width: 1,
                height: 12,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                color: kPremiumOrange.withValues(alpha: 0.1),
              ),
              // 滚动条目
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: doubled.length,
                  itemBuilder: (_, i) => _buildItem(doubled[i]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTradesLabel() {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // amber 脉冲圆点
          _PulsingDot(color: kPremiumOrange, size: 4),
          const SizedBox(width: 6),
          Text(
            'TRADES',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: kPremiumOrange.withValues(alpha: 0.4),
              letterSpacing: 1.2,
              shadows: _kAmberTextShadow,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(TradeTapeVO item) {
    final isWin = item.isWin;
    final color = isWin ? kPremiumGreen : kPremiumRed;
    final sign = isWin ? '+' : '−';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 方向箭头（Higher=左上指, Lower=旋转90°）
            Transform.rotate(
              angle: item.mode == 'Lower' ? 1.5708 : 0, // 90° in radians
              child: SvgPicture.asset(
                Assets.svgsAnalysisTradeTapeArrow,
                width: 10,
                height: 10,
                colorFilter: ColorFilter.mode(
                  color.withValues(alpha: 0.4),
                  BlendMode.srcIn,
                ),
              ),
            ),
            const SizedBox(width: 6),
            // 资产名
            Text(
              item.asset.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: color.withValues(alpha: 0.55),
                letterSpacing: 0.5,
                shadows: _kAmberTextShadow,
              ),
            ),
            const SizedBox(width: 6),
            // PnL
            Text(
              '$sign\$${_formatPnl(item.pnl.abs())}',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: color.withValues(alpha: 0.55),
                fontFeatures: const [FontFeature.tabularFigures()],
                letterSpacing: 0.3,
                shadows: _kAmberTextShadow,
              ),
            ),
            const SizedBox(width: 8),
            // 分隔点
            Container(
              width: 3,
              height: 3,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return _TapeCrtShell(
      child: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: Row(
          children: [
            _PulsingDot(color: kPremiumOrange.withValues(alpha: 0.3), size: 4),
            const SizedBox(width: 6),
            Text(
              'AWAITING SIGNAL …',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: kPremiumOrange.withValues(alpha: 0.25),
                letterSpacing: 1.0,
                shadows: _kAmberTextShadow,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static final _compactFormat =
      NumberFormat.compactCurrency(symbol: '', decimalDigits: 0);

  static String _formatPnl(double value) {
    if (value >= 1000) return _compactFormat.format(value);
    return value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 2);
  }
}

/// Tape CRT 外壳 — 背景 + 扫描线 + 上下边框 + 暗角
///
/// Web: tape-crt-screen 样式
class _TapeCrtShell extends StatelessWidget {
  final Widget child;

  const _TapeCrtShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        height: 36,
        child: Stack(
          children: [
            // 暖色深色背景（不透明，确保 CRT 暖色调可见）
            // Web: linear-gradient(180deg, rgba(12,10,6,0.85) ...) 在深色页面上
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: const [
                      Color(0xFF0C0A06), // 暖黑色（上边缘）
                      Color(0xFF0A0A0A), // 纯深色（中间）
                      Color(0xFF0A0A0A),
                      Color(0xFF0C0A06), // 暖黑色（下边缘）
                    ],
                    stops: const [0.0, 0.3, 0.7, 1.0],
                  ),
                ),
              ),
            ),
            // CRT 扫描线（白色，带左右边缘渐隐）
            // Web: repeating-linear-gradient white/0.04, opacity 0.55,
            //       mask-image fade 10%-90%
            Positioned.fill(
              child: ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.white,
                    Colors.white,
                    Colors.transparent,
                  ],
                  stops: [0.0, 0.1, 0.9, 1.0],
                ).createShader(bounds),
                blendMode: BlendMode.dstIn,
                child: CustomPaint(
                  painter: const _TapeScanLinesPainter(),
                ),
              ),
            ),
            // 顶部 amber 发光条
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 8, // h-2 = 8px
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      kPremiumOrange.withValues(alpha: 0.04),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // 底部 amber 发光条
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 8,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      kPremiumOrange.withValues(alpha: 0.03),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // 暗角 — Web: radial-gradient(ellipse 85% 130%, transparent 40%, rgba(0,0,0,0.6))
            // Flutter 的 RadialGradient.radius 基于最短边(height)，
            // 对于宽扁控件需要很大的 radius 才能水平覆盖
            // 85% width / half-height ≈ 8.5
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 8.5,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.6),
                    ],
                    stops: const [0.4, 1.0],
                  ),
                ),
              ),
            ),
            // 上边框线 (h-px)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      kPremiumOrange.withValues(alpha: 0.08),
                      Colors.transparent,
                    ],
                    stops: const [0.1, 0.5, 0.9],
                  ),
                ),
              ),
            ),
            // amber 氛围光 — Web: radial-gradient(60% 100%, rgba(255,153,0,0.03), transparent 70%)
            // 60% width / half-height ≈ 6.0
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 6.0,
                    colors: [
                      kPremiumOrange.withValues(alpha: 0.03),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.7],
                  ),
                ),
              ),
            ),
            // 内容
            child,
            // 下边框线 (h-px, z-[7] 在内容之上)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      kPremiumOrange.withValues(alpha: 0.04),
                      Colors.transparent,
                    ],
                    stops: const [0.15, 0.5, 0.85],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tape 专用扫描线 — 白色细线
/// Web: repeating-linear-gradient(0deg, rgba(255,255,255,0.04) 0px 1px, transparent 1px 3px)
///      overall opacity 0.55
class _TapeScanLinesPainter extends CustomPainter {
  const _TapeScanLinesPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const lineHeight = 1.0;
    const gap = 2.0; // 总间距 3px（1px 线 + 2px 间隔）
    // 在不透明深色背景上，直接用 0.04 * 0.55 太淡
    // 适当提高到 0.04 使扫描线纹理可见
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..style = PaintingStyle.fill;

    for (double y = 0; y < size.height; y += lineHeight + gap) {
      canvas.drawRect(
        Rect.fromLTWH(0, y, size.width, lineHeight),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 脉冲圆点动画
class _PulsingDot extends StatefulWidget {
  final Color color;
  final double size;

  const _PulsingDot({required this.color, required this.size});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
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
        // Web: opacity 0.4~1.0, 三层 box-shadow
        final t = Curves.easeInOut.transform(_controller.value);
        final opacity = 0.4 + 0.6 * t;
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: widget.color.withValues(alpha: opacity),
            shape: BoxShape.circle,
            boxShadow: [
              // 内层强发光
              BoxShadow(
                color: widget.color.withValues(alpha: 0.9 * t),
                blurRadius: 4,
                spreadRadius: 1 * t,
              ),
              // 中层扩散
              BoxShadow(
                color: widget.color.withValues(alpha: 0.5 * t),
                blurRadius: 10,
                spreadRadius: 2 * t,
              ),
              // 外层柔和光晕
              BoxShadow(
                color: widget.color.withValues(alpha: 0.2 * t),
                blurRadius: 20,
                spreadRadius: 4 * t,
              ),
            ],
          ),
        );
      },
    );
  }
}
