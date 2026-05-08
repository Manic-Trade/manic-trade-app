import 'package:finality/features/history/model/deposit_history_item_vo.dart';
import 'package:finality/features/history/widgets/history_item_shared.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

class DepositItemWidget extends StatelessWidget {
  final DepositHistoryItemVO vo;
  final bool isLoading;
  final VoidCallback? onTxHashTap;

  const DepositItemWidget({
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
              label: 'Address',
              child: HistoryInfoValue(vo.addressShort),
            ),
            Dimens.vGap8,
            HistoryInfoRow(
              label: 'Amount',
              child: HistoryInfoValue(vo.amountDisplay),
            ),
            Dimens.vGap8,
            HistoryInfoRow(
              label: 'Time',
              child: HistoryInfoValue(vo.timeDisplay),
            ),
            Dimens.vGap8,
            HistoryInfoRow(
              label: 'Tx Hash',
              child: HistoryTxHashBadge(
                hash: vo.txHashShort,
                isLoading: isLoading,
                onTap: onTxHashTap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
