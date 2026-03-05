import 'package:finality/theme/attrs/text_color_theme.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/material.dart';

class EmptyHistoryRecent extends StatelessWidget {
  const EmptyHistoryRecent({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 300),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Dimens.vGap16,
            Icon(
              Icons.history,
              size: 56,
              color: context.textColorTheme.textColorHelper,
            ),
            Dimens.vGap8,
            Text(
              "No recent history",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: context.textColorTheme.textColorHelper,
                fontSize: 15,
                letterSpacing: 0,
              ),
            ),
          
            Dimens.vGap20,
          ],
        ),
      ),
    );
  }
}
