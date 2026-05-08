import 'package:finality/common/constants/blockchain.dart';
import 'package:finality/common/utils/block_explorer_utils.dart';
import 'package:finality/common/utils/color_scheme_extensions.dart';
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
    // payout 是微单位，需要除以 1000000
    final payoutAmount = payout / 1000000;
    return '\$${NumberFormat('#,##0.00').format(payoutAmount)}';
  }

  String _formatMode(String? mode) {
    if (mode == null) return '';
    switch (mode) {
      case 'batch':
        return '统一模式';
      case 'single':
        return '单独模式';
      default:
        return mode;
    }
  }

  String _formatSide(String side) {
    switch (side) {
      case 'call':
        return '看涨 (HIGHER)';
      case 'put':
        return '看跌 (LOWER)';
      default:
        return side;
    }
  }

  String _formatResult(String? result) {
    if (result == null) return '';
    switch (result) {
      case 'Won':
        return '获胜';
      case 'Lose':
        return '失败';
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
        // 资产和模式
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
            if (item.mode != null) ...[
              Dimens.hGap8,
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: context.colorScheme.surfaceContainerHighest,
                  borderRadius: Dimens.radius8,
                ),
                child: Text(
                  _formatMode(item.mode),
                  style: TextStyle(
                    fontSize: 12,
                    color: context.textColorTheme.textColorSecondary,
                  ),
                ),
              ),
            ],
          ],
        ),
        Dimens.vGap24,
        // 结果标签
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
        // 派彩金额
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
        title: const Text('交易详情'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: Dimens.edgeInsetsH16,
        child: Column(
          children: [
            Dimens.vGap32,
            _buildHeader(context),
            Dimens.vGap32,
            // 方向
            TransactionDetailRow(
              svgIconAssetName: Assets.svgsIcTransactionDetailStatus,
              label: '方向',
              detail: _formatSide(item.side),
              detailColor: _getSideColor(item.side),
              isEven: true,
            ),
            // 金额
            TransactionDetailRow(
              svgIconAssetName: Assets.svgsIcTransactionDetailPriorityFee,
              label: '金额',
              detail: _formatAmount(item.uiAmount),
              isEven: false,
            ),
            // 入场价
            TransactionDetailRow(
              svgIconAssetName: Assets.svgsIcTransactionDetailHash,
              label: '入场价',
              detail: '\$${_formatPrice(item.boundaryPrice)}',
              isEven: true,
            ),
            // 最终价
            TransactionDetailRow(
              svgIconAssetName: Assets.svgsIcTransactionDetailHash,
              label: '最终价',
              detail: item.finalPrice != null
                  ? '\$${_formatPrice(item.finalPrice!)}'
                  : '-',
              isEven: false,
            ),
            // 派彩
            TransactionDetailRow(
              svgIconAssetName: Assets.svgsIcTransactionDetailPriorityFee,
              label: '派彩',
              detail: _formatPayout(item.payout),
              detailColor: item.payout > 0 ? Colors.green : null,
              isEven: true,
            ),
            // 开始时间
            TransactionDetailRow(
              svgIconAssetName: Assets.svgsIcTransactionDetailDate,
              label: '开始时间',
              detail: _formatTime(item.startTime),
              isEven: false,
            ),
            // 结束时间
            TransactionDetailRow(
              svgIconAssetName: Assets.svgsIcTransactionDetailDate,
              label: '结束时间',
              detail: _formatTime(item.endTime),
              isEven: true,
            ),
            // 开仓签名
            if (item.openSig != null)
              TransactionDetailRow(
                svgIconAssetName: Assets.svgsIcTransactionDetailHash,
                label: '开仓签名',
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
            // 结算签名
            if (item.resultSig != null)
              TransactionDetailRow(
                svgIconAssetName: Assets.svgsIcTransactionDetailHash,
                label: '结算签名',
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

  void _viewOnExplorer(BuildContext context,String? signature) {
    if (signature != null) {
      final url = Networks.solana.links?.formatTXUrl(signature);
      if (url != null) {
        BlockExplorerUtils.viewTransaction(url);
      }
    }
  }
}
