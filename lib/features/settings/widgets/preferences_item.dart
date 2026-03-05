import 'package:finality/common/widgets/touchable.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:finality/theme/attrs/text_color_theme.dart';
import 'package:finality/theme/dimens.dart';

class PreferencesItem extends StatelessWidget {
  final String title;
  final String? trailingText;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showArrow;

  const PreferencesItem({
    super.key,
    required this.title,
    this.trailingText,
    this.trailing,
    this.onTap,
    this.showArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Touchable(
          onTap: onTap,
          child: Container(
            constraints: BoxConstraints(
              minHeight: 52,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: context.textTheme.bodyLarge,
                  ),
                ),
                if (trailing != null)
                  trailing!
                else if (trailingText != null) ...[
                  buildTrailingText(context, trailingText!),
                  Dimens.hGap8,
                ],
                Visibility(
                  visible: showArrow,
                  child: Icon(
                    Icons.keyboard_arrow_right_rounded,
                    color: context.textColorTheme.textColorTertiary,
                  ),
                ),
              ],
            ),
          ),
        ),
        Divider(
          indent: 16,
        ),
      ],
    );
  }

  static Widget buildTrailingText(BuildContext context, String text) {
    return Text(
      text,
      style: context.textTheme.bodyMedium?.copyWith(
        color: context.textColorTheme.textColorSecondary,
      ),
    );
  }
}
