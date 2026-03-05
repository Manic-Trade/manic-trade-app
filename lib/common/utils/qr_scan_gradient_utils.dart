import 'package:flutter/material.dart';

/// QR码扫描渐变效果工具类
/// 提供从左下角开始的扫描动画渐变效果
class QrScanGradientUtils {
  QrScanGradientUtils._();

  // 原始彩色数组
  static const _originalColors = [
    Colors.cyan,
    Color(0xff008000),
    Color(0xff0000ff),
    Color(0xff4b0082),
    Color(0xffee82ee),
  ];

  // 动画参数常量
  static const _scanPhaseEnd = 0.8; // 80%时扫描完成
  static const _fadeOutPhaseStart = 0.8; // 从80%开始淡出白色区域
  static const _scanLineWidth = 0.4; // 扫描线覆盖40%的范围
  static const _glowDistance = 0.1; // 发光效果距离
  static const _glowColor = Color(0xFFF0F8FF); // 淡蓝白色

  /// 构建扫描渐变效果
  ///
  /// [progress] 动画进度，范围 0.0 到 1.0
  /// 返回 LinearGradient 或 null（当动画完成时）
  static LinearGradient? buildSweepGradient(double progress) {
    if (progress >= 1.0) return null;

    final totalColors = _originalColors.length;
    final isInScanPhase = progress <= _scanPhaseEnd;

    return LinearGradient(
      begin: Alignment.bottomLeft,
      end: Alignment.topRight,
      colors: isInScanPhase
          ? _buildScanPhaseColors(progress, totalColors)
          : _buildFadePhaseColors(progress, totalColors),
    );
  }

  /// 构建扫描阶段的颜色列表
  static List<Color> _buildScanPhaseColors(double progress, int totalColors) {
    final scanProgress = progress / _scanPhaseEnd;
    final scanLineHalfWidth = _scanLineWidth / 2;

    return List.generate(totalColors, (i) {
      final colorPosition = i / (totalColors - 1);
      final distanceFromScanCenter = (colorPosition - scanProgress).abs();

      if (scanProgress < colorPosition - scanLineHalfWidth) {
        // 扫描线还没到达这个颜色，保持原色
        return _originalColors[i];
      } else if (scanProgress > colorPosition + scanLineHalfWidth) {
        // 扫描线已经完全通过这个颜色，变为黑色
        return Colors.black;
      } else {
        // 在扫描线范围内，进行平滑过渡
        return _calculateScanLineColor(
          _originalColors[i],
          distanceFromScanCenter,
          scanLineHalfWidth,
        );
      }
    });
  }

  /// 计算扫描线范围内的颜色
  static Color _calculateScanLineColor(
    Color originalColor,
    double distanceFromCenter,
    double scanLineHalfWidth,
  ) {
    final localProgress = 1.0 - (distanceFromCenter / scanLineHalfWidth);

    Color currentColor;
    if (localProgress < 0.5) {
      // 前半段：原色 -> 白色
      final whiteProgress = localProgress * 2;
      currentColor = Color.lerp(originalColor, Colors.white, whiteProgress)!;
    } else {
      // 后半段：白色 -> 黑色
      final blackProgress = (localProgress - 0.5) * 2;
      currentColor = Color.lerp(Colors.white, Colors.black, blackProgress)!;
    }

    // 在扫描线中心附近添加发光效果
    if (distanceFromCenter < _glowDistance) {
      currentColor = Color.lerp(Colors.white, _glowColor, 0.5)!;
    }

    return currentColor;
  }

  /// 构建淡出阶段的颜色列表
  static List<Color> _buildFadePhaseColors(double progress, int totalColors) {
    final fadeProgress =
        (progress - _fadeOutPhaseStart) / (1.0 - _fadeOutPhaseStart);
    final scanLineHalfWidth = _scanLineWidth / 2;

    return List.generate(totalColors, (i) {
      final colorPosition = i / (totalColors - 1);
      final distanceFromScanCenter = (colorPosition - 1.0).abs();

      if (distanceFromScanCenter > scanLineHalfWidth) {
        // 已经完全变黑的区域
        return Colors.black;
      }

      final localProgress = 1.0 - (distanceFromScanCenter / scanLineHalfWidth);
      if (localProgress <= 0.5) {
        return Colors.black;
      }

      // 计算白色强度并应用淡出效果
      final whiteIntensity = (localProgress - 0.5) * 2;
      final baseColor = Color.lerp(Colors.black, Colors.white, whiteIntensity)!;
      return Color.lerp(baseColor, Colors.black, fadeProgress)!;
    });
  }

  /// 创建自定义颜色的扫描渐变效果
  ///
  /// [progress] 动画进度，范围 0.0 到 1.0
  /// [colors] 自定义颜色数组
  /// [scanPhaseEnd] 扫描阶段结束时间点（默认0.8）
  /// [scanLineWidth] 扫描线宽度（默认0.4）
  static LinearGradient? buildCustomSweepGradient(
    double progress, {
    List<Color>? colors,
    double scanPhaseEnd = 0.8,
    double scanLineWidth = 0.4,
  }) {
    if (progress >= 1.0) return null;

    final targetColors = colors ?? _originalColors;
    final totalColors = targetColors.length;
    final isInScanPhase = progress <= scanPhaseEnd;

    return LinearGradient(
      begin: Alignment.bottomLeft,
      end: Alignment.topRight,
      colors: isInScanPhase
          ? _buildCustomScanPhaseColors(
              progress, targetColors, scanPhaseEnd, scanLineWidth)
          : _buildCustomFadePhaseColors(
              progress, totalColors, scanPhaseEnd, scanLineWidth),
    );
  }

  static List<Color> _buildCustomScanPhaseColors(
    double progress,
    List<Color> colors,
    double scanPhaseEnd,
    double scanLineWidth,
  ) {
    final scanProgress = progress / scanPhaseEnd;
    final scanLineHalfWidth = scanLineWidth / 2;
    final totalColors = colors.length;

    return List.generate(totalColors, (i) {
      final colorPosition = i / (totalColors - 1);
      final distanceFromScanCenter = (colorPosition - scanProgress).abs();

      if (scanProgress < colorPosition - scanLineHalfWidth) {
        return colors[i];
      } else if (scanProgress > colorPosition + scanLineHalfWidth) {
        return Colors.black;
      } else {
        return _calculateScanLineColor(
            colors[i], distanceFromScanCenter, scanLineHalfWidth);
      }
    });
  }

  static List<Color> _buildCustomFadePhaseColors(
    double progress,
    int totalColors,
    double scanPhaseEnd,
    double scanLineWidth,
  ) {
    final fadeProgress = (progress - scanPhaseEnd) / (1.0 - scanPhaseEnd);
    final scanLineHalfWidth = scanLineWidth / 2;

    return List.generate(totalColors, (i) {
      final colorPosition = i / (totalColors - 1);
      final distanceFromScanCenter = (colorPosition - 1.0).abs();

      if (distanceFromScanCenter > scanLineHalfWidth) {
        return Colors.black;
      }

      final localProgress = 1.0 - (distanceFromScanCenter / scanLineHalfWidth);
      if (localProgress <= 0.5) {
        return Colors.black;
      }

      final whiteIntensity = (localProgress - 0.5) * 2;
      final baseColor = Color.lerp(Colors.black, Colors.white, whiteIntensity)!;
      return Color.lerp(baseColor, Colors.black, fadeProgress)!;
    });
  }
}
