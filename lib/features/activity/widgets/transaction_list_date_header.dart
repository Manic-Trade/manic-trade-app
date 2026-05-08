import 'package:finality/theme/attrs/text_color_theme.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionListDateHeader extends StatelessWidget {
  final DateTime dateTime;
  final bool showDivider;

  //可以移到工具类里面，用static修饰
  static final DateFormat _dateFormat = DateFormat('MMM d yyyy');

  const TransactionListDateHeader({
    super.key,
    required this.dateTime,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showDivider) Dimens.hGap16,
        if (showDivider) Divider(),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            _dateFormat.format(dateTime),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: context.textColorTheme.textColorSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
