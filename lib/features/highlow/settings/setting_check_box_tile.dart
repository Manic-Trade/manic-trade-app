import 'package:finality/common/utils/color_scheme_extensions.dart';
import 'package:finality/common/utils/haptic_feedback_utils.dart';
import 'package:finality/common/widgets/dashed_divider.dart';
import 'package:finality/common/widgets/touchable.dart';
import 'package:finality/theme/app_color_theme.dart';
import 'package:finality/theme/attrs/text_color_theme.dart';
import 'package:flutter/material.dart';

class SettingCheckBoxTile extends StatelessWidget {
  final bool? value;
  final ValueChanged<bool?>? onChanged;
  final String title;
  final bool enabled;
  final bool showBadge;
  final VoidCallback? onLabelTap;

  const SettingCheckBoxTile({
    super.key,
    required this.value,
    required this.onChanged,
    required this.title,
    this.onLabelTap,
    this.enabled = true,
    this.showBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    var colorScheme = context.colorScheme;
    var textColorTheme = context.textColorTheme;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onLabelTap != null
          ? null
          : (onChanged != null ? _handleValueChange : null),
      child: Row(
        children: [
          Opacity(
            opacity: onChanged == null || !enabled ? 0.2 : 1,
            child: Transform.scale(
              scale: 0.9,
              child: Checkbox(
                value: value,
                visualDensity: VisualDensity.compact,
                onChanged: enabled && onChanged != null
                    ? (value) {
                        HapticFeedbackUtils.selectionClick();
                        onChanged!.call(value);
                      }
                    : null,
                overlayColor: WidgetStateProperty.all(Colors.transparent),
                splashRadius: 0,
                activeColor: colorScheme.primary,
                checkColor: colorScheme.onPrimary,
                side: BorderSide(
                  color: textColorTheme.textColorQuaternary,
                  width: 1,
                ),
              ),
            ),
          ),
          Touchable.plain(
            onTap: onLabelTap == null
                ? null
                : () {
                    onLabelTap!();
                  },
            child: IntrinsicWidth(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: onChanged == null || !enabled
                          ? textColorTheme.textColorHelper
                          : textColorTheme.textColorTertiary,
                    ),
                  ),
                  if (onLabelTap != null)
                    DashedDivider(
                      color: textColorTheme.textColorQuaternary,
                      height: 1.0,
                      thickness: 0.5,
                    )
                ],
              ),
            ),
          ),
          if (showBadge)
            Container(
              margin: const EdgeInsets.only(left: 4),
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: context.appColors.bearish,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }

  void _handleValueChange() {
    if (onChanged == null) return;
    HapticFeedbackUtils.selectionClick();
    switch (value) {
      case false:
        onChanged!(true);
      case true:
        onChanged!(false);
      case null:
        onChanged!(false);
    }
  }
}
