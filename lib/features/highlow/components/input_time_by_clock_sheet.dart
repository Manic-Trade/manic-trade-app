import 'package:finality/common/utils/color_scheme_extensions.dart';
import 'package:finality/common/utils/haptic_feedback_utils.dart';
import 'package:finality/common/widgets/drag_handle.dart';
import 'package:finality/common/widgets/touchable.dart';
import 'package:finality/domain/options/entities/options_duration.dart';
import 'package:finality/features/highlow/utils/settle_time_utils.dart';
import 'package:finality/theme/app_color_theme.dart';
import 'package:finality/theme/attrs/text_color_theme.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/context_extensions.dart';

class InputTimeByClockSheet extends StatefulWidget {
  final TimerDuration initialDuration;
  final ValueListenable<int?> lastBeatSeconds;
  final List<TimerDuration> allDurations;

  const InputTimeByClockSheet({
    super.key,
    required this.initialDuration,
    required this.lastBeatSeconds,
    required this.allDurations,
  });

  @override
  State<InputTimeByClockSheet> createState() => _InputTimeByClockSheetState();
}

class _InputTimeByClockSheetState extends State<InputTimeByClockSheet> {
  late TimerDuration _selectedDuration;

  @override
  void initState() {
    super.initState();
    _selectedDuration = widget.initialDuration;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        border: Border(
          top: BorderSide(
            color: context.colorScheme.outlineVariant,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const DragHandle(),
            Padding(
              padding: Dimens.edgeInsetsA16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Settle Time',
                    style: context.textTheme.titleLarge?.copyWith(
                      color: context.appColors.bottomSheetTitle,
                    ),
                  ),
                  Dimens.vGap40,
                  // 时间选项网格
                  _buildDurationGrid(context),
                  Dimens.vGap32,
                  // Confirm 按钮
                  _buildConfirmButton(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationGrid(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 每行 3 个，计算宽度
        const spacing = 16.0; // item 间距
        const itemsPerRow = 3; // 每行 3 个
        final itemWidth =
            (constraints.maxWidth - spacing * (itemsPerRow - 1)) / itemsPerRow;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: widget.allDurations.map((duration) {
            return SizedBox(
              width: itemWidth,
              child: ValueListenableBuilder(
                  valueListenable: widget.lastBeatSeconds,
                  builder: (context, value, child) {
                    return _buildClockOption(context, value, duration);
                  }),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildClockOption(
      BuildContext context, int? lastBeatSeconds, TimerDuration duration) {
    final isSelected = _selectedDuration == duration;
    final label = _formatClock(lastBeatSeconds, duration);
    return Touchable.plain(
      onTap: () {
        setState(() {
          _selectedDuration = duration;
        });
      },
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: isSelected
              ? context.colorScheme.primary.withValues(alpha: 0.05)
              : context.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected
                ? context.colorScheme.primary
                : context.colorScheme.outlineVariant,
            width: isSelected ? 1 : 0.8,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: context.textTheme.labelLarge?.copyWith(
              color: isSelected
                  ? context.textColorTheme.textColorPrimary
                  : context.textColorTheme.textColorSecondary,
            ),
          ),
        ),
      ),
    );
  }

  String _formatClock(int? lastBeatSeconds, TimerDuration duration) {
    if (lastBeatSeconds == null) {
      return '--:--';
    }
    final settleTime = SettleTimeUtils.calculateSettleTimeBySeconds(
        lastBeatSeconds, duration.seconds);
    return SettleTimeUtils.formatSettleTime(settleTime);
  }

  Widget _buildConfirmButton(BuildContext context) {
    return Touchable.button(
      child: SizedBox(
        width: double.infinity,
        height: 40,
        child: FilledButton(
          onPressed: () {
            HapticFeedbackUtils.lightImpact();
            Navigator.of(context).pop(_selectedDuration);
          },
          style: FilledButton.styleFrom(
            backgroundColor: context.colorScheme.primary,
            foregroundColor: context.colorScheme.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          child: Text(
            'Confirm',
            style: context.textTheme.labelMedium?.copyWith(
              color: context.colorScheme.onPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

/// 显示 Duration 选择底部弹窗
Future<TimerDuration?> showInputTimeByClockSheet(
  BuildContext context, {
  required TimerDuration initialDuration,
  required ValueListenable<int?> lastBeatSeconds,
  List<TimerDuration> allDurations = const [
    TimerDuration.m1,
    TimerDuration.m2,
    TimerDuration.m3,
    TimerDuration.m4,
    TimerDuration.m5,
  ],
}) {
  return showModalBottomSheet<TimerDuration>(
    backgroundColor: Colors.transparent,
    elevation: 0,
    isScrollControlled: true,
    context: context,
    builder: (_) => InputTimeByClockSheet(
      initialDuration: initialDuration,
      lastBeatSeconds: lastBeatSeconds,
      allDurations: allDurations,
    ),
  );
}
