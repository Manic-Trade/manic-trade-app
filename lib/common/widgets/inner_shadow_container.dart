import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart';

/// 内阴影容器
///
/// 支持圆形或圆角矩形，带有向内扩散的阴影效果。
/// 基于 `flutter_inset_shadow` 实现。
class InnerShadowContainer extends StatelessWidget {
  /// 容器宽度
  final double? width;

  /// 容器高度
  final double? height;

  /// 形状：圆形或圆角矩形
  final BoxShape shape;

  /// 圆角矩形的圆角半径，仅在 [shape] 为 [InnerShadowShape.roundedRect] 时生效
  final BorderRadius? borderRadius;

  /// 容器背景颜色
  final Color backgroundColor;

  /// 内阴影颜色
  final Color shadowColor;

  /// 内阴影偏移
  final Offset shadowOffset;

  /// 内阴影模糊半径
  final double shadowBlurRadius;

  /// 内阴影扩散半径
  final double shadowSpreadRadius;

  /// 边框
  final Border? border;

  /// 内边距
  final EdgeInsetsGeometry? padding;

  /// 子组件
  final Widget? child;

  const InnerShadowContainer({
    super.key,
    this.width,
    this.height,
    this.shape = BoxShape.circle,
    this.borderRadius,
    required this.backgroundColor,
    required this.shadowColor,
    this.shadowOffset = Offset.zero,
    this.shadowBlurRadius = 8.0,
    this.shadowSpreadRadius = 0.0,
    this.border,
    this.padding,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        shape: shape,
        borderRadius: shape == BoxShape.rectangle
            ? (borderRadius ?? BorderRadius.circular(12))
            : null,
        color: backgroundColor,
        border: border,
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            offset: shadowOffset,
            blurRadius: shadowBlurRadius,
            spreadRadius: shadowSpreadRadius,
            inset: true,
          ),
        ],
      ),
      padding: padding,
      child: child != null ? Center(child: child) : null,
    );
  }
}
