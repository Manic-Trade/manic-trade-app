import 'package:finality/common/utils/color_scheme_extensions.dart';
import 'package:finality/common/widgets/touchable.dart';
import 'package:finality/theme/attrs/text_color_theme.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// 历史记录列表通用行：左侧标签 + 右侧内容
class HistoryInfoRow extends StatelessWidget {
  final String label;
  final Widget child;

  const HistoryInfoRow({
    super.key,
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: context.textColorTheme.textColorQuaternary,
          ),
        ),
        child,
      ],
    );
  }
}

/// 历史记录通用文本值
class HistoryInfoValue extends StatelessWidget {
  final String text;

  const HistoryInfoValue(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: context.textColorTheme.textColorSecondary,
      ),
    );
  }
}

/// Tx Hash 徽章（橙色，可点击，骨架加载时显示 Bone）
class HistoryTxHashBadge extends StatelessWidget {
  final String hash;
  final bool isLoading;
  final VoidCallback? onTap;

  const HistoryTxHashBadge({
    super.key,
    required this.hash,
    this.isLoading = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Bone.text(fontSize: 10, width: 77);
    }
    final color = context.colorScheme.primary;
    return Touchable.plain(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 0.5),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              //hash,
              "View",
              style: TextStyle(fontSize: 10, color: color, height: 1),
            ),
            Dimens.hGap4,
            Icon(Icons.open_in_new, size: 10, color: color),
          ],
        ),
      ),
    );
  }
}
