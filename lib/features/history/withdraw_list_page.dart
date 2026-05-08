import 'package:finality/common/constants/blockchain.dart';
import 'package:finality/common/utils/block_explorer_utils.dart';
import 'package:finality/common/utils/color_scheme_extensions.dart';
import 'package:finality/common/widgets/error_view.dart';
import 'package:finality/common/widgets/page_list.dart';
import 'package:finality/core/error/exception_handler.dart';
import 'package:finality/data/network/manic_trade_data_source.dart';
import 'package:finality/data/network/model/manic/withdraw_item.dart';
import 'package:finality/di/injector.dart';
import 'package:finality/features/history/model/withdraw_history_item_vo.dart';
import 'package:finality/features/history/widgets/empty_history_items.dart';
import 'package:finality/features/history/widgets/withdraw_item_widget.dart';
import 'package:flutter/material.dart';

class WithdrawListPage extends PageList<WithdrawItem> {
  const WithdrawListPage({super.key});

  @override
  PagePagingState<PageList, WithdrawItem> createState() {
    return _WithdrawListPageState();
  }
}

class _WithdrawListPageState
    extends PageListState<WithdrawListPage, WithdrawItem> {
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
      itemBuilder: (context, index) => WithdrawItemWidget(
        vo: WithdrawHistoryItemVO.placeholder(),
        isLoading: true,
      ),
    );
  }

  @override
  Widget buildEmptyWidget(BuildContext context) {
    return const EmptyHistoryItems(message: 'No withdraws found');
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
  Widget buildItem(BuildContext context, int index, WithdrawItem item) {
    return WithdrawItemWidget(
      vo: WithdrawHistoryItemVO.fromWithdrawItem(item),
      onTxHashTap: () {
        var signature = item.signature;
        if (signature != null) {
          final url = Networks.solana.links?.formatTXUrl(signature);
          if (url != null) {
            BlockExplorerUtils.viewTransaction(url);
          }
        }
      },
    );
  }

  @override
  Widget buildFrame(BuildContext context, Widget child) {
    return child;
  }

  @override
  Future<List<WithdrawItem>> doLoadInitial(bool isRefresh) async {
    if (isRefresh) {
      _currentPage = 1;
      _hasMore = true;
    }
    final response = await _dataSource.getWithdraws(
      page: _currentPage,
      limit: _pageSize,
    );
    return response.nodes;
  }

  @override
  Future<List<WithdrawItem>> doLoadMore() async {
    if (!_hasMore) return [];
    _currentPage++;
    final response = await _dataSource.getWithdraws(
      page: _currentPage,
      limit: _pageSize,
    );
    return response.nodes;
  }

  @override
  bool moreDataAfterLoadInitial(List<WithdrawItem> initialData) {
    _hasMore = initialData.length >= _pageSize;
    return _hasMore;
  }

  @override
  bool moreDataAfterLoadMore(List<WithdrawItem> moreData) {
    _hasMore = moreData.length >= _pageSize;
    return _hasMore;
  }
}
