import 'package:finality/common/utils/haptic_feedback_utils.dart';
import 'package:finality/theme/attrs/text_color_theme.dart';
import 'package:flutter/material.dart';
import 'package:finality/common/utils/color_scheme_extensions.dart';
import 'package:jelly/jelly.dart';

class BouncyNavItem {
  final Widget activeIcon;
  final Widget icon;
  final String label;
  final GestureTapCallback? onLongPress;
  final int? badgeCount;

  BouncyNavItem({
    required this.activeIcon,
    required this.icon,
    required this.label,
    this.onLongPress,
    this.badgeCount,
  });
}

class BouncyNavBar extends StatelessWidget {
  final List<BouncyNavItem> items;
  final int currentIndex;
  final Function(int) onTap;
  final double height;
  final Color? backgroundColor;
  final bool showLabel;

  const BouncyNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.height = 66.0,
    this.backgroundColor,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: height,
        color: backgroundColor ?? context.colorScheme.surface,
        child: Row(
          children: List.generate(
            items.length,
            (index) => Expanded(
              child: _buildNavItem(
                context: context,
                activeIcon: items[index].activeIcon,
                icon: items[index].icon,
                label: items[index].label,
                badgeCount: items[index].badgeCount,
                isSelected: currentIndex == index,
                onTap: () {
                  HapticFeedbackUtils.lightImpact();
                  onTap(index);
                },
                onLongPress: items[index].onLongPress,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required Widget activeIcon,
    required Widget icon,
    required String label,
    required int? badgeCount,
    required bool isSelected,
    required GestureTapCallback onTap,
    GestureTapCallback? onLongPress,
  }) {
    return Jelly(
      onTap: onTap,
      onLongPress: onLongPress == null
          ? null
          : () {
              HapticFeedbackUtils.mediumImpact();
              onLongPress();
            },
      highlightColor: Colors.transparent,
      shrinkScaleFactor: 0.90,
      highlightBorderRadius: null,
      quickResponse: true,
      shrinkDuration: const Duration(milliseconds: 90),
      delayedDurationBeforeGrow: const Duration(milliseconds: 10),
      growDuration: const Duration(milliseconds: 100),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: showLabel
              ? [
                  Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.topRight,
                    children: [
                      Container(
                        padding: EdgeInsets.only(top: 3, bottom: 4),
                        child: isSelected ? activeIcon : icon,
                      ),
                      if (badgeCount != null && badgeCount > 0)
                        Positioned(
                          right: -10,
                          top: -2,
                          child: Container(
                            padding: badgeCount > 9
                                ? const EdgeInsets.symmetric(horizontal: 4)
                                : EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            decoration: BoxDecoration(
                              color: Color(0xFF1E1A13),
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(3),
                              border: Border.all(
                                color: Color(0xFF573A0D),
                                width: 0.5,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                badgeCount > 99 ? '99+' : badgeCount.toString(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: context.colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected
                          ? context.colorScheme.primary
                          : context.textColorTheme.textColorSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ]
              : [
                  isSelected ? activeIcon : icon,
                ],
        ),
      ),
    );
  }
}
