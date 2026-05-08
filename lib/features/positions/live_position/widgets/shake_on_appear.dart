
import 'dart:math' as math;

import 'package:flutter/material.dart';

/// 在首次出现时播放摆动动画的包装组件
class ShakeOnAppear extends StatefulWidget {
  const ShakeOnAppear({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<ShakeOnAppear> createState() => _ShakeOnAppearState();
}

class _ShakeOnAppearState extends State<ShakeOnAppear>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    // 延迟一帧后开始摆动，等 AnimatedSwitcher 的淡入完成
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _controller.forward();
      }
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
      builder: (context, child) {
        // 摆动 2 次，幅度从 4 像素衰减到 0
        final progress = _controller.value;
        final shake = math.sin(progress * math.pi * 3) * (1 - progress) * 3;

        return Transform.translate(
          offset: Offset(shake, 0),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}