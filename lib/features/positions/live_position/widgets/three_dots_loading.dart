import 'package:flutter/material.dart';

/// 三点跳动 Loading 动画
/// 三个点依次放大缩小，形成波浪效果
/// 动画参考自前端 CSS:
/// ```css
/// @keyframes scaleBounce {
///   0%, 80%, 100% { transform: scale(0.5); opacity: 0.6; }
///   40% { transform: scale(1.2); opacity: 1; }
/// }
/// ```
class ThreeDotsLoading extends StatefulWidget {
  const ThreeDotsLoading({
    super.key,
    required this.color,
    this.size = 4,
    this.borderRadius = 1,
    this.spacing = 2,
    this.duration = const Duration(milliseconds: 1200),
  });

  /// 点的颜色
  final Color color;

  /// 点的大小（宽高）
  final double size;

  /// 圆角半径
  final double borderRadius;

  /// 点之间的间距
  final double spacing;

  /// 动画周期（默认 1200ms，和前端一致）
  final Duration duration;

  @override
  State<ThreeDotsLoading> createState() => _ThreeDotsLoadingState();
}

class _ThreeDotsLoadingState extends State<ThreeDotsLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        // 延迟比例：第1个点 -0.4s, 第2个点 -0.2s, 第3个点 0s
        // 转换为比例：0.333, 0.167, 0（相对于 1.2s 周期）
        // 用正向延迟实现：第1个点先开始，所以延迟最小
        final delay = (2 - index) * (0.2 / 1.2); // 0.333, 0.167, 0

        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            // 计算当前点的动画进度（加上延迟偏移）
            final progress = (_controller.value + delay) % 1.0;

            // 根据前端 CSS keyframes 计算 scale 和 opacity
            // 0% -> scale: 0.5, opacity: 0.6
            // 40% -> scale: 1.2, opacity: 1.0
            // 80%-100% -> scale: 0.5, opacity: 0.6
            double scale;
            double opacity;

            if (progress < 0.4) {
              // 0% -> 40%: 放大
              final t = progress / 0.4;
              scale = 0.5 + 0.7 * t; // 0.5 -> 1.2
              opacity = 0.6 + 0.4 * t; // 0.6 -> 1.0
            } else if (progress < 0.8) {
              // 40% -> 80%: 缩小
              final t = (progress - 0.4) / 0.4;
              scale = 1.2 - 0.7 * t; // 1.2 -> 0.5
              opacity = 1.0 - 0.4 * t; // 1.0 -> 0.6
            } else {
              // 80% -> 100%: 保持最小
              scale = 0.5;
              opacity = 0.6;
            }

            return Container(
              margin: EdgeInsets.only(right: index < 2 ? widget.spacing : 0),
              width: widget.size,
              height: widget.size,
              child: Transform.scale(
                scale: scale,
                child: Opacity(
                  opacity: opacity,
                  child: Container(
                    decoration: BoxDecoration(
                      color: widget.color,
                      borderRadius: BorderRadius.circular(widget.borderRadius),
                      boxShadow: [
                        BoxShadow(
                          color: widget.color.withValues(alpha: 0.8),
                          blurRadius: 3,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
