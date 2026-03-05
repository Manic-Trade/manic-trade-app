import 'package:finality/common/utils/color_scheme_extensions.dart';
import 'package:finality/common/utils/haptic_feedback_utils.dart';
import 'package:finality/common/widgets/touchable.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/material.dart';
import 'package:finality/common/utils/localization_extensions.dart';
import 'package:haptic_feedback/haptic_feedback.dart';

class PercentageSelector extends StatelessWidget {
  final Function(double percentage) onPercentageSelected;
  final bool enable;

  const PercentageSelector({
    super.key,
    required this.onPercentageSelected,
    this.enable = true,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !enable,
      child: Padding(
        padding: Dimens.edgeInsetsH28,
        child: Row(
          children: [
            Expanded(child: _buildPercentButton(context, '10%', 0.1)),
            Dimens.hGap12,
            Expanded(child: _buildPercentButton(context, '25%', 0.25)),
            Dimens.hGap12,
            Expanded(child: _buildPercentButton(context, '50%', 0.5)),
            Dimens.hGap12,
            Expanded(
              child: _buildPercentButton(
                  context, context.strings.title_transfer_percentage_max, 1.0),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPercentButton(
      BuildContext context, String text, double percentage) {
    return Touchable.plain(
      shrinkScaleFactor: 0.86,
      quickResponse: true,
      enableFeedback: false,
      onTap: () {
        HapticFeedbackUtils.vibrate(HapticsType.soft);
        onPercentageSelected(percentage);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        width: double.infinity,
        decoration: BoxDecoration(
          color: context.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
