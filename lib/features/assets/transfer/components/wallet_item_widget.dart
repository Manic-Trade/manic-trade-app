import 'package:finality/common/utils/data_time_extensions.dart';
import 'package:finality/common/utils/string_extensions.dart';
import 'package:finality/common/widgets/touchable.dart';
import 'package:finality/domain/wallet/entities/unified_wallet_accounts.dart';
import 'package:finality/features/assets/transfer/components/address_item_delete_popup.dart';
import 'package:finality/common/widgets/wallet_avatar.dart';
import 'package:finality/theme/attrs/text_color_theme.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/context_extensions.dart';

class WalletItemWidget extends StatelessWidget {
  final UnifiedWalletAccounts walletAccount;
  final bool isSelected;
  final VoidCallback onTap;
  final DateTime? lastUsedAt;
  final VoidCallback? onDelete;

  const WalletItemWidget(
      {super.key,
      required this.walletAccount,
      required this.isSelected,
      required this.onTap,
      this.lastUsedAt,
      this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Touchable(
      onTap: onTap,
      onLongPress: onDelete != null
          ? () {
              showAddressItemDeletePopup(context, onDelete: onDelete!);
            }
          : null,
      child: SizedBox(
        height: 68,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              WalletAvatar(
                avatar: walletAccount.wallet.avatar,
                size: 40,
              ),
              Dimens.hGap12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            walletAccount.wallet.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        if (lastUsedAt != null)
                          Text(
                            lastUsedAt!.smartFormat2(context),
                            maxLines: 1,
                            style: TextStyle(
                                fontSize: 14,
                                overflow: TextOverflow.ellipsis,
                                height: 1,
                                color:
                                    context.textColorTheme.textColorSecondary),
                          ),
                      ],
                    ),
                    Dimens.vGap2,
                    Text(
                      walletAccount.accounts.first.address.truncateWithEllipsis(
                          prefixLength: 4, suffixLength: 4),
                      maxLines: 1,
                      style: TextStyle(
                          fontSize: 14,
                          overflow: TextOverflow.ellipsis,
                          height: 1,
                          color: context.textColorTheme.textColorSecondary),
                    ),
                  ],
                ),
              ),
              Dimens.hGap24,
              Icon(
                  isSelected
                      ? Icons.check_circle_rounded
                      : Icons.check_circle_outline_rounded,
                  color: isSelected
                      ? context.theme.colorScheme.primary
                      : context.textColorTheme.textColorTertiary),
            ],
          ),
        ),
      ),
    );
  }
}
