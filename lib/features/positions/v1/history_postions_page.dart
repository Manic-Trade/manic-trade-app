import 'dart:async';

import 'package:finality/common/utils/localization_extensions.dart';
import 'package:finality/common/utils/value_listenable_removable.dart';
import 'package:finality/common/widgets/empty_view.dart';
import 'package:finality/common/widgets/page_list.dart';
import 'package:finality/data/drift/options_database.dart';
import 'package:finality/data/network/model/manic/position_history_item.dart';
import 'package:finality/features/activity/widgets/transaction_list_date_header.dart';
import 'package:finality/features/activity/widgets/transaction_sliver_loading.dart';
import 'package:finality/features/highlow/trading_pairs/vm/options_trading_pairs_vm.dart';
import 'package:finality/features/positions/model/history_position_vo.dart';
import 'package:finality/features/positions/v1/widgets/history_list_item.dart';
import 'package:finality/features/positions/vm/trading_history_vm.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_scope/store_scope.dart';

import '../../activity/position_history_detail_screen.dart';

/// 交易历史页面
/// 显示全部已结算的交易记录，支持分页加载和时间分组
class HistoryPostionsPage extends PageList<PositionHistoryItem> {
  const HistoryPostionsPage({super.key});

  @override
  PagePagingState<PageList, PositionHistoryItem> createState() {
    return _TradingHistoryPageState();
  }
}

class _TradingHistoryPageState
    extends PageListState<HistoryPostionsPage, PositionHistoryItem>
    with ScopedSpaceStateMixin {
  late final TradingHistoryVM _viewModel;
  late final OptionsTradingPairsVM _optionsTradingPairsVM;

  final Map<String, ValueNotifier<OptionsTradingPair?>> _currentTradingPair =
      {};

  Removable? _tradingPairsStateRemovable;
  StreamSubscription? _refreshSubscription;

  @override
  void initState() {
    super.initState();
    _viewModel = space.bind(tradingHistoryVMProvider);
    _optionsTradingPairsVM = space.bind(optionsTradingPairsVMProvider);
    _tradingPairsStateRemovable =
        _optionsTradingPairsVM.tradingPairsState.listen((tradingPairsState) {
      tradingPairsState.valueOrFallback?.forEach((element) {
        getCurrentTradingPair(element.raw.pair.baseAsset).value =
            element.raw.pair;
      });
    }, immediate: true);
    _refreshSubscription = _viewModel.onRefresh.listen((_) {
      loadInitial(true);
    });
    loadInitial(false);
  }

  @override
  void dispose() {
    _tradingPairsStateRemovable?.remove();
    _refreshSubscription?.cancel();
    super.dispose();
  }

  ValueNotifier<OptionsTradingPair?> getCurrentTradingPair(String asset) {
    var notifier = _currentTradingPair[asset];
    if (notifier == null) {
      notifier = ValueNotifier(null);
      _currentTradingPair[asset] = notifier;
    }
    return notifier;
  }

  @override
  Widget buildLoadingWidget(BuildContext context) {
    return const TransactionSliverLoading();
  }

  @override
  Widget buildEmptyWidget(BuildContext context) {
    return const EmptyView(center: true);
  }

  // @override
  // Widget buildItem(BuildContext context, int index, PositionHistoryItem item) {
  //   var outlineVariant = context.colorScheme.outlineVariant;
  //   return Column(
  //     children: [
  //       HistoryListItem(
  //         item: HistoryPositionVO.fromPositionHistoryItem(
  //             item, getCurrentTradingPair(item.asset)),
  //         onTap: () {
  //           Get.to(() => PositionHistoryDetailScreen(item: item));
  //         },
  //       ),
  //       Divider(height: 0.5, thickness: 0.5, color: outlineVariant),
  //     ],
  //   );
  // }

  @override
  Widget buildItem(BuildContext context, int index, PositionHistoryItem item) {
    final showDateHeader = _shouldShowDateHeader(index);

    final itemWidget = HistoryListItem(
      item: HistoryPositionVO.fromPositionHistoryItem(
          item, getCurrentTradingPair(item.asset)),
      onTap: () {
        Get.to(() => PositionHistoryDetailScreen(item: item));
      },
    );

    if (showDateHeader) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TransactionListDateHeader(
            dateTime: _getItemDateTime(item),
            showDivider: index != 0,
          ),
          itemWidget,
        ],
      );
    }
    return itemWidget;
  }

  @override
  Widget buildFrame(BuildContext context, Widget child) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.strings.title_trading_history),
      ),
      body: SafeArea(child: child),
    );
  }

  /// 获取 item 的时间
  DateTime _getItemDateTime(PositionHistoryItem item) {
    return DateTime.fromMillisecondsSinceEpoch(item.endTime * 1000).toLocal();
  }

  /// 判断是否需要显示日期头
  bool _shouldShowDateHeader(int index) {
    if (index == 0) return true;
    final currentItem = items[index];
    final previousItem = items[index - 1];
    return !_isSameDay(currentItem, previousItem);
  }

  /// 判断两个 item 是否在同一天
  bool _isSameDay(PositionHistoryItem a, PositionHistoryItem b) {
    final dateA = _getItemDateTime(a);
    final dateB = _getItemDateTime(b);
    return dateA.year == dateB.year &&
        dateA.month == dateB.month &&
        dateA.day == dateB.day;
  }

  @override
  Future<List<PositionHistoryItem>> doLoadInitial(bool isRefresh) async {
    return _viewModel.loadInitial(isRefresh);
  }

  @override
  Future<List<PositionHistoryItem>> doLoadMore() async {
    return _viewModel.loadMore();
  }

  @override
  bool moreDataAfterLoadInitial(List<PositionHistoryItem> initialData) {
    return !_viewModel.isTheEnd;
  }

  @override
  bool moreDataAfterLoadMore(List<PositionHistoryItem> moreData) {
    return !_viewModel.isTheEnd;
  }
}
