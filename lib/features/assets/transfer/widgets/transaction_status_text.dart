import 'package:finality/theme/attrs/text_color_theme.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:finality/features/assets/transfer/execute_status.dart';
import 'package:finality/common/utils/localization_extensions.dart';

class TransactionStatusText extends StatelessWidget {
  final ExecuteStatus? status;
  final VoidCallback? onViewTransaction;
  final String? initialText;

  const TransactionStatusText({
    super.key,
    required this.status,
    this.onViewTransaction,
    this.initialText,
  });

  @override
  Widget build(BuildContext context) {
    var textStyle = TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: context.textColorTheme.textColorSecondary);
    if (status == null) {
      return Text(
        initialText ?? "",
        style: textStyle,
      );
    }

    if (status == ExecuteStatus.timeout || status == ExecuteStatus.failed) {
      return RichText(
        text: TextSpan(
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: context.textColorTheme.textColorSecondary),
          children: [
            TextSpan(
              text: status == ExecuteStatus.timeout
                  ? context.strings.message_transfer_timeout
                  : context.strings.message_transfer_failed,
              style: textStyle,
            ),
            if (onViewTransaction != null)
              TextSpan(
                text: context.strings.action_view_on_solscan,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: context.textColorTheme.textColorSecondary,
                  decoration: TextDecoration.underline,
                ),
                recognizer: TapGestureRecognizer()..onTap = onViewTransaction,
              ),
          ],
        ),
      );
    }

    String text = context.strings.message_transfer_building;

    if (status == ExecuteStatus.success) {
      text = context.strings.message_transfer_success;
    } else if (status == ExecuteStatus.pending) {
      text = context.strings.message_transfer_pending;
    } else if (status == ExecuteStatus.buildFailure) {
      text = context.strings.message_transfer_build_failed;
    }

    return Text(
      text,
      style: textStyle,
    );
  }
}
