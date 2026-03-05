import 'package:finality/common/utils/block_explorer_utils.dart';
import 'package:finality/common/utils/localization_extensions.dart';
import 'package:finality/common/widgets/empty_view.dart';
import 'package:finality/common/widgets/page_list.dart';
import 'package:finality/di/injector.dart';
import 'package:finality/features/activity/model/activity_item.dart';
import 'package:finality/features/activity/vm/activity_vm.dart';
import 'package:finality/features/activity/widgets/activity_list_item_widget.dart';
import 'package:finality/features/activity/widgets/transaction_list_date_header.dart';
import 'package:finality/features/activity/widgets/transaction_sliver_loading.dart';
import 'package:finality/features/activity/deposit_detail_screen.dart';
import 'package:finality/features/activity/position_history_detail_screen.dart';
import 'package:finality/features/activity/withdraw_detail_screen.dart';
import 'package:finality/services/wallet/wallet_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_scope/store_scope.dart';

class ActivityScreen extends PageList<ActivityItem> {
  const ActivityScreen({super.key});

  @override
  PagePagingState<PageList, ActivityItem> createState() {
    return _ActivityScreenState();
  }
}

class _ActivityScreenState extends PageListState<ActivityScreen, ActivityItem>
    with ScopedSpaceStateMixin {
  late final ActivityVM _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = space.bind(activityVMProvider);
    loadInitial(false);
  }

  @override
  Widget buildLoadingWidget(BuildContext context) {
    return const TransactionSliverLoading();
  }

  @override
  Widget buildEmptyWidget(BuildContext context) {
    return const EmptyView(center: true);
  }

  @override
  Widget buildItem(BuildContext context, int index, ActivityItem item) {
    final showDateHeader = _shouldShowDateHeader(index);

    void onItemTap() {
      switch (item) {
        case OpenPositionActivityItem i:
          Get.to(() => PositionHistoryDetailScreen(item: i.raw));
          break;
        case SettlePositionActivityItem i:
          Get.to(() => PositionHistoryDetailScreen(item: i.raw));
          break;
        case DepositActivityItem i:
          Get.to(() => DepositDetailScreen(item: i.raw));
          break;
        case WithdrawActivityItem i:
          Get.to(() => WithdrawDetailScreen(item: i.raw));
          break;
      }
    }

    final itemWidget = ActivityListItemWidget(
      item: item,
      onTap: onItemTap,
      key: Key(item.id),
    );

    if (showDateHeader) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TransactionListDateHeader(
            dateTime: item.time,
            showDivider: index != 0,
          ),
          itemWidget,
        ],
      );
    }
    return itemWidget;
  }

  bool _shouldShowDateHeader(int index) {
    if (index == 0) return true;
    final currentItem = items[index];
    final previousItem = items[index - 1];
    return !currentItem.isSameDay(previousItem);
  }

  @override
  Widget buildFrame(BuildContext context, Widget child) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.strings.title_transactions),
        actions: [
          IconButton(
            onPressed: () {
              var solanaAccount = injector<WalletService>().getSolanaAccount();
              if (solanaAccount != null) {
                BlockExplorerUtils.viewSolanaAccountDefi(solanaAccount.address);
              }
            },
            icon: Icon(Icons.travel_explore_rounded),
          ),
        ],
      ),
      body: SafeArea(child: child),
    );
  }

  @override
  Future<List<ActivityItem>> doLoadInitial(bool isRefresh) async {
    return _viewModel.loadInitial(isRefresh);
  }

  @override
  Future<List<ActivityItem>> doLoadMore() async {
    return _viewModel.loadMore();
  }

  @override
  bool moreDataAfterLoadInitial(List<ActivityItem> initialData) {
    return !_viewModel.isTheEnd;
  }

  @override
  bool moreDataAfterLoadMore(List<ActivityItem> moreData) {
    return !_viewModel.isTheEnd;
  }
}
