import 'package:finality/common/utils/color_scheme_extensions.dart';
import 'package:flutter/material.dart';

/// Widget that shows the connection status with the given [text].
class ChartStatusLabel extends StatelessWidget {
  /// Creates a widget that shows the connection status with the given [text].
  const ChartStatusLabel({super.key, this.text = ''});

  /// The text to display for the current connection status.
  final String text;

  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            // ignore: deprecated_member_use
            color: context.colorScheme.surface.withOpacity(0.26),
          ),
          child: Text(text,
              style: TextStyle(color: context.colorScheme.onSurface)),
        ),
      );
}
