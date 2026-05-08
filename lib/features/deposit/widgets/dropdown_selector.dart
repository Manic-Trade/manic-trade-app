import 'package:cached_network_image/cached_network_image.dart';
import 'package:finality/common/widgets/touchable.dart';
import 'package:finality/generated/assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kumi_popup_window/kumi_popup_window.dart';
import 'package:skeletonizer/skeletonizer.dart';

class DropdownItem {
  final String id;
  final String name;
  final String iconUrl;

  const DropdownItem({
    required this.id,
    required this.name,
    required this.iconUrl,
  });
}

/// 充值页下拉选择器，使用 showPopupWindow 弹出浮层
class DropdownSelector extends StatelessWidget {
  final List<DropdownItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final bool isLoading;

  const DropdownSelector({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    this.isLoading = false,
  });

  static const double _itemHeight = 44;
  static const int _maxVisibleItems = 5;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Bone(
        height: 42,
        width: double.infinity,
        uniRadius: 6,
      );
    }
    final selected = items.isNotEmpty && selectedIndex < items.length
        ? items[selectedIndex]
        : null;

    return Builder(builder: (buttonContext) {
      return Touchable.plain(
        onTap: () => _showPopup(buttonContext),
        child: Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFF262626)),
          ),
          child: Row(
            children: [
              if (selected != null && selected.iconUrl.isNotEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: selected.iconUrl,
                    width: 24,
                    height: 24,
                    errorWidget: (_, __, ___) => const SizedBox(
                      width: 24,
                      height: 24,
                    ),
                    placeholder: (_, __) => const SizedBox(
                      width: 24,
                      height: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Text(
                  selected?.name ?? '',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              const Icon(Icons.keyboard_arrow_down,
                  size: 16, color: Color(0xFF666666)),
            ],
          ),
        ),
      );
    });
  }

  void _showPopup(BuildContext context) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final triggerWidth = renderBox.size.width;

    showPopupWindow(
      context,
      targetRenderBox: renderBox,
      gravity: KumiPopupGravity.leftTop,
      customAnimation: true,
      clickOutDismiss: true,
      clickBackDismiss: true,
      offsetY: 44 + 4,
      duration: const Duration(milliseconds: 80),
      customPop: false,
      customPage: false,
      bgColor: Colors.transparent,
      childFun: (popup) => _buildAnimateLayout(
        context,
        controller: popup.controller!,
        child: _DropdownPopupContent(
          items: items,
          selectedIndex: selectedIndex,
          triggerWidth: triggerWidth,
          onSelected: (index) {
            popup.dismiss(context);
            onSelected(index);
          },
        ),
      ),
    );
  }
}

// ── Popup 内容 ──────────────────────────────────────────────

class _DropdownPopupContent extends StatelessWidget {
  const _DropdownPopupContent({
    required this.items,
    required this.selectedIndex,
    required this.triggerWidth,
    required this.onSelected,
  });

  final List<DropdownItem> items;
  final int selectedIndex;
  final double triggerWidth;
  final ValueChanged<int> onSelected;

  static const double _itemHeight = DropdownSelector._itemHeight;
  static const int _maxVisibleItems = DropdownSelector._maxVisibleItems;

  @override
  Widget build(BuildContext context) {
    final visibleCount =
        items.length > _maxVisibleItems ? _maxVisibleItems : items.length;
    final listHeight = visibleCount * _itemHeight;

    return Container(
      width: triggerWidth,
      height: listHeight,
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF262626)),
      ),
      clipBehavior: Clip.antiAlias,
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: items.length,
        itemExtent: _itemHeight,
        physics: items.length > _maxVisibleItems
            ? const ClampingScrollPhysics()
            : const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final item = items[index];
          final isSelected = index == selectedIndex;
          return Touchable.plain(
            onTap: () {
              onSelected(index);
            },
            child: Container(
              height: _itemHeight,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  if (item.iconUrl.isNotEmpty) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: item.iconUrl,
                        width: 24,
                        height: 24,
                        errorWidget: (_, __, ___) =>
                            const SizedBox(width: 24, height: 24),
                        placeholder: (_, __) => const SizedBox(
                          width: 24,
                          height: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: Text(
                      item.name,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF666666),
                            fontWeight: isSelected
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                    ),
                  ),
                  if (isSelected)
                    SvgPicture.asset(Assets.svgsRemixCheckboxCircleLine,
                        width: 14, height: 14),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── 弹出动画 ────────────────────────────────────────────────

Widget _buildAnimateLayout(
  BuildContext context, {
  required Widget child,
  required AnimationController controller,
}) {
  const curve = Curves.decelerate;

  return ScaleTransition(
    key: GlobalKey(),
    alignment: Alignment.topCenter,
    scale: Tween(begin: 0.86, end: 1.0)
        .chain(CurveTween(curve: curve))
        .animate(controller),
    child: FadeTransition(
      opacity: Tween(begin: 0.0, end: 1.0)
          .chain(CurveTween(curve: curve))
          .animate(controller),
      child: child,
    ),
  );
}
