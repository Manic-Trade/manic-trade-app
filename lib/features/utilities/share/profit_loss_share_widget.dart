import 'package:finality/common/constants/constants.dart';
import 'package:finality/common/utils/color_scheme_extensions.dart';
import 'package:finality/common/utils/date_time_extensions.dart';
import 'package:finality/common/utils/localization_extensions.dart';
import 'package:finality/common/widgets/logo_image.dart';
import 'package:finality/generated/assets.dart';
import 'package:finality/theme/attrs/text_color_theme.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/material.dart';

class ProfitLossShareWidget extends StatelessWidget {
  final String imageUrl;
  final String symbol;
  final String profitLossPctText;
  final bool isWin;
  final DateTime? since;

  const ProfitLossShareWidget(
      {super.key,
      required this.imageUrl,
      required this.symbol,
      required this.profitLossPctText,
      required this.isWin,
      this.since});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: context.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: context.colorScheme.outlineVariant,
              width: 1,
            ),
          ),
          padding: Dimens.edgeInsetsA24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Dimens.vGap16,
              LogoImage(
                iconURL: imageUrl,
                width: 48,
                height: 48,
                symbol: symbol,
              ),
              Dimens.vGap16,
              Text(
                symbol.toUpperCase(),
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  color: context.textColorTheme.textColorPrimary,
                ),
              ),
              Dimens.vGap10,
              Text(
                profitLossPctText,
                style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w700,
                    color: isWin ? Colors.green : Colors.red,
                    letterSpacing: 0.0),
              ),
              Dimens.vGap10,
              if (since != null)
                Text(
                  context.strings.flag_since,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: context.textColorTheme.textColorPrimary,
                  ),
                ),
              if (since != null)
                Text(
                  since!.formatSinceDate(),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: context.textColorTheme.textColorPrimary,
                  ),
                ),
              if (since != null) Dimens.vGap10,
            ],
          ),
        ),
        Dimens.vGap20,
        Text(
          context.strings.flag_with,
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              height: 1,
              color: context.textColorTheme.textColorSecondary),
        ),
        Dimens.vGap6,
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              Assets.logoAppTransparentBg,
              width: 28,
              height: 28,
            ),
            Dimens.hGap16,
            Text(
              Constants.appNameFull,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: context.textColorTheme.textColorPrimary,
              ),
            ),
          ],
        )
      ],
    );
  }
}
