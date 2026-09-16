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
import 'package:skeletonizer/skeletonizer.dart';

/// 已结算仓位列表项（卡片式 UI）
///
/// 设计稿：单行卡片，左侧 token + 交易对信息，右侧时长 + 盈亏 + WIN/LOSE 标签
class SettledPositionListItem extends StatelessWidget {
  final HistoryPositionVO item;
  final VoidCallback? onTap;
  final bool isLoading;

  const SettledPositionListItem({
    super.key,
    required this.item,
    this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final bullishColor = context.appColors.bullish;
    final bearishColor = context.appColors.bearish;
    var textColorTertiary = context.textColorTheme.textColorTertiary;
    final directionColor = item.isHigh ? bullishColor : bearishColor;
    final resultColor = item.isWin == null
        ? textColorTertiary
        : (item.isSettledWin ? bullishColor : bearishColor);

    return Touchable.plain(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
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
            // 左侧：token 图标 + 交易对信息
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: item.tradingPair,
                builder: (context, tradingPair, _) {
                  return Row(
                    children: [
                      if (!isLoading)
                        LogoImage(
                          symbol: item.baseAsset,
                          width: 34,
                          height: 34,
                          iconURL: tradingPair?.iconUrl ?? item.baseAsset,
                        ),
                      if (isLoading) Bone.circle(size: 34),
                      Dimens.hGap4,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 交易对名称
                          Text(
                            tradingPair?.pairName ??
                                '${item.baseAsset.toUpperCase()}/USD',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              height: 1.25,
                              color:
                                  context.textColorTheme.textColorQuaternary,
                            ),
                          ),
                          Dimens.vGap2,
                          // 金额 + 方向箭头
                          Row(
                            children: [
                              Text(
                                item.amountDisplay,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  height: 1.2142,
                                  color: context
                                      .textColorTheme.textColorSecondary,
                                ),
                              ),
                              Dimens.hGap2,
                              if (!isLoading)
                                SvgPicture.asset(
                                  item.isHigh
                                      ? Assets.svgsIcTradingActionUp
                                      : Assets.svgsIcTradingActionDown,
                                  width: 16,
                                  height: 16,
                                  colorFilter: ColorFilter.mode(
                                    directionColor,
                                    BlendMode.srcIn,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // 时长
                Text(
                  item.durationDisplay,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    height: 1.25,
                    color: context.textColorTheme.textColorQuaternary,
                  ),
                ),
                Dimens.vGap2,
                // 盈亏金额 + WIN/LOSE 标签
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.isWin == null ? '--' : item.payoutDisplay,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: resultColor,
                          height: 1.2142),
                    ),
                    if (!isLoading) _buildResultBadge(context, resultColor),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// WIN/LOSE 标签
  Widget _buildResultBadge(BuildContext context, Color color) {
    if (item.isWin == null) return const SizedBox.shrink();
    final text = item.isSettledWin ? 'WIN' : 'LOSE';
    return Container(
      width: 30,
      height: 17,
      margin: EdgeInsets.only(left: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: color, width: 0.5),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.w500,
            color: color,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
