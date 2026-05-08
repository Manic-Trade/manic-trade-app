import 'package:finality/common/widgets/error_view.dart';
import 'package:flutter/material.dart';

class KlineErrorView extends StatelessWidget {
  final String? errorMessage;
  final VoidCallback? onRetry;

  const KlineErrorView({super.key, this.errorMessage, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: ErrorView(
        message: errorMessage,
        onRetry: onRetry,
      ),
    );
  }
}
