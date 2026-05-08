import 'package:finality/data/socket/manic/manic_price_data.dart';
import 'package:finality/features/positions/live_position/live_position_bar_vm.dart';
import 'package:finality/features/positions/live_position/model/live_position_item_data.dart';
import 'package:finality/features/positions/live_position/widgets/animated_live_positions.dart';
import 'package:finality/domain/options/entities/opened_position.dart';
import 'package:finality/features/highlow/model/settled_position_event.dart';
import 'package:flutter/material.dart';

/// Live Position Bar
/// 显示当前币对的进行中订单，支持横向滚动
/// 支持 item 插入/移除动画
class LivePositionBar extends StatelessWidget {
  const LivePositionBar({
    super.key,
    required this.currentPrice,
    required this.openedPositions,
    required this.settledEvents,
    required this.currentAsset,
    required this.livePositionBarVM,
    this.onActiveItemTap,
    this.onlyShowProcessing = false,
  });

  final ValueNotifier<ManicPriceData?> currentPrice;
  final List<OpenedPosition> openedPositions;
  final List<SettledPositionEvent> settledEvents;
  final String currentAsset;
  final LivePositionBarVM livePositionBarVM;
  final bool onlyShowProcessing;

  /// Active item 被点击时的回调，回传对应的 OpenedPosition
  final void Function(OpenedPosition position)? onActiveItemTap;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<ProcessingItemData>>(
      valueListenable: livePositionBarVM.processingPositions,
      builder: (context, _, __) {
        final allItems = livePositionBarVM.buildLivePositionList(
          openedPositions: openedPositions,
          settledEvents: settledEvents,
          currentAsset: currentAsset,
        );
        final List<LivePositionItemData> items = onlyShowProcessing
            ? allItems.whereType<ProcessingItemData>().toList()
            : allItems;
        return Padding(
          padding: const EdgeInsets.only(top: 4),
          child: AnimatedLivePositions(
            items: items,
            hideCountItem: onlyShowProcessing,
            currentPrice: currentPrice,
            onActiveItemTap: onActiveItemTap == null
                ? null
                : (activeItem) {
                    // 通过 ID 查找对应的 OpenedPosition
                    final position = openedPositions
                        .where((p) => p.id == activeItem.id)
                        .firstOrNull;
                    if (position != null) {
                      onActiveItemTap!(position);
                    }
                  },
          ),
        );
      },
    );
  }
}
