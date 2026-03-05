import 'package:finality/common/utils/date_time_extensions.dart';
import 'package:finality/common/widgets/logo_image.dart';
import 'package:finality/common/widgets/touchable.dart';
import 'package:finality/features/activity/model/activity_item.dart';
import 'package:finality/theme/app_color_theme.dart';
import 'package:finality/theme/attrs/text_color_theme.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/material.dart';

/// Activity list item widget
class ActivityListItemWidget extends StatelessWidget {
  final ActivityItem item;
  final VoidCallback? onTap;

  const ActivityListItemWidget({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return switch (item) {
      OpenPositionActivityItem i =>
        _OpenPositionItemWidget(item: i, onTap: onTap),
      SettlePositionActivityItem i =>
        _SettlePositionItemWidget(item: i, onTap: onTap),
      DepositActivityItem i => _DepositItemWidget(item: i, onTap: onTap),
      WithdrawActivityItem i => _WithdrawItemWidget(item: i, onTap: onTap),
    };
  }
}

/// Base container for list items
class _ActivityItemContainer extends StatelessWidget {
  final Widget leading;
  final String title;
  final String subtitle;
  final String amount;
  final Color amountColor;
  final VoidCallback? onTap;
  final bool? isWin;

  const _ActivityItemContainer({
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.amountColor,
    this.onTap,
    this.isWin,
  });

  @override
  Widget build(BuildContext context) {
    return Touchable(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            leading,
            Dimens.hGap12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: context.textColorTheme.textColorPrimary,
                        ),
                      ),
                      if (isWin != null) ...[
                        Dimens.hGap6,
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isWin!
                                ? const Color(0x1A4CAF50)
                                : const Color(0x1AFF8A65),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            isWin! ? 'WIN' : 'LOSS',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: isWin!
                                  ? const Color(0xFF4CAF50)
                                  : const Color(0xFFFF8A65),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Dimens.vGap4,
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: context.textColorTheme.textColorSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              amount,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: amountColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Asset icon widget
class _AssetIcon extends StatelessWidget {
  final String asset;

  const _AssetIcon({
    required this.asset,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        LogoImage(
          symbol: asset,
          width: 40,
          height: 40,
          iconURL: asset,
        )
      ],
    );
  }
}

/// Deposit/Withdraw icon widget
class _TransferIcon extends StatelessWidget {
  final bool isDeposit;

  const _TransferIcon({
    required this.isDeposit,
  });

  @override
  Widget build(BuildContext context) {
    return LogoImage(
      symbol: 'USDC',
      width: 40,
      height: 40,
      iconURL: 'USDC',
    );
  }
}

/// Open position item widget
class _OpenPositionItemWidget extends StatelessWidget {
  final OpenPositionActivityItem item;
  final VoidCallback? onTap;

  const _OpenPositionItemWidget({
    required this.item,
    this.onTap,
  });

  String _formatAge(BuildContext context) {
    return item.time.formatHMMSSWithAmPm();
  }

  String _formatDirection() {
    return item.isHigh ? '↑' : '↓';
  }

  @override
  Widget build(BuildContext context) {
    return _ActivityItemContainer(
      leading: _AssetIcon(asset: item.asset),
      title: '${_formatDirection()} ${item.asset} Open',
      subtitle: _formatAge(context),
      amount: item.amountDisplay,
      amountColor: context.textColorTheme.textColorPrimary,
      onTap: onTap,
    );
  }
}

/// Settle position item widget
class _SettlePositionItemWidget extends StatelessWidget {
  final SettlePositionActivityItem item;
  final VoidCallback? onTap;

  const _SettlePositionItemWidget({
    required this.item,
    this.onTap,
  });

  String _formatAge(BuildContext context) {
    return item.time.formatHMMSSWithAmPm();
  }

  String _formatDirection() {
    return item.isHigh ? '↑' : '↓';
  }

  @override
  Widget build(BuildContext context) {
    final amountColor = item.payoutAmount > 0
        ? context.appColors.bullish
        : (item.payoutAmount < 0
            ? context.appColors.bearish
            : context.textColorTheme.textColorPrimary);
    return _ActivityItemContainer(
      leading: _AssetIcon(asset: item.asset),
      title: '${_formatDirection()} ${item.asset} Settle',
      subtitle: _formatAge(context),
      amount: item.payoutDisplay,
      amountColor: amountColor,
      onTap: onTap,
      isWin: item.isWin,
    );
  }
}

/// Deposit item widget
class _DepositItemWidget extends StatelessWidget {
  final DepositActivityItem item;
  final VoidCallback? onTap;

  const _DepositItemWidget({
    required this.item,
    this.onTap,
  });
  String _formatAge(BuildContext context) {
    return item.time.formatHMMSSWithAmPm();
  }

  @override
  Widget build(BuildContext context) {
    return _ActivityItemContainer(
      leading: const _TransferIcon(isDeposit: true),
      title: 'Deposit',
      subtitle: _formatAge(context),
      amount: item.amountDisplay,
      amountColor: context.appColors.bullish,
      onTap: onTap,
    );
  }
}

/// Withdraw item widget
class _WithdrawItemWidget extends StatelessWidget {
  final WithdrawActivityItem item;
  final VoidCallback? onTap;

  const _WithdrawItemWidget({
    required this.item,
    this.onTap,
  });

  String _formatAge(BuildContext context) {
    return item.time.formatHMMSSWithAmPm();
  }

  @override
  Widget build(BuildContext context) {
    return _ActivityItemContainer(
      leading: const _TransferIcon(isDeposit: false),
      title: 'Withdraw',
      subtitle: _formatAge(context),
      amount: item.amountDisplay,
      amountColor: context.textColorTheme.textColorPrimary,
      onTap: onTap,
    );
  }
}
