import 'package:finality/common/utils/color_scheme_extensions.dart';
import 'package:finality/features/positions/live_position/widgets/scanning_container.dart';
import 'package:finality/features/positions/live_position/widgets/three_dots_loading.dart';
import 'package:finality/features/positions/live_position/model/live_position_item_data.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/material.dart';

/// Processing 状态的 item（高度 30）
class ProcessingItem extends StatelessWidget {
  const ProcessingItem({super.key, required this.data});

  final ProcessingItemData data;

  @override
  Widget build(BuildContext context) {
    final primary = context.colorScheme.primary;

    return ScanningContainer(
      width: 128,
      height: 30,
      scanColor: primary,
      borderRadius: Dimens.radius6,
      backgroundColor: const Color(0xFF1A160F),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ThreeDotsLoading(
            color: primary,
            size: 4,
            spacing: 2,
            borderRadius: 1,
          ),
          Dimens.hGap6,
          Text(
            "PROCESSING",
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w600,
              color: primary,
              shadows: [
                Shadow(
                  color: const Color(0xFFDB8300),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
