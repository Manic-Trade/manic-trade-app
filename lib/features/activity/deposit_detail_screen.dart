import 'package:finality/common/constants/blockchain.dart';
import 'package:finality/common/utils/block_explorer_utils.dart';
import 'package:finality/common/utils/color_scheme_extensions.dart';
import 'package:finality/common/utils/string_extensions.dart';
import 'package:finality/common/widgets/copyable_widget.dart';
import 'package:finality/common/widgets/touchable.dart';
import 'package:finality/data/network/model/manic/deposit_item.dart';
import 'package:finality/features/activity/widgets/transaction_detail_row.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../generated/assets.dart';

class DepositDetailScreen extends StatelessWidget {
  final DepositItem item;

  const DepositDetailScreen({
    super.key,
    required this.item,
  });

  String _formatAmount(String amount) {
    return '\$${amount}';
  }

  String _formatTime(int timestamp) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    final locale = Intl.getCurrentLocale();
    if (locale == 'zh') {
      return DateFormat('yyyy-MM-dd HH:mm:ss', 'zh_CN').format(dateTime);
    }
    return DateFormat('yyyy-MM-dd HH:mm:ss', locale).format(dateTime);
  }

  void _viewOnExplorer(BuildContext context) {
    final url = Networks.solana.links?.formatTXUrl(item.signature);
    if (url != null) {
      BlockExplorerUtils.viewTransaction(url);
    }
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        // 金额
        Text(
          _formatAmount(item.amount),
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deposit Details'),
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
                        prefixLength: 8,
                        suffixLength: 8,
                      ),
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Dimens.hGap4,
                    Icon(
                      Icons.copy,
                      size: 16,
                      color: Colors.blue,
                    ),
                  ],
                ),
              ),
              isEven: true,
            ),
            // To Address (Wallet Address)
            TransactionDetailRow(
              svgIconAssetName: Assets.svgsIcTransactionDetailHash,
              label: 'To',
              detailWidget: CopyableWidget(
                content: item.walletAddress,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.walletAddress.truncateWithEllipsis(
                        prefixLength: 8,
                        suffixLength: 8,
                      ),
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Dimens.hGap4,
                    Icon(
                      Icons.copy,
                      size: 16,
                      color: Colors.blue,
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
              detail: _formatAmount(item.amount),
              detailColor: Colors.green,
              isEven: true,
            ),
            // Time
            TransactionDetailRow(
              svgIconAssetName: Assets.svgsIcTransactionDetailDate,
              label: 'Time',
              detail: _formatTime(item.timestamp),
              isEven: false,
            ),
            // Signature
            Builder(builder: (context) {
              final copyController = CopyController();
              return TransactionDetailRow(
                svgIconAssetName: Assets.svgsIcTransactionDetailHash,
                label: 'Tx Hash',
                onTap: () {
                  copyController.copy();
                },
                isEven: true,
                detailWidget: CopyableWidget(
                  content: item.signature,
                  clickable: true,
                  controller: copyController,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.signature.truncateWithEllipsis(
                          prefixLength: 8,
                          suffixLength: 8,
                        ),
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Dimens.hGap4,
                      Icon(
                        Icons.copy,
                        size: 16,
                        color: Colors.blue,
                      ),
                    ],
                  ),
                ),
              );
            }),
            Dimens.vGap32,
            // View on Explorer button
            Touchable.plain(
              onTap: () {
                _viewOnExplorer(context);
              },
              child: SizedBox(
                height: 48,
                width: double.infinity,
                child: Center(
                  child: Text(
                    'View on Explorer',
                    style: TextStyle(
                      color: context.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
            Dimens.vGap32,
          ],
        ),
      ),
    );
  }
}
