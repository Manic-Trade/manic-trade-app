import 'package:finality/common/constants/blockchain.dart';
import 'package:finality/common/utils/block_explorer_utils.dart';
import 'package:finality/common/utils/color_scheme_extensions.dart';
import 'package:finality/common/utils/localization_extensions.dart';
import 'package:finality/common/widgets/drag_handle.dart';
import 'package:finality/common/widgets/logo_image.dart';
import 'package:finality/common/widgets/touchable.dart';
import 'package:finality/features/positions/model/history_position_vo.dart';
import 'package:finality/features/positions/share/settled_postion_share_sheet.dart';
import 'package:finality/features/positions/widgets/postion_prop_row.dart';
import 'package:finality/generated/assets.dart';
import 'package:finality/theme/app_color_theme.dart';
import 'package:finality/theme/attrs/text_color_theme.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

/// 已结算订单详情底部弹窗
class SettledPositionDetailsSheet extends StatelessWidget {
  final HistoryPositionVO item;
  final bool isAgent;

  const SettledPositionDetailsSheet({
    super.key,
    required this.item,
    required this.isAgent,
  });

  @override
  Widget build(BuildContext context) {
    final bullishColor = context.appColors.bullish;
    final bearishColor = context.appColors.bearish;
    var textColorTertiary = context.textColorTheme.textColorTertiary;
    final resultColor = item.isWin == null
        ? textColorTertiary
        : (item.isSettledWin ? bullishColor : bearishColor);

    return Container(
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Dimens.sheetTopRadius,
        ),
        border: Border(
          top: BorderSide(
            color: context.colorScheme.outlineVariant,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const DragHandle(),
            Padding(
              padding: Dimens.edgeInsetsH16,
              child: Column(
                children: [
                  // 头部：交易对信息 + 盈亏
                  _buildHeader(context, resultColor),
                  Dimens.vGap24,
                  // 属性列表
                  _buildProperties(context),
                  Dimens.vGap40,
                  if (item.isWin != null) _buildShareButton(context),
                  Dimens.vGap16,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 头部区域：左侧 token + 交易对，右侧盈亏金额 + WIN/LOSE
  Widget _buildHeader(BuildContext context, Color resultColor) {
    final directionColor =
        item.isHigh ? context.appColors.bullish : context.appColors.bearish;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // 左侧：token 图标 + 交易对 + 金额
        ValueListenableBuilder(
          valueListenable: item.tradingPair,
          builder: (context, tradingPair, _) {
            return Row(
              children: [
                LogoImage(
                  symbol: item.baseAsset,
                  width: 40,
                  height: 40,
                  iconURL: tradingPair?.iconUrl ?? item.baseAsset,
                ),
                Dimens.hGap8,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 交易对名称
                    Text(
                      tradingPair?.pairName ??
                          '${item.baseAsset.toUpperCase()}/USD',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        height: 1.25,
                        color: context.textColorTheme.textColorTertiary,
                      ),
                    ),
                    // 金额 + 方向箭头
                    Row(
                      children: [
                        Text(
                          item.amountDisplay,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            height: 1.2142,
                            color: context.textColorTheme.textColorSecondary,
                          ),
                        ),
                        Dimens.hGap2,
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
        // 右侧：盈亏金额 + WIN/LOSE 标签
        Row(
          children: [
            Text(
              item.isWin == null ? '--' : item.payoutDisplay,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: resultColor,
                height: 1.25,
                shadows: [
                  Shadow(
                    color: resultColor,
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
            _buildResultBadge(context, resultColor),
          ],
        ),
      ],
    );
  }

  /// WIN/LOSE 标签
  Widget _buildResultBadge(BuildContext context, Color color) {
    if (item.isWin == null) return const SizedBox.shrink();
    final text = item.isSettledWin ? 'WIN' : 'LOSE';
    return Container(
      margin: EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: color, width: 0.5),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: color,
          height: 1.2142,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  /// 属性列表
  Widget _buildProperties(BuildContext context) {
    return Column(
      children: [
        PostionPropRow(
          title: 'Expiry Type',
          value: item.modeDisplay,
        ),
        Dimens.vGap16,
        PostionPropRow(
          title: 'Duration',
          value: item.durationDisplay,
        ),
        Dimens.vGap16,
        PostionPropRow(
          title: 'Amount',
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                item.isHigh
                    ? Assets.svgsIcTradingActionUp
                    : Assets.svgsIcTradingActionDown,
                width: 16,
                height: 16,
              ),
              Dimens.hGap2,
              Text(
                item.amountDisplay,
                style: PostionPropRow.valueTextStyle(context),
              ),
            ],
          ),
        ),
        Dimens.vGap16,
        ValueListenableBuilder(
          valueListenable: item.tradingPair,
          builder: (context, tradingPair, _) {
            return PostionPropRow(
              title: 'Entry Price',
              value: item.getEntryPriceDisplay(tradingPair?.pipSize ?? 2),
            );
          },
        ),
        if (item.isWin != null) ...[
          Dimens.vGap16,
          ValueListenableBuilder(
            valueListenable: item.tradingPair,
            builder: (context, tradingPair, _) {
              return PostionPropRow(
                title: 'Close Price',
                value: item.getClosePriceDisplay(tradingPair?.pipSize ?? 2),
              );
            },
          ),
        ],
        Dimens.vGap16,
        PostionPropRow(
          title: 'Ended At',
          value: item.endTimeDisplay,
        ),
        if (item.isWin != null) ...[
          Dimens.vGap16,
          PostionPropRow(
            title: 'Close Type',
            value: item.closeTypeDisplay,
          ),
          Dimens.vGap16,
          PostionPropRow(
            title: 'PnL%',
            trailing: Text(
              "${item.pnlSign}${item.pnlPercent}%",
              style: PostionPropRow.valueTextStyle(context,
                  color: item.profit >= 0
                      ? context.appColors.bullish
                      : context.appColors.bearish),
            ),
          ),
        ],
        if (item.settleTxHash != null) ...[
          Dimens.vGap16,
          PostionPropRow(
            title: 'Settle',
            trailing: Touchable.plain(
              onTap: () {
                _viewOnExplorer(context);
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  color: context.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(
                      color: context.colorScheme.primary.withValues(alpha: 0.3),
                      width: 0.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.settleTxHashShort ?? '',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        color: context.colorScheme.primary,
                        height: 1,
                      ),
                    ),
                    Dimens.hGap4,
                    Icon(
                      Icons.open_in_new,
                      size: 10,
                      color: context.colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ],
    );
  }

  /// 底部交易哈希按钮
  Widget _buildShareButton(BuildContext context) {
    return Touchable(
      onTap: () {
        showSettledPositionShareSheet(context, item: item, isAgent: isAgent);
      },
      child: Container(
        width: double.infinity,
        height: 40,
        decoration: BoxDecoration(
          color: context.colorScheme.primary,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              context.strings.share,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: context.colorScheme.onPrimary,
              ),
            ),
            Dimens.hGap8,
            SvgPicture.asset(
              Assets.svgsRemixOpenInNew,
              width: 16,
              height: 16,
              colorFilter: ColorFilter.mode(
                context.colorScheme.onPrimary,
                BlendMode.srcIn,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 在浏览器中查看交易
  void _viewOnExplorer(BuildContext context) {
    final hash = item.settleTxHash;
    if (hash != null) {
      final url = Networks.solana.links?.formatTXUrl(hash);
      if (url != null) {
        BlockExplorerUtils.viewTransaction(url);
      }
    }
  }
}

/// 显示已结算订单详情底部弹窗
Future<void> showSettledPositionDetailsSheet(
  BuildContext context, {
  required HistoryPositionVO item,
  required bool isAgent,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => SettledPositionDetailsSheet(item: item, isAgent: isAgent),
  );
}
