import 'package:finality/common/utils/color_scheme_extensions.dart';
import 'package:finality/common/widgets/logo_image.dart';
import 'package:finality/common/widgets/touchable.dart';
import 'package:finality/features/positions/model/history_position_vo.dart';
import 'package:finality/generated/assets.dart';
import 'package:finality/theme/app_color_theme.dart';
import 'package:finality/theme/attrs/text_color_theme.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class HistoryListItem extends StatelessWidget {
  final HistoryPositionVO item;
  final VoidCallback onTap;
  final GestureTapCallback? onSharePressed;

  const HistoryListItem({
    super.key,
    required this.item,
    required this.onTap,
    this.onSharePressed,
  });

  bool get isWin => item.isWin;

  /// 是否是看涨方向
  bool get isHigher => item.isHigh;

  /// 开单金额显示（如 Đ150.00）
  String get amountDisplay {
    return item.amountDisplay;
  }

  /// 持仓时间显示（如 1 min, 30 sec）
  String get durationDisplay {
    final durationSecs = item.endTime - item.startTime;
    if (durationSecs >= 60) {
      final minutes = durationSecs ~/ 60;
      return '$minutes min';
    } else {
      return '$durationSecs sec';
    }
  }

  /// 盈亏金额显示
  String get pnlDisplay {
    if (isWin) {
      // 赢了显示 payout
      return item.payoutDisplay;
    } else {
      // 输了显示负的开单金额
      return item.payoutDisplay;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bullishColor = context.appColors.bullish;
    final bearishColor = context.appColors.bearish;
    final directionColor = item.isHigh ? bullishColor : bearishColor;

    return Touchable(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: ValueListenableBuilder(
            valueListenable: item.tradingPair,
            builder: (context, tradingPair, child) {
              return Row(
                children: [
                  // 资产图标
                  LogoImage(
                    symbol: item.baseAsset,
                    width: 40,
                    height: 40,
                    iconURL: tradingPair?.iconUrl ?? item.baseAsset,
                  ),
                  Dimens.hGap12,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tradingPair?.pairName ??
                              ("${item.baseAsset.toUpperCase()}/USD"),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: context.textColorTheme.textColorTertiary,
                          ),
                        ),
                        Dimens.vGap2,
                        Row(
                          children: [
                            Text(
                              amountDisplay,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: context.textColorTheme.textColorPrimary,
                              ),
                            ),
                            Dimens.hGap4,
                            SvgPicture.asset(
                              isHigher
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        durationDisplay,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: context.textColorTheme.textColorTertiary,
                        ),
                      ),
                      Dimens.vGap2,
                      Text(
                        pnlDisplay,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isWin ? bullishColor : bearishColor,
                        ),
                      ),
                    ],
                  ),
                  if (onSharePressed != null) Dimens.hGap16,
                  if (onSharePressed != null) _buildShareButton(context),
                ],
              );
            }),
      ),
    );
  }

  Widget _buildShareButton(BuildContext context) {
    return Touchable.plain(
      onTap: onSharePressed,
      shrinkScaleFactor: 0.8,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: context.colorScheme.primary.withOpacity(0.12),
        ),
        child: Center(
          child: SvgPicture.asset(
            Assets.svgsIcActionShare,
            width: 17,
            color: context.colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
