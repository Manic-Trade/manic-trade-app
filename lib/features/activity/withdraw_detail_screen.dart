import 'package:finality/common/constants/blockchain.dart';
import 'package:finality/common/utils/block_explorer_utils.dart';
import 'package:finality/common/utils/string_extensions.dart';
import 'package:finality/common/widgets/copyable_widget.dart';
import 'package:finality/common/widgets/touchable.dart';
import 'package:finality/data/network/model/manic/withdraw_item.dart';
import 'package:finality/features/activity/widgets/transaction_detail_row.dart';
import 'package:finality/theme/attrs/text_color_theme.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../generated/assets.dart';

class WithdrawDetailScreen extends StatelessWidget {
  final WithdrawItem item;

  const WithdrawDetailScreen({
    super.key,
    required this.item,
  });

  String _formatAmount(String uiAmount) {
    return '\$${uiAmount}';
  }

  String _formatTime(DateTime dateTime) {
    final locale = Intl.getCurrentLocale();
    if (locale == 'zh') {
      return DateFormat('yyyy-MM-dd HH:mm:ss', 'zh_CN').format(dateTime);
    }
    return DateFormat('yyyy-MM-dd HH:mm:ss', locale).format(dateTime);
  }

  String _formatStatus(String status) {
    return status.toUpperCase();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
      case 'error':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _viewOnExplorer(BuildContext context) {
    if (item.signature != null) {
      final url = Networks.solana.links?.formatTXUrl(item.signature!);
      if (url != null) {
        BlockExplorerUtils.viewTransaction(url);
      }
    }
  }

  Widget _buildHeader(BuildContext context) {
    final statusColor = _getStatusColor(item.status);

    return Column(
      children: [
        // Status Label
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.2),
            borderRadius: Dimens.radius12,
          ),
          child: Text(
            _formatStatus(item.status),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),
        ),
        Dimens.vGap16,
        // Amount
        Text(
          _formatAmount(item.uiAmount),
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Withdrawal Details'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: Dimens.edgeInsetsH16,
        child: Column(
          children: [
            Dimens.vGap32,
            _buildHeader(context),
            Dimens.vGap32,
            // From Address
            TransactionDetailRow(
              svgIconAssetName: Assets.svgsIcTransactionDetailHash,
              label: 'From',
              detailWidget: CopyableWidget(
                content: item.fromAddress,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.fromAddress.truncateWithEllipsis(
                        prefixLength: 4,
                        suffixLength: 4,
                      ),
                      style: TextStyle(
                        color: context.textColorTheme.textColorPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Dimens.hGap4,
                    Icon(
                      Icons.copy,
                      size: 15,
                      color: context.textColorTheme.textColorPrimary,
                    ),
                  ],
                ),
              ),
              isEven: true,
            ),
            // To Address
            TransactionDetailRow(
              svgIconAssetName: Assets.svgsIcTransactionDetailHash,
              label: 'To',
              detailWidget: CopyableWidget(
                content: item.toAddress,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.toAddress.truncateWithEllipsis(
                        prefixLength: 4,
                        suffixLength: 4,
                      ),
                      style: TextStyle(
                        color: context.textColorTheme.textColorPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Dimens.hGap4,
                    Icon(
                      Icons.copy,
                      size: 15,
                      color: context.textColorTheme.textColorPrimary,
                    ),
                  ],
                ),
              ),
              isEven: false,
            ),
            // Amount
            TransactionDetailRow(
              svgIconAssetName: Assets.svgsIcTransactionDetailPriorityFee,
              label: 'Amount',
              detail: _formatAmount(item.uiAmount),
              detailColor: Colors.orange,
              isEven: true,
            ),
            // Status
            TransactionDetailRow(
              svgIconAssetName: Assets.svgsIcTransactionDetailStatus,
              label: 'Status',
              detail: _formatStatus(item.status),
              detailColor: _getStatusColor(item.status),
              isEven: false,
            ),
            // Created At
            TransactionDetailRow(
              svgIconAssetName: Assets.svgsIcTransactionDetailDate,
              label: 'Created At',
              detail: _formatTime(item.createdAt),
              isEven: true,
            ),
            // Updated At
            TransactionDetailRow(
              svgIconAssetName: Assets.svgsIcTransactionDetailDate,
              label: 'Updated At',
              detail: _formatTime(item.updatedAt),
              isEven: false,
            ),
            // Signature
            if (item.signature != null)
              Builder(builder: (context) {
                return TransactionDetailRow(
                  svgIconAssetName: Assets.svgsIcTransactionDetailHash,
                  label: 'Tx Hash',
                  onTap: () {
                    _viewOnExplorer(context);
                  },
                  isEven: true,
                  detailWidget: Touchable.plain(
                    onTap: () {
                      _viewOnExplorer(context);
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item.signature!.truncateWithEllipsis(
                            prefixLength: 4,
                            suffixLength: 4,
                          ),
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
                );
              }),
            // Error Message
            if (item.errorMessage != null)
              TransactionDetailRow(
                svgIconAssetName: Assets.svgsIcTransactionDetailStatus,
                label: 'Error',
                detail: item.errorMessage!,
                detailColor: Colors.red,
                isEven: false,
              ),
            Dimens.vGap32,
            // View on Explorer button
          ],
        ),
      ),
    );
  }
}
