import 'package:finality/theme/attrs/text_color_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// 已结算仓位列表中的日期分组标题
class SettledPositionDateItem extends StatelessWidget {
  final DateTime dateTime;

  static final DateFormat _dateFormat = DateFormat('MMM dd yyyy');

  final bool isFirst;

  const SettledPositionDateItem({
    super.key,
    required this.dateTime,
    this.isFirst = false,
  });

  static String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return 'Today';
    }
    return _dateFormat.format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: isFirst ? 4 : 12, bottom: 12),
      child: Text(
        _formatDate(dateTime),
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: context.textColorTheme.textColorSecondary,
        ),
      ),
    );
  }
}
