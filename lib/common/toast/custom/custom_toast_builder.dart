import 'dart:async';
import 'dart:ui';

import 'package:finality/common/toast/app_toast_data.dart';
import 'package:finality/common/toast/app_toast_theme.dart';
import 'package:finality/common/utils/color_scheme_extensions.dart';
import 'package:finality/theme/attrs/text_color_theme.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

const _kBorderRadius = 8.0;
const _kAccentStripWidth = 4.0;

/// Top-level builder returned by [toastification.showCustom].
///
/// Wraps the visual toast content with drag-to-dismiss, pause-on-hover,
/// and tap handling – behaviour borrowed from the library's built-in
/// container without pulling in its theme / style machinery.
class CustomToastBuilder extends StatefulWidget {
  const CustomToastBuilder({
    super.key,
    required this.item,
    required this.data,
  });

  final ToastificationItem item;
  final AppToastData data;

  @override
  State<CustomToastBuilder> createState() => _CustomToastBuilderState();
}

class _CustomToastBuilderState extends State<CustomToastBuilder> {
  /// 是否允许用户手动关闭（关闭按钮 + 滑动关闭）
  late bool _isDismissible;
  Timer? _dismissibleTimer;

  @override
  void initState() {
    super.initState();
    final dismissibleAfter = widget.data.dismissibleAfter;
    final isLoading = widget.data.type == AppToastType.loading;

    if (dismissibleAfter != null) {
      // 有 dismissibleAfter，初始不可关闭，到时间后允许
      _isDismissible = false;
      _dismissibleTimer = Timer(dismissibleAfter, () {
        if (mounted) setState(() => _isDismissible = true);
      });
    } else {
      // 没有 dismissibleAfter：loading 默认不可关闭，其他默认可关闭
      _isDismissible = !isLoading;
    }
  }

  @override
  void dispose() {
    _dismissibleTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget toast = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: _ToastContent(
        data: widget.data,
        onCloseTap: () => toastification.dismiss(widget.item),
        showCloseButton: _isDismissible,
      ),
    );

    // Pause auto-close timer on mouse hover (desktop).
    if (widget.item.hasTimer) {
      toast = MouseRegion(
        onEnter: (_) => widget.item.pause(),
        onExit: (_) => widget.item.start(),
        child: toast,
      );
    }

    // Tap callback.
    if (widget.data.onTap != null) {
      toast = GestureDetector(onTap: widget.data.onTap, child: toast);
    }

    // 允许关闭时才启用滑动关闭
    if (_isDismissible) {
      toast = _FadeDismissible(
        item: widget.item,
        onDismissed: widget.data.onDismiss,
        child: toast,
      );
    }

    return toast;
  }
}

// ─── Visual content ─────────────────────────────────────────────────────────

class _ToastContent extends StatelessWidget {
  const _ToastContent({
    required this.data,
    required this.onCloseTap,
    this.showCloseButton = true,
  });

  final AppToastData data;
  final VoidCallback onCloseTap;
  final bool showCloseButton;

  @override
  Widget build(BuildContext context) {
    final accent = data.colorConfig.primaryColor;
    final baseColor = context.colorScheme.surfaceContainer;
    // Layer 1: solid surfaceContainer
    // Layer 2: primaryColor at 5% opacity fading left→right
    // Pre-blend into a single LinearGradient.
    final gradientStart = Color.alphaBlend(
      accent.withValues(alpha: 0.05),
      baseColor,
    );

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [gradientStart, baseColor],
        ),
        borderRadius: BorderRadius.circular(_kBorderRadius),
        border: Border.all(color: context.colorScheme.outlineVariant, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.70),
            blurRadius: 10,
            spreadRadius: -6,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.40),
            blurRadius: 25,
            spreadRadius: -5,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_kBorderRadius - 1),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 64),
          child: Stack(
            children: [
              // Main content – determines the Stack's size
              Padding(
                padding:
                    const EdgeInsetsDirectional.only(start: _kAccentStripWidth),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      _IconBox(
                        type: data.type,
                        accentColor: accent,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _TextSection(
                          title: data.title,
                          subtitle: data.subtitle,
                        ),
                      ),
                      if (data.trailingText != null) ...[
                        const SizedBox(width: 8),
                        _TrailingSection(
                          text: data.trailingText!,
                          textColor: data.resolvedTrailingTextColor,
                          label: data.trailingLabel,
                        ),
                      ],
                      if (showCloseButton) ...[
                        const SizedBox(width: 8),
                        _CloseButton(onTap: onCloseTap),
                      ],
                    ],
                  ),
                ),
              ),
              // Left accent strip – stretches to fill Stack height
              PositionedDirectional(
                start: 0,
                top: 0,
                bottom: 0,
                width: _kAccentStripWidth,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: accent,
                    boxShadow: [
                      BoxShadow(
                        color: accent.withValues(alpha: 0.60),
                        blurRadius: 12,
                      ),
                    ],
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

// ─── Sub-widgets ────────────────────────────────────────────────────────────

class _IconBox extends StatelessWidget {
  const _IconBox({required this.type, required this.accentColor});

  final AppToastType? type;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final isLoading = type == AppToastType.loading;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: accentColor.withValues(alpha: 0.1),
        border: Border.all(color: accentColor.withValues(alpha: 0.3), width: 1),
      ),
      alignment: Alignment.center,
      child: isLoading
          ? SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: accentColor,
              ),
            )
          : Icon(_iconForType(type), color: accentColor, size: 20),
    );
  }
}

class _TextSection extends StatelessWidget {
  const _TextSection({required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
              color: context.textColorTheme.textColorPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 14,
              height: 1.2142),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: TextStyle(
                fontWeight: FontWeight.w500,
                color: context.textColorTheme.textColorQuaternary,
                fontSize: 12,
                height: 1.25),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}

class _TrailingSection extends StatelessWidget {
  const _TrailingSection({
    required this.text,
    this.textColor,
    this.label,
  });

  final String text;
  final Color? textColor;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (label != null)
          Text(
            label!,
            style: TextStyle(
                color: context.textColorTheme.textColorQuaternary,
                fontWeight: FontWeight.w500,
                fontSize: 12,
                height: 1.25),
          ),
        Text(
          text,
          style: TextStyle(
              color: textColor ?? context.textColorTheme.textColorPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 18,
              height: 1.2222),
        ),
      ],
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 24,
        height: 24,
        child: Icon(
          Icons.close,
          color: context.textColorTheme.textColorQuaternary,
          size: 20,
        ),
      ),
    );
  }
}

// ─── Helpers ────────────────────────────────────────────────────────────────

IconData _iconForType(AppToastType? type) {
  return switch (type) {
    AppToastType.success => Icons.check_circle_outline,
    AppToastType.failed => Icons.warning_amber_rounded,
    AppToastType.loading =>
      Icons.hourglass_empty, // 实际由 _IconBox 中的 CircularProgressIndicator 替代
    AppToastType.gameWon => Icons.sentiment_satisfied_alt_outlined,
    AppToastType.gameLost => Icons.sentiment_dissatisfied_outlined,
    AppToastType.date => Icons.calendar_today_outlined,
    AppToastType.gift => Icons.card_giftcard_outlined,
    null => Icons.info_outline,
  };
}

// ─── Drag to dismiss ────────────────────────────────────────────────────────

class _FadeDismissible extends StatefulWidget {
  const _FadeDismissible({
    required this.item,
    this.onDismissed,
    required this.child,
  });

  final ToastificationItem item;
  final VoidCallback? onDismissed;
  final Widget child;

  @override
  State<_FadeDismissible> createState() => _FadeDismissibleState();
}

class _FadeDismissibleState extends State<_FadeDismissible> {
  double _dragProgress = 0;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (e) {
        // Only pause for touch – mouse hover is handled by MouseRegion.
        if (e.kind != PointerDeviceKind.mouse) {
          widget.item.pause();
        }
      },
      onPointerUp: (e) {
        if (e.kind != PointerDeviceKind.mouse) {
          widget.item.start();
        }
      },
      child: Dismissible(
        key: ValueKey('toast-dismiss-${widget.item.id}'),
        direction: DismissDirection.horizontal,
        onUpdate: (details) {
          setState(() => _dragProgress = details.progress);
        },
        onDismissed: (_) {
          widget.onDismissed?.call();
          toastification.dismiss(widget.item, showRemoveAnimation: false);
        },
        child: _dragProgress > 0
            ? Opacity(
                opacity: 1 - _dragProgress,
                child: widget.child,
              )
            : widget.child,
      ),
    );
  }
}
