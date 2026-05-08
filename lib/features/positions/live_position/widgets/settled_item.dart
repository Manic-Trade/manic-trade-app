import 'package:finality/features/positions/live_position/model/live_position_item_data.dart';
import 'package:finality/theme/app_color_theme.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/material.dart';

/// Settled 状态的 item（高度 30，单行布局：WON/LOST + 金额）
class SettledItem extends StatelessWidget {
  const SettledItem({super.key, required this.data});

  final SettledItemData data;

  @override
  Widget build(BuildContext context) {
    final color =
        data.isHigh ? context.appColors.bullish : context.appColors.bearish;
    // TODO 没做多主题适配，硬编码了颜色
    final bgColor = data.isHigh ? const Color(0xFF0E2E22) : const Color(0xFF341815);

    return Container(
      width: 128,
      height: 30,
      decoration: BoxDecoration(
        borderRadius: Dimens.radius6,
        border: Border.all(color: color, width: 0.5),
        color: bgColor,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // WON / LOST 标签
          Text(
            data.isWin ? 'WON' : 'LOST',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
              height: 1,
              shadows: [
                Shadow(color: color, blurRadius: 2.71),
              ],
            ),
          ),
          Dimens.hGap4,
          // 盈亏金额
          Text(
            data.pnlText,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              height: 1,
              letterSpacing: 0.34,
            ),
          ),
        ],
      ),
    );
  }
}
