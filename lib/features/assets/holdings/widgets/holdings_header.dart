import 'package:finality/common/constants/currencies.dart';
import 'package:finality/common/utils/color_scheme_extensions.dart';
import 'package:finality/common/utils/decimal_format.dart';
import 'package:finality/common/utils/localization_extensions.dart';
import 'package:finality/common/widgets/touchable.dart';
import 'package:finality/data/app_preferences.dart';
import 'package:finality/di/injector.dart';
import 'package:finality/generated/assets.dart';
import 'package:finality/theme/attrs/text_color_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:store_scope/store_scope.dart';

import '../../../../theme/dimens.dart';

class HoldingsHeader extends StatelessWidget with ScopedStatelessMixin {
  final VoidCallback? onWalletSelectorTap;
  final VoidCallback onSendPressed;
  final VoidCallback onReceivePressed;
  final VoidCallback onReclaimPressed;
  final Widget? notificationCards;

  final ValueListenable<double> totalAssetValue;
  final bool isLoading;

  HoldingsHeader({
    super.key,
    this.onWalletSelectorTap,
    required this.onSendPressed,
    required this.onReceivePressed,
    required this.onReclaimPressed,
    this.notificationCards,
    required this.totalAssetValue,
    this.isLoading = false,
  });

  @override
  Widget buildScoped(BuildContext context, Listenable scope) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Dimens.vGap16,
        Padding(
          padding: Dimens.edgeInsetsH16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                context.strings.title_total_balance,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: context.textColorTheme.textColorSecondary,
                ),
              ),
              // Dimens.hGap8,
              // Text(
              //   "Demo Account",
              //   style: TextStyle(
              //     fontSize: 14,
              //     fontWeight: FontWeight.w600,
              //     color: context.textColorTheme.textColorSecondary,
              //   ),
              // ),
            ],
          ),
        ),
        Dimens.vGap6,
        Padding(
          padding: Dimens.edgeInsetsH16,
          child: ValueListenableBuilder(
              valueListenable: injector<AppPreferences>().amountVisibleNotifier,
              builder: (context, amountVisible, child) {
                return _buildTotalAsset(context, amountVisible);
              }),
        ),
        // Dimens.vGap2,
        // Padding(
        //   padding: Dimens.edgeInsetsH16,
        //   child: ValueListenableBuilder(
        //       valueListenable: injector<AppPreferences>().amountVisibleNotifier,
        //       builder: (context, amountVisible, child) {
        //         return _buildPriceChangeIndicator(context, amountVisible);
        //       }),
        // ),
        Dimens.vGap24,
        Padding(
          padding: Dimens.edgeInsetsH16,
          child: _buildActionButtons(context, scope),
        ),
        if (notificationCards != null) notificationCards!,
        Dimens.vGap28,
        const Divider(),
      ],
    );
  }

  Widget _buildTotalAssetText(BuildContext context, String text) {
    var titleTextStyle = TextStyle(
      fontSize: 45,
      fontWeight: FontWeight.w600,
      color: context.colorScheme.onSurface,
    );
    return GestureDetector(
      onTap: () {
        injector<AppPreferences>().amountVisible =
            !injector<AppPreferences>().amountVisible;
      },
      child: Skeletonizer(
        enabled: isLoading,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: titleTextStyle,
        ),
      ),
    );
  }

  Widget _buildTotalAsset(BuildContext context, bool amountVisible) {
    const hiddenText = "******";
    if (!amountVisible) {
      return _buildTotalAssetText(context, hiddenText);
    }

    return ValueListenableBuilder(
      valueListenable: totalAssetValue,
      builder: (context, value, child) {
        return _buildTotalAssetText(
            context, value.formatWithDecimals(2).withUsdSymbol());
      },
    );
  }

  Widget _buildActionButtons(BuildContext context, Listenable scope) {
    // var viewModel =
    //     context.store.bindWith(holdingsViewModelProvider, scope);
    return Row(
      children: [
        // Spacer(),
        // _buildActionButton(context,
        //     label: context.strings.action_deposit,
        //     assetName: Assets.svgsIcWalletActionBuy, onPressed: () {
        //   var address = viewModel.walletAccounts.value?.accounts.first.address;
        //   if (address != null) {
        //     launchUrl(Uri.parse(AppLinks.getTransakBuyUrl(address)),
        //         mode: LaunchMode.externalApplication);
        //   }
        // }),
        Spacer(),
        Spacer(),
        _buildActionButton(context,
            label: context.strings.action_deposit,
            assetName: Assets.svgsIcWalletActionDeposit,
            onPressed: onReceivePressed),
        Spacer(),
        _buildActionButton(context,
            label: context.strings.action_send,
            assetName: Assets.svgsIcWalletActionSend,
            onPressed: onSendPressed),
        // Spacer(),
        // _buildActionIconButton(context,
        //     label: context.strings.title_airdrop,
        //     icon: Icons.airplanemode_active_rounded,
        //     onPressed: onReclaimPressed),
        Spacer(),
        Spacer(),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String label,
    required String assetName,
    required VoidCallback onPressed,
  }) {
    return Touchable.iconButton(
      onTap: onPressed,
      child: Column(
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: FloatingActionButton(
              focusElevation: 0,
              hoverElevation: 0,
              highlightElevation: 0,
              heroTag: label,
              disabledElevation: 0,
              backgroundColor: context.colorScheme.primary.withOpacity(0.12),
              foregroundColor: context.colorScheme.primary,
              elevation: 0,
              shape: const CircleBorder(),
              onPressed: null,
              child: SvgPicture.asset(
                assetName,
                color: context.colorScheme.primary,
              ),
            ),
          ),
          Dimens.vGap8,
          Text(label, style: context.textTheme.labelMedium),
        ],
      ),
    );
  }

  Widget _buildActionIconButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Touchable.iconButton(
      onTap: onPressed,
      child: Column(
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: FloatingActionButton(
              focusElevation: 0,
              hoverElevation: 0,
              highlightElevation: 0,
              heroTag: label,
              disabledElevation: 0,
              backgroundColor: context.colorScheme.primary.withOpacity(0.12),
              foregroundColor: context.colorScheme.primary,
              elevation: 0,
              shape: const CircleBorder(),
              onPressed: null,
              child: Icon(
                icon,
                size: 24,
                color: context.colorScheme.primary,
              ),
            ),
          ),
          Dimens.vGap8,
          Text(label, style: context.textTheme.labelMedium),
        ],
      ),
    );
  }
}
