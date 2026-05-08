import 'package:flutter/material.dart';

/// 数字递增/递减动画 Widget
///
/// 当 [value] 变化时，会从旧值平滑过渡到新值。
/// 支持首次出场从 0 开始计数。
class AnimatedCounter extends StatefulWidget {
  final int value;
  final TextStyle? style;

  /// 动画时长
  final Duration duration;

  /// 首次出场延迟
  final Duration delay;

  /// 动画曲线
  final Curve curve;

  /// 可选的 Text 包装器，用于在 Text 外层添加效果（如 CrtGlitchEffect）
  final Widget Function(Widget text)? textWrapper;

  const AnimatedCounter({
    super.key,
    required this.value,
    this.style,
    this.duration = const Duration(milliseconds: 1800),
    this.delay = const Duration(milliseconds: 300),
    this.curve = const Cubic(0.16, 1, 0.3, 1),
    this.textWrapper,
  });

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  int _oldValue = 0;
  bool _firstBuild = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );
    _startAnimation();
  }

  @override
  void didUpdateWidget(covariant AnimatedCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _oldValue = oldWidget.value;
      _firstBuild = false;
      _controller.reset();
      _startAnimation();
    }
  }

  void _startAnimation() {
    if (_firstBuild && widget.delay > Duration.zero) {
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final current =
            (_oldValue + (_animation.value * (widget.value - _oldValue)))
                .round();
        final text = Text('$current', style: widget.style);
        return widget.textWrapper?.call(text) ?? text;
      },
    );
  }
}
