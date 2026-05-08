import 'package:finality/theme/attrs/text_color_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/context_extensions.dart';

class PreferencesSectionTitle extends StatelessWidget {
  final String title;

  const PreferencesSectionTitle({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: Text(
        title.toUpperCase(),
        style: context.textTheme.bodyMedium?.copyWith(
          color: context.textColorTheme.textColorSecondary,
        ),
      ),
    );
  }
}
