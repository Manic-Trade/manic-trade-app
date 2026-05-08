import 'package:finality/common/widgets/touchable.dart';
import 'package:finality/features/analysis/models/analysis_vo.dart';
import 'package:flutter/material.dart';

const _kOrange = Color(0xFFFF9900);

/// 账户胜率入口卡片（放在 UserPage，点击跳转 AnalysisScreen）
/// 动画效果参考 web 端 account-profile.tsx WinRateCard
class AccountWinRateCard extends StatefulWidget {
  final WinRateVO? data;
  final VoidCallback? onTap;

  const AccountWinRateCard({
    super.key,
    required this.data,
    this.onTap,
  });

  @override
  State<AccountWinRateCard> createState() => _AccountWinRateCardState();
}

class _AccountWinRateCardState extends State<AccountWinRateCard>
    with TickerProviderStateMixin {
  // 6 秒周期：glitch + 扫描线
  late final AnimationController _effectsController;
  // 1.4 秒周期：EKG 脉冲
  late final AnimationController _ekgController;

  @override
  void initState() {
    super.initState();
    _effectsController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
    _ekgController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _effectsController.dispose();
    _ekgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Touchable.plain(
      onTap: widget.onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: ColoredBox(
          color: _kOrange,
          child: Stack(
            children: [
              // Glitch 层 1 (#CC7700)
              _buildGlitchLayer(
                color: const Color(0xFFCC7700),
                getState: _getGlitch1State,
              ),
              // Glitch 层 2 (#FFBB33)
              _buildGlitchLayer(
                color: const Color(0xFFFFBB33),
                getState: _getGlitch2State,
              ),
              // 扫描线
              AnimatedBuilder(
                animation: _effectsController,
                builder: (context, _) => Positioned.fill(
                  child: CustomPaint(
                    painter: _ScanlinesPainter(_effectsController.value),
                  ),
                ),
              ),
              // 内容
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTopRow(),
                    const SizedBox(height: 12),
                    _buildViewAnalysisButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── 顶部行：胜率信息 + EKG ──

  Widget _buildTopRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: _buildWinRateInfo()),
        const SizedBox(width: 8),
        _buildEkg(),
      ],
    );
  }

  Widget _buildWinRateInfo() {
    final data = widget.data;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题
        const Text(
          "TODAY'S WIN RATE",
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Color(0x80000000),
            letterSpacing: 0.8,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 2),
        // 胜率 + 战绩
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              '${data?.winRate ?? 0}%',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(width: 8),
            Text.rich(
              TextSpan(
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                  color: Color(0xB3000000), // black/70
                ),
                children: [
                  TextSpan(text: '${data?.wins ?? 0}W '),
                  const TextSpan(
                    text: '·',
                    style: TextStyle(color: Color(0x4D000000)), // black/30
                  ),
                  TextSpan(text: ' ${data?.losses ?? 0}L'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── EKG 心电图 ──

  Widget _buildEkg() {
    return SizedBox(
      width: 32,
      height: 16,
      child: AnimatedBuilder(
        animation: _ekgController,
        builder: (context, _) => CustomPaint(
          painter: _EkgPainter(_ekgController.value),
        ),
      ),
    );
  }

  // ── View Analysis 按钮 ──

  Widget _buildViewAnalysisButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'View Analysis',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0x99000000), // black/60
              letterSpacing: 0.4,
              height: 1.5,
            ),
          ),
          Icon(
            Icons.chevron_right,
            size: 12,
            color: Colors.black.withValues(alpha: 0.4),
          ),
        ],
      ),
    );
  }

  // ── Glitch 效果 ──

  Widget _buildGlitchLayer({
    required Color color,
    required _GlitchState? Function(double t) getState,
  }) {
    return AnimatedBuilder(
      animation: _effectsController,
      builder: (context, _) {
        final state = getState(_effectsController.value);
        if (state == null) return const SizedBox.shrink();
        return Positioned.fill(
          child: Opacity(
            opacity: state.opacity,
            child: Transform.translate(
              offset: Offset(state.translateX, 0),
              child: ClipRect(
                clipper: _HorizontalBandClipper(
                  state.topFraction,
                  state.bottomFraction,
                ),
                child: ColoredBox(color: color),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Glitch 状态定义 + 关键帧插值（对齐 CSS keyframes 的平滑过渡）
// ══════════════════════════════════════════════════════════════════════════════

class _GlitchState {
  final double topFraction;
  final double bottomFraction;
  final double opacity;
  final double translateX;

  const _GlitchState(
    this.topFraction,
    this.bottomFraction,
    this.opacity,
    this.translateX,
  );

  static _GlitchState lerp(_GlitchState a, _GlitchState b, double t) {
    return _GlitchState(
      a.topFraction + (b.topFraction - a.topFraction) * t,
      a.bottomFraction + (b.bottomFraction - a.bottomFraction) * t,
      a.opacity + (b.opacity - a.opacity) * t,
      a.translateX + (b.translateX - a.translateX) * t,
    );
  }
}

/// 关键帧定义：(时间百分比, 状态)
class _Keyframe {
  final double time;
  final _GlitchState state;
  const _Keyframe(this.time, this.state);
}

const _kHidden = _GlitchState(0, 0, 0, 0);

/// 在关键帧列表中做线性插值，与 CSS animation 行为一致
_GlitchState? _interpolateKeyframes(List<_Keyframe> keyframes, double t) {
  // 找到 t 所在的区间
  for (int i = 0; i < keyframes.length - 1; i++) {
    final a = keyframes[i];
    final b = keyframes[i + 1];
    if (t >= a.time && t <= b.time) {
      // 如果两端都是隐藏状态，直接返回 null 避免不必要的绘制
      if (a.state.opacity == 0 && b.state.opacity == 0) return null;
      final segT = (t - a.time) / (b.time - a.time);
      return _GlitchState.lerp(a.state, b.state, segT);
    }
  }
  return null;
}

/// CSS keyframes wr-glitch-slice-1
/// 24% hidden → 25% 出现 → 26.5% 切位置 → 28% hidden
/// 74% hidden → 75% 出现 → 76% 切位置 → 77% hidden
final _glitch1Keyframes = [
  const _Keyframe(0.24, _kHidden),
  const _Keyframe(0.25, _GlitchState(0.20, 0.35, 0.35, -1.5)),
  const _Keyframe(0.265, _GlitchState(0.55, 0.70, 0.30, 2.0)),
  const _Keyframe(0.28, _kHidden),
  const _Keyframe(0.74, _kHidden),
  const _Keyframe(0.75, _GlitchState(0.65, 0.85, 0.30, 1.5)),
  const _Keyframe(0.76, _GlitchState(0.10, 0.22, 0.35, -2.0)),
  const _Keyframe(0.77, _kHidden),
];

/// CSS keyframes wr-glitch-slice-2
/// 24% hidden → 25.5% 出现 → 27% 切位置 → 28% hidden
/// 74% hidden → 75.5% 出现 → 76.5% 切位置 → 77% hidden
final _glitch2Keyframes = [
  const _Keyframe(0.24, _kHidden),
  const _Keyframe(0.255, _GlitchState(0.50, 0.65, 0.30, 1.5)),
  const _Keyframe(0.27, _GlitchState(0.75, 0.90, 0.25, -1.5)),
  const _Keyframe(0.28, _kHidden),
  const _Keyframe(0.74, _kHidden),
  const _Keyframe(0.755, _GlitchState(0.05, 0.18, 0.30, -1.5)),
  const _Keyframe(0.765, _GlitchState(0.40, 0.55, 0.25, 2.0)),
  const _Keyframe(0.77, _kHidden),
];

_GlitchState? _getGlitch1State(double t) =>
    _interpolateKeyframes(_glitch1Keyframes, t);

_GlitchState? _getGlitch2State(double t) =>
    _interpolateKeyframes(_glitch2Keyframes, t);

// ══════════════════════════════════════════════════════════════════════════════
// 水平带裁剪器（模拟 CSS clip-path: inset()）
// ══════════════════════════════════════════════════════════════════════════════

class _HorizontalBandClipper extends CustomClipper<Rect> {
  final double topFraction;
  final double bottomFraction;

  _HorizontalBandClipper(this.topFraction, this.bottomFraction);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(
      0,
      size.height * topFraction,
      size.width,
      size.height * bottomFraction,
    );
  }

  @override
  bool shouldReclip(_HorizontalBandClipper old) {
    return old.topFraction != topFraction || old.bottomFraction != bottomFraction;
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// 扫描线绘制器（CRT 效果）
// ══════════════════════════════════════════════════════════════════════════════

class _ScanlinesPainter extends CustomPainter {
  final double progress;

  _ScanlinesPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.03)
      ..style = PaintingStyle.fill;

    // 1px 线 + 2px 间距 = 3px 周期，6 秒滚动 30px
    const period = 3.0;
    final scrollOffset = progress * 30;

    double y = -period + (scrollOffset % period);
    while (y < size.height) {
      canvas.drawRect(Rect.fromLTRB(0, y, size.width, y + 1), paint);
      y += period;
    }
  }

  @override
  bool shouldRepaint(_ScanlinesPainter old) => old.progress != progress;
}

// ══════════════════════════════════════════════════════════════════════════════
// EKG 心电图绘制器（脉冲动画）
// ══════════════════════════════════════════════════════════════════════════════

class _EkgPainter extends CustomPainter {
  final double progress;

  _EkgPainter(this.progress);

  /// SVG path: M0 9h5l3-7 4 14 3-12 2 5h5l2-3 2 3h6 (viewBox 0 0 32 18)
  Path _createPath(Size size) {
    final sx = size.width / 32;
    final sy = size.height / 18;
    return Path()
      ..moveTo(0, 9 * sy)
      ..lineTo(5 * sx, 9 * sy)
      ..lineTo(8 * sx, 2 * sy)
      ..lineTo(12 * sx, 16 * sy)
      ..lineTo(15 * sx, 4 * sy)
      ..lineTo(17 * sx, 9 * sy)
      ..lineTo(22 * sx, 9 * sy)
      ..lineTo(24 * sx, 6 * sy)
      ..lineTo(26 * sx, 9 * sy)
      ..lineTo(32 * sx, 9 * sy);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final path = _createPath(size);
    final metrics = path.computeMetrics().first;
    final totalLength = metrics.length;

    // 背景静态线
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..color = Colors.black.withValues(alpha: 0.15)
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // 脉冲动画
    // CSS: dasharray=[20, 180], pathLength=100, offset 从 20→0→-100
    // 映射：dash 可见段起点 fraction 从 -0.2 → 1.0
    final t = Curves.easeIn.transform(progress);
    const dashFraction = 0.2;
    final dashStart = -dashFraction + t * (1.0 + dashFraction);
    final clampedStart = (dashStart * totalLength).clamp(0.0, totalLength);
    final clampedEnd =
        ((dashStart + dashFraction) * totalLength).clamp(0.0, totalLength);

    if (clampedEnd > clampedStart + 0.1) {
      final subPath = metrics.extractPath(clampedStart, clampedEnd);

      // 多层叠加：从宽（辉光）到窄（实线），从浅到深
      const layers = [
        (8.0, 0.04),
        (4.0, 0.1),
        (2.0, 0.35),
        (0.8, 0.7),
      ];
      for (final (width, alpha) in layers) {
        canvas.drawPath(
          subPath,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = width
            ..color = Colors.black.withValues(alpha: alpha)
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_EkgPainter old) => old.progress != progress;
}
