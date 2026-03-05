import 'package:finality/common/utils/color_scheme_extensions.dart';
import 'package:finality/common/widgets/logo_image.dart';
import 'package:finality/common/widgets/touchable.dart';
import 'package:finality/features/highlow/trading_pairs/models/options_trading_pair_vo.dart';
import 'package:finality/theme/attrs/text_color_theme.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

class OptionsTradingPairItem extends StatelessWidget {
  final OptionsTradingPairVO asset;
  final bool isSelected;
  final bool isLoading;
  final VoidCallback? onTap;

  const OptionsTradingPairItem(
      {super.key,
      required this.asset,
      required this.isSelected,
      required this.isLoading,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: isLoading,
      child: Touchable(
        onTap: isLoading || !asset.isActive ? null : onTap,
        child: Opacity(
          opacity: asset.isActive ? 1.0 : 0.5,
          child: Container(
            padding: Dimens.edgeInsetsH16,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: context.colorScheme.outlineVariant,
                  width: 0.5,
                ),
              ),
            ),
            height: 62,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icon and Name
                Expanded(
                  flex: 144,
                  child: Row(
                    children: [
                      isLoading
                          ? Bone.circle(
                              size: 24,
                            )
                          : LogoImage(
                              symbol: asset.name,
                              width: 24,
                              height: 24,
                              iconURL: asset.iconUrl,
                            ),
                      Dimens.hGap12,
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              asset.name,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color:
                                    context.textColorTheme.textColorSecondary,
                                height: 1,
                              ),
                            ),
                            Dimens.vGap2,
                            Text(
                              asset.isActive
                                  ? asset.ticker
                                  : _getInactiveSinceTimeText(),
                              style: TextStyle(
                                fontSize: asset.isActive ? 12 : 11,
                                height: 1,
                                letterSpacing: 0,
                                fontWeight: FontWeight.w500,
                                color:
                                    context.textColorTheme.textColorQuaternary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Payout
                Expanded(
                  flex: 72,
                  child: Text(
                    asset.payout,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: context.textColorTheme.textColorSecondary,
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
                Expanded(
                  flex: 100,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      constraints: BoxConstraints(
                        minWidth: 50,
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: context.colorScheme.primary
                            .withValues(alpha: isLoading ? 0.12 : 0.05),
                        borderRadius: BorderRadius.circular(3),
                        border: isLoading
                            ? null
                            : Border.all(
                                color: context.colorScheme.primary
                                    .withValues(alpha: 0.3),
                                width: 0.5,
                              ),
                      ),
                      child: isLoading
                          ? Dimens.emptyBox
                          : Text(
                              asset.multiplier,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                height: 1,
                                letterSpacing: 0,
                                color: context.colorScheme.primary,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getInactiveSinceTimeText() {
    if (asset.inactiveSinceTime == null) {
      return asset.ticker;
    }
    return 'Inactive since ${asset.inactiveSinceTime} UTC';
  }
}
