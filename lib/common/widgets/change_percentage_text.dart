import 'package:decimal/decimal.dart';
import 'package:finality/theme/attrs/text_color_theme.dart';
import 'package:flutter/material.dart';
import 'package:finality/common/utils/decimal_formats.dart';

class ChangePercentageText extends StatelessWidget {
  final double? _doubleValue;
  final Decimal? _decimalValue;
  final TextStyle? style;
  final Color plusColor;
  final Color minusColor;
  final bool textVisible;
  final String invisibleText;

  // double 构造函数
  const ChangePercentageText.fromDouble(this._doubleValue,
      {super.key,
      this.style,
      this.plusColor = Colors.green,
      this.minusColor = Colors.red,
      this.textVisible = true,
      this.invisibleText = "******"})
      : _decimalValue = null;

  // Decimal 构造函数
  const ChangePercentageText.fromDecimal(this._decimalValue,
      {super.key,
      this.style,
      this.plusColor = Colors.green,
      this.minusColor = Colors.red,
      this.textVisible = true,
      this.invisibleText = "******"})
      : _doubleValue = null;

  bool? _compareToZeroDouble(double value) {
    if (value > 0) return true;
    if (value < 0) return false;
    return null;
  }

  bool? _compareToZeroDecimal(Decimal value) {
    if (value > Decimal.zero) return true;
    if (value < Decimal.zero) return false;
    return null;
  }

  String _formatDouble(double value) {
    return value.formatAsChange();
  }

  String _formatDecimal(Decimal value) {
    return value.toDouble().formatAsChange();
  }

  @override
  Widget build(BuildContext context) {
    if (!textVisible) {
      return Text(
        invisibleText,
        style: (style ??
            TextStyle(
                fontSize: 14,
                color: context.textColorTheme.textColorSecondary)),
      );
    }
    if (_doubleValue == null && _decimalValue == null) {
      return const Text("--");
    }
    final comparison = _doubleValue != null
        ? _compareToZeroDouble(_doubleValue)
        : _compareToZeroDecimal(_decimalValue!);

    final formattedText = _doubleValue != null
        ? _formatDouble(_doubleValue)
        : _formatDecimal(_decimalValue!);

    final textColor = comparison == true
        ? plusColor
        : comparison == false
            ? minusColor
            : context.textColorTheme.textColorSecondary;

    var textStyle = style ?? const TextStyle(fontSize: 14);

    return Text(
      formattedText,
      style: comparison == null ? textStyle : textStyle.apply(color: textColor),
    );
  }
}
