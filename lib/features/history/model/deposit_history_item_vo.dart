import 'package:finality/common/utils/decimal_format.dart';
import 'package:finality/common/utils/string_extensions.dart';
import 'package:finality/data/network/model/manic/deposit_item.dart';
import 'package:intl/intl.dart';

class DepositHistoryItemVO {
  /// 钱包地址（截断展示，如 "0x71C7...9B2a"）
  final String addressShort;

  /// 金额展示（如 "$2,500.00"）
  final String amountDisplay;

  /// 时间展示（如 "14:30, Oct 19"）
  final String timeDisplay;

  /// Tx Hash 短地址（如 "0x8a12...29c1"）
  final String txHashShort;

  /// 区块链浏览器链接
  final String? explorerUrl;

  const DepositHistoryItemVO({
    required this.addressShort,
    required this.amountDisplay,
    required this.timeDisplay,
    required this.txHashShort,
    this.explorerUrl,
  });

  factory DepositHistoryItemVO.fromDepositItem(DepositItem item) {
    return DepositHistoryItemVO(
      addressShort: item.fromAddress.truncateWithEllipsis(
        prefixLength: 4,
        suffixLength: 4,
      ),
      amountDisplay: '\$${item.amount.formatWithDecimals(2)}',
      timeDisplay: _formatTime(item.createdAt),
      txHashShort: item.destHash?.truncateWithEllipsis(
            prefixLength: 4,
            suffixLength: 4,
          ) ??
          '--',
      explorerUrl: item.explorerUrl,
    );
  }

  /// 占位符对象（用于骨架加载）
  factory DepositHistoryItemVO.placeholder() {
    return const DepositHistoryItemVO(
      addressShort: '0x71...9B2a',
      amountDisplay: '\$200.00',
      timeDisplay: '14:30:00, OCT 19',
      txHashShort: '0x8a12...29c1',
      explorerUrl: null,
    );
  }

  static String _formatTime(int timestamp) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    final locale = Intl.getCurrentLocale();
    if (locale == 'zh') {
      return DateFormat('HH:mm:ss, MMM dd', 'zh_CN').format(dateTime);
    }
    return DateFormat('HH:mm:ss, MMM dd', locale).format(dateTime);
  }
}
