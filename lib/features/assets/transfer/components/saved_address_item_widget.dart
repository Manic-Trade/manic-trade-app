import 'package:finality/common/utils/data_time_extensions.dart';
import 'package:finality/common/utils/string_extensions.dart';
import 'package:finality/common/widgets/touchable.dart';
import 'package:finality/data/drift/user_preferences_database.dart';
import 'package:finality/features/assets/transfer/components/address_item_delete_popup.dart';
import 'package:finality/common/widgets/wallet_avatar.dart';
import 'package:finality/theme/attrs/text_color_theme.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/context_extensions.dart';

class SavedAddressItemWidget extends StatelessWidget {
  final SavedAddress savedAddress;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final DateTime? lastUsedAt;
  final bool isDeleteContact;

  const SavedAddressItemWidget({
    super.key,
    required this.savedAddress,
    required this.isSelected,
    required this.onTap,
    this.onDelete,
    this.lastUsedAt,
    this.isDeleteContact = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasLabel =
        savedAddress.label != null && savedAddress.label!.isNotEmpty;
    return Touchable(
      onTap: onTap,
      onLongPress: onDelete != null
          ? () {
              showAddressItemDeletePopup(context,
                  onDelete: onDelete!, isDeleteContact: isDeleteContact);
            }
          : null,
      child: SizedBox(
        height: 68,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              WalletAvatar(
                avatar: savedAddress.address,
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
                            hasLabel
                                ? savedAddress.label!
                                : savedAddress.address.truncateWithEllipsis(
                                    prefixLength: 4, suffixLength: 4),
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
                      hasLabel
                          ? savedAddress.address.truncateWithEllipsis(
                              prefixLength: 4, suffixLength: 4)
                          : savedAddress.address.truncateWithEllipsis(
                              prefixLength: 6, suffixLength: 6),
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
