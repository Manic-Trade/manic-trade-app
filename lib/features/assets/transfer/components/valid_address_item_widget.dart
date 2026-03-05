import 'package:finality/common/constants/blockchain.dart';
import 'package:finality/common/utils/string_extensions.dart';
import 'package:finality/common/widgets/touchable.dart';
import 'package:finality/data/model/network_address_pair.dart';
import 'package:finality/generated/assets.dart';
import 'package:finality/theme/attrs/text_color_theme.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_utils/src/extensions/context_extensions.dart';

class ValidAddressItemWidget extends StatelessWidget {
  final NetworkAddressPair networkAddress;
  final bool isSelected;
  final VoidCallback onTap;

  const ValidAddressItemWidget({
    super.key,
    required this.networkAddress,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Touchable(
      onTap: onTap,
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected
                    ? context.theme.colorScheme.primary.withOpacity(0.12)
                    : context.theme.colorScheme.surfaceContainerLow,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.location_on_rounded,
                  size: 24,
                  color: isSelected
                      ? context.theme.colorScheme.primary
                      : context.theme.colorScheme.onSurface,
                ),
              ),
            ),
            Dimens.hGap12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      networkAddress.address.truncateWithEllipsis(
                          prefixLength: 4, suffixLength: 4),
                      style: TextStyle(
                        fontSize: 16,
                        color: isSelected
                            ? context.theme.colorScheme.primary
                            : context.theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      )),
                  Dimens.vGap2,
                  Row(
                    children: [
                      SvgPicture.asset(
                        Assets.svgsIcSolanaExplorerLogo,
                        width: 16,
                        height: 16,
                        color: isSelected
                            ? context.theme.colorScheme.primary.withOpacity(0.8)
                            : context.textColorTheme.textColorSecondary,
                      ),
                      Dimens.hGap6,
                      Text(
                        Networks.getNetworkName(networkAddress.networkCode),
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isSelected
                                ? context.theme.colorScheme.primary
                                    .withOpacity(0.8)
                                : context.textColorTheme.textColorSecondary),
                      ),
                    ],
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
    );
  }
}
