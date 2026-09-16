import 'package:finality/common/widgets/touchable.dart';
import 'package:finality/data/socket/manic/manic_price_data.dart';
import 'package:finality/features/positions/live_position/model/live_position_item_data.dart';
import 'package:finality/features/positions/live_position/widgets/activie_item.dart';
import 'package:finality/features/positions/live_position/widgets/processing_item.dart';
import 'package:finality/features/positions/live_position/widgets/settled_item.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'widgets/shake_on_appear.dart';

/// Live Position Bar 中的单个 item 组件
class LivePositionItem extends StatelessWidget {
  const LivePositionItem({
    super.key,
    required this.currentPrice,
    required this.itemData,
    this.onTap,
  });

  final ValueListenable<ManicPriceData?> currentPrice;
  final LivePositionItemData itemData;

  /// 点击回调（仅 ActiveItem 响应）
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final data = itemData;

    if (data is ProcessingItemData) {
      return ProcessingItem(
        data: data,
        key: ValueKey('${data.id}_processing'),
      );
    } else if (data is ActiveItemData) {
      return ShakeOnAppear(
        key: ValueKey('${data.id}_active'),
        child: Touchable.plain(
          onTap: onTap,
          child: ActiveItem(
            currentPrice: currentPrice,
            data: data,
          ),
        ),
      );
    } else if (data is SettledItemData) {
      return ShakeOnAppear(
        key: ValueKey('${data.id}_settled'),
        child: SettledItem(data: data),
      );
    } else {
      return Dimens.emptyBox;
    }
  }
}
