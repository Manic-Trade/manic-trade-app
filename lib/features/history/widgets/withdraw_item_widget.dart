import 'package:finality/common/utils/color_scheme_extensions.dart';
import 'package:finality/features/history/model/withdraw_history_item_vo.dart';
import 'package:finality/features/history/widgets/history_item_shared.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

class WithdrawItemWidget extends StatelessWidget {
  final WithdrawHistoryItemVO vo;
  final bool isLoading;
  final VoidCallback? onTxHashTap;

  const WithdrawItemWidget({
    super.key,
    required this.vo,
    this.isLoading = false,
    this.onTxHashTap,
  });

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: isLoading,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFF1F1F1F), width: 0.5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HistoryInfoRow(
              label: 'From',
              child: HistoryInfoValue(vo.fromShort),
            ),
            Dimens.vGap8,
            HistoryInfoRow(
              label: 'To',
              child: HistoryInfoValue(vo.toShort),
            ),
            Dimens.vGap8,
            HistoryInfoRow(
              label: 'Amount',
              child: HistoryInfoValue(vo.amountDisplay),
            ),
            Dimens.vGap8,
            HistoryInfoRow(
              label: 'Status',
              child: isLoading
                  ? Bone.text(fontSize: 10, width: 77)
                  : _StatusBadge(status: vo.status, label: vo.statusDisplay),
            ),
            Dimens.vGap8,
            HistoryInfoRow(
              label: 'Time',
              child: HistoryInfoValue(vo.timeDisplay),
            ),
            // Tx Hash 行：signature 为 null 时隐藏（如 Failed 状态）
            if (vo.txHashShort != null) ...[
              Dimens.vGap8,
              HistoryInfoRow(
                label: 'Tx Hash',
                child: HistoryTxHashBadge(
                  hash: vo.txHashShort!,
                  isLoading: isLoading,
                  onTap: onTxHashTap,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  final String label;

  const _StatusBadge({required this.status, required this.label});

  Color _colorFor(BuildContext context) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return const Color(0xFF00C853); // 绿色
      case 'pending':
      case 'failed':
      case 'error':
        return context.colorScheme.primary; // 橙色
      default:
        return const Color(0xFF888888); // 灰色
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 0.5),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: color,
          height: 1,
        ),
      ),
    );
  }
}
