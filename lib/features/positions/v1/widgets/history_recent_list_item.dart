import 'package:finality/common/constants/currencies.dart';
import 'package:finality/common/utils/color_scheme_extensions.dart';
import 'package:finality/common/utils/decimal_format.dart';
import 'package:finality/common/widgets/logo_image.dart';
import 'package:finality/common/widgets/touchable.dart';
import 'package:finality/data/network/model/manic/position_history_item.dart';
import 'package:finality/generated/assets.dart';
import 'package:finality/theme/attrs/text_color_theme.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class HistoryRecentListItem extends StatelessWidget {
  final PositionHistoryItem item;
  final VoidCallback onTap;
  final GestureTapCallback? onSharePressed;


  const HistoryRecentListItem({
    super.key,
    required this.item,
    required this.onTap,
    this.onSharePressed,
  });

  bool get isWin => item.result == 'Won';

  /// 是否是看涨方向
  bool get isHigher => item.side == 'call';

  /// 方向颜色
  Color get directionColor => isHigher ? Colors.green : Colors.red;

  /// 交易对名称（如 EUR/USD OTC）
  String get pairName => '${item.asset.toUpperCase()}/USD';

  /// 开单金额显示（如 Đ150.00）
  String get amountDisplay {
    return item.uiAmount.formatWithDecimals(2).withUsdSymbol();
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
      final payoutAmount = (item.payout - item.amount) / 1000000;
      return '+${payoutAmount.formatWithDecimals(2).withUsdSymbol()}';
    } else {
      // 输了显示负的开单金额
      return '-${item.uiAmount.formatWithDecimals(2).withUsdSymbol()}';
    }
  }

  /// 盈亏颜色
  Color pnlColor(BuildContext context) {
    if (isWin) {
      return Colors.green;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Touchable(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // 资产图标
            LogoImage(
              symbol: item.asset.toUpperCase(),
              width: 40,
              height: 40,
              iconURL: item.asset.toUpperCase(),
            ),
            Dimens.hGap12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pairName,
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
                    color: pnlColor(context),
                  ),
                ),
              ],
            ),
            if (onSharePressed != null) Dimens.hGap16,
            if (onSharePressed != null) _buildShareButton(context),
          ],
        ),
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
