import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:finality/common/widgets/page_paging.dart';

export 'page_paging.dart';

abstract class PageList<T> extends PagePaging<T> {
  final EdgeInsetsGeometry? padding;

  const PageList(
      {this.padding,
      super.scrollController,
      super.physics,
      super.key,
      super.keepAlive,
      super.pageController});

  @override
  PagePagingState<PageList, T> createState();
}

abstract class PageListState<V extends PageList, T>
    extends PagePagingState<V, T> {
  @override
  Widget buildScrollView(BuildContext context,
      ScrollController? scrollController, Widget? header) {
    return CustomScrollView(
      controller: scrollController,
      slivers: [
        SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
          if (header == null) {
            return buildItem(context, index, items[index]);
          } else {
            if (index == 0) {
              return header;
            } else {
              return buildItem(context, index, items[index - 1]);
            }
          }
        }, childCount: header == null ? itemCount : itemCount + 1)),
        const FooterLocator.sliver(),
      ],
    );
  }

  @override
  IndicatorPosition footerPosition() {
    return IndicatorPosition.locator;
  }

  Widget buildSeparator(BuildContext context, int index) {
    return const Divider();
  }

  Widget buildItem(BuildContext context, int index, T item);
}
