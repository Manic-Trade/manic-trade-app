import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:finality/core/error/exception_handler.dart';
import 'package:finality/core/logger.dart';

import 'empty_view.dart';
import 'error_view.dart';
import 'loading_view.dart';

abstract class NestedTabPageSliverPaging<T> extends StatefulWidget {
  final bool keepAlive;
  final ScrollPhysics? physics;
  final NestedTabPageSliverController? controller;

  const NestedTabPageSliverPaging(
      {super.key, this.keepAlive = true, this.physics, this.controller});

  @override
  NestedTabPageSliverPagingState<NestedTabPageSliverPaging, T> createState();
}

abstract class NestedTabPageSliverPagingState<
    V extends NestedTabPageSliverPaging,
    T> extends State<V> with AutomaticKeepAliveClientMixin {
  List<T> _items = [];

  List<T> get items => _items;

  int get itemCount => _items.length;

  // 是否还有更多数据
  bool _hasMoreData = false;

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
    } else {
      _hasMoreData = false;
      _isInitializing = true;
      _initializationError = null;
    }
    _updateTree();
    try {
      List<T> newItems = await doLoadInitial(isRefresh);
      _items = newItems;
      _hasMoreData = moreDataAfterLoadInitial(newItems);
      if (isRefresh) {
        _isRefreshing = false;
      } else {
        _initializationError = null;
        _isInitializing = false;
      }
      _updateTree();
    } catch (error) {
      logger.e("loadInitial($isRefresh)", error: error);
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

  Widget buildEmptyWidget() {
    return const EmptyView();
  }

  Widget buildLoadingWidget() {
    return const LoadingView();
  }

  Widget buildErrorWidget(Object error, Function() retry) {
    return ErrorView(
        onRetry: retry, message: ErrorHandler.getMessage(context, error));
  }

  void handleRefreshError(Object error) {
    Fluttertoast.showToast(msg: ErrorHandler.getMessage(context, error));
  }

  /// Build sliver.
  List<Widget> buildSlivers(List<T> items);

  /// Build slivers.
  List<Widget> _internalBuildSlivers() {
    if (itemCount == 0) {
      return [
        SliverFillViewport(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return buildEmptyWidget();
            },
            childCount: 1,
          ),
        )
      ];
    } else {
      return buildSlivers(items);
    }
  }

  /// Build scroll view.
  Widget _buildScrollView(ScrollPhysics? physics) {
    return CustomScrollView(
      physics: physics,
      slivers: _internalBuildSlivers(),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_initializationError != null) {
      return buildErrorWidget(_initializationError!, () {
        loadInitial(false);
      });
    } else if (_isInitializing) {
      return buildLoadingWidget();
    }
    return _buildScrollView(widget.physics);
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
    widget.controller?._bind(this);
  }

  @override
  void didUpdateWidget(covariant V oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update controller.
    if (widget.controller != null &&
        oldWidget.controller != widget.controller) {
      widget.controller?._bind(this);
    }
  }

  @override
  void dispose() {
    super.dispose();
    widget.controller?.dispose();
  }
}

class NestedTabPageSliverController {
  NestedTabPageSliverPagingState? _state;

  void _bind(NestedTabPageSliverPagingState state) {
    _state = state;
  }

  Future loadMore() async {
    return await _state?.loadMore();
  }

  Future<void> refresh() async {
    await _state?.loadInitial(true);
  }

  /// Unbind.
  void dispose() {
    _state = null;
  }
}
