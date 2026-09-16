import 'package:finality/common/widgets/touchable.dart';
import 'package:finality/theme/attrs/text_color_theme.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/material.dart';
import 'package:finality/common/utils/localization_extensions.dart';

class WalletNotInitializedCard extends StatelessWidget {
  final VoidCallback onTap;
  const WalletNotInitializedCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Touchable(
      highlightBorderRadius: null,
      highlightColor: Colors.transparent,
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: Dimens.edgeInsetsA16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.strings.title_wallet_not_initialized,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                context.strings.message_wallet_not_initialized,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 12),
              Touchable(
                highlightBorderRadius: null,
                highlightColor: Colors.transparent,
                onTap: onTap,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      context.strings.action_setup_wallet,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: context.textColorTheme.textColorPrimary,
                      ),
                    ),
                    Dimens.hGap4,
                    Icon(
                      Icons.keyboard_arrow_right_rounded,
                      size: 20,
                      color: context.textColorTheme.textColorPrimary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
