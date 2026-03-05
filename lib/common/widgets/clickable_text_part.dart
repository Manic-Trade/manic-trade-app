import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class ClickableTextPart {
  final String text;
  final VoidCallback onTap;

  const ClickableTextPart({
    required this.text,
    required this.onTap,
  });
}

class ClickableTextWidget extends StatelessWidget {
  final String fullText;
  final List<ClickableTextPart> clickableParts;
  final TextStyle? baseStyle;
  final TextStyle? linkStyle;
  final TextAlign textAlign;
  final TextDirection? textDirection;
  final bool softWrap;
  final TextOverflow overflow;
  final int? maxLines;

  const ClickableTextWidget({
    super.key,
    required this.fullText,
    required this.clickableParts,
    this.baseStyle,
    this.linkStyle,
    this.textAlign = TextAlign.start,
    this.textDirection,
    this.softWrap = true,
    this.overflow = TextOverflow.clip,
    this.maxLines,
  });

  List<TextSpan> _buildTextSpans() {
    final List<TextSpan> spans = [];
    var remainingText = fullText;

    for (final part in clickableParts) {
      final index = remainingText.indexOf(part.text);
      if (index == -1) {
        throw ArgumentError('Clickable text "${part.text}" not found in full text');
      }

      if (index > 0) {
        spans.add(TextSpan(
          text: remainingText.substring(0, index),
          style: baseStyle,
        ));
      }

      spans.add(TextSpan(
        text: part.text,
        style: linkStyle,
        recognizer: TapGestureRecognizer()..onTap = part.onTap,
      ));

      remainingText = remainingText.substring(index + part.text.length);
    }

    if (remainingText.isNotEmpty) {
      spans.add(TextSpan(
        text: remainingText,
        style: baseStyle,
      ));
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: textAlign,
      textDirection: textDirection,
      softWrap: softWrap,
      overflow: overflow,
      maxLines: maxLines,
      text: TextSpan(
        children: _buildTextSpans(),
      ),
    );
  }
}