import 'dart:async';

import 'package:finality/common/utils/value_listenable_removable.dart';
import 'package:finality/common/widgets/empty_view.dart';
import 'package:finality/common/widgets/page_list.dart';
import 'package:finality/core/error/exception_handler.dart';
import 'package:finality/data/drift/entities/options_trading_pair.dart';
import 'package:finality/data/network/model/manic/position_history_item.dart';
import 'package:finality/features/analysis/analysis_screen.dart';
import 'package:finality/features/highlow/trading_pairs/vm/options_trading_pairs_vm.dart';
import 'package:finality/features/positions/details/settled_position_details_sheet.dart';
import 'package:finality/features/positions/item_widgets/settled_position_list_item.dart';
import 'package:finality/features/positions/item_widgets/settled_postion_date_item.dart';
import 'package:finality/features/positions/model/history_position_vo.dart';
import 'package:finality/features/positions/vm/trading_history_vm.dart';
import 'package:finality/features/positions/widgets/error_settled_positions.dart';
import 'package:finality/theme/attrs/druk_wide_font.dart';
import 'package:finality/theme/attrs/text_color_theme.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:store_scope/store_scope.dart';

/// 全部已结算仓位页面（分页列表）
///
/// 设计稿：顶部 AppBar "TRADING HISTORY"，列表使用 SettledPositionListItem 卡片
class SettledPositionsScreen extends PageList<PositionHistoryItem> {
  const SettledPositionsScreen({super.key, this.isAgent = false});

  final bool isAgent;

  @override
  PagePagingState<PageList, PositionHistoryItem> createState() {
    return _SettledPositionsScreenState();
  }
}

class _SettledPositionsScreenState
    extends PageListState<SettledPositionsScreen, PositionHistoryItem>
    with ScopedSpaceStateMixin {
  late final TradingHistoryVM _viewModel;
  late final OptionsTradingPairsVM _optionsTradingPairsVM;

  final Map<String, ValueNotifier<OptionsTradingPair?>> _tradingPairNotifiers =
      {};
  Removable? _tradingPairsRemovable;
  StreamSubscription? _refreshSubscription;

  @override
  void initState() {
    super.initState();
    _viewModel = space.bind(
      widget.isAgent ? agentTradingHistoryVMProvider : tradingHistoryVMProvider,
    );
    _optionsTradingPairsVM = space.bind(optionsTradingPairsVMProvider);

    _tradingPairsRemovable =
        _optionsTradingPairsVM.tradingPairsState.listen((state) {
      state.valueOrFallback?.forEach((element) {
        _getTradingPairNotifier(element.raw.pair.baseAsset).value =
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
    _tradingPairsRemovable?.remove();
    _refreshSubscription?.cancel();
    super.dispose();
  }

  ValueNotifier<OptionsTradingPair?> _getTradingPairNotifier(String asset) {
    return _tradingPairNotifiers.putIfAbsent(
      asset,
      () => ValueNotifier(null),
    );
  }

  @override
  Widget buildFrame(BuildContext context, Widget child) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'TRADING HISTORY',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: context.textColorTheme.textColorPrimary,
            letterSpacing: 0.5,
          ).toDrukWide(),
        ),
        actions: widget.isAgent
            ? []
            : [
                IconButton(
                  onPressed: () {
                    Get.to(() => const AnalysisScreen());
                  },
                  icon: Icon(
                    RemixIcons.pie_chart_line,
                    size: 21,
                  ),
                ),
              ],
      ),
      body: child,
    );
  }

  @override
  Widget buildLoadingWidget(BuildContext context) {
    return Skeletonizer(
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 10,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (index == 0)
                  SettledPositionDateItem(
                    dateTime: DateTime.now(),
                    isFirst: true,
                  ),
                SettledPositionListItem(
                  item: HistoryPositionVO.placeholder(),
                  isLoading: true,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget buildEmptyWidget(BuildContext context) {
    return const EmptyView(center: true);
  }

  @override
  Widget buildErrorWidget(
      BuildContext context, Object error, Function() retry) {
    return Center(
      child: Padding(
        padding: Dimens.edgeInsetsH16,
        child: ErrorSettledPositions(
          message: ErrorHandler.getMessage(context, error),
          onRetry: retry,
        ),
      ),
    );
  }

  @override
  Widget buildItem(BuildContext context, int index, PositionHistoryItem item) {
    final vo = HistoryPositionVO.fromPositionHistoryItem(
      item,
      _getTradingPairNotifier(item.asset),
    );
    final showDateHeader = _shouldShowDateHeader(index);
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 0,
        bottom: 8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showDateHeader)
            SettledPositionDateItem(
              dateTime: _getItemDateTime(item),
              isFirst: index == 0,
            ),
          SettledPositionListItem(
            item: vo,
            onTap: () => showSettledPositionDetailsSheet(context,
                item: vo, isAgent: widget.isAgent),
          ),
        ],
      ),
    );
  }

  /// 获取 item 的结算时间
  DateTime _getItemDateTime(PositionHistoryItem item) {
    return DateTime.fromMillisecondsSinceEpoch(item.endTime * 1000).toLocal();
  }

  /// 判断是否需要显示日期头
  bool _shouldShowDateHeader(int index) {
    if (index == 0) return true;
    final currentItem = items[index];
    final previousItem = items[index - 1];
    final dateA = _getItemDateTime(currentItem);
    final dateB = _getItemDateTime(previousItem);
    return dateA.year != dateB.year ||
        dateA.month != dateB.month ||
        dateA.day != dateB.day;
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
