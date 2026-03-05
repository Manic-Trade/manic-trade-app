import 'package:finality/common/utils/color_scheme_extensions.dart';
import 'package:finality/common/utils/countdown_notifier.dart';
import 'package:finality/common/widgets/logo_image.dart';
import 'package:finality/common/widgets/touchable.dart';
import 'package:finality/core/notifier/computed_notifier.dart';
import 'package:finality/domain/options/entities/opened_position.dart';
import 'package:finality/generated/assets.dart';
import 'package:finality/theme/app_color_theme.dart';
import 'package:finality/theme/attrs/text_color_theme.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class GameStatusListItem extends StatefulWidget {
  final OpenedPosition position;
  final ValueNotifier<double?> currentPriceNotifier;
  final VoidCallback? onTap;

  const GameStatusListItem({
    super.key,
    required this.position,
    required this.currentPriceNotifier,
    this.onTap,
  });

  @override
  State<GameStatusListItem> createState() => _GameStatusListItemState();
}

class _GameStatusListItemState extends State<GameStatusListItem> {
  late final CountdownNotifier _countdownNotifier;
  late final ComputedNotifier<bool, double?> _isWinningNotifier;

  @override
  void initState() {
    super.initState();
    _countdownNotifier = CountdownNotifier(widget.position.endTime);
    _isWinningNotifier = ComputedNotifier(
      source: widget.currentPriceNotifier,
      compute: (currentPrice) {
        if (currentPrice == null) return true;
        if (widget.position.isHigh) {
          return currentPrice >= widget.position.entryPrice;
        } else {
          return currentPrice < widget.position.entryPrice;
        }
      },
    );
  }

  @override
  void dispose() {
    _countdownNotifier.dispose();
    _isWinningNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final position = widget.position;
    final bullishColor = context.appColors.bullish;
    final bearishColor = context.appColors.bearish;
    final directionColor = position.isHigh ? bullishColor : bearishColor;

    return Touchable(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Logo
            LogoImage(
              symbol: position.tradingPair.baseAsset,
              iconURL: position.tradingPair.iconUrl,
              width: 40,
              height: 40,
            ),
            Dimens.hGap12,
            // Left: pair name + direction & amount
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    position.tradingPair.pairName,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: context.textColorTheme.textColorTertiary,
                    ),
                  ),
                  Dimens.vGap2,
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        position.amountDisplay,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: context.textColorTheme.textColorPrimary,
                        ),
                      ),
                      Dimens.hGap4,
                      SvgPicture.asset(
                        position.isHigh
                            ? Assets.svgsIcTradingActionUp
                            : Assets.svgsIcTradingActionDown,
                        width: 20,
                        height: 20,
                        color: directionColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Right: countdown + P&L
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Countdown
                ValueListenableBuilder<int>(
                  valueListenable: _countdownNotifier,
                  builder: (context, remaining, _) {
                    if (remaining <= 0) {
                      return _buildSettlingBadge(context);
                    }
                    return _buildCountdownBadge(context, remaining,
                        context.textColorTheme.textColorTertiary);
                  },
                ),
                Dimens.vGap4,
                // Expected Payout
                ValueListenableBuilder<bool>(
                  valueListenable: _isWinningNotifier,
                  builder: (context, isWin, _) {
                    return Text(
                      isWin
                          ? "+\$${position.winPayoutDisplay}"
                          : "\$${position.lossPayoutDisplay}",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        fontFeatures: [FontFeature.tabularFigures()],
                        color: isWin ? bullishColor : bearishColor,
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountdownBadge(
      BuildContext context, int remaining, Color color) {
    final minutes = remaining ~/ 60;
    final seconds = remaining % 60;
    final timeText =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return Text(
      timeText,
      style: TextStyle(
        color: color,
        fontSize: 13,
        fontWeight: FontWeight.w500,
        fontFeatures: [FontFeature.tabularFigures()],
      ),
    );
  }

  Widget _buildSettlingBadge(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 10,
          height: 10,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            color: context.colorScheme.primary,
          ),
        ),
        Dimens.hGap4,
        Text(
          'Settling...',
          style: TextStyle(
            color: context.colorScheme.primary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
