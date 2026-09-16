import 'package:finality/data/socket/manic/manic_price_data.dart';
import 'package:finality/features/positions/live_position/live_position_item.dart';
import 'package:finality/features/positions/live_position/model/live_position_item_data.dart';
import 'package:finality/features/positions/live_position/widgets/count_item.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/material.dart';

/// 内部动画列表组件
/// 负责管理 AnimatedList 的插入/移除动画
/// 支持 bar 级别的横向展开/收起（由 CountItem 控制）
class AnimatedLivePositions extends StatefulWidget {
  const AnimatedLivePositions({
    super.key,
    required this.items,
    required this.currentPrice,
    this.onActiveItemTap,
    this.hideCountItem = false,
  });

  final List<LivePositionItemData> items;
  final ValueNotifier<ManicPriceData?> currentPrice;

  /// Active item 点击回调，参数为 item 数据
  final void Function(ActiveItemData item)? onActiveItemTap;

  final bool hideCountItem;

  @override
  State<AnimatedLivePositions> createState() => _AnimatedLivePositionsState();
}

class _AnimatedLivePositionsState extends State<AnimatedLivePositions> {
  /// AnimatedList 的 key
  /// hideCountItem 变化时重建以重置内部 itemsCount，避免索引偏移失配导致越界
  GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  /// 当前显示的 items
  List<LivePositionItemData> _currentItems = [];

  /// 动画时长
  static const _animationDuration = Duration(milliseconds: 250);

  /// item 统一高度
  static const _kItemHeight = 30.0;

  /// bar 是否横向展开（显示所有 items）
  bool _isBarExpanded = true;

  @override
  void initState() {
    super.initState();
    _currentItems = List.from(widget.items);
  }

  @override
  void didUpdateWidget(covariant AnimatedLivePositions oldWidget) {
    super.didUpdateWidget(oldWidget);
    // hideCountItem 变化会让 AnimatedList 的 countItemOffset 失配，
    // 直接重建 AnimatedList 并跳过本次过渡动画
    if (oldWidget.hideCountItem != widget.hideCountItem) {
      _listKey = GlobalKey<AnimatedListState>();
      _currentItems = List.from(widget.items);
      return;
    }
    _syncItems(widget.items);
  }

  @override
  Widget build(BuildContext context) {
    if (_currentItems.isEmpty) {
      return Dimens.emptyBox;
    }

    final countItemOffset = widget.hideCountItem ? 0 : 1;

    // 收起态：只显示 CountItem
    if (!_isBarExpanded && !widget.hideCountItem) {
      return SizedBox(
        height: _kItemHeight,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: CountItem(
            count: _currentItems.length,
            isBarExpanded: false,
            onToggle: _toggleBarExpand,
          ),
        ),
      );
    }

    return SizedBox(
      height: _kItemHeight,
      child: AnimatedList(
        key: _listKey,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        initialItemCount: _currentItems.length + countItemOffset,
        itemBuilder: (context, index, animation) {
          if (!widget.hideCountItem && index == 0) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: CountItem(
                count: _currentItems.length,
                isBarExpanded: true,
                onToggle: _toggleBarExpand,
              ),
            );
          }

          final itemIndex = index - countItemOffset;
          if (itemIndex >= _currentItems.length) {
            return Dimens.emptyBox;
          }

          return _buildItem(_currentItems[itemIndex], animation);
        },
      ),
    );
  }

  void _toggleBarExpand() {
    setState(() => _isBarExpanded = !_isBarExpanded);
  }

  /// 同步 items 列表，处理增删动画
  void _syncItems(List<LivePositionItemData> newItems) {
    // 收起态下不操作 AnimatedList，直接更新数据
    if (!_isBarExpanded && !widget.hideCountItem) {
      if (!_listEquals(_currentItems, newItems)) {
        setState(() => _currentItems = List.from(newItems));
      }
      return;
    }

    final countItemOffset = widget.hideCountItem ? 0 : 1;
    final listState = _listKey.currentState;
    if (listState == null) {
      if (!_listEquals(_currentItems, newItems)) {
        setState(() => _currentItems = List.from(newItems));
      }
      return;
    }

    // 1. 找出需要移除的 items
    final removedItems = <_ItemChange>[];
    for (int i = 0; i < _currentItems.length; i++) {
      final oldItem = _currentItems[i];
      if (!newItems.any((n) => n.id == oldItem.id)) {
        removedItems.add(_ItemChange(index: i, item: oldItem));
      }
    }

    // 2. 找出需要插入的 items
    final insertedItems = <_ItemChange>[];
    for (int i = 0; i < newItems.length; i++) {
      final newItem = newItems[i];
      if (!_currentItems.any((o) => o.id == newItem.id)) {
        insertedItems.add(_ItemChange(index: i, item: newItem));
      }
    }

    // 3. 处理移除（从后往前，避免索引错乱）
    removedItems.sort((a, b) => b.index.compareTo(a.index));
    for (final removed in removedItems) {
      _currentItems.removeAt(removed.index);
      listState.removeItem(
        removed.index + countItemOffset,
        (context, animation) => _buildRemovedItem(removed.item, animation),
        duration: _animationDuration,
      );
    }

    // 4. 处理插入
    for (final inserted in insertedItems) {
      final insertIndex = inserted.index.clamp(0, _currentItems.length);
      _currentItems.insert(insertIndex, inserted.item);
      listState.insertItem(
        insertIndex + countItemOffset,
        duration: _animationDuration,
      );
    }

    // 5. 同步数据更新
    if (!_listEquals(_currentItems, newItems)) {
      _currentItems = List.from(newItems);
      setState(() {});
    }
  }

  bool _listEquals(List<LivePositionItemData> a, List<LivePositionItemData> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id || a[i].runtimeType != b[i].runtimeType) {
        return false;
      }
    }
    return true;
  }

  Widget _buildItem(LivePositionItemData item, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: animation,
      axis: Axis.horizontal,
      child: FadeTransition(
        opacity: animation,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: LivePositionItem(
            currentPrice: widget.currentPrice,
            itemData: item,
            onTap: item is ActiveItemData && widget.onActiveItemTap != null
                ? () => widget.onActiveItemTap!(item)
                : null,
          ),
        ),
      ),
    );
  }

  Widget _buildRemovedItem(
      LivePositionItemData item, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: animation,
      axis: Axis.horizontal,
      child: FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: animation,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: LivePositionItem(
              currentPrice: widget.currentPrice,
              itemData: item,
            ),
          ),
        ),
      ),
    );
  }
}

/// 记录 item 变化信息
class _ItemChange {
  final int index;
  final LivePositionItemData item;

  _ItemChange({required this.index, required this.item});
}
