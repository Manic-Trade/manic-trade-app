import 'package:finality/common/utils/haptic_feedback_utils.dart';
import 'package:finality/common/utils/string_extensions.dart';
import 'package:finality/common/widgets/touchable.dart';
import 'package:finality/di/injector.dart';
import 'package:finality/common/widgets/wallet_avatar.dart';
import 'package:finality/services/turnkey/turnkey_manager.dart';
import 'package:finality/services/wallet/wallet_service.dart';
import 'package:finality/theme/attrs/text_color_theme.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/material.dart';

class HoldingTopBar extends StatelessWidget {
  final VoidCallback onTap;
  final VoidCallback onTransactionsTap;
  final VoidCallback onSettingsTap;
  final void Function(BuildContext) onWalletLongPress;
  final Function(String) onPasteText;

  const HoldingTopBar({
    super.key,
    required this.onTap,
    required this.onTransactionsTap,
    required this.onSettingsTap,
    required this.onWalletLongPress,
    required this.onPasteText,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Dimens.hGap4,
        _buildSettingsButton(context),
        Dimens.hGap4,
        Spacer(),
        Dimens.hGap4,
        Touchable.iconButton(
          child: IconButton(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            icon: const Icon(Icons.history_rounded),
            onPressed: () {
              HapticFeedbackUtils.lightImpact();
              onTransactionsTap();
            },
          ),
        ),
        Dimens.hGap4,
      ],
    );
  }

  Widget _buildSettingsButton(BuildContext context) {
    var turnkeyManager = injector<TurnkeyManager>();
    return ValueListenableBuilder(
        valueListenable: injector<WalletService>().walletAccounts,
        builder: (context, value, child) {
          var walletAccounts = value;
          if (walletAccounts == null) {
            return Touchable.iconButton(
              enableFeedback: false,
              child: IconButton(
                  onPressed: () {
                    HapticFeedbackUtils.lightImpact();
                    onSettingsTap();
                  },
                  icon: const Icon(Icons.settings_rounded)),
            );
          }
          return Touchable(
            onTap: () {
              onSettingsTap();
            },
            child: Builder(builder: (context) {
              return Row(
                children: [
                  Dimens.hGap8,
                  WalletAvatar(
                    avatar: walletAccounts.wallet.avatar,
                    size: 28,
                  ),
                  Dimens.hGap8,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          turnkeyManager.user?.userEmail?.emailUsername ??
                              walletAccounts.wallet.name,
                          style: TextStyle(
                            height: 1,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: context.textColorTheme.textColorPrimary,
                          )),
                      Text(
                        "Demo Account",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: context.textColorTheme.textColorTertiary,
                        ),
                      ),
                    ],
                  ),
                  Dimens.hGap4,
                  Icon(
                    Icons.keyboard_arrow_right_rounded,
                    size: 20,
                    color: context.textColorTheme.textColorPrimary,
                  ),
                ],
              );
            }),
          );
        });
  }
}
