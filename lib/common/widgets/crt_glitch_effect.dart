import 'dart:math' as math;

import 'package:flutter/material.dart';

/// CRT 风格色差分离闪烁效果
///
/// 在子 Widget 上叠加多层色差偏移的幽灵副本，
/// 模拟 CRT 显示器的 RGB 通道错位故障。
/// 参考 web 端 glitch-number / g-layer-1-subtle / g-layer-2-subtle。
///
/// 每个幽灵层包含 3 种颜色（主色 + 2 个 text-shadow），共 6 种颜色
/// 产生彩虹般的闪烁效果。关键帧之间线性插值实现平滑过渡。
///
/// ```dart
/// CrtGlitchEffect(
///   child: Text('65', style: myStyle),
/// )
/// ```
class CrtGlitchEffect extends StatefulWidget {
  final Widget child;

  const CrtGlitchEffect({
    super.key,
    required this.child,
  });

  @override
  State<CrtGlitchEffect> createState() => _CrtGlitchEffectState();
}

class _CrtGlitchEffectState extends State<CrtGlitchEffect>
    with TickerProviderStateMixin {
  // 2.5s alternate-reverse: 色差分离动画（同 CSS）
  late final AnimationController _glitchController;
  // 5s repeat: g-skew 微抖动（同 CSS）
  late final AnimationController _skewController;

  @override
  void initState() {
    super.initState();
    _glitchController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);
    _skewController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
  }

  @override
  void dispose() {
    _glitchController.dispose();
    _skewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 幽灵层使用去掉 shadows 的干净副本，避免大面积模糊辉光被染色产生方块感
    // CSS ::before/::after 是纯文本副本，不继承原始元素的 text-shadow
    final ghost = _stripShadows(widget.child);
    return AnimatedBuilder(
      animation: Listenable.merge([_glitchController, _skewController]),
      child: widget.child,
      builder: (context, child) {
        final t = _glitchController.value;
        final skewT = _skewController.value;

        final layer1 = _interpolateKeyframes(_kLayer1Keyframes, t);
        final layer2 = _interpolateKeyframes(_kLayer2Keyframes, t);
        final skewRad = _interpolateSkew(skewT);

        final showLayer1 = layer1.opacity > 0.01;
        final showLayer2 = layer2.opacity > 0.01;

        Widget result;
        if (!showLayer1 && !showLayer2) {
          result = child!;
        } else {
          result = Stack(
            clipBehavior: Clip.none,
            children: [
              // Layer 2 幽灵 (CSS ::after, z-index: -2)
              if (showLayer2)
                _buildGhostLayerGroup(
                  ghost,
                  layer2,
                  _kLayer2Main,
                  _kLayer2Shadow1,
                  _kLayer2Shadow2,
                ),
              // Layer 1 幽灵 (CSS ::before, z-index: -1)
              if (showLayer1)
                _buildGhostLayerGroup(
                  ghost,
                  layer1,
                  _kLayer1Main,
                  _kLayer1Shadow1,
                  _kLayer1Shadow2,
                ),
              // 主内容（顶层，保留原始 shadows）
              child!,
            ],
          );
        }

        // g-skew 微抖动
        if (skewRad.abs() > 0.0001) {
          return Transform(
            transform: Matrix4.skewX(skewRad),
            child: result,
          );
        }
        return result;
      },
    );
  }

  /// 去掉 Text 的 shadows，返回干净副本用于幽灵层渲染
  static Widget _stripShadows(Widget child) {
    if (child is Text && child.style != null) {
      return Text(
        child.data ?? '',
        style: child.style!.copyWith(shadows: const []),
        textAlign: child.textAlign,
        textDirection: child.textDirection,
        maxLines: child.maxLines,
        overflow: child.overflow,
      );
    }
    return child;
  }

  /// 构建一个幽灵层组（主色 + 2 个 text-shadow 子层）
  /// 模拟 CSS: color + text-shadow: 2px 0 shadow1, -2px 0 shadow2
  Widget _buildGhostLayerGroup(
    Widget child,
    _GlitchState state,
    Color mainColor,
    Color shadow1Color,
    Color shadow2Color,
  ) {
    return Opacity(
      opacity: state.opacity,
      child: Transform.translate(
        offset: Offset(state.dx, state.dy),
        child: ClipRect(
          clipper: _HorizontalBandClipper(state.topFrac, state.bottomFrac),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // text-shadow 2: -2px 水平偏移
              Transform.translate(
                offset: const Offset(-2, 0),
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(shadow2Color, BlendMode.srcIn),
                  child: child,
                ),
              ),
              // text-shadow 1: +2px 水平偏移
              Transform.translate(
                offset: const Offset(2, 0),
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(shadow1Color, BlendMode.srcIn),
                  child: child,
                ),
              ),
              // 主色
              ColorFiltered(
                colorFilter: ColorFilter.mode(mainColor, BlendMode.srcIn),
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// 颜色常量（参考 web 端 globals.css .glitch-number）
// ══════════════════════════════════════════════════════════════════════════════

// Layer 1 (CSS ::before): color #FF412C, text-shadow: 2px 0 #4E9EFF, -2px 0 #00D385
const _kLayer1Main = Color(0xFFFF412C); // 红
const _kLayer1Shadow1 = Color(0xFF4E9EFF); // 蓝 (+2px)
const _kLayer1Shadow2 = Color(0xFF00D385); // 绿 (-2px)

// Layer 2 (CSS ::after): color #4E9EFF, text-shadow: 2px 0 #FF412C, -2px 0 #FF0
const _kLayer2Main = Color(0xFF4E9EFF); // 蓝
const _kLayer2Shadow1 = Color(0xFFFF412C); // 红 (+2px)
const _kLayer2Shadow2 = Color(0xFFFFFF00); // 黄 (-2px)

// ══════════════════════════════════════════════════════════════════════════════
// Glitch 状态 + 关键帧插值
// ══════════════════════════════════════════════════════════════════════════════

class _GlitchState {
  final double topFrac;
  final double bottomFrac;
  final double dx;
  final double dy;
  final double opacity;

  const _GlitchState(
      this.topFrac, this.bottomFrac, this.dx, this.dy, this.opacity);

  static _GlitchState lerp(_GlitchState a, _GlitchState b, double t) {
    return _GlitchState(
      a.topFrac + (b.topFrac - a.topFrac) * t,
      a.bottomFrac + (b.bottomFrac - a.bottomFrac) * t,
      a.dx + (b.dx - a.dx) * t,
      a.dy + (b.dy - a.dy) * t,
      a.opacity + (b.opacity - a.opacity) * t,
    );
  }
}

/// 关键帧：(时间 0~1, 状态)
typedef _KF = (double, _GlitchState);

/// 线性插值查找（匹配 CSS 动画引擎的逐帧插值行为）
_GlitchState _interpolateKeyframes(List<_KF> keyframes, double t) {
  if (t <= keyframes.first.$1) return keyframes.first.$2;
  if (t >= keyframes.last.$1) return keyframes.last.$2;
  for (int i = 0; i < keyframes.length - 1; i++) {
    if (t <= keyframes[i + 1].$1) {
      final seg =
          (t - keyframes[i].$1) / (keyframes[i + 1].$1 - keyframes[i].$1);
      return _GlitchState.lerp(keyframes[i].$2, keyframes[i + 1].$2, seg);
    }
  }
  return keyframes.last.$2;
}

/// 不可见状态 (opacity=0, 全区域可见但透明)
const _off = _GlitchState(0, 1, 0, 0, 0);

/// Layer 1 关键帧 — 对应 CSS @keyframes g-layer-1-subtle
/// 向左偏移，红色为主
const _kLayer1Keyframes = <_KF>[
  (0.00, _off),
  (0.05, _GlitchState(0.15, 0.45, -4.5, 2, 0.6)),
  (0.10, _off),
  (0.15, _GlitchState(0.45, 0.75, -5.5, 1.5, 0.55)),
  (0.20, _off),
  (0.32, _off),
  (0.35, _GlitchState(0.65, 0.90, -3.5, 3, 0.6)),
  (0.40, _GlitchState(0.25, 0.55, -5, 1.5, 0.5)),
  (0.45, _off),
  (0.57, _off),
  (0.60, _GlitchState(0.05, 0.25, -4.5, 2, 0.55)),
  (0.65, _off),
  (0.77, _off),
  (0.80, _GlitchState(0.75, 0.95, -5.5, 1.5, 0.6)),
  (0.85, _GlitchState(0.35, 0.65, -3.5, 3, 0.45)),
  (0.90, _off),
  (1.00, _off),
];

/// Layer 2 关键帧 — 对应 CSS @keyframes g-layer-2-subtle
/// 向右偏移，蓝色为主
const _kLayer2Keyframes = <_KF>[
  (0.00, _off),
  (0.07, _GlitchState(0.55, 0.85, 4.5, -2, 0.5)),
  (0.12, _off),
  (0.18, _GlitchState(0.10, 0.35, 5.5, -1.5, 0.45)),
  (0.22, _off),
  (0.35, _off),
  (0.38, _GlitchState(0.30, 0.60, 3.5, -3, 0.55)),
  (0.42, _GlitchState(0.70, 0.90, 5, -1.5, 0.4)),
  (0.47, _off),
  (0.59, _off),
  (0.62, _GlitchState(0.80, 0.95, 4.5, -2, 0.5)),
  (0.67, _off),
  (0.79, _off),
  (0.82, _GlitchState(0.20, 0.50, 5.5, -1.5, 0.45)),
  (0.87, _GlitchState(0.50, 0.75, 3.5, -3, 0.55)),
  (0.92, _off),
  (1.00, _off),
];

// ══════════════════════════════════════════════════════════════════════════════
// Skew 微抖动 — 对应 CSS @keyframes g-skew (5s infinite)
// ══════════════════════════════════════════════════════════════════════════════

const _kSkewKeyframes = <(double, double)>[
  (0.00, 0),
  (0.03, 0.6),
  (0.05, -0.5),
  (0.07, 0),
  (0.93, 0),
  (0.95, 0.4),
  (0.97, -0.3),
  (0.99, 0),
  (1.00, 0),
];

/// 插值 skew 角度，返回弧度值
double _interpolateSkew(double t) {
  for (int i = 0; i < _kSkewKeyframes.length - 1; i++) {
    final (t0, v0) = _kSkewKeyframes[i];
    final (t1, v1) = _kSkewKeyframes[i + 1];
    if (t <= t1) {
      final seg = (t1 > t0) ? (t - t0) / (t1 - t0) : 0.0;
      final deg = v0 + (v1 - v0) * seg;
      return deg * math.pi / 180;
    }
  }
  return 0;
}

// ══════════════════════════════════════════════════════════════════════════════
// 水平带裁剪器（模拟 CSS clip-path: inset()）
// ══════════════════════════════════════════════════════════════════════════════

class _HorizontalBandClipper extends CustomClipper<Rect> {
  final double topFrac;
  final double bottomFrac;

  _HorizontalBandClipper(this.topFrac, this.bottomFrac);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(
      0,
      size.height * topFrac,
      size.width,
      size.height * bottomFrac,
    );
  }

  @override
  bool shouldReclip(_HorizontalBandClipper old) {
    return old.topFrac != topFrac || old.bottomFrac != bottomFrac;
  }
}
