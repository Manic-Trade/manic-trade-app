import 'package:finality/features/login/widgets/not_white_listed_layout.dart';
import 'package:finality/theme/attrs/text_color_theme.dart';
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;

class AccessRestrictedScreen extends StatelessWidget {
  const AccessRestrictedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: context.textColorTheme.textColorTertiary,
      ),
      body: NotWhiteListedLayout(),
    );
  }
}
