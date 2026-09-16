import 'package:flutter/material.dart';

/// 根据当前价格与开仓价格的大小关系显示不同颜色的价格文本
///
/// - current > entry → [increaseColor]（绿色）
/// - current < entry → [decreaseColor]（红色）
/// - current == entry → [unchangedColor]（与 Entry Price 相同的默认色）
class EntryComparedPriceText extends StatelessWidget {
  final double? price;
  final double entryPrice;
  final String Function(double) formatPrice;
  final Color increaseColor;
  final Color decreaseColor;
  final Color unchangedColor;
  final TextStyle? textStyle;

  const EntryComparedPriceText({
    super.key,
    required this.price,
    required this.entryPrice,
    required this.formatPrice,
    required this.increaseColor,
    required this.decreaseColor,
    required this.unchangedColor,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final currentPrice = price;
    if (currentPrice == null) {
      return Text(
        '--',
        style: (textStyle ?? const TextStyle()).copyWith(
          color: unchangedColor,
        ),
      );
    }

    final Color color;
    if (currentPrice > entryPrice) {
      color = increaseColor;
    } else if (currentPrice < entryPrice) {
      color = decreaseColor;
    } else {
      color = unchangedColor;
    }

    return Text(
      formatPrice(currentPrice),
      style: (textStyle ?? const TextStyle()).copyWith(color: color),
    );
  }
}
