import 'package:finality/theme/app_color_theme.dart';
import 'package:flutter/material.dart';

class DragHandle extends StatelessWidget {
  final Color? color;
  const DragHandle({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 12),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: color ?? context.appColors.dragHandleColor,
        borderRadius: const BorderRadius.all(Radius.circular(2)),
      ),
    );
  }
}
