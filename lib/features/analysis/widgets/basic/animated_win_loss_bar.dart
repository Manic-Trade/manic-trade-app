import 'package:finality/theme/dimens.dart';
import 'package:flutter/material.dart';

/// 品牌橙色
const _kOrange = Color(0xFFFF9900);

/// Win/Loss 比例条形图，带宽度过渡动画和扫光效果
class AnimatedWinLossBar extends StatelessWidget {
  final double winBarRatio;
  final int wins;
  final int losses;

  /// 动画时长
  final Duration duration;

  /// 动画延迟
  final Duration delay;

  const AnimatedWinLossBar({
    super.key,
    required this.winBarRatio,
    required this.wins,
    required this.losses,
    this.duration = const Duration(milliseconds: 1100),
    this.delay = const Duration(milliseconds: 300),
  });

  /// Win 条最小占比 22%（与 web 端一致）
  static const _kMinWinPct = 0.22;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final availableWidth = (totalWidth - 4).clamp(0.0, totalWidth); // 减去中间 4px 间距
        final total = wins + losses;

        // Win 条百分比，最小 22%（与 web 端 Math.max(winPct, 22) 一致）
        final winPct = total > 0 ? wins / total : 0.5;
        final clampedPct = winPct.clamp(_kMinWinPct, 1.0);
        final winWidth = availableWidth * clampedPct;

        return Row(
          children: [
            _WinBar(
              targetWidth: winWidth,
              wins: wins,
              duration: duration,
              delay: delay,
            ),
            Dimens.hGap4,
            Expanded(
              child: _LossBar(losses: losses, delay: delay),
            ),
          ],
        );
      },
    );
  }
}

/// Win 条：宽度动画 + 呼吸光晕效果（与 web 端 g-bar-win-glow 一致）
class _WinBar extends StatefulWidget {
  final double targetWidth;
  final int wins;
  final Duration duration;
  final Duration delay;

  const _WinBar({
    required this.targetWidth,
    required this.wins,
    required this.duration,
    required this.delay,
  });

  @override
  State<_WinBar> createState() => _WinBarState();
}

class _WinBarState extends State<_WinBar> with TickerProviderStateMixin {
  late AnimationController _widthController;
  late AnimationController _glowController;
  late Animation<double> _widthAnimation;
  double _oldWidth = 0;
  bool _firstBuild = true;

  @override
  void initState() {
    super.initState();
    _widthController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _widthAnimation = CurvedAnimation(
      parent: _widthController,
      curve: const Cubic(0.16, 1, 0.3, 1),
    );

    // 呼吸光晕动画：3s 循环，与 web 端 g-bar-win-glow 一致
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _startWidthAnimation();
  }

  @override
  void didUpdateWidget(covariant _WinBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((oldWidget.targetWidth - widget.targetWidth).abs() > 1) {
      _oldWidth = oldWidget.targetWidth;
      _firstBuild = false;
      _widthController.reset();
      _startWidthAnimation();
    }
  }

  void _startWidthAnimation() {
    final delay = _firstBuild ? widget.delay : Duration.zero;
    Future.delayed(delay, () {
      if (!mounted) return;
      _widthController.forward();
    });

    // 呼吸光晕在宽度动画结束后开始循环
    final glowDelay = delay + widget.duration;
    Future.delayed(glowDelay, () {
      if (!mounted) return;
      _glowController.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _widthController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_widthAnimation, _glowController]),
      builder: (context, child) {
        final currentWidth = _oldWidth +
            _widthAnimation.value * (widget.targetWidth - _oldWidth);

        // 呼吸光晕：blurRadius 12→20，opacity 0.35→0.55
        final glowT = Curves.easeInOut.transform(_glowController.value);
        final blurRadius = 12.0 + 8.0 * glowT;
        final glowAlpha = 0.08 + 0.3 * glowT;

        return SizedBox(
          width: currentWidth.clamp(0, double.infinity),
          height: 28,
          // 外层 Container 只做光晕阴影，不裁剪
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF9900).withValues(alpha: glowAlpha),
                  blurRadius: blurRadius,
                ),
              ],
            ),
            // ClipRRect 裁剪内容（宽度动画展开时），不影响外层阴影
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: OverflowBox(
                minWidth: 0,
                maxWidth: widget.targetWidth,
                alignment: Alignment.centerLeft,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_kOrange, Color(0xFFFFB840)],
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: child,
                ),
              ),
            ),
          ),
        );
      },
      child: Row(
        children: [
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFF00D385),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00D385).withValues(alpha: 0.6),
                  blurRadius: 6,
                ),
              ],
            ),
          ),
          Dimens.hGap4,
          Text(
            '${widget.wins}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          Dimens.hGap4,
          const Text(
            'WINS',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: Color(0x73000000),
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

/// Loss 条：带淡入动画
class _LossBar extends StatefulWidget {
  final int losses;
  final Duration delay;

  const _LossBar({
    required this.losses,
    required this.delay,
  });

  @override
  State<_LossBar> createState() => _LossBarState();
}

class _LossBarState extends State<_LossBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    // 延迟启动（首次 0.6s，与 web 一致）
    Future.delayed(
      widget.delay + const Duration(milliseconds: 300),
      () {
        if (mounted) _controller.forward();
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: Container(
          height: 28,
          decoration: BoxDecoration(
            color: const Color(0xFF141414),
            borderRadius: BorderRadius.circular(999),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.centerRight,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            reverse: true,
            physics: const NeverScrollableScrollPhysics(),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF412C),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF412C).withValues(alpha: 0.5),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
                Dimens.hGap4,
                Text(
                  '${widget.losses}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withValues(alpha: 0.4),
                  ),
                ),
                Dimens.hGap4,
                Text(
                  'LOSSES',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.2),
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
