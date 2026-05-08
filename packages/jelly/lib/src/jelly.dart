import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class Jelly extends StatefulWidget {
  const Jelly({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.onLongPressUp,
    this.shrinkScaleFactor = 0.965,
    this.shrinkCurve = Curves.easeInSine,
    this.growCurve = Curves.easeOutSine,
    this.shrinkDuration = const Duration(milliseconds: 130),
    this.growDuration = const Duration(milliseconds: 100),
    this.delayedDurationBeforeGrow = const Duration(milliseconds: 25),
    this.highlightBorderRadius,
    this.highlightColor = const Color(0x1F939BAC),
    this.statesController,
    this.focusNode,
    this.canRequestFocus = true,
    this.onFocusChange,
    this.autofocus = false,
    this.quickResponse = false,
  }) : assert(shrinkScaleFactor > 0 && shrinkScaleFactor <= 1,
            'shrinkScaleFactor must be greater than 0 and less than or equal to 1');

  /// The child widget that will have the shrink/grow animation applied.
  final Widget child;

  /// Callback methods for various touch interactions.
  final Function()? onTap, onLongPress, onLongPressUp;

  /// The closer to 0, the more it will shrink.
  /// Values between 0 and 1 (exclusive) are valid.
  final double shrinkScaleFactor;

  /// The curve for shrink and grow animations.
  final Curve shrinkCurve, growCurve;

  /// The duration for the shrink and grow animations.
  final Duration shrinkDuration, growDuration;

  /// Delay before the grow animation starts after the shrink animation completes.
  ///
  /// You can set it to [Duration.zero] to remove the delay, but a small delay provides a smoother effect.
  final Duration delayedDurationBeforeGrow;

  /// Border radius for the highlight overlay widget.
  final BorderRadius? highlightBorderRadius;

  /// Color that will be highlighted when the widget is tapped.
  final Color highlightColor;

  /// 是否启用交互
  bool get isEnabled =>
      onTap != null || onLongPress != null || onLongPressUp != null;

  /// 用于控制组件状态的控制器
  final WidgetStatesController? statesController;

  /// 焦点节点
  final FocusNode? focusNode;

  /// 是否可以获取焦点
  final bool canRequestFocus;

  /// 焦点变化回调
  final ValueChanged<bool>? onFocusChange;

  /// 是否自动获取焦点
  final bool autofocus;

  /// 是否快速响应
  final bool quickResponse;

  @override
  State<Jelly> createState() => _JellyState();
}

class _JellyState extends State<Jelly> with SingleTickerProviderStateMixin {
  /// Animation controller to manage animation states.
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.shrinkDuration,
    reverseDuration: widget.growDuration,
  );

  /// The shrink and grow animation value.
  late final Animation<double> _animation =
      Tween(begin: 1.0, end: widget.shrinkScaleFactor).animate(
    CurvedAnimation(
      parent: _controller,
      curve: widget.shrinkCurve,
      reverseCurve: widget.growCurve,
    ),
  );

  // 添加状态控制器
  WidgetStatesController? _internalStatesController;
  WidgetStatesController get statesController =>
      widget.statesController ??
      (_internalStatesController ??= WidgetStatesController());

  bool _hasFocus = false;

  /// Target border radius for the child widget.
  BorderRadiusGeometry? targetRadius;

  @override
  void initState() {
    super.initState();
    _initStateController();
    FocusManager.instance
        .addHighlightModeListener(_handleFocusHighlightModeChange);

    if (widget.highlightBorderRadius == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          if (mounted) {
            targetRadius = getChildBorderCloseBorderRadius(context);
          }
        } catch (e, stack) {
          log('BorderRadius retrieval failed', error: e, stackTrace: stack);
        }
      });
    }
  }

  void _initStateController() {
    statesController.update(WidgetState.disabled, !widget.isEnabled);
    statesController.addListener(_handleStatesControllerChange);
  }

  void _handleStatesControllerChange() {
    setState(() {});
  }

  @override
  void didUpdateWidget(Jelly oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.statesController != oldWidget.statesController) {
      oldWidget.statesController?.removeListener(_handleStatesControllerChange);
      if (widget.statesController != null) {
        _internalStatesController?.dispose();
        _internalStatesController = null;
      }
      _initStateController();
    }
    if (widget.isEnabled != oldWidget.isEnabled) {
      statesController.update(WidgetState.disabled, !widget.isEnabled);
      if (!widget.isEnabled) {
        statesController.update(WidgetState.pressed, false);
        _controller.reverse();
      }
    }
  }

  void _handleFocusHighlightModeChange(FocusHighlightMode mode) {
    if (!mounted) {
      return;
    }
    setState(() {
      _updateFocusHighlights();
    });
  }

  bool get _shouldShowFocus {
    final NavigationMode mode = MediaQuery.maybeOf(context)?.navigationMode ??
        NavigationMode.traditional;
    switch (mode) {
      case NavigationMode.traditional:
        return widget.isEnabled && _hasFocus;
      case NavigationMode.directional:
        return _hasFocus;
    }
  }

  void _updateFocusHighlights() {
    bool showFocus;
    switch (FocusManager.instance.highlightMode) {
      case FocusHighlightMode.touch:
        showFocus = false;
        break;
      case FocusHighlightMode.traditional:
        showFocus = _shouldShowFocus;
        break;
    }
    if (showFocus) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  void _handleFocusUpdate(bool hasFocus) {
    _hasFocus = hasFocus;
    statesController.update(WidgetState.focused, hasFocus);
    _updateFocusHighlights();
    widget.onFocusChange?.call(hasFocus);
  }

  Future<void> _ensureForwardComplete() async {
    // 如果动画还没有完成，等待它完成
    if (!_controller.isCompleted) {
      await _controller.forward();
    }
  }

  Future<void> _ensureQuickForwardComplete() async {
    // 如果动画还没有完成，等待它完成
    if (!_controller.isCompleted) {
      await _controller.forward();
    }
    await Future.delayed(widget.delayedDurationBeforeGrow);
    if (!mounted) return;
    // 3. 执行放大动画
    _controller.reverse();
  }

  int? _pressedPointerId;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.isEnabled ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: (event) {
        if (widget.isEnabled) {
          _controller.forward();
          statesController.update(WidgetState.hovered, true);
        }
      },
      onExit: (event) {
        if (widget.isEnabled) {
          _controller.reverse();
          statesController.update(WidgetState.hovered, false);
        }
      },
      child: Focus(
        focusNode: widget.focusNode,
        canRequestFocus: widget.isEnabled && widget.canRequestFocus,
        onFocusChange: _handleFocusUpdate,
        autofocus: widget.autofocus,
        child: Semantics(
          button: widget.isEnabled,
          enabled: widget.isEnabled,
          child: Listener(
            onPointerDown: (event) {
              _pressedPointerId ??= event.pointer;
            },
            onPointerUp: (event) async {
              // 只有当弹起的手指ID和按下的手指ID相同时才执行动画
              if (_pressedPointerId == event.pointer) {
                _controller.reverse();
                _pressedPointerId = null;
              }
            },
            onPointerCancel: (event) {
              // 手势取消时也需要重置手指ID
              if (_pressedPointerId == event.pointer) {
                _pressedPointerId = null;
              }
            },
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              excludeFromSemantics: !widget.isEnabled,
              onTapDown: widget.isEnabled
                  ? (_) async {
                      //_controller.reset();
                      _controller.forward();
                      statesController.update(WidgetState.pressed, true);
                    }
                  : null,
              onTap: widget.isEnabled
                  ? () async {
                      if (widget.quickResponse) {
                        _ensureQuickForwardComplete();
                        widget.onTap?.call();
                        statesController.update(WidgetState.pressed, false);
                      } else {
                        await _ensureForwardComplete();
                        widget.onTap?.call();
                        await Future.delayed(widget.delayedDurationBeforeGrow);
                        if (!mounted) return;
                        _controller.reverse();
                        statesController.update(WidgetState.pressed, false);
                      }
                    }
                  : null,
              onTapCancel: widget.onTap != null && widget.onLongPress == null
                  ? () {
                      _controller.reverse();
                      statesController.update(WidgetState.pressed, false);
                    }
                  : null,
              onLongPressCancel: widget.onLongPress != null
                  ? () {
                      _controller.reverse();
                      statesController.update(WidgetState.pressed, false);
                    }
                  : null,
              onLongPress: widget.onLongPress,
              onLongPressUp: widget.onLongPress != null
                  ? () async {
                      // 1. 确保缩小动画完成
                      await _ensureForwardComplete();
                      // 2. 等待延迟时间
                      await Future.delayed(widget.delayedDurationBeforeGrow);
                      if (!mounted) return;
                      // 3. 执行放大动画
                      _controller.reverse();
                      if (!mounted) return;
                      statesController.update(WidgetState.pressed, false);
                      widget.onLongPressUp?.call();
                    }
                  : null,
              child: AnimatedBuilder(
                animation: _animation,
                child: widget.child,
                builder: (context, child) {
                  return Transform.scale(
                    alignment: Alignment.center,
                    scale: widget.isEnabled ? _animation.value : 1.0,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        child!,
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: targetRadius ??
                                widget.highlightBorderRadius ??
                                BorderRadius.zero,
                            child: IgnorePointer(
                              child: AnimatedBuilder(
                                animation: _animation,
                                builder: (context, child) {
                                  final opacity = _animation.value ==
                                          widget.shrinkScaleFactor
                                      ? 1.0
                                      : (1.0 - _animation.value) /
                                          (1.0 - widget.shrinkScaleFactor);
                                  return Opacity(
                                    opacity: opacity,
                                    child: ColoredBox(
                                      color: widget.highlightColor,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    FocusManager.instance
        .removeHighlightModeListener(_handleFocusHighlightModeChange);
    statesController.removeListener(_handleStatesControllerChange);
    _internalStatesController?.dispose();
    _controller.dispose();
    super.dispose();
  }

  /// Finds the closest [BorderRadius] of a child widget within the widget tree.
  /// This method traverses the widget tree to find and return the closest non-zero [BorderRadius].
  BorderRadiusGeometry? getChildBorderCloseBorderRadius(BuildContext context) {
    try {
      BorderRadiusGeometry? closestBorderRadius;

      void inspectElement(Element element) {
        final renderObject = element.renderObject;
        if (renderObject is RenderBox) {
          final renderInfo = _getRenderInfoFromRenderObject(renderObject);
          if (context.size == renderInfo.size &&
              renderInfo.borderRadius != null &&
              renderInfo.borderRadius != BorderRadius.zero) {
            closestBorderRadius = renderInfo.borderRadius;
            return;
          }
        }

        element.visitChildren((childElement) {
          inspectElement(childElement);
          if (closestBorderRadius != null) return;
        });
      }

      final rootElement = context as Element;
      inspectElement(rootElement);

      return closestBorderRadius;
    } catch (e) {
      log('An issue occurred while retrieving the borderRadius of the target widget. This might be due to an unexpected error or require updates for compatibility with the Flutter version. $e');
      return null;
    }
  }

  /// Extracts BorderRadius from various types of RenderBox.
  ({Size size, BorderRadiusGeometry? borderRadius})
      _getRenderInfoFromRenderObject(RenderBox renderObject) {
    if (renderObject is RenderClipRRect) {
      return (size: renderObject.size, borderRadius: renderObject.borderRadius);
    }
    if (renderObject is RenderPhysicalModel) {
      return (size: renderObject.size, borderRadius: renderObject.borderRadius);
    }
    if (renderObject is RenderDecoratedBox) {
      final decoration = renderObject.decoration;
      if (decoration is BoxDecoration) {
        return (size: renderObject.size, borderRadius: decoration.borderRadius);
      } else if (decoration is ShapeDecoration) {
        final shape = decoration.shape;
        if (shape is RoundedRectangleBorder) {
          return (size: renderObject.size, borderRadius: shape.borderRadius);
        }
      }
    }
    if (renderObject is RenderPhysicalShape) {
      final CustomClipper<Path>? clipper = renderObject.clipper;
      if (clipper is ShapeBorderClipper) {
        final shape = clipper.shape;
        if (shape is RoundedRectangleBorder) {
          return (size: renderObject.size, borderRadius: shape.borderRadius);
        }
      }
    }
    return (size: renderObject.size, borderRadius: null);
  }
}
