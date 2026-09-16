import 'package:finality/common/constants/blockchain.dart';
import 'package:finality/common/utils/block_explorer_utils.dart';
import 'package:finality/common/utils/color_scheme_extensions.dart';
import 'package:finality/common/widgets/error_view.dart';
import 'package:finality/common/widgets/page_list.dart';
import 'package:finality/core/error/exception_handler.dart';
import 'package:finality/data/network/manic_trade_data_source.dart';
import 'package:finality/data/network/model/manic/deposit_item.dart';
import 'package:finality/di/injector.dart';
import 'package:finality/features/history/model/deposit_history_item_vo.dart';
import 'package:finality/features/history/widgets/deposit_item_widget.dart';
import 'package:finality/features/history/widgets/empty_history_items.dart';
import 'package:flutter/material.dart';

class DepositListPage extends PageList<DepositItem> {
  const DepositListPage({super.key});

  @override
  PagePagingState<PageList, DepositItem> createState() {
    return _DepositListPageState();
  }
}

class _DepositListPageState
    extends PageListState<DepositListPage, DepositItem> {
  final ManicTradeDataSource _dataSource = injector();
  int _currentPage = 1;
  static const int _pageSize = 20;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    loadInitial(false);
  }

  @override
  Widget buildLoadingWidget(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 6,
      itemBuilder: (context, index) => DepositItemWidget(
        vo: DepositHistoryItemVO.placeholder(),
        isLoading: true,
      ),
    );
  }

  @override
  Widget buildEmptyWidget(BuildContext context) {
    return const EmptyHistoryItems(message: 'No deposits found');
  }

  @override
  Widget buildErrorWidget(
      BuildContext context, Object error, Function() retry) {
    return ErrorView(
      onRetry: retry,
      message: ErrorHandler.getMessage(context, error),
      buttonBackgroundColor: context.colorScheme.surfaceContainerHighest,
    );
  }

  @override
  Widget buildItem(BuildContext context, int index, DepositItem item) {
    return DepositItemWidget(
      vo: DepositHistoryItemVO.fromDepositItem(item),
      onTxHashTap: () {
        final url = item.explorerUrl ??
            Networks.solana.links?.formatTXUrl(item.destHash);
        if (url != null) {
          BlockExplorerUtils.viewTransaction(url);
        }
      },
    );
  }

  @override
  Widget buildFrame(BuildContext context, Widget child) {
    return child;
  }

  @override
  Future<List<DepositItem>> doLoadInitial(bool isRefresh) async {
    if (isRefresh) {
      _currentPage = 1;
      _hasMore = true;
    }
    final response = await _dataSource.getDeposits(
      page: _currentPage,
      limit: _pageSize,
    );
    return response.nodes;
  }

  @override
  Future<List<DepositItem>> doLoadMore() async {
    if (!_hasMore) return [];
    _currentPage++;
    final response = await _dataSource.getDeposits(
      page: _currentPage,
      limit: _pageSize,
    );
    return response.nodes;
  }

  @override
  bool moreDataAfterLoadInitial(List<DepositItem> initialData) {
    _hasMore = initialData.length >= _pageSize;
    return _hasMore;
  }

  @override
  bool moreDataAfterLoadMore(List<DepositItem> moreData) {
    _hasMore = moreData.length >= _pageSize;
    return _hasMore;
  }
}
