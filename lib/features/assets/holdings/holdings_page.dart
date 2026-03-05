import 'package:easy_refresh/easy_refresh.dart';
import 'package:finality/common/constants/blockchain.dart';
import 'package:finality/common/toast/app_toast_manager.dart';
import 'package:finality/common/utils/localization_extensions.dart';
import 'package:finality/core/logger.dart';
import 'package:finality/core/notifier/multi_value_listenable_builder.dart';
import 'package:finality/data/app_preferences.dart';
import 'package:finality/data/drift/entities/token.dart';
import 'package:finality/di/injector.dart';
import 'package:finality/features/assets/holdings/holdings_view_model.dart';
import 'package:finality/features/assets/holdings/widgets/holdings_header.dart';
import 'package:finality/features/assets/holdings/widgets/holdings_top_bar.dart';
import 'package:finality/features/assets/receive/receive_bottom_sheet.dart';
import 'package:finality/features/assets/transfer/transfer_builder_sheet.dart';
import 'package:finality/features/main/v1/main_v1_controller.dart';
import 'package:finality/features/positions/v1/history_postions_page.dart';
import 'package:finality/features/positions/v1/opened_positions_list.dart';
import 'package:finality/features/positions/v1/trading_history_recent_list.dart';
import 'package:finality/features/positions/v1/widgets/empty_opened_positions.dart';
import 'package:finality/routes/app_pages.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:store_scope/store_scope.dart';


class HoldingsPage extends StatelessWidget with ScopedStatelessMixin {
  HoldingsPage({super.key});
  final ValueListenable<bool> amountVisibleNotifier =
      injector<AppPreferences>().amountVisibleNotifier;

  @override
  Widget buildScoped(BuildContext context, Listenable scope) {
    var viewModel = context.store.bindWith(holdingsViewModelProvider, scope);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        titleSpacing: 0,
        title: HoldingTopBar(
          onTap: () {},
          onTransactionsTap: () {
            Get.toNamed(Routes.transactions);
          },
          onSettingsTap: () {
            Get.toNamed(Routes.settings);
          },
          onWalletLongPress: (itemContext) {},
          onPasteText: (text) {},
        ),
      ),
      body: _buildPageBody(context, viewModel),
    );
  }

  Widget _buildPageBody(BuildContext context, HoldingsViewModel viewModel) {
    return EasyRefresh(
      controller: viewModel.refreshController,
      onRefresh: () async {
        await viewModel.refreshData();
      },
      child: CustomScrollView(
        controller: viewModel.scrollController,
        slivers: [
          SliverToBoxAdapter(
              child: HoldingsHeader(
            totalAssetValue: viewModel.totalAssetValueNotifier,
            onReceivePressed: () async {
              showReceiveBottomSheet(context, token: Tokens.usdc);
              //injector<WalletAuthManager>().loginWallet(viewModel.walletAccounts.value!);
            },
            onSendPressed: () {
              showSendBuilderSheet(context, token: Tokens.usdc);
            },
            onReclaimPressed: () {
              //showAccountRecoverySheet(context);
              triggerAirdrop(context, viewModel);
            },
          )),
          // SliverToBoxAdapter(child: _buildCashTokenSection(context, viewModel)),
          SliverToBoxAdapter(
              child: _buildOpenedPositionsSection(context, viewModel)),
          OpenedPositionsSliverList(
            emptyWidget: EmptyOpenedPositions(
              onGoToTrade: () {
                if (Get.isRegistered<MainV1Controller>()) {
                  Get.find<MainV1Controller>().goToTrade();
                }
              },
            ),
            onItemTap: (position) {
              if (Get.isRegistered<MainV1Controller>()) {
                Get.find<MainV1Controller>().goToTrade();
              }
            },
          ),
          SliverToBoxAdapter(
            child: TradingHistoryRecentList(
              onViewAllTap: () {
                Get.to(() => HistoryPostionsPage());
              },
            ),
          ),
          SliverToBoxAdapter(
            child: Dimens.vGap32,
          ),
        ],
      ),
    );
  }

  Widget _buildOpenedPositionsSection(
      BuildContext context, HoldingsViewModel viewModel) {
    return ValueListenableBuilder2(
        first: viewModel.totalPendingPositionAssetValue,
        second: viewModel.fetchHoldingsUiState,
        builder: (context, totalPendingPositionAssetValue, uiState, child) {
          return Container(
            height: 56,
            padding: const EdgeInsets.only(left: 16),
            child: Center(
              child: Baseline(
                baseline: 18,
                baselineType: TextBaseline.alphabetic,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      context.strings.title_active_trades,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    // Dimens.hGap12,
                    // Expanded(
                    //   child: Skeletonizer(
                    //     enabled: isLoading,
                    //     child: ValueListenableBuilder(
                    //         valueListenable: amountVisibleNotifier,
                    //         builder: (context, value, child) {
                    //           return Text(
                    //             value
                    //                 ? totalPendingPositionAssetValue
                    //                     .formatPrice()
                    //                     .withUsdSymbol()
                    //                 : "******",
                    //             style: TextStyle(
                    //               color:
                    //                   context.textColorTheme.textColorSecondary,
                    //               fontSize: 14,
                    //               fontWeight: FontWeight.w500,
                    //             ),
                    //           );
                    //         }),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          );
        });
  }


  void toTokenDetail(Token token, int precision) async {}


  void triggerAirdrop(BuildContext context, HoldingsViewModel viewModel) async {
    try {
      EasyLoading.show(status: "Triggering airdrop...");
      await viewModel.triggerAirdrop();
      EasyLoading.dismiss();
      AppToastManager.showSuccess(
        title: 'Airdrop successfully',
        subtitle: 'You have received 100 USDC',
      );
    } catch (e, stackTrace) {
      logger.e(e, stackTrace: stackTrace);
      EasyLoading.dismiss();
      AppToastManager.showFailed(
        title: 'Airdrop failed',
        subtitle: 'Please try again later',
      );
    }
  }
}
