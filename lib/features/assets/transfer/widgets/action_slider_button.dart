import 'package:action_slider/action_slider.dart';
import 'package:finality/common/utils/haptic_feedback_utils.dart';
import 'package:finality/common/widgets/touchable.dart';
import 'package:finality/core/error/cancel_error.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:finality/common/utils/color_scheme_extensions.dart';
import 'package:finality/generated/assets.dart';

class ActionSliderButton extends StatefulWidget {
  final bool enabled;
  final BuildContext context;
  final Future<bool> Function() action;
  final VoidCallback? onSuccess;
  final Widget child;
  final bool noSwap;

  const ActionSliderButton(
      {super.key,
      required this.enabled,
      required this.context,
      required this.action,
      required this.child,
      this.onSuccess,
      this.noSwap = false});

  @override
  State<ActionSliderButton> createState() => _ActionSliderButtonState();
}

class _ActionSliderButtonState extends State<ActionSliderButton> {
  DateTime? _lastVibrationTime;
  static const _minVibrationInterval = Duration(milliseconds: 50);

  bool isSuccess = false;
  bool isError = false;
  Color successBgColor = Colors.green;
  Color errorBgColor = Colors.red;
  // You can adjust this value to control frequency
  @override
  Widget build(BuildContext context) {
    if (widget.noSwap) {
      return _buildNoSwapAction(context, widget.child);
    }
    var successOrError = isSuccessOrError();
    var successOrErrorBgColor = getSuccessOrErrorBgColor(context);
    return IgnorePointer(
      ignoring: !widget.enabled,
      child: Opacity(
        opacity: widget.enabled || successOrError ? 1.0 : 0.5,
        child: ActionSlider.standard(
          sliderBehavior: SliderBehavior.stretch,
          style: SliderStyle(
            backgroundColor: context.colorScheme.surfaceContainerHigh,
            toggleColor: successOrError
                ? successOrErrorBgColor
                : context.colorScheme.primary.withOpacity(0.72),
            toggleGradient: isSuccessOrError()
                ? LinearGradient(colors: [
                    successOrErrorBgColor,
                    successOrErrorBgColor,
                  ])
                : widget.enabled
                    ? LinearGradient(colors: [
                        context.colorScheme.primary.withOpacity(0.68),
                        context.colorScheme.primary,
                      ], stops: const [
                        0.0,
                        0.8
                      ])
                    : null,
            boxShadow: [],
          ),
          toggleWidth: 86,
          borderWidth: 0,
          height: 60,
          iconAlignment: Alignment.centerRight,
          loadingIcon: Center(
              child: SizedBox(
            width: 24.0,
            height: 24.0,
            child: CircularProgressIndicator(
                strokeWidth: 4.0, color: context.colorScheme.onPrimary),
          )),
          successIcon: Center(
              child: Icon(Icons.check_rounded,
                  color: context.colorScheme.onPrimary)),
          failureIcon: Center(
              child: Icon(Icons.close_rounded,
                  color: context.colorScheme.onPrimary)),
          icon: Container(
              decoration: BoxDecoration(
                color: widget.enabled
                    ? (successOrError
                        ? successOrErrorBgColor
                        : context.colorScheme.primary)
                    : const Color(0xFFD8D8D9),
                borderRadius: const BorderRadius.all(Radius.circular(30.0)),
              ),
              width: 86,
              child: Center(
                  child: SvgPicture.asset(
                Assets.svgsIcActionSliderArrow,
                colorFilter: ColorFilter.mode(
                    widget.enabled
                        ? context.colorScheme.onPrimary
                        : Colors.grey.shade700,
                    BlendMode.srcIn),
              ))),
          actionThresholdType: ThresholdType.release,
          stateChangeCallback: (oldState, state, controller) {
            if (state.slidingStatus == SlidingStatus.dragged) {
              final now = DateTime.now();
              if (_lastVibrationTime == null ||
                  now.difference(_lastVibrationTime!) >=
                      _minVibrationInterval) {
                HapticFeedbackUtils.selectionClick();
                _lastVibrationTime = now;
              }
            }
          },
          action: (controller) async {
            vibration(HapticsType.warning);
            controller.loading(expanded: true);
            try {
              var bool = await widget.action();

              if (bool) {
                resetSuccessAndError();
                controller.reset();
                return;
              }
              if (context.mounted) {
                if (isSuccess != true) {
                  setState(() {
                    isSuccess = true;
                  });
                }
                controller.success(expanded: true);
                vibration(HapticsType.success);
              }
              Future.delayed(const Duration(milliseconds: 1000), () {
                widget.onSuccess?.call();
              });
            } catch (error) {
              if (error is CancelError) {
                Fluttertoast.showToast(msg: error.message);
                return;
              }
              if (context.mounted) {
                if (error is! CancelError) {
                  vibration(HapticsType.error);
                }
                if (isError != true) {
                  setState(() {
                    isError = true;
                  });
                }
                controller.failure(expanded: true);
                Future.delayed(const Duration(milliseconds: 1000), () {
                  if (context.mounted) {
                    resetSuccessAndError();
                    controller.reset();
                  }
                });
              }
            }
          },
          child: widget.child,
        ),
      ),
    );
  }

  Widget _buildNoSwapAction(BuildContext context, Widget child) {
    return IgnorePointer(
      ignoring: !widget.enabled,
      child: Opacity(
        opacity: widget.enabled ? 1.0 : 0.5,
        child: Touchable(
          onTap: () async {
            await widget.action();
          },
          child: Container(
            width: double.infinity,
            height: 60,
            decoration: BoxDecoration(
              color: context.colorScheme.primary,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Center(
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  bool isSuccessOrError() {
    return isSuccess || isError;
  }

  Color getSuccessOrErrorBgColor(BuildContext context) {
    if (isError) {
      return errorBgColor;
    } else if (isSuccess) {
      return successBgColor;
    }
    return context.colorScheme.primary;
  }

  void resetSuccessAndError() {
    if (isError || isSuccess) {
      setState(() {
        isError = false;
        isSuccess = false;
      });
    }
  }

  Future<void> vibration(HapticsType type) async {
    try {
      final canVibrate = await Haptics.canVibrate();
      if (canVibrate) {
        await Haptics.vibrate(type);
      }
    } catch (e) {
      //debugPrint('Vibration failed: $e');
    }
  }
}
