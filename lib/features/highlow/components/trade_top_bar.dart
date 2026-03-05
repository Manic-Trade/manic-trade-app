import 'package:finality/common/constants/currencies.dart';
import 'package:finality/common/utils/haptic_feedback_utils.dart';
import 'package:finality/common/widgets/logo_image.dart';
import 'package:finality/common/widgets/touchable.dart';
import 'package:finality/common/widgets/price_change_text.dart';
import 'package:finality/generated/assets.dart';
import 'package:finality/theme/app_color_theme.dart';
import 'package:finality/theme/attrs/clash_display_font.dart';
import 'package:finality/theme/attrs/druk_wide_font.dart';
import 'package:finality/theme/attrs/text_color_theme.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class TradeTopBar extends StatelessWidget {
  final String asset;
  final String pairName;
  final String? iconUrl;
  final ValueListenable<double?> currentPrice;
  final VoidCallback onTap;
  final VoidCallback onTransactionsTap;
  final bool canTrade;
  final int pipSize;

  const TradeTopBar({
    super.key,
    required this.asset,
    required this.pairName,
    required this.iconUrl,
    required this.currentPrice,
    required this.onTap,
    required this.onTransactionsTap,
    required this.canTrade,
    required this.pipSize,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Dimens.hGap4,
        _buildSettingsButton(context),
        Dimens.hGap4,
        Spacer(),
        Dimens.hGap4,
        Touchable.iconButton(
          child: IconButton(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            icon: const Icon(Icons.history_rounded),
            onPressed: () {
              HapticFeedbackUtils.lightImpact();
              onTransactionsTap();
            },
          ),
        ),
        Dimens.hGap4,
      ],
    );
  }

  Widget _buildSettingsButton(BuildContext context) {
    return Touchable(
      onTap: onTap,
      child: Row(
        children: [
          Dimens.hGap8,
          LogoImage(
            iconURL: iconUrl,
            symbol: asset,
            width: 24,
            height: 24,
            strokeWidth: 0,
          ),
          Dimens.hGap8,
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(pairName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        height: 1,
                        color: context.textColorTheme.textColorPrimary,
                        fontFamily: DrukWideFont.fontFamily,
                      )),
                  Dimens.vGap6,
                  if (!canTrade) _buildCloseState(context),
                  if (canTrade)
                    ValueListenableBuilder(
                        valueListenable: currentPrice,
                        builder: (context, value, child) {
                          return PriceChangeText(
                            price: value,
                            formatPrice: (double p1) {
                              return Currencies.symbolUsd +
                                  p1.toStringAsFixed(pipSize);
                            },
                            increaseColor: context.appColors.bullish,
                            decreaseColor: context.appColors.bearish,
                            unchangedColor:
                                context.textColorTheme.textColorPrimary,
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                              height: 1,
                              fontFamily: ClashDisplayFont.fontFamily,
                            ),
                          );
                        }),
                ],
              ),
              Dimens.hGap8,
              SizedBox(
                width: 16,
                height: 16,
                child: Center(
                  child: SvgPicture.asset(
                    Assets.svgsIcArrowDownCommonSmall,
                    width: 10,
                    height: 10,
                    color: context.textColorTheme.textColorTertiary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCloseState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: Color(0xFFFF412C).withValues(alpha: 0.05),
        borderRadius: Dimens.radius4,
        border: Border.all(
            color: Color(0xFFFF412C).withValues(alpha: 0.30), width: 0.5),
      ),
      child: Text(
        'CLOSED',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w400,
          height: 1,
          color: Color(0xFFFF412C),
        ),
      ),
    );
  }
}
