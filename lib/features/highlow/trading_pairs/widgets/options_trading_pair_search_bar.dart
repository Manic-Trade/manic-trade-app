import 'package:finality/common/utils/color_scheme_extensions.dart';
import 'package:finality/generated/assets.dart';
import 'package:finality/theme/attrs/text_color_theme.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class OptionsTradingPairSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onCancel;

  const OptionsTradingPairSearchBar(
      {super.key, required this.controller, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    var colorScheme = context.colorScheme;
    var textColorTheme = context.textColorTheme;
    final borderRadius = BorderRadius.circular(4);
    final border = OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: BorderSide(
        color: colorScheme.outlineVariant,
        width: 0.5,
      ),
    );
    final focusedBorder = OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: BorderSide(
        color: textColorTheme.textColorTertiary,
        width: 0.5,
      ),
    );

    return Padding(
      padding: Dimens.edgeInsetsH16,
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.search,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textColorTheme.textColorPrimary,
        ),
        maxLines: 1,
        cursorColor: textColorTheme.textColorPrimary,
        decoration: InputDecoration(
          hintText: 'Search assets...',
          constraints: const BoxConstraints(minHeight: 40, maxHeight: 40),
          hintStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: textColorTheme.textColorHelper,
          ),
          filled: true,
          fillColor: colorScheme.surfaceContainer,
          border: border,
          enabledBorder: border,
          focusedBorder: focusedBorder,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 0,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 10, right: 4),
            child: SvgPicture.asset(
              Assets.svgsIcSearchPrefix,
              color: textColorTheme.textColorHelper,
              width: 16,
              height: 16,
            ),
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 0, // 10 (左边距) + 16 (icon宽度) = 26
            minHeight: 0,
          ),
        ),
        //   onSubmitted: (_) => _handleNext(),
      ),
    );
  }
}
