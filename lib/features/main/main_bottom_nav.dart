import 'dart:ui';

import 'package:finality/common/utils/color_scheme_extensions.dart';
import 'package:finality/common/utils/haptic_feedback_utils.dart';
import 'package:finality/theme/attrs/text_color_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jelly/jelly.dart';

class MainBottomNavItem {
  final Widget activeIcon;
  final Widget icon;
  final String label;
  final ValueListenable<bool>? showBadge;

  /// 选中态图标发光的 blur radius，对应 CSS box-shadow 的 blur-radius
  /// 例如 6px → sigma 3，3px → sigma 1.5
  final double glowBlurRadius;

  MainBottomNavItem({
    required this.activeIcon,
    required this.icon,
    required this.label,
    this.glowBlurRadius = 6.0,
    this.showBadge,
  });
}

class MainBottomNav extends StatelessWidget {
  final List<MainBottomNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final double height;

  const MainBottomNav({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.height = 49.0,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        color: context.colorScheme.surface,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 顶部渐变分割线
            Container(
              height: 1,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0x4D181818), // rgba(24, 24, 24, 0.3)
                    Color(0x4DDB8300), // rgba(219, 131, 0, 0.3)
                    Color(0x4D181818), // rgba(24, 24, 24, 0.3)
                  ],
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
            ),
            // 导航内容
            SizedBox(
              height: height,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: List.generate(
                    items.length,
                    (index) => Expanded(
                      child: _buildNavItem(
                        context: context,
                        item: items[index],
                        isSelected: currentIndex == index,
                        onTap: () {
                          HapticFeedbackUtils.lightImpact();
                          onTap(index);
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required MainBottomNavItem item,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Jelly(
      onTap: onTap,
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
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // 图标区域：布局上固定 24x24，glow 通过 Clip.none 溢出
            _buildMenuIcon(context, item, isSelected),
            const SizedBox(height: 2),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                height: 1.25,
                color: isSelected
                    ? context.colorScheme.primary
                    : context.textColorTheme.textColorHelper,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuIcon(
      BuildContext context, MainBottomNavItem item, bool isSelected) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: isSelected
              ? _buildGlowIcon(item.activeIcon, item.glowBlurRadius)
              : item.icon,
        ),
        if (item.showBadge != null)
          ValueListenableBuilder(
              valueListenable: item.showBadge!,
              builder: (context, value, child) {
                if (!value) return SizedBox.shrink();
                return Positioned(
                  right: 1.5,
                  top: 0,
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
                );
              }),
      ],
    );
  }

  /// 选中态图标：底层模糊 + 上层清晰，产生跟随图标形状的发光效果
  /// [glowBlurRadius] 对应 CSS box-shadow blur-radius，sigma = blurRadius / 2
  Widget _buildGlowIcon(Widget icon, double glowBlurRadius) {
    final sigma = glowBlurRadius / 2;
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        // 模糊层 → 发光效果（溢出 24x24 但不影响布局）
        Positioned.fill(
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
            child: icon,
          ),
        ),
        // 清晰图标层
        icon,
      ],
    );
  }
}
