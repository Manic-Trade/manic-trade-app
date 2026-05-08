import 'package:finality/common/constants/currencies.dart';
import 'package:finality/common/utils/color_scheme_extensions.dart';
import 'package:finality/common/utils/decimal_format.dart';
import 'package:finality/core/notifier/multi_value_listenable_builder.dart';
import 'package:finality/theme/app_color_theme.dart';
import 'package:finality/theme/attrs/text_color_theme.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// 活跃仓位汇总栏：Invested / Est.Payout
class ActivePositionsSummaryBar extends StatelessWidget {
  final ValueListenable<double> investedNotifier;
  final ValueListenable<double> estPayoutNotifier;

  const ActivePositionsSummaryBar({
    super.key,
    required this.investedNotifier,
    required this.estPayoutNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder2(
      first: investedNotifier,
      second: estPayoutNotifier,
      builder: (context, invested, estPayout, _) {
        final isPositive = estPayout > 0;
        final estPayoutColor =
            isPositive ? context.appColors.bullish : context.appColors.bearish;
        final estPayoutDisplay =
            estPayout.abs().formatWithDecimals(2).withUsdSymbol();

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: context.colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: context.colorScheme.outlineVariant,
              width: 0.5,
            ),
          ),
          child: Row(
            children: [
              // Invested
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Invested',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: context.textColorTheme.textColorQuaternary,
                      ),
                    ),
                    Dimens.vGap2,
                    Text(
                      invested.formatWithDecimals(2).withUsdSymbol(),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: context.textColorTheme.textColorSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Est.Payout
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Est.Payout',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: context.textColorTheme.textColorQuaternary,
                    ),
                  ),
                  Dimens.vGap2,
                  Text(
                    '${isPositive ? '+' : ''}$estPayoutDisplay',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: estPayoutColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
