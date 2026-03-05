import 'package:async_button_builder/async_button_builder.dart';
import 'package:flutter/material.dart';

class PrimaryAsyncButton extends StatelessWidget {
  const PrimaryAsyncButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.borderRadius = 24.0,
    this.loadingSize = 16.0,
    this.backgroundColor,
    this.foregroundColor,
    this.disabledBackgroundColor,
    this.disabledForegroundColor,
    this.shape,
    this.onError,
    this.textStyle,
    this.duration = const Duration(milliseconds: 250),
    this.loadingWidget,
    this.showError = true,
  });

  final Future<void> Function()? onPressed;
  final Widget child;
  final double borderRadius;
  final double loadingSize;
  final OutlinedBorder? shape;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? disabledBackgroundColor;
  final Color? disabledForegroundColor;
  final Duration duration;
  final bool Function(dynamic error)? onError;
  final TextStyle? textStyle;
  final Widget? loadingWidget;
  final bool showError;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return NotificationListener<AsyncButtonNotification>(
      onNotification: (notification) {
        var buttonState = notification.buttonState;
        if (buttonState is Error) {
          return onError?.call(buttonState.error) ?? false;
        }
        return false;
      },
      child: AsyncButtonBuilder(
        showSuccess: false,
        showError: showError,
        duration: duration,
        onPressed: onPressed,
        loadingWidget: loadingWidget ??
            SizedBox(
              height: loadingSize,
              width: loadingSize,
              child: CircularProgressIndicator(
                color: foregroundColor ?? theme.colorScheme.onPrimary,
              ),
            ),
        builder: (context, child, callback, _) {
          return FilledButton(
            onPressed: callback,
            style: FilledButton.styleFrom(
              textStyle: textStyle,
              backgroundColor: backgroundColor ?? theme.colorScheme.primary,
              foregroundColor: foregroundColor ?? theme.colorScheme.onPrimary,
              shape: shape,
              disabledBackgroundColor: onPressed != null
                  ? (backgroundColor ?? theme.colorScheme.primary)
                  : (disabledBackgroundColor ??
                      backgroundColor?.withOpacity(0.38) ??
                      theme.colorScheme.primary.withOpacity(0.38)),
              disabledForegroundColor:
                  disabledForegroundColor ?? theme.colorScheme.onPrimary,
            ),
            child: child,
          );
        },
        child: child,
      ),
    );
  }
}
