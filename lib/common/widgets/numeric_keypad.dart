import 'dart:async';
import 'dart:ui';

import 'package:finality/common/utils/haptic_feedback_utils.dart';
import 'package:finality/common/widgets/touchable.dart';
import 'package:flutter/material.dart';
import 'package:haptic_feedback/haptic_feedback.dart';

class NumericKeypad extends StatefulWidget {
  final void Function(String number) onNumberPressed;
  final bool Function() onDeletePressed;
  //为 1 时，字体大小为 maxFontSize
  //为 0 时，字体大小为 minFontSize
  //为 0.5 时，字体大小为 (maxFontSize + minFontSize) / 2
  final double fontScale;
  final bool enable;
  final double maxFontSize;
  final double minFontSize;
  final FontWeight fontWeight;
  final Color? textColor;

  const NumericKeypad(
      {super.key,
      required this.onNumberPressed,
      required this.onDeletePressed,
      this.fontScale = 1.0,
      this.enable = true,
      this.maxFontSize = 48,
      this.minFontSize = 34,
      this.textColor,
      this.fontWeight = FontWeight.w600});

  @override
  State<NumericKeypad> createState() => _NumericKeypadState();
}

class _NumericKeypadState extends State<NumericKeypad> {
  Timer? _deleteTimer;

  bool _hasMoreToDelete = true;

  Widget _buildNumberButton(String text) {
    var fontSize = lerpDouble(
          widget.minFontSize,
          widget.maxFontSize,
          widget.fontScale.clamp(0.0, 1.0), // 限制在 0~1 之间
        ) ??
        widget.maxFontSize;
    return Expanded(
      child: AspectRatio(
        aspectRatio: 1.861,
        child: Touchable.plain(
          shrinkScaleFactor: 0.8,
          quickResponse: true,
          enableFeedback: false,
          onTap: () {
            HapticFeedbackUtils.vibrate(HapticsType.soft);
            if (text == 'delete') {
              widget.onDeletePressed();
            } else {
              widget.onNumberPressed(text);
            }
          },
          onLongPress: text == 'delete'
              ? () {
                  _deleteTimer?.cancel();
                  _deleteTimer = Timer.periodic(
                    const Duration(milliseconds: 100),
                    (timer) {
                      if (_hasMoreToDelete) {
                        HapticFeedbackUtils.selectionClick();
                      }
                      _hasMoreToDelete = widget.onDeletePressed();
                    },
                  );
                }
              : null,
          onLongPressUp: text == 'delete'
              ? () {
                  _deleteTimer?.cancel();
                  _deleteTimer = null;
                  _hasMoreToDelete = true;
                }
              : null,
          child: Center(
            child: text == 'delete'
                ? Icon(Icons.backspace_rounded,
                    size: (fontSize * 0.8).clamp(16, 32), color: widget.textColor)
                : Text(
                    text,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: widget.fontWeight,
                      color: widget.textColor,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !widget.enable,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Row(
              children: [
                _buildNumberButton('1'),
                _buildNumberButton('2'),
                _buildNumberButton('3'),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                _buildNumberButton('4'),
                _buildNumberButton('5'),
                _buildNumberButton('6'),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                _buildNumberButton('7'),
                _buildNumberButton('8'),
                _buildNumberButton('9'),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                _buildNumberButton('.'),
                _buildNumberButton('0'),
                _buildNumberButton('delete'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _deleteTimer?.cancel();
    super.dispose();
  }
}
