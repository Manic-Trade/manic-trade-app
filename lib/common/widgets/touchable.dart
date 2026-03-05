import 'package:bounce_tapper/bounce_tapper.dart';
import 'package:finality/common/utils/haptic_feedback_utils.dart';
import 'package:flutter/material.dart';
import 'package:jelly/jelly.dart';

class Touchable extends StatelessWidget {
  const Touchable({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.onLongPressUp,
    this.highlightBorderRadius = const BorderRadius.all(Radius.circular(6)),
    this.highlightColor,
    this.shrinkScaleFactor = 0.965,
    this.quickResponse = false,
    this.enableFeedback = true,
    this.shrinkDuration = const Duration(milliseconds: 130),
    this.growDuration = const Duration(milliseconds: 100),
    this.delayedDurationBeforeGrow = const Duration(milliseconds: 25),
    this.enable = true,
    this.buttonChild = false,
  });

  final Widget child;
  final VoidCallback? onTap;
  final GestureLongPressCallback? onLongPress;
  final GestureLongPressUpCallback? onLongPressUp;
  final BorderRadius? highlightBorderRadius;
  final Color? highlightColor;
  final bool buttonChild;
  final bool quickResponse;
  final bool enableFeedback;
  final bool enable;

  /// The closer to 0, the more it will shrink.
  /// Values between 0 and 1 (exclusive) are valid.
  final double shrinkScaleFactor;

  /// The duration for the shrink and grow animations.
  final Duration shrinkDuration, growDuration;

  /// Delay before the grow animation starts after the shrink animation completes.
  ///
  /// You can set it to [Duration.zero] to remove the delay, but a small delay provides a smoother effect.
  final Duration delayedDurationBeforeGrow;

  ///可以包裹FilledButton、OutlinedButton、TextButton等按钮实现弹性点击效果，但震动反馈需要自己处理
  const Touchable.button({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.onLongPressUp,
    this.quickResponse = false,
    this.enableFeedback = true,
    this.shrinkDuration = const Duration(milliseconds: 130),
    this.growDuration = const Duration(milliseconds: 100),
    this.delayedDurationBeforeGrow = const Duration(milliseconds: 25),
    this.shrinkScaleFactor = 0.965,
    this.enable = true,
  })  : buttonChild = true,
        highlightBorderRadius = null,
        highlightColor = Colors.transparent;

  const Touchable.iconButton({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.onLongPressUp,
    this.quickResponse = false,
    this.enableFeedback = true,
    this.shrinkDuration = const Duration(milliseconds: 130),
    this.growDuration = const Duration(milliseconds: 100),
    this.delayedDurationBeforeGrow = const Duration(milliseconds: 25),
    this.shrinkScaleFactor = 0.8,
    this.enable = true,
  })  : buttonChild = true,
        highlightBorderRadius = null,
        highlightColor = Colors.transparent;

  const Touchable.plain({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.onLongPressUp,
    this.buttonChild = false,
    this.quickResponse = false,
    this.shrinkScaleFactor = 0.93,
    this.enableFeedback = true,
    this.shrinkDuration = const Duration(milliseconds: 130),
    this.growDuration = const Duration(milliseconds: 100),
    this.delayedDurationBeforeGrow = const Duration(milliseconds: 25),
    this.enable = true,
  })  : highlightBorderRadius = null,
        highlightColor = Colors.transparent;

  @override
  Widget build(BuildContext context) {
    return buttonChild ? _buildBounceTapper(context) : _buildJelly(context);
  }

  Widget _buildJelly(BuildContext context) {
    return Jelly(
      shrinkScaleFactor: shrinkScaleFactor,
      quickResponse: quickResponse,
      onTap: onTap == null || !enable
          ? null
          : () {
              if (enableFeedback) {
                HapticFeedbackUtils.lightImpact();
              }
              onTap!();
            },
      onLongPress: onLongPress == null || !enable
          ? null
          : () {
              if (enableFeedback) {
                HapticFeedbackUtils.selectionClick();
              }
              onLongPress!();
            },
      onLongPressUp: onLongPressUp == null || !enable
          ? null
          : () {
              if (enableFeedback) {
                HapticFeedbackUtils.selectionClick();
              }
              onLongPressUp!();
            },
      highlightBorderRadius: highlightBorderRadius,
      highlightColor: highlightColor ??
          Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.02),
      child: child,
    );
  }

  Widget _buildBounceTapper(BuildContext context) {
    return BounceTapper(
      shrinkScaleFactor: shrinkScaleFactor,
      enable: enable,
      onTap: onTap == null
          ? null
          : () {
              if (enableFeedback) {
                HapticFeedbackUtils.lightImpact();
              }
              onTap!();
            },
      onLongPress: onLongPress == null
          ? null
          : () {
              if (enableFeedback) {
                HapticFeedbackUtils.selectionClick();
              }
              onLongPress!();
            },
      highlightBorderRadius:
          highlightColor == null ? null : highlightBorderRadius,
      highlightColor: highlightColor ?? Colors.transparent,
      onLongPressUp: onLongPressUp == null
          ? null
          : () {
              if (enableFeedback) {
                HapticFeedbackUtils.selectionClick();
              }
              onLongPressUp!();
            },
      child: child,
    );
  }
}
