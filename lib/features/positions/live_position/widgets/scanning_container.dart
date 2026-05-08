import 'package:flutter/material.dart';

/// 带扫描光线动画效果的容器
///
/// 光线会从左到右扫过容器，可以自定义扫描颜色、尺寸、动画时长等
class ScanningContainer extends StatefulWidget {
  const ScanningContainer({
    super.key,
    required this.child,
    required this.width,
    required this.height,
    this.scanColor,
    this.borderRadius,
    this.borderColor,
    this.borderWidth = 0.5,
    this.backgroundColor,
    this.scanDuration = const Duration(milliseconds: 800),
    this.pauseDuration = const Duration(milliseconds: 1000),
  });

  /// 容器内的内容
  final Widget child;

  /// 容器宽度
  final double width;

  /// 容器高度
  final double height;

  /// 扫描光线颜色，默认使用 Theme 的 primary 颜色
  final Color? scanColor;

  /// 圆角半径
  final BorderRadius? borderRadius;

  /// 边框颜色，默认使用 scanColor
  final Color? borderColor;

  /// 边框宽度
  final double borderWidth;

  /// 背景颜色
  final Color? backgroundColor;

  /// 扫描动画时长
  final Duration scanDuration;

  /// 扫描后停顿时长
  final Duration pauseDuration;

  @override
  State<ScanningContainer> createState() => _ScanningContainerState();
}

class _ScanningContainerState extends State<ScanningContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _scanController;

  int get _scanDurationMs => widget.scanDuration.inMilliseconds;
  int get _pauseDurationMs => widget.pauseDuration.inMilliseconds;
  int get _totalDurationMs => _scanDurationMs + _pauseDurationMs;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: _totalDurationMs),
    )..repeat();
  }

  @override
  void didUpdateWidget(covariant ScanningContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 如果动画时长变化，更新控制器
    if (oldWidget.scanDuration != widget.scanDuration ||
        oldWidget.pauseDuration != widget.pauseDuration) {
      _scanController.duration = Duration(milliseconds: _totalDurationMs);
    }
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scanColor = widget.scanColor ?? Theme.of(context).colorScheme.primary;
    final borderColor = widget.borderColor ?? scanColor;
    final borderRadius = widget.borderRadius ?? BorderRadius.circular(6);

    return ClipRRect(
      borderRadius: borderRadius,
      child: Container(
        height: widget.height,
        width: widget.width,
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          border: Border.all(color: borderColor, width: widget.borderWidth),
          color: widget.backgroundColor,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 扫描光线效果
            AnimatedBuilder(
              animation: _scanController,
              builder: (context, child) {
                final rawProgress = _scanController.value;
                final scanRatio = _scanDurationMs / _totalDurationMs;

                double scanProgress;
                if (rawProgress < scanRatio) {
                  // 扫描阶段：0 -> 1
                  scanProgress = rawProgress / scanRatio;
                } else {
                  // 停顿阶段：保持在 1（光线已经扫出去了）
                  scanProgress = 1.0;
                }

                // 从左边 -50% 移动到右边 150%
                final left = -0.5 + scanProgress * 2.0;

                return Positioned(
                  left: widget.width * left,
                  top: -10,
                  bottom: -10,
                  child: Transform(
                    transform: Matrix4.skewX(-0.35), // skewX(-20deg)
                    alignment: Alignment.center,
                    child: Container(
                      width: widget.width * 0.7,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            scanColor.withValues(alpha: 0.1),
                            scanColor.withValues(alpha: 0.2),
                            scanColor.withValues(alpha: 0.1),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            // 内容
            widget.child,
          ],
        ),
      ),
    );
  }
}
