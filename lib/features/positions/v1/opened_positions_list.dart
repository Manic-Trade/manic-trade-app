import 'package:finality/common/utils/decimal_format.dart';
import 'package:finality/core/notifier/multi_value_listenable_builder.dart';
import 'package:finality/domain/options/entities/opened_position.dart';
import 'package:finality/features/positions/v1/widgets/game_status_list_item.dart';
import 'package:finality/features/positions/vm/opened_positions_vm.dart';
import 'package:finality/theme/app_color_theme.dart';
import 'package:finality/theme/attrs/text_color_theme.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/material.dart';
import 'package:store_scope/store_scope.dart';

/// 已开仓位列表组件
///
/// 这是一个独立的可复用组件，内部管理了 [OpenedPositionsVM] 的生命周期。
/// 可以在任何需要显示持仓列表的地方使用。
///
/// 使用示例：
/// ```dart
/// // 在 CustomScrollView 中使用（作为 Sliver）
/// CustomScrollView(
///   slivers: [
///     OpenedPositionsSliverList(),
///   ],
/// )
///
/// // 或者使用普通的 ListView 版本
/// OpenedPositionsListView()
/// ```
class OpenedPositionsSliverList extends StatefulWidget {
  /// 列表的水平内边距
  final double horizontalPadding;

  /// 列表的垂直内边距
  final double verticalPadding;

  /// 列表项之间的间距
  final double itemSpacing;

  /// 列表为空时显示的组件（默认为空）
  final Widget? emptyWidget;

  /// 点击列表项时的回调
  final void Function(OpenedPosition position)? onItemTap;

  const OpenedPositionsSliverList({
    super.key,
    this.horizontalPadding = 16,
    this.verticalPadding = 8,
    this.itemSpacing = 12,
    this.emptyWidget,
    this.onItemTap,
  });

  @override
  State<OpenedPositionsSliverList> createState() =>
      _OpenedPositionsSliverListState();
}

class _OpenedPositionsSliverListState extends State<OpenedPositionsSliverList>
    with ScopedStateMixin {
  late final OpenedPositionsVM _gameStatusVM;

  @override
  void initState() {
    super.initState();
    _gameStatusVM =
        context.store.bindWithScoped(openedPositionsVMProvider, this);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<OpenedPosition>>(
      valueListenable: _gameStatusVM.openedPositions,
      builder: (context, openedPositions, child) {
        if (openedPositions.isEmpty) {
          return SliverToBoxAdapter(
            child: widget.emptyWidget ?? const SizedBox.shrink(),
          );
        }
        return SliverPadding(
          padding: EdgeInsets.symmetric(
            vertical: widget.verticalPadding,
          ),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                // index 0 = header
                if (index == 0) {
                  return _ActiveTradesHeader(
                    totalAmountNotifier:
                        _gameStatusVM.totalPendingPositionAssetValue,
                    totalEstPayoutNotifier: _gameStatusVM.totalEstPayout,
                  );
                }
                final posIndex = index - 1;
                final position = openedPositions[posIndex];
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: posIndex < openedPositions.length - 1
                        ? widget.itemSpacing
                        : 0,
                  ),
                  child: GameStatusListItem(
                    key: ValueKey(position.id),
                    position: position,
                    currentPriceNotifier: _gameStatusVM
                        .getPriceNotifier(position.tradingPair.baseAsset),
                    onTap: widget.onItemTap != null
                        ? () => widget.onItemTap!(position)
                        : null,
                  ),
                );
              },
              childCount: openedPositions.length + 1,
            ),
          ),
        );
      },
    );
  }
}

/// 已开仓位列表组件（ListView 版本）
///
/// 这是一个普通的 Widget（非 Sliver），适合在普通布局中使用。
/// 内部管理了 [OpenedPositionsVM] 的生命周期。
///
/// 使用示例：
/// ```dart
/// Column(
///   children: [
///     SomeHeader(),
///     Expanded(
///       child: OpenedPositionsListView(),
///     ),
///   ],
/// )
/// ```
class OpenedPositionsListView extends StatefulWidget {
  /// 列表的内边距
  final EdgeInsetsGeometry? padding;

  /// 列表项之间的间距
  final double itemSpacing;

  /// 列表为空时显示的组件（默认为空）
  final Widget? emptyWidget;

  /// 是否允许滚动（默认为 true）
  final bool shrinkWrap;

  /// 滚动物理效果
  final ScrollPhysics? physics;

  /// 点击列表项时的回调
  final void Function(OpenedPosition position)? onItemTap;

  const OpenedPositionsListView({
    super.key,
    this.padding,
    this.itemSpacing = 12,
    this.emptyWidget,
    this.shrinkWrap = false,
    this.physics,
    this.onItemTap,
  });

  @override
  State<OpenedPositionsListView> createState() =>
      _OpenedPositionsListViewState();
}

class _OpenedPositionsListViewState extends State<OpenedPositionsListView>
    with ScopedStateMixin {
  late final OpenedPositionsVM _gameStatusVM;

  @override
  void initState() {
    super.initState();
    _gameStatusVM =
        context.store.bindWithScoped(openedPositionsVMProvider, this);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<OpenedPosition>>(
      valueListenable: _gameStatusVM.openedPositions,
      builder: (context, openedPositions, child) {
        if (openedPositions.isEmpty) {
          return widget.emptyWidget ?? const SizedBox.shrink();
        }
        return ListView.separated(
          padding: widget.padding ??
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shrinkWrap: widget.shrinkWrap,
          physics: widget.physics,
          itemCount: openedPositions.length + 1,
          separatorBuilder: (context, index) =>
              SizedBox(height: widget.itemSpacing),
          itemBuilder: (context, index) {
            if (index == 0) {
              return _ActiveTradesHeader(
                totalAmountNotifier:
                    _gameStatusVM.totalPendingPositionAssetValue,
                totalEstPayoutNotifier: _gameStatusVM.totalEstPayout,
              );
            }
            final position = openedPositions[index - 1];
            return GameStatusListItem(
              position: position,
              currentPriceNotifier: _gameStatusVM
                  .getPriceNotifier(position.tradingPair.baseAsset),
              onTap: widget.onItemTap != null
                  ? () => widget.onItemTap!(position)
                  : null,
            );
          },
        );
      },
    );
  }
}

class _ActiveTradesHeader extends StatelessWidget {
  final ValueNotifier<double> totalAmountNotifier;
  final ValueNotifier<double> totalEstPayoutNotifier;

  const _ActiveTradesHeader({
    required this.totalAmountNotifier,
    required this.totalEstPayoutNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder2(
      first: totalAmountNotifier,
      second: totalEstPayoutNotifier,
      builder: (context, totalAmount, totalEstPayout, _) {
        final pnl = totalEstPayout;
        final isPositive = pnl >= 0;
        final pnlColor =
            isPositive ? context.appColors.bullish : context.appColors.bearish;
        final pnlDisplay = pnl.abs().formatWithDecimals(2);

        return Padding(
          padding: const EdgeInsets.only(bottom: 12, left: 16, right: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Invested',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: context.textColorTheme.textColorTertiary,
                    ),
                  ),
                  Dimens.vGap4,
                  Text(
                    '\$${totalAmount.formatWithDecimals(2)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: context.textColorTheme.textColorPrimary,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Est.Payout',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: context.textColorTheme.textColorTertiary,
                    ),
                  ),
                  Dimens.vGap4,
                  Text(
                    '${isPositive ? '+' : '-'}\$$pnlDisplay',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: pnlColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
