import 'package:finality/common/utils/color_scheme_extensions.dart';
import 'package:finality/common/widgets/touchable.dart';
import 'package:finality/theme/attrs/text_color_theme.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class UserMenuItem extends StatelessWidget {
  /// SVG 资源路径；当传入 [iconData] 时可不传。
  final String? svgAssetPath;

  /// 可选 IconData，优先级高于 [svgAssetPath]。用于直接使用 Remix 等字体图标。
  final IconData? iconData;

  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? titleColor;
  final bool showBadge;

  const UserMenuItem({
    super.key,
    this.svgAssetPath,
    this.iconData,
    required this.title,
    this.trailing,
    this.onTap,
    this.titleColor,
    this.showBadge = false,
  }) : assert(svgAssetPath != null || iconData != null,
            'UserMenuItem 必须传 svgAssetPath 或 iconData 之一');

  @override
  Widget build(BuildContext context) {
    final color = titleColor ?? context.textColorTheme.textColorTertiary;
    return Touchable(
      onTap: onTap,
      child: Container(
        height: 56,
        padding: Dimens.edgeInsetsH16,
        child: Row(
          children: [
            _buildLeadingIcon(context, color, showBadge),
            Dimens.hGap4,
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }

  Widget _buildLeadingIcon(BuildContext context, Color color, bool showBadge) {
    final iconWidget = iconData != null
        ? Icon(iconData, size: 16, color: color)
        : SvgPicture.asset(
            svgAssetPath!,
            width: 16,
            height: 16,
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
          );

    if (!showBadge) {
      return SizedBox(
        width: 24,
        height: 24,
        child: Center(child: iconWidget),
      );
    }
    return SizedBox(
      width: 24,
      height: 24,
      child: Center(
        child: SizedBox(
          width: 16,
          height: 16,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              iconWidget,
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: context.colorScheme.surfaceContainerHigh, // 边框色
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF412C),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
