import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:deriv_chart/deriv_chart.dart';
import 'package:finality/generated/assets.dart';
import 'package:finality/theme/attrs/clash_display_font.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'custom_tick_marker_icon_painter.dart';

/// 负责合约圆形标记的完整绘制。
///
/// 包含：底圆+内发光+边框+选中框、激活药丸展开动画、
/// 中心箭头/文字、上方金额标签、激活状态管理。
class ContractMarkerRenderer {
  ContractMarkerRenderer({
    required this.markerConfig,
  });

  final ContractMarkerConfig markerConfig;

  // ==================== 图片模式开关 ====================

  /// 切换为 true 使用 PNG 图片绘制标记（底圆+内发光+箭头），
  /// 切换为 false 使用 Canvas 手绘（原始方式）。
  static bool useImageMarker = true;

  /// 预加载的标记背景图片（底圆+内发光，不含箭头）。
  static ui.Image? _markerUpBgImage;
  static ui.Image? _markerDownBgImage;
  static bool _imagesLoaded = false;

  /// 预加载标记图片，应在初始化时调用一次。
  static Future<void> loadImages() async {
    if (_imagesLoaded) return;
    _imagesLoaded = true;
    final results = await Future.wait([
      _loadImage(Assets.chartContractMarkerUpBg),
      _loadImage(Assets.chartContractMarkerDownBg),
    ]);
    _markerUpBgImage = results[0];
    _markerDownBgImage = results[1];
  }

  static Future<ui.Image> _loadImage(String assetPath) async {
    final ByteData data = await rootBundle.load(assetPath);
    final ui.Codec codec =
        await ui.instantiateImageCodec(data.buffer.asUint8List());
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    return frameInfo.image;
  }

  /// 图片绘制用的 Paint（复用）。
  final Paint _imagePaint = Paint();

  // ==================== 可复用 Paint 实例 ====================

  final Paint _selectionPaint = Paint()..style = PaintingStyle.stroke;
  final Paint _backgroundPaint = Paint()..style = PaintingStyle.fill;
  final Paint _glowPaint = Paint();
  final Paint _borderPaint = Paint()..style = PaintingStyle.stroke;
  final Paint _labelBgPaint = Paint();
  final Paint _arrowPaint = Paint();

  // ==================== TextPainter 缓存 ====================

  /// 缓存已 layout 的 TextPainter，key 为 (text, fontSize)。
  final Map<(String, double), TextPainter> _textPainterCache = {};

  /// 上一帧的 zoom 值，zoom 变化时清除缓存。
  double _lastZoom = -1;

  /// 获取或创建已 layout 的 TextPainter（标签用）。
  TextPainter _getOrCreateLabelPainter(String text, double zoom) {
    final double fontSize = _labelFontSize * zoom;
    final key = (text, fontSize);
    final cached = _textPainterCache[key];
    if (cached != null) return cached;

    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
          fontFamily: ClashDisplayFont.fontFamily,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    )..layout();
    _textPainterCache[key] = painter;
    return painter;
  }

  /// 在每帧开始时调用，zoom 变化时清除缓存。
  void _checkZoomChanged(double zoom) {
    if (zoom != _lastZoom) {
      _textPainterCache.clear();
      _lastZoom = zoom;
    }
  }

  // ==================== 激活状态管理 ====================

  /// 当前激活的标记 ID。
  String? _activeMarkerId;

  /// 设置激活的标记。
  void setActiveMarker(String markerId, String? text) {
    _activeMarkerId = markerId;
  }

  /// 清除激活状态。
  void clearActiveMarker() {
    _activeMarkerId = null;
  }

  /// 检查是否有激活的标记。
  bool get hasActiveMarker => _activeMarkerId != null;

  /// 检查指定标记是否是激活状态。
  bool isActiveMarker(String? markerId) =>
      markerId != null && _activeMarkerId == markerId;

  // ==================== 金额标签配置 ====================

  /// 标签字体大小
  static const double _labelFontSize = 11;

  /// 标签水平内边距
  static const double _labelHPadding = 6;

  /// 标签垂直内边距
  static const double _labelVPadding = 3;

  /// 标签圆角半径
  static const double _labelBorderRadius = 6;

  /// 标签与圆形之间的间距
  static const double _labelGap = 4;

  /// 标签背景透明度
  static const double _labelBackgroundOpacity = 1;

  // ==================== 公共方法 ====================

  /// 计算标签的尺寸（包含内边距）。
  ///
  /// 用于在 prepareMarkerGroup 中计算包含标签的边界，
  /// 以及在绘制时确定标签区域。
  Size? calculateLabelSize(String? text, double zoom) {
    if (text == null || text.isEmpty) return null;
    final TextPainter textPainter = _getOrCreateLabelPainter(text, zoom);
    return Size(
      textPainter.width + _labelHPadding * 2 * zoom,
      textPainter.height + _labelVPadding * 2 * zoom,
    );
  }

  /// 绘制合约标记（底圆+内发光+边框+选中框+中心内容+金额标签+激活药丸）。
  void drawContractMarker(
    Canvas canvas,
    ChartMarker marker,
    Offset anchor,
    MarkerStyle style,
    ChartTheme theme,
    double zoom,
    int granularity,
    double opacity,
    AnimationInfo animationInfo,
    String? markerGroupId,
    MarkerGroup markerGroup,
  ) {
    _checkZoomChanged(zoom);

    final double borderRadius = markerConfig.borderRadius(zoom);
    final double scaledStrokeWidth = markerConfig.scaledStrokeWidth(zoom);
    final bool isActive = isActiveMarker(markerGroupId);

    final Offset effectiveAnchor = anchor;

    // 如果有激活标记，非激活的标记变半透明
    final double effectiveOpacity = (hasActiveMarker && !isActive)
        ? opacity * markerConfig.inactiveOpacityFactor
        : opacity;

    // ========== 颜色配置 ==========
    final Color markerColor = marker.direction == MarkerDirection.up
        ? style.upColor
        : style.downColor;

    // ========== 绘制背景圆（深色填充 + 内发光） ==========
    final double fullRadius = markerConfig.fullRadius(zoom);

    // ========== 绘制选中边框 ==========
    if (isActive) {
      final double selectionStrokeWidth =
          markerConfig.selectionBorderWidth * zoom;
      final double selectionRadius = markerConfig.selectionBorderRadius(zoom);
      _selectionPaint
        ..color = markerColor.withValues(alpha: effectiveOpacity)
        ..strokeWidth = selectionStrokeWidth;
      canvas.drawCircle(effectiveAnchor, selectionRadius, _selectionPaint);
    }

    // ========== 绘制标记主体（底圆+内发光+箭头） ==========
    final ui.Image? bgImage = useImageMarker
        ? (marker.direction == MarkerDirection.up
            ? _markerUpBgImage
            : _markerDownBgImage)
        : null;

    if (bgImage != null) {
      // PNG 模式：背景图片替代底圆+内发光
      final double imageSize = fullRadius * 2;
      final Rect dst = Rect.fromCenter(
        center: effectiveAnchor,
        width: imageSize,
        height: imageSize,
      );
      _imagePaint.color = Color.fromRGBO(255, 255, 255, effectiveOpacity);
      canvas.drawImageRect(
        bgImage,
        Rect.fromLTWH(
            0, 0, bgImage.width.toDouble(), bgImage.height.toDouble()),
        dst,
        _imagePaint,
      );
    } else {
      // Canvas 手绘模式（原始方式）
      final Color darkFillColor = marker.direction == MarkerDirection.up
          ? const Color(0xFF002E1D)
          : const Color(0xFF481400);
      _backgroundPaint.color =
          darkFillColor.withValues(alpha: effectiveOpacity);
      canvas.drawCircle(effectiveAnchor, fullRadius, _backgroundPaint);

      // 内发光效果
      final Color glowColor = marker.direction == MarkerDirection.up
          ? const Color(0xFF00A669)
          : const Color(0xFFFF412C);
      _drawInnerGlow(
          canvas, effectiveAnchor, fullRadius, glowColor, effectiveOpacity);
    }

    // ========== 绘制黑色边框 ==========
    _borderPaint
      ..color = theme.backgroundColor.withValues(alpha: effectiveOpacity)
      ..strokeWidth = scaledStrokeWidth;
    canvas.drawCircle(effectiveAnchor, fullRadius, _borderPaint);

    // ========== 绘制中心内容（标签或箭头） ==========
    if (markerGroup.props.markerLabel != null) {
      _drawMarkerLabel(canvas, effectiveAnchor, markerGroup.props.markerLabel!,
          effectiveOpacity, zoom, style);
    } else {
      _drawArrowIcon(canvas, effectiveAnchor, marker,
          markerColor.withValues(alpha: effectiveOpacity), zoom, 16);
    }

    // ========== 绘制上方金额标签 ==========
    if (marker.text != null && marker.text!.isNotEmpty) {
      String? remainingTimeText;
      if (isActive) {
        final int? remainingSeconds = _calculateRemainingSeconds(markerGroup);
        if (remainingSeconds != null && remainingSeconds > 0) {
          remainingTimeText = _formatRemainingTime(remainingSeconds);
        }
      }
      _drawContractMarkerLabel(
        theme,
        canvas,
        effectiveAnchor,
        marker.text!,
        effectiveOpacity,
        zoom,
        isActive: isActive,
        remainingTimeText: remainingTimeText,
      );
    }

    // 更新点击区域（包含标签区域）
    Rect tapRect =
        Rect.fromCircle(center: effectiveAnchor, radius: borderRadius);
    if (marker.text != null && marker.text!.isNotEmpty) {
      final Size? labelSize = calculateLabelSize(marker.text!, zoom);
      if (labelSize != null) {
        final double scaledGap = _labelGap * zoom;
        final double outerR = markerConfig.outerRadius(zoom);
        final double labelTop =
            effectiveAnchor.dy - outerR - scaledGap - labelSize.height;
        tapRect = Rect.fromLTRB(
          math.min(tapRect.left, effectiveAnchor.dx - labelSize.width / 2),
          labelTop,
          math.max(tapRect.right, effectiveAnchor.dx + labelSize.width / 2),
          tapRect.bottom,
        );
      }
    }
    marker.tapArea = tapRect;
  }

  // ==================== 私有绘制方法 ====================

  /// 绘制圆内文字标签。
  void _drawMarkerLabel(Canvas canvas, Offset anchor, String label,
      double opacity, double zoom, MarkerStyle style) {
    final double radius = 12 * zoom;
    final double padding = 5 * zoom;
    final double maxWidth = (radius - padding) * 2;
    final double maxHeight = (radius - padding) * 2;

    final TextStyle baseTextStyle = style.markerLabelTextStyle.copyWith(
      fontSize: style.markerLabelTextStyle.fontSize! * zoom,
      color: style.markerLabelTextStyle.color!.withValues(alpha: opacity),
      height: 1,
    );

    final TextPainter painter = makeFittedTextPainter(
      label,
      baseTextStyle,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
    );

    paintWithTextPainter(
      canvas,
      painter: painter,
      anchor: anchor,
    );
  }

  /// 箭头 Path（14x14 SVG 坐标，静态不变），只构建一次。
  static final Path _arrowPath = Path()
    ..moveTo(9.33545, 5.49162)
    ..lineTo(4.31495, 10.5121)
    ..lineTo(3.48999, 9.68718)
    ..lineTo(8.5105, 4.66667)
    ..lineTo(4.08547, 4.66667)
    ..lineTo(4.08547, 3.5)
    ..lineTo(10.5021, 3.5)
    ..lineTo(10.5021, 9.91667)
    ..lineTo(9.33545, 9.91667)
    ..close();

  /// SVG viewBox 尺寸。
  static const double _arrowViewBoxSize = 14;

  /// 绘制中心箭头图标。
  void _drawArrowIcon(Canvas canvas, Offset center, ChartMarker marker,
      Color color, double zoom, double size) {
    final double dir = marker.direction == MarkerDirection.up ? 1 : -1;
    final double iconSize = size * zoom;

    canvas
      ..save()
      ..translate(
        center.dx - iconSize / 2,
        center.dy - (iconSize / 2) * dir,
      )
      ..scale(
        iconSize / _arrowViewBoxSize,
        (iconSize / _arrowViewBoxSize) * dir,
      );

    _arrowPaint.color = color;
    canvas
      ..drawPath(_arrowPath, _arrowPaint)
      ..restore();
  }

  /// 绘制合约标记上方的金额标签。
  void _drawContractMarkerLabel(
    ChartTheme theme,
    Canvas canvas,
    Offset circleCenter,
    String text,
    double opacity,
    double zoom, {
    bool isActive = false,
    String? remainingTimeText,
  }) {
    final double labelOpacity = isActive ? opacity : opacity * 0.54;

    final double scaledHPadding = _labelHPadding * zoom;
    final double scaledVPadding = _labelVPadding * zoom;
    final double scaledBorderRadius = _labelBorderRadius * zoom;
    final double scaledGap = _labelGap * zoom;
    final double outerRadius = markerConfig.outerRadius(zoom);

    // 使用缓存的 TextPainter（layout 结果不受颜色影响，绘制前更新颜色）
    final TextPainter textPainter = _getOrCreateLabelPainter(text, zoom);
    // 更新文字颜色（颜色不影响 layout，可以安全修改）
    textPainter.text = TextSpan(
      text: text,
      style: TextStyle(
        color: Colors.white.withValues(alpha: labelOpacity),
        fontSize: _labelFontSize * zoom,
        fontWeight: FontWeight.w500,
        fontFamily: ClashDisplayFont.fontFamily,
      ),
    );

    final double labelWidth = textPainter.width + scaledHPadding * 2;
    final double labelHeight = textPainter.height + scaledVPadding * 2;

    // 如果有剩余时间文字，计算时间标签尺寸
    TextPainter? timePainter;
    double timeLabelWidth = 0;
    if (remainingTimeText != null) {
      timePainter = _getOrCreateLabelPainter(remainingTimeText, zoom);
      timePainter.text = TextSpan(
        text: remainingTimeText,
        style: TextStyle(
          color: Colors.white.withValues(alpha: labelOpacity),
          fontSize: _labelFontSize * zoom,
          fontWeight: FontWeight.w500,
          fontFamily: ClashDisplayFont.fontFamily,
        ),
      );
      timeLabelWidth = timePainter.width + scaledHPadding * 2;
    }

    final double labelCenterY =
        circleCenter.dy - outerRadius - scaledGap - labelHeight / 2;

    // ========== 绘制金额标签 ==========
    final Rect labelRect = Rect.fromCenter(
      center: Offset(circleCenter.dx, labelCenterY),
      width: labelWidth,
      height: labelHeight,
    );

    _labelBgPaint.color = theme.backgroundColor
        .withValues(alpha: _labelBackgroundOpacity * labelOpacity);

    canvas.drawRRect(
      RRect.fromRectAndRadius(labelRect, Radius.circular(scaledBorderRadius)),
      _labelBgPaint,
    );
    textPainter.paint(
      canvas,
      Offset(labelRect.left + scaledHPadding, labelRect.top + scaledVPadding),
    );

    // ========== 绘制剩余时间标签（选中时） ==========
    if (timePainter != null) {
      final Rect timeRect = Rect.fromLTWH(
        labelRect.right + 2 * zoom,
        labelCenterY - labelHeight / 2,
        timeLabelWidth,
        labelHeight,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(timeRect, Radius.circular(scaledBorderRadius)),
        _labelBgPaint,
      );
      timePainter.paint(
        canvas,
        Offset(timeRect.left + scaledHPadding, timeRect.top + scaledVPadding),
      );
    }
  }

  // ==================== 内发光 Path 缓存 ====================

  /// 缓存的内发光参数，避免每帧重建 Path。
  Offset? _lastGlowCenter;
  double? _lastGlowRadius;
  Path? _cachedClipPath;
  Path? _cachedInvertedPath;

  /// 绘制内发光效果（保留原始 MaskFilter.blur，缓存 Path 避免每帧重建）。
  void _drawInnerGlow(
    Canvas canvas,
    Offset center,
    double radius,
    Color glowColor,
    double opacity,
  ) {
    final double shadowSigma = 6 * (radius / 16);

    // 只在 center/radius 变化时重建 Path
    if (center != _lastGlowCenter || radius != _lastGlowRadius) {
      _lastGlowCenter = center;
      _lastGlowRadius = radius;
      _cachedClipPath = Path()
        ..addOval(Rect.fromCircle(center: center, radius: radius));
      _cachedInvertedPath = Path()
        ..addRect(
            Rect.fromCircle(center: center, radius: radius + shadowSigma * 3))
        ..addOval(Rect.fromCircle(center: center, radius: radius))
        ..fillType = PathFillType.evenOdd;
    }

    canvas.save();
    canvas.clipPath(_cachedClipPath!);
    _glowPaint
      ..shader = null
      ..color = glowColor.withValues(alpha: opacity)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, shadowSigma);
    canvas.drawPath(_cachedInvertedPath!, _glowPaint);
    canvas.restore();
  }

  // ==================== 工具方法 ====================

  /// 计算合约剩余秒数。
  int? _calculateRemainingSeconds(MarkerGroup markerGroup) {
    if (markerGroup.currentEpoch == null) return null;

    int? endEpoch;
    for (final ChartMarker groupMarker in markerGroup.markers) {
      if (groupMarker.markerType == MarkerType.exitSpot) {
        endEpoch ??= groupMarker.epoch;
      } else if (groupMarker.markerType == MarkerType.exitTimeCollapsed) {
        endEpoch ??= groupMarker.epoch;
      }
      if (endEpoch != null) break;
    }

    if (endEpoch == null) return null;
    final int remainingMs = endEpoch - markerGroup.currentEpoch!;
    return (remainingMs / 1000).ceil();
  }

  /// 格式化剩余时间为 mm:ss 格式。
  String _formatRemainingTime(int seconds) {
    final int m = seconds ~/ 60;
    final int s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}
