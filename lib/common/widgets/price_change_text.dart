import 'dart:async';

import 'package:flutter/material.dart';

class PriceChangeText extends StatefulWidget {
  final double? price;
  final String Function(double) formatPrice;
  final Color increaseColor;
  final Color decreaseColor;
  final Color unchangedColor;
  final TextStyle? textStyle;

  const PriceChangeText({
    super.key,
    required this.price,
    required this.formatPrice,
    this.increaseColor = Colors.green,
    this.decreaseColor = Colors.red,
    required this.unchangedColor,
    this.textStyle,
  });

  @override
  State<PriceChangeText> createState() => _PriceChangeTextState();
}

class _PriceChangeTextState extends State<PriceChangeText> {
  double? _previousPrice;
  late Color _currentColor;
  Timer? _colorResetTimer;

  @override
  void initState() {
    super.initState();
    _previousPrice = widget.price;
    _currentColor = widget.unchangedColor;
  }

  @override
  void didUpdateWidget(PriceChangeText oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.price != widget.price ||
        oldWidget.unchangedColor != widget.unchangedColor) {
      _colorResetTimer?.cancel();

      if (_previousPrice == null) {
        _currentColor = widget.unchangedColor;
      } else if (widget.price != null && widget.price! > _previousPrice!) {
        _currentColor = widget.increaseColor;
      } else if (widget.price != null && widget.price! < _previousPrice!) {
        _currentColor = widget.decreaseColor;
      } else {
        _currentColor = widget.unchangedColor;
      }

      _previousPrice = widget.price;
      _colorResetTimer = Timer(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _currentColor = widget.unchangedColor;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var price = widget.price;
    return Text(
      price != null ? widget.formatPrice(price) : "--",
      style: (widget.textStyle ?? const TextStyle()).copyWith(
        color: _currentColor,
      ),
    );
  }

  @override
  void dispose() {
    _colorResetTimer?.cancel();
    super.dispose();
  }
}
