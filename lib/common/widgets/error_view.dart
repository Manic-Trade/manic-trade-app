import 'package:flutter/material.dart';
import 'package:finality/common/utils/localization_extensions.dart';

import '../../generated/assets.dart';

class ErrorView extends StatelessWidget {
  final Function()? onRetry;
  final String? message;

  const ErrorView({this.onRetry, this.message, super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            Assets.commonPageErrorPic,
            width: 110,
            height: 110,
          ),
          const SizedBox(height: 8),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                message ?? context.strings.error_default,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  letterSpacing: -0.43,
                ),
              )),
          const SizedBox(height: 16),
          if (onRetry != null)
            SizedBox(
              height: 36,
              child: FilledButton(
                onPressed: onRetry,
                child: Text(
                  context.strings.action_retry,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
