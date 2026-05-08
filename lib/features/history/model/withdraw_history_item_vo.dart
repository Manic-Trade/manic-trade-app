import 'package:finality/common/utils/string_extensions.dart';
import 'package:finality/data/network/model/manic/withdraw_item.dart';
import 'package:intl/intl.dart';

class WithdrawHistoryItemVO {
  /// From 地址（截断展示）
  final String fromShort;

  /// To 地址（截断展示）
  final String toShort;

  /// 金额展示（如 "$1,000.00"）
  final String amountDisplay;

  /// 状态大写展示（如 "CONFIRMED"、"FAILED"）
  final String statusDisplay;

  /// 原始 status 字符串（用于颜色判断）
  final String status;

  /// 时间展示（如 "16:17:24, Mar 16"）
  final String timeDisplay;

  /// Tx Hash 短地址（如 "2cN5...DYGY"），Failed 时为 null
  final String? txHashShort;

  /// 完整签名（用于跳转区块链浏览器），Failed 时为 null
  final String? signature;

  const WithdrawHistoryItemVO({
    required this.fromShort,
    required this.toShort,
    required this.amountDisplay,
    required this.statusDisplay,
    required this.status,
    required this.timeDisplay,
    this.txHashShort,
    this.signature,
  });

  factory WithdrawHistoryItemVO.fromWithdrawItem(WithdrawItem item) {
    return WithdrawHistoryItemVO(
      fromShort: item.fromAddress.truncateWithEllipsis(
        prefixLength: 6,
        suffixLength: 4,
      ),
      toShort: item.toAddress.truncateWithEllipsis(
        prefixLength: 6,
        suffixLength: 4,
      ),
      amountDisplay: '\$${item.uiAmount}',
      statusDisplay: item.status.toUpperCase(),
      status: item.status,
      timeDisplay: _formatTime(item.createdAt),
      txHashShort: item.signature?.truncateWithEllipsis(
        prefixLength: 4,
        suffixLength: 4,
      ),
      signature: item.signature,
    );
  }

  /// 占位符对象（用于骨架加载）
  factory WithdrawHistoryItemVO.placeholder() {
    return const WithdrawHistoryItemVO(
      fromShort: 'DYs6...k2DD',
      toShort: 'QoKF...Zuih',
      amountDisplay: '\$1,000.00',
      statusDisplay: 'CONFIRMED',
      status: 'confirmed',
      timeDisplay: '16:17:24, Mar 16',
      txHashShort: '2cN5...DYGY',
      signature: '2cN512345678901234567890123456789012345678901234567890DYGY',
    );
  }

  static String _formatTime(DateTime dateTime) {
    final locale = Intl.getCurrentLocale();
    if (locale == 'zh') {
      return DateFormat('HH:mm:ss, MMM dd', 'zh_CN').format(dateTime);
    }
    return DateFormat('HH:mm:ss, MMM dd', locale).format(dateTime);
  }
}
