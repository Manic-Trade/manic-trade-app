import 'package:finality/theme/attrs/text_color_theme.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

class OptionsTradingPairsTableHeader extends StatelessWidget {
  final bool isLoading;

  const OptionsTradingPairsTableHeader({
    super.key,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    var textStyle = TextStyle(
        color: context.textColorTheme.textColorHelper,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1,
        letterSpacing: 0);
    return Skeletonizer(
      enabled: isLoading,
      child: SizedBox(
        height: 32,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Divider(),
            Expanded(
              child: Padding(
                padding: Dimens.edgeInsetsH16,
                child: Row(
                  children: [
                    Expanded(
                      flex: 144,
                      child: Text(
                        'Asset Name',
                        style: textStyle,
                      ),
                    ),
                    Expanded(
                      flex: 72,
                      child: Text(
                        'Payout',
                        style: textStyle,
                        textAlign: TextAlign.end,
                      ),
                    ),
                    Expanded(
                      flex: 100,
                      child: Text(
                        'Multiplier',
                        style: textStyle,
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Divider(),
          ],
        ),
      ),
    );
  }
}
