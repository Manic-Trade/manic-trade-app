import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:finality/core/error/exception_handler.dart';
import 'package:finality/core/logger.dart';

import 'easy_refresh_footer.dart';
import 'empty_view.dart';
import 'error_view.dart';
import 'loading_view.dart';

abstract class PagePaging<T> extends StatefulWidget {
  final bool keepAlive;
  final PagePagingController? pageController;
  final ScrollController? scrollController;
  final ScrollPhysics? physics;

  const PagePaging(
      {super.key,
      this.keepAlive = true,
      this.pageController,
      this.scrollController,
      this.physics});

  @override
  PagePagingState<PagePaging, T> createState();
}

abstract class PagePagingState<V extends PagePaging, T> extends State<V>
    with AutomaticKeepAliveClientMixin {
  final refreshController = EasyRefreshController();

  List<T> _items = [];

  List<T> get items => _items;

  int get itemCount => _items.length;

  // 是否还有更多数据
  bool _hasMoreData = false;
  bool _afterInitialHasMore = false;

  // 是否正在初始化
  bool _isInitializing = true;

  // 是否初始化失败
  Object? _initializationError;

  // 是否正在刷新
  bool _isRefreshing = false;

  bool get canLoadMore =>
      _hasMoreData &&
      !_isRefreshing &&
      !_isInitializing &&
      _initializationError == null;

  Future<void> loadInitial(bool isRefresh) async {
    if (isRefresh) {
      _isRefreshing = true;
      _updateTree();
    } else {
      if (!_isInitializing) {
        _isInitializing = true;
        _initializationError = null;
        _hasMoreData = false;
        _updateTree();
      }
    }
    try {
      List<T> newItems = await doLoadInitial(isRefresh);
      _items = newItems;
      _hasMoreData = moreDataAfterLoadInitial(newItems);
      _afterInitialHasMore = _hasMoreData;
      if (isRefresh) {
        _isRefreshing = false;
      } else {
        _initializationError = null;
        _isInitializing = false;
      }
      _updateTree();
    } catch (error, stackTrace) {
      logger.e("loadInitial($isRefresh)", error: error, stackTrace: stackTrace);
      if (isRefresh) {
        _isRefreshing = false;
        handleRefreshError(error);
      } else {
        _hasMoreData = false;
        _initializationError = error;
        _isInitializing = false;
        _updateTree();
      }
    }
  }

  void updateInitialData(List<T> data) {
    _items = data;
    _hasMoreData = moreDataAfterLoadInitial(data);
    _afterInitialHasMore = _hasMoreData;
    _updateTree();
  }

  Future<List<T>> doLoadInitial(bool isRefresh);

  //加载失败状态由外部处理，内部不处理
  Future loadMore() async {
    if (canLoadMore) {
      var moreData = await doLoadMore();
      _hasMoreData = moreDataAfterLoadMore(moreData);
      _items.addAll(moreData);
      _updateTree();
      if (_hasMoreData) {
        return IndicatorResult.success;
      } else {
        return IndicatorResult.noMore;
      }
    }
    return IndicatorResult.noMore;
  }

  Future<List<T>> doLoadMore();

  //判断初始化后是否还能加载更多
  bool moreDataAfterLoadInitial(List<T> initialData);

  //判断初始化后是否还能加载更多
  bool moreDataAfterLoadMore(List<T> moreData);

  Widget buildErrorWidget(
      BuildContext context, Object error, Function() retry) {
    var header = buildHeader(context);
    if (header == null) {
      return ErrorView(
          onRetry: retry, message: ErrorHandler.getMessage(context, error));
    } else {
      return Column(
        children: [
          header,
          Expanded(
              child: ErrorView(
                  onRetry: retry,
                  message: ErrorHandler.getMessage(context, error))),
        ],
      );
    }
  }

  Widget buildEmptyWidget(BuildContext context) {
    return const EmptyView(center: true);
  }

  Widget buildLoadingWidget(BuildContext context) {
    var header = buildHeader(context);
    if (header == null) {
      return const LoadingView();
    } else {
      return Column(
        children: [
          header,
          const Expanded(child: LoadingView()),
        ],
      );
    }
  }

  void handleRefreshError(Object error) {
    if (mounted) {
      Fluttertoast.showToast(msg: ErrorHandler.getMessage(context, error));
    }
  }

  /// Build scroll view.
  Widget _internalBuildScrollView(BuildContext context) {
    var header = buildHeader(context);
    if (itemCount == 0 && enableEmpty) {
      return CustomScrollView(
        physics: widget.physics,
        slivers: [
          SliverFillViewport(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (header == null) {
                  return buildEmptyWidget(context);
                } else {
                  return Column(
                    children: [
                      header,
                      Expanded(child: buildEmptyWidget(context)),
                    ],
                  );
                }
              },
              childCount: 1,
            ),
          )
        ],
      );
    }
    return buildScrollView(context, widget.scrollController, header);
  }

  Widget buildScrollView(
      BuildContext context, ScrollController? scrollController, Widget? header);

  Widget? buildHeader(BuildContext context) {
    return null;
  }

  bool get enableEmpty => true;

  /// Enable refresh.
  bool get enableRefresh => true;

  /// Enable load.
  bool get enableLoadMore => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return buildFrame(context, _buildPaging(context));
  }

  Widget buildFrame(BuildContext context, Widget child) {
    return child;
  }

  Widget _buildPaging(BuildContext context) {
    if (_initializationError != null) {
      return buildErrorWidget(context, _initializationError!, () {
        loadInitial(false);
      });
    } else if (_isInitializing) {
      return buildLoadingWidget(context);
    }
    return EasyRefresh(
      notLoadFooter: const NotLoadFooter(clamping: true),
      footer: ListRefreshFooter(position: footerPosition()),
      onRefresh: enableRefresh
          ? () async {
              return await loadInitial(true);
            }
          : null,
      onLoad: enableLoadMore && itemCount > 0 && _afterInitialHasMore
          ? loadMore
          : null,
      controller: refreshController,
      refreshOnStart: false,
      child: _internalBuildScrollView(context),
    );
  }

  IndicatorPosition footerPosition() {
    return IndicatorPosition.above;
  }

  @override
  bool get wantKeepAlive => widget.keepAlive;

  void _updateTree() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    widget.pageController?._bind(this);
  }

  Future<void> callRefresh() async {
    await refreshController.callRefresh();
  }

  @override
  void didUpdateWidget(covariant V oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update controller.
    if (widget.pageController != null &&
        oldWidget.pageController != widget.pageController) {
      widget.pageController?._bind(this);
    }
  }
}

class PagePagingController {
  PagePagingState? _state;

  void _bind(PagePagingState state) {
    _state = state;
  }

  Future loadMore() async {
    return await _state?.loadMore();
  }

  Future<void> refresh() async {
    await _state?.callRefresh();
  }

  Future<void> refreshData() async {
    await _state?.loadInitial(true);
  }

  bool get enableLoadMore => _state?.enableLoadMore == true;

  /// Unbind.
  void dispose() {
    _state = null;
  }
}
