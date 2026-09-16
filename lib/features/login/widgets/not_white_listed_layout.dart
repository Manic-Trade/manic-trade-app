import 'package:finality/common/constants/app_links.dart';
import 'package:finality/common/utils/color_scheme_extensions.dart';
import 'package:finality/common/widgets/touchable.dart';
import 'package:finality/features/login/widgets/top_logo_on_logo.dart';
import 'package:finality/generated/assets.dart';
import 'package:finality/theme/attrs/druk_wide_font.dart';
import 'package:finality/theme/attrs/text_color_theme.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class NotWhiteListedLayout extends StatelessWidget {
  const NotWhiteListedLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textColorTheme = context.textColorTheme;
    return LayoutBuilder(builder: (context, constraints) {
      var maxHeight = constraints.maxHeight;
      var topOffset = maxHeight * 0.27;
      return SingleChildScrollView(
        child: Padding(
          padding: Dimens.edgeInsetsScreenH,
          child: Align(
            alignment: Alignment.center,
            child: Column(
              children: [
                SizedBox(height: topOffset),
                _buildIcon(colorScheme),
                Dimens.vGap32,
                Text(
                  'ACCESS RESTRICTED',
                  style: DrukWideFont.textStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColorTheme.textColorPrimary,
                    letterSpacing: 1.5,
                  ),
                ),
                Dimens.vGap12,
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 313),
                  child: Column(
                    children: [
                      Text(
                        'You\'re not on the whitelist yet. Please fill out the application form to apply for whitelist access.',
                        textAlign: TextAlign.center,
                        style: context.textTheme.bodyLarge?.copyWith(
                          color: textColorTheme.textColorTertiary,
                        ),
                      ),
                      Dimens.vGap32,
                      _buildApplyButton(context, colorScheme, textColorTheme),
                    ],
                  ),
                ),
                Dimens.vGap32,
                Dimens.safeBottomSpace,
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildIcon(ColorScheme colorScheme) {
    return TopLogoOnLogo(
      child: SvgPicture.asset(
        Assets.svgsIcLoginAccessRestricted,
        width: 28,
        height: 28,
      ),
    );
  }

  Widget _buildApplyButton(BuildContext context, ColorScheme colorScheme,
      TextColorTheme textColorTheme) {
    return Touchable.button(
      onTap: () {
        launchUrl(
          Uri.parse(AppLinks.urlApplyForWhitelist),
          mode: LaunchMode.externalApplication,
        );
      },
      child: Container(
        height: 40,
        width: double.infinity,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: colorScheme.outlineVariant, width: 0.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              Assets.svgsIcWhiteListApply,
              width: 16,
              height: 16,
              colorFilter: ColorFilter.mode(
                textColorTheme.textColorTertiary,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Apply Now',
              style: context.textTheme.labelSmall?.copyWith(
                color: textColorTheme.textColorTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
