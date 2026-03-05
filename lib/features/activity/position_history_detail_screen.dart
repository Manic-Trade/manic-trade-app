import 'package:finality/common/constants/blockchain.dart';
import 'package:finality/common/utils/block_explorer_utils.dart';
import 'package:finality/common/utils/date_time_extensions.dart';
import 'package:finality/common/widgets/touchable.dart';
import 'package:finality/data/network/model/manic/position_history_item.dart';
import 'package:finality/features/activity/widgets/transaction_detail_row.dart';
import 'package:finality/theme/attrs/text_color_theme.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../generated/assets.dart';

class PositionHistoryDetailScreen extends StatelessWidget {
  final PositionHistoryItem item;

  const PositionHistoryDetailScreen({
    super.key,
    required this.item,
  });

  String _formatPrice(double price) {
    return NumberFormat('#,##0.00').format(price);
  }

  String _formatAmount(double amount) {
    return '\$${NumberFormat('#,##0.00').format(amount)}';
  }

  String _formatPayout(int payout) {
    if (payout == 0) {
      return '\$0.00';
    }
    // payout is in micro units, need to divide by 1000000
    final payoutAmount = payout / 1000000;
    return '\$${NumberFormat('#,##0.00').format(payoutAmount)}';
  }

  String _formatSide(String side) {
    switch (side) {
      case 'call':
        return 'HIGHER';
      case 'put':
        return 'LOWER';
      default:
        return side;
    }
  }

  String _formatResult(String? result) {
    if (result == null) return '';
    switch (result) {
      case 'Won':
        return 'WIN';
      case 'Lose':
        return 'LOSE';
      default:
        return result;
    }
  }

  String _formatTime(int timestamp) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return dateTime.formatFullDateTime();
  }

  Color _getSideColor(String side) {
    return side == 'call' ? Colors.green : Colors.orange;
  }

  Color _getResultColor(String? result) {
    if (result == null) return Colors.grey;
    return result == 'Won' ? Colors.green : Colors.orange;
  }

  Widget _buildHeader(BuildContext context) {
    final resultColor = _getResultColor(item.result);

    return Column(
      children: [
        // Asset and Mode
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              item.asset.toUpperCase(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: context.textColorTheme.textColorPrimary,
              ),
            ),
          ],
        ),
        Dimens.vGap24,
        // Result Label
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: resultColor.withOpacity(0.2),
            borderRadius: Dimens.radius12,
          ),
          child: Text(
            _formatResult(item.result),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: resultColor,
            ),
          ),
        ),
        Dimens.vGap16,
        // Payout Amount
        Text(
          _formatPayout(item.payout),
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: item.payout > 0
                ? Colors.green
                : context.textColorTheme.textColorPrimary,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trade Details'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: Dimens.edgeInsetsH16,
        child: Column(
          children: [
            Dimens.vGap32,
            _buildHeader(context),
            Dimens.vGap32,
            // Direction
            TransactionDetailRow(
              svgIconAssetName: Assets.svgsIcTransactionDetailStatus,
              label: 'Direction',
              detail: _formatSide(item.side),
              detailColor: _getSideColor(item.side),
              isEven: true,
            ),
            // Amount
            TransactionDetailRow(
              svgIconAssetName: Assets.svgsIcTransactionDetailPriorityFee,
              label: 'Amount',
              detail: _formatAmount(item.uiAmount),
              isEven: false,
            ),
            // Entry Price
            TransactionDetailRow(
              svgIconAssetName: Assets.svgsIcTransactionDetailHash,
              label: 'Entry Price',
              detail: '\$${_formatPrice(item.boundaryPrice)}',
              isEven: true,
            ),
            // Final Price
            TransactionDetailRow(
              svgIconAssetName: Assets.svgsIcTransactionDetailHash,
              label: 'Final Price',
              detail: item.finalPrice != null
                  ? '\$${_formatPrice(item.finalPrice!)}'
                  : '-',
              isEven: false,
            ),
            // Payout
            TransactionDetailRow(
              svgIconAssetName: Assets.svgsIcTransactionDetailPriorityFee,
              label: 'Payout',
              detail: _formatPayout(item.payout),
              detailColor: item.payout > 0 ? Colors.green : null,
              isEven: true,
            ),
            // Start Time
            TransactionDetailRow(
              svgIconAssetName: Assets.svgsIcTransactionDetailDate,
              label: 'Start Time',
              detail: _formatTime(item.startTime),
              isEven: false,
            ),
            // End Time
            TransactionDetailRow(
              svgIconAssetName: Assets.svgsIcTransactionDetailDate,
              label: 'End Time',
              detail: _formatTime(item.endTime),
              isEven: true,
            ),
            // Open Transaction Signature
            if (item.openSig != null)
              TransactionDetailRow(
                svgIconAssetName: Assets.svgsIcTransactionDetailHash,
                label: 'Open Tx',
                detailWidget: Touchable.plain(
                  onTap: () {
                    _viewOnExplorer(context, item.openSig);
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${item.openSig!.substring(0, 4)}...${item.openSig!.substring(item.openSig!.length - 4)}',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Dimens.hGap4,
                      Icon(
                        Icons.open_in_new,
                        size: 16,
                        color: Colors.blue,
                      ),
                    ],
                  ),
                ),
                isEven: false,
              ),
            // Settlement Transaction Signature
            if (item.resultSig != null)
              TransactionDetailRow(
                svgIconAssetName: Assets.svgsIcTransactionDetailHash,
                label: 'Settle Tx',
                detailWidget: Touchable.plain(
                  onTap: () {
                    _viewOnExplorer(context, item.resultSig);
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${item.resultSig!.substring(0, 4)}...${item.resultSig!.substring(item.resultSig!.length - 4)}',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Dimens.hGap4,
                      Icon(
                        Icons.open_in_new,
                        size: 16,
                        color: Colors.blue,
                      ),
                    ],
                  ),
                ),
                isEven: true,
              ),
            Dimens.vGap32,
          ],
        ),
      ),
    );
  }

  void _viewOnExplorer(BuildContext context, String? signature) {
    if (signature != null) {
      final url = Networks.solana.links?.formatTXUrl(signature);
      if (url != null) {
        BlockExplorerUtils.viewTransaction(url);
      }
    }
  }
}
