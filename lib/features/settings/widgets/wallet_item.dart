import 'package:finality/common/utils/localization_extensions.dart';
import 'package:finality/common/utils/string_extensions.dart';
import 'package:finality/common/widgets/copyable_widget.dart';
import 'package:finality/common/widgets/touchable.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:finality/common/widgets/wallet_avatar.dart';
import 'package:finality/theme/attrs/text_color_theme.dart';
import 'package:finality/theme/dimens.dart';

class WalletItem extends StatelessWidget {
  final String? avatar;
  final String name;
  final String address;
  final VoidCallback? onTap;
  final VoidCallback? onSwitchWallet;
  final bool showArrow;
  const WalletItem({
    super.key,
    required this.avatar,
    required this.name,
    required this.address,
    this.onTap,
    this.onSwitchWallet,
    this.showArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Touchable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            WalletAvatar(
              avatar: avatar,
              size: 46,
            ),
            Dimens.hGap12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          name,
                          style: context.textTheme.titleMedium
                              ?.copyWith(fontSize: 17),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (onSwitchWallet != null)
                        Touchable.plain(
                          onTap: onSwitchWallet,
                          child: Container(
                            margin: const EdgeInsets.only(left: 8, right: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: context.textColorTheme.textColorPrimary
                                    .withValues(alpha: 0.15),
                              ),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(context.strings.action_switch_wallet_short,
                                    style: context.textTheme.bodySmall
                                        ?.copyWith(
                                            color: context.textColorTheme
                                                .textColorPrimary)),
                                Dimens.hGap4,
                                Icon(
                                  Icons.sync_alt,
                                  color:
                                      context.textColorTheme.textColorPrimary,
                                  size: 12,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  Dimens.vGap4,
                  CopyableWidget(
                    content: address,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(address.truncateWithEllipsis(),
                            maxLines: 1,
                            style: context.textTheme.bodyMedium?.copyWith(
                                color:
                                    context.textColorTheme.textColorSecondary)),
                        Dimens.hGap2,
                        Icon(
                          Icons.copy_rounded,
                          color: context.textColorTheme.textColorSecondary,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (showArrow)
              Icon(
                Icons.keyboard_arrow_right_rounded,
                color: context.textColorTheme.textColorSecondary,
              ),
          ],
        ),
      ),
    );
  }
}
