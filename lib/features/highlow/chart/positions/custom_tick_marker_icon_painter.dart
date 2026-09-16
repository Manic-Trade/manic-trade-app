import 'dart:math' as math;

import 'package:deriv_chart/deriv_chart.dart';
import 'package:flutter/material.dart';

import 'contract_marker_renderer.dart';
import 'marker_overlap_resolver.dart';

/// 合约标记的尺寸配置。
///
/// 用于统一管理合约标记的各种尺寸参数，避免在代码中重复定义。
class ContractMarkerConfig {
  const ContractMarkerConfig({
    this.baseRadius = 12,
    this.borderPadding = 0,
    this.strokeWidth = 1.5,
    this.progressBackgroundOpacity = 0.2,
    this.selectionBorderGap = 0,
    this.selectionBorderWidth = 2,
    this.inactiveOpacityFactor = 1,
    this.activeProgressBackgroundOpacity = 0.38,
  });

  /// 内圆基础半径
  final double baseRadius;

  /// 边框与内圆的间距
  final double borderPadding;

  /// 边框和进度条的线宽
  final double strokeWidth;

  /// 进度条背景透明度
  final double progressBackgroundOpacity;

  /// 选中时进度条背景透明度
  final double activeProgressBackgroundOpacity;

  /// 选中边框与进度条边框之间的间距
  final double selectionBorderGap;

  /// 选中边框的线宽
  final double selectionBorderWidth;

  /// 有选中标记时，非选中标记的透明度系数（0.0 = 纯黑/完全透明，1.0 = 不变）
  final double inactiveOpacityFactor;

  /// 计算应用 zoom 后的内圆半径
  double radius(double zoom) => baseRadius * zoom;

  /// 计算应用 zoom 后的边框半径
  double borderRadius(double zoom) => radius(zoom) + (borderPadding * zoom);

  /// 计算应用 zoom 后的线宽
  double scaledStrokeWidth(double zoom) => strokeWidth * zoom;

  /// 底圆半径（含内发光区域，即原内圆 + 描边宽度）
  double fullRadius(double zoom) => radius(zoom) + scaledStrokeWidth(zoom);

  /// 黑色边框的外边缘半径
  double borderOuterRadius(double zoom) =>
      fullRadius(zoom) + scaledStrokeWidth(zoom) / 2;

  /// 选中边框的中心半径（紧贴黑色边框外缘）
  double selectionBorderRadius(double zoom) =>
      borderOuterRadius(zoom) + selectionBorderGap * zoom;

  /// 计算标记的外半径（始终包含选中边框的预留空间，防止选中时位置移动）
  double outerRadius(double zoom) =>
      borderOuterRadius(zoom) +
      selectionBorderGap * zoom +
      selectionBorderWidth * zoom / 2;

  /// 计算标记的直径
  double diameter(double zoom) => outerRadius(zoom) * 2;

  /// 默认配置
  static const ContractMarkerConfig defaultConfig = ContractMarkerConfig();
}

/// 在金融图表上绘制基于 tick 的合约标记的专用 painter。
///
/// 职责为**编排调度**：决定画什么、按什么顺序画，
/// 具体绘制逻辑委托给以下子类：
/// - [MarkerOverlapResolver]：重叠检测与位置计算
/// - [ContractMarkerRenderer]：合约圆形标记的完整绘制
/// - [BarrierLinePainter]：连线与进度线绘制
class CustomTickMarkerIconPainter extends MarkerGroupIconPainter {
  /// 创建一个 CustomTickMarkerIconPainter 实例。
  ///
  /// [showContractToStartDashedLine] 控制是否绘制从合约标记到开始时间的价格虚线。
  /// [showExitToEdgeDashedLine] 控制是否绘制从结束时间到屏幕边缘的价格虚线。
  /// [enableOverlapHandling] 控制是否启用重叠处理。当多个合约标记的价格接近时，
  /// 如果启用此选项，标记会自动横向排列以避免重叠；如果禁用，标记会直接重叠显示。
  /// [showExitCountdown] 控制是否在出场点显示旗帜图标和倒计时。
  /// [markerConfig] 合约标记的尺寸配置，默认使用 [ContractMarkerConfig.defaultConfig]。
  CustomTickMarkerIconPainter({
    this.showContractToStartDashedLine = true,
    this.showExitToEdgeDashedLine = false,
    this.enableOverlapHandling = true,
    this.showExitCountdown = true,
    this.markerConfig = ContractMarkerConfig.defaultConfig,
  })  : _overlapResolver = MarkerOverlapResolver(),
        _contractRenderer = ContractMarkerRenderer(
          markerConfig: markerConfig,
        );

  /// 合约标记的尺寸配置
  final ContractMarkerConfig markerConfig;

  /// 是否绘制从合约标记到开始时间的价格虚线。
  final bool showContractToStartDashedLine;

  /// 是否绘制从结束时间到屏幕边缘的价格虚线。
  final bool showExitToEdgeDashedLine;

  /// 是否启用重叠处理。
  final bool enableOverlapHandling;

  /// 是否在出场点显示旗帜图标和倒计时。
  final bool showExitCountdown;

  // ==================== 子模块 ====================

  /// 重叠检测与位置计算。
  final MarkerOverlapResolver _overlapResolver;

  /// 合约圆形标记绘制。
  final ContractMarkerRenderer _contractRenderer;


  // ==================== 常量配置 ====================

  static const double _contractMarkerSpacing = 24;

  // ==================== Exit emoji 配置 ====================

  /// 表情尺寸
  static const double _emojiSize = 12;

  /// 表情左侧距离锚点的间距
  static const double _emojiLeftPadding = 8;

  /// 表情背景内边距
  static const double _emojiBgPadding = 4.5;

  /// 表情背景尺寸（emojiSize + bgPadding * 2）
  static const double _emojiBgSize = _emojiSize + _emojiBgPadding * 2;

  // ==================== 激活状态代理 ====================

  /// 设置激活的标记。
  void setActiveMarker(String markerId, String? text) {
    _contractRenderer.setActiveMarker(markerId, text);
  }

  /// 清除激活状态。
  void clearActiveMarker() {
    _contractRenderer.clearActiveMarker();
  }

  /// 检查是否有激活的标记。
  bool get hasActiveMarker => _contractRenderer.hasActiveMarker;

  /// 检查指定标记是否是激活状态。
  bool isActiveMarker(String? markerId) =>
      _contractRenderer.isActiveMarker(markerId);

  // ==================== 生命周期 ====================

  /// 每帧开始时调用，清空上一帧的状态。
  @override
  void onFrameStart() {
    if (enableOverlapHandling) {
      _overlapResolver.onFrameStart();
    }
  }

  // ==================== 预注册阶段 ====================

  /// 准备 MarkerGroup 数据，用于后续的绑制（如位置计算、重叠处理等）。
  @override
  void prepareMarkerGroup(
    MarkerGroup markerGroup,
    Size size,
    EpochToX epochToX,
    QuoteToY quoteToY,
    PainterProps painterProps,
  ) {
    if (!enableOverlapHandling) return;

    // 先找到 startTimeCollapsed 的 epoch
    int? startTimeCollapsedEpoch;
    for (final ChartMarker marker in markerGroup.markers) {
      if (marker.markerType == MarkerType.startTimeCollapsed) {
        startTimeCollapsedEpoch = marker.epoch;
        break;
      }
    }

    // 查找 contractMarker 并注册其位置信息
    for (final ChartMarker marker in markerGroup.markers) {
      if (marker.markerType == MarkerType.contractMarker) {
        final double zoom = painterProps.zoom;
        final int granularity = painterProps.granularity;
        final double markerDiameter = markerConfig.diameter(zoom);
        final double contractOuterRadius = markerConfig.outerRadius(zoom);

        final double originalY = quoteToY(marker.quote);

        final double anchorX;
        if (startTimeCollapsedEpoch != null) {
          anchorX = _calculateInterpolatedX(
                startTimeCollapsedEpoch,
                granularity,
                epochToX,
              ) -
              _contractMarkerSpacing -
              contractOuterRadius;
        } else {
          anchorX =
              markerGroup.props.contractMarkerLeftPadding + contractOuterRadius;
        }
        final Offset anchor = Offset(anchorX, originalY);

        Rect bounds = Rect.fromCenter(
          center: anchor,
          width: markerDiameter,
          height: markerDiameter,
        );

        // 如果有标签文字，扩展边界以包含标签区域（用于重叠检测）
        final Size? labelSize =
            _contractRenderer.calculateLabelSize(marker.text, zoom);
        if (labelSize != null) {
          const double labelGap = 4;
          final double scaledGap = labelGap * zoom;
          final double labelTop = bounds.top - scaledGap - labelSize.height;
          final double labelLeft = anchor.dx - labelSize.width / 2;
          final double labelRight = anchor.dx + labelSize.width / 2;
          bounds = Rect.fromLTRB(
            math.min(bounds.left, labelLeft),
            labelTop,
            math.max(bounds.right, labelRight),
            bounds.bottom,
          );
        }

        _overlapResolver.registerContractMarker(
          bounds,
          markerGroup.id,
          originalY,
          marker.epoch,
        );
        break;
      }
    }

    // 注册 exitSpot emoji 的位置信息（用于重叠检测）
    _registerExitEmojiIfNeeded(markerGroup, epochToX, quoteToY);
  }

  /// 检查并注册 exit emoji 的位置信息。
  void _registerExitEmojiIfNeeded(
    MarkerGroup markerGroup,
    EpochToX epochToX,
    QuoteToY quoteToY,
  ) {
    ChartMarker? exitSpotMarker;
    for (final ChartMarker marker in markerGroup.markers) {
      if (marker.markerType == MarkerType.exitSpot) {
        exitSpotMarker = marker;
        break;
      }
    }
    if (exitSpotMarker == null) return;

    final int? currentEpoch = markerGroup.currentEpoch;
    if (currentEpoch == null) return;
    final int remainingMs = exitSpotMarker.epoch - currentEpoch;
    if (remainingMs <= 0) return;

    final double? currentQuote = markerGroup.currentQuote;
    double? entryPrice;
    for (final ChartMarker m in markerGroup.markers) {
      if (m.markerType == MarkerType.entrySpot ||
          m.markerType == MarkerType.contractMarker ||
          m.markerType == MarkerType.startTimeCollapsed) {
        entryPrice = m.quote;
        break;
      }
    }
    if (currentQuote == null || entryPrice == null) return;

    final double anchorX = epochToX(exitSpotMarker.epoch);
    final double anchorY = quoteToY(exitSpotMarker.quote);
    final double emojiBgCenterX =
        anchorX + _emojiLeftPadding + _emojiBgSize / 2;

    final Rect bounds = Rect.fromCenter(
      center: Offset(emojiBgCenterX, anchorY),
      width: _emojiBgSize,
      height: _emojiBgSize,
    );

    _overlapResolver.registerExitEmoji(
      bounds,
      markerGroup.id,
      anchorY,
      exitSpotMarker.epoch,
    );
  }

  // ==================== 底层绘制（线/barriers + 非合约标记） ====================

  @override
  void paintMarkerGroup(
    Canvas canvas,
    Size size,
    ChartTheme theme,
    MarkerGroup markerGroup,
    EpochToX epochToX,
    QuoteToY quoteToY,
    PainterProps painterProps,
    AnimationInfo animationInfo,
  ) {
    // 确保所有标记的偏移后位置已计算完成
    _ensurePositionsCalculated();

    final Map<MarkerType, Offset> points = _collectMarkerPoints(
      markerGroup,
      epochToX,
      quoteToY,
      painterProps,
      useInterpolatedCollapsedX: true,
    );

    final Offset? startPoint = points[MarkerType.start];
    final Offset? exitPoint = points[MarkerType.exit];
    final Offset? endPoint = points[MarkerType.exitSpot];

    double opacity = 1;
    if (startPoint != null && (endPoint != null || exitPoint != null)) {
      opacity = calculateOpacity(startPoint.dx, exitPoint?.dx);
    }

    final Paint paint = Paint()
      ..color = markerGroup.style.backgroundColor.withValues(alpha: opacity);

    // 绘制线（barriers）
    _drawBarriers(canvas, size, points, markerGroup, markerGroup.style,
        theme, opacity, painterProps, paint, epochToX, markerGroup.id);

    // 绘制除 contractMarker 之外的所有标记
    for (final ChartMarker marker in markerGroup.markers) {
      if (marker.markerType == MarkerType.contractMarker) {
        continue;
      }

      final Offset center = points[marker.markerType!] ??
          Offset(epochToX(marker.epoch), quoteToY(marker.quote));

      if (marker.markerType == MarkerType.entry &&
          points[MarkerType.entrySpot] != null) {
        continue;
      }

      _drawMarker(canvas, size, theme, marker, center, markerGroup.style,
          painterProps.zoom, painterProps.granularity, opacity, paint,
          animationInfo, markerGroup.id, markerGroup);
    }
  }

  // ==================== 顶层绘制（contractMarker） ====================

  @override
  void paintMarkerGroupHigh(
    Canvas canvas,
    Size size,
    ChartTheme theme,
    MarkerGroup markerGroup,
    EpochToX epochToX,
    QuoteToY quoteToY,
    PainterProps painterProps,
    AnimationInfo animationInfo,
  ) {
    _ensurePositionsCalculated();

    final Map<MarkerType, Offset> points = _collectMarkerPoints(
      markerGroup,
      epochToX,
      quoteToY,
      painterProps,
      useInterpolatedCollapsedX: false,
    );

    final Offset? startPoint = points[MarkerType.start];
    final Offset? exitPoint = points[MarkerType.exit];
    final Offset? endPoint = points[MarkerType.exitSpot];

    double opacity = 1;
    if (startPoint != null && (endPoint != null || exitPoint != null)) {
      opacity = calculateOpacity(startPoint.dx, exitPoint?.dx);
    }

    // 只绘制 contractMarker，确保它在最顶层
    for (final ChartMarker marker in markerGroup.markers) {
      if (marker.markerType != MarkerType.contractMarker) {
        continue;
      }

      final Offset center = points[MarkerType.contractMarker]!;

      _drawMarker(canvas, size, theme, marker, center, markerGroup.style,
          painterProps.zoom, painterProps.granularity, opacity,
          Paint()
            ..color =
                markerGroup.style.backgroundColor.withValues(alpha: opacity),
          animationInfo, markerGroup.id, markerGroup);
    }
  }

  // ==================== 标记分发 ====================

  /// 根据标记类型分发到对应的绘制方法。
  void _drawMarker(
    Canvas canvas,
    Size size,
    ChartTheme theme,
    ChartMarker marker,
    Offset anchor,
    MarkerStyle style,
    double zoom,
    int granularity,
    double opacity,
    Paint paint,
    AnimationInfo animationInfo,
    String? markerGroupId,
    MarkerGroup markerGroup,
  ) {
    YAxisConfig.instance.yAxisClipping(canvas, size, () {
      switch (marker.markerType) {
        case MarkerType.contractMarker:
          _contractRenderer.drawContractMarker(canvas, marker, anchor, style,
              theme, zoom, granularity, opacity, animationInfo, markerGroupId,
              markerGroup);
          break;
        case MarkerType.startTime:
          paintStartLine(canvas, size, marker, anchor, style, theme, zoom,
              markerGroup.props);
          break;
        case MarkerType.start:
          _drawStartPoint(
              canvas, size, theme, marker, anchor, style, zoom, opacity);
          break;
        case MarkerType.entry:
        case MarkerType.entrySpot:
          _drawSpotPoint(canvas, marker, anchor, style, theme, zoom, opacity);
          break;
        case MarkerType.exitSpot:
          _drawExitSpotWithCountdown(
            canvas,
            marker,
            anchor,
            style,
            theme,
            zoom,
            opacity,
            markerGroup,
            isActive: isActiveMarker(markerGroupId),
          );
          break;
        case MarkerType.exit:
          canvas.drawCircle(anchor, 3 * zoom, paint);
          break;
        case MarkerType.tick:
          final Paint paint = Paint()..color = theme.base01Color;
          _drawTickPoint(canvas, anchor, paint, zoom);
          break;
        case MarkerType.latestTick:
          _drawTickPoint(canvas, anchor, paint, zoom);
          break;
        case MarkerType.exitTime:
          paintEndLine(canvas, size, marker, anchor, style, theme, zoom,
              markerGroup.props);
          break;
        case MarkerType.startTimeCollapsed:
          _drawCollapsedTimeLine(
              canvas, marker, anchor, style, theme, zoom, opacity);
          break;
        case MarkerType.exitTimeCollapsed:
          _drawCollapsedTimeLine(
              canvas, marker, anchor, style, theme, zoom, opacity);
          break;
        case MarkerType.profitAndLossLabel:
          _drawProfitAndLossLabel(
            canvas, theme, markerGroup, marker, anchor, style, 1, opacity,
            fixedLeftAligned: false,
          );
          break;
        case MarkerType.profitAndLossLabelFixed:
          _drawProfitAndLossLabel(
            canvas, theme, markerGroup, marker, anchor, style, 1, opacity,
            fixedLeftAligned: true,
          );
          break;
        default:
          break;
      }
    });
  }

  // ==================== 辅助方法 ====================

  /// 确保所有标记的偏移后位置已计算完成。
  void _ensurePositionsCalculated() {
    if (enableOverlapHandling) {
      _overlapResolver.calculateAllContractMarkerPositions();
      _overlapResolver.calculateAllExitEmojiPositions();
    }
  }

  /// 收集所有标记的画布坐标。
  ///
  /// [useInterpolatedCollapsedX] 为 true 时，startTimeCollapsed/exitTimeCollapsed
  /// 使用插值计算精确 X 坐标（用于 paintMarkerGroup 中的线条绘制）。
  Map<MarkerType, Offset> _collectMarkerPoints(
    MarkerGroup markerGroup,
    EpochToX epochToX,
    QuoteToY quoteToY,
    PainterProps painterProps, {
    required bool useInterpolatedCollapsedX,
  }) {
    final Map<MarkerType, Offset> points = <MarkerType, Offset>{};
    final double contractOuterRadius =
        markerConfig.outerRadius(painterProps.zoom);
    final int granularity = painterProps.granularity;

    // 先找到 startTimeCollapsed 的 X 坐标
    double? startTimeCollapsedX;
    for (final ChartMarker marker in markerGroup.markers) {
      if (marker.markerType == MarkerType.startTimeCollapsed) {
        startTimeCollapsedX = useInterpolatedCollapsedX
            ? _calculateInterpolatedX(
                marker.epoch, granularity, epochToX)
            : epochToX(marker.epoch);
        break;
      }
    }

    for (final ChartMarker marker in markerGroup.markers) {
      final Offset center;

      if (marker.markerType == MarkerType.contractMarker) {
        final double anchorX;
        if (startTimeCollapsedX != null) {
          anchorX = startTimeCollapsedX -
              _contractMarkerSpacing -
              contractOuterRadius;
        } else {
          anchorX =
              markerGroup.props.contractMarkerLeftPadding + contractOuterRadius;
        }
        final Offset originalCenter = Offset(anchorX, quoteToY(marker.quote));
        center = enableOverlapHandling
            ? _overlapResolver.getAdjustedPosition(
                markerGroup.id, originalCenter)
            : originalCenter;
      } else if (useInterpolatedCollapsedX &&
          (marker.markerType == MarkerType.startTimeCollapsed ||
              marker.markerType == MarkerType.exitTimeCollapsed)) {
        center = Offset(
          _calculateInterpolatedX(
              marker.epoch, granularity, epochToX),
          quoteToY(marker.quote),
        );
      } else {
        center = Offset(
          epochToX(marker.epoch),
          quoteToY(marker.quote),
        );
      }

      if (marker.markerType != null && marker.markerType != MarkerType.tick) {
        points[marker.markerType!] = center;
      }
    }

    return points;
  }

  // ==================== 简单标记绘制方法 ====================

  void _drawProfitAndLossLabel(
    Canvas canvas,
    ChartTheme theme,
    MarkerGroup markerGroup,
    ChartMarker marker,
    Offset anchor,
    MarkerStyle style,
    double zoom,
    double opacity, {
    required bool fixedLeftAligned,
  }) {
    final bool isProfit = markerGroup.props.isProfit;
    final Color borderColor = isProfit
        ? theme.closedMarkerBorderColorGreen
        : theme.closedMarkerBorderColorRed;
    final Color backgroundColor = isProfit
        ? theme.closedMarkerSurfaceColorGreen
        : theme.closedMarkerSurfaceColorRed;
    final Color textIconColor = isProfit
        ? theme.closedMarkerTextIconColorGreen
        : theme.closedMarkerTextIconColorRed;

    final double pillHeight = 32 * zoom;
    final double radius = pillHeight / 2;
    final double iconSize = 24 * zoom;
    const double leftPadding = 8;
    const double spacing = 4;
    const double rightPadding = 16;

    final TextStyle textStyle = theme
        .textStyle(
          textStyle: theme.profitAndLossLabelTextStyle,
          color: textIconColor,
        )
        .copyWith(
          fontSize: theme.profitAndLossLabelTextStyle.fontSize! * zoom,
          height: 1,
        );

    final String text = markerGroup.profitAndLossText ?? '';
    final TextPainter textPainter = makeTextPainter(text, textStyle);

    final double contentWidth =
        leftPadding + iconSize + spacing + textPainter.width + rightPadding;

    Rect pillRect;
    if (fixedLeftAligned) {
      const double leftX = 5;
      pillRect = Rect.fromLTWH(
        leftX,
        anchor.dy - pillHeight / 2,
        contentWidth,
        pillHeight,
      );
    } else {
      pillRect = Rect.fromCenter(
        center: Offset(anchor.dx, anchor.dy),
        width: contentWidth,
        height: pillHeight,
      );
    }

    final Paint fillPaint = Paint()
      ..color = backgroundColor.withOpacity(0.88 * opacity)
      ..style = PaintingStyle.fill;
    final RRect rrect =
        RRect.fromRectAndRadius(pillRect, Radius.circular(radius));
    canvas.drawRRect(rrect, fillPaint);

    final Paint strokePaint = Paint()
      ..color = borderColor.withOpacity(opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRRect(rrect, strokePaint);

    final TextPainter iconPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(QuillIcons.flag_checkered.codePoint),
        style: TextStyle(
          fontFamily: QuillIcons.kFontFam,
          fontSize: iconSize,
          package: QuillIcons.kFontPkg,
          color: textIconColor.withOpacity(opacity),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final double iconX = pillRect.left + leftPadding;
    final double iconY = anchor.dy - iconPainter.height / 2;
    iconPainter.paint(canvas, Offset(iconX, iconY));

    paintWithTextPainter(
      canvas,
      painter: textPainter,
      anchor: Offset(iconX + iconSize + spacing, anchor.dy),
      anchorAlignment: Alignment.centerLeft,
    );

    marker.tapArea = pillRect;
  }

  void _drawTickPoint(Canvas canvas, Offset anchor, Paint paint, double zoom) {
    canvas.drawCircle(anchor, 1.5 * zoom, paint);
  }

  void _drawSpotPoint(Canvas canvas, ChartMarker marker, Offset anchor,
      MarkerStyle style, ChartTheme theme, double zoom, double opacity) {
    final Paint fillPaint = Paint()
      ..color = (marker.direction == MarkerDirection.up
              ? theme.markerStyle.upColorProminent
              : theme.markerStyle.downColorProminent)
          .withValues(alpha: opacity)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(anchor, 2.5 * zoom, fillPaint);
  }

  /// 绘制出场点标记，包含倒计时和胜负状态。
  void _drawExitSpotWithCountdown(
    Canvas canvas,
    ChartMarker marker,
    Offset anchor,
    MarkerStyle style,
    ChartTheme theme,
    double zoom,
    double opacity,
    MarkerGroup markerGroup, {
    bool isActive = false,
  }) {
    final int? currentEpoch = markerGroup.currentEpoch;
    final int endEpoch = marker.epoch;

    if (currentEpoch == null) return;

    final int remainingMs = endEpoch - currentEpoch;
    if (remainingMs <= 0) return;

    final double? currentQuote = markerGroup.currentQuote;
    final MarkerDirection direction = markerGroup.direction;

    double? entryPrice;
    for (final ChartMarker m in markerGroup.markers) {
      if (m.markerType == MarkerType.entrySpot ||
          m.markerType == MarkerType.contractMarker ||
          m.markerType == MarkerType.startTimeCollapsed) {
        entryPrice = m.quote;
        break;
      }
    }

    bool? isWinning;
    if (currentQuote != null && entryPrice != null) {
      if (direction == MarkerDirection.up) {
        isWinning = currentQuote > entryPrice;
      } else {
        isWinning = currentQuote < entryPrice;
      }
    }

    // 获取调整后的 emoji 位置（处理重叠偏移）
    final Offset? adjustedEmojiCenter = enableOverlapHandling
        ? _overlapResolver.getEmojiAdjustedPosition(markerGroup.id)
        : null;
    final double naturalX = anchor.dx + _emojiLeftPadding + _emojiBgSize / 2;
    final double emojiBgCenterX = adjustedEmojiCenter != null
        ? math.max(adjustedEmojiCenter.dx, naturalX)
        : naturalX;

    // 绘制虚线连接（如果 emoji 被偏移了）
    final int emojiPositionIndex = enableOverlapHandling
        ? _overlapResolver.getEmojiPositionIndex(markerGroup.id)
        : 0;
    if (emojiPositionIndex > 0) {
      final double emojiLeftEdge = emojiBgCenterX - _emojiBgSize / 2;
      if (anchor.dx < emojiLeftEdge) {
        final Color lineColor = markerGroup.direction == MarkerDirection.up
            ? theme.markerStyle.upColorProminent
            : theme.markerStyle.downColorProminent;
        paintHorizontalDashedLine(
          canvas,
          anchor.dx,
          emojiLeftEdge,
          anchor.dy,
          lineColor.withValues(alpha: opacity),
          1,
          dashWidth: 2,
          dashSpace: 2,
        );
      }
    }

    // 绘制胜负表情
    if (isWinning != null) {
      final Color stateColor =
          isWinning ? theme.markerStyle.upColor : theme.markerStyle.downColor;

      const double emojiBgRadius = 4;
      final double bgX = emojiBgCenterX - _emojiBgSize / 2;
      final double bgY = anchor.dy - _emojiBgSize / 2;
      final RRect bgRRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(bgX, bgY, _emojiBgSize, _emojiBgSize),
        const Radius.circular(emojiBgRadius),
      );

      canvas.drawRRect(
        bgRRect,
        Paint()..color = stateColor.withValues(alpha: 0.1 * opacity),
      );
      canvas.drawRRect(
        bgRRect,
        Paint()
          ..color =
              stateColor.withValues(alpha: (isActive ? 1.0 : 0.3) * opacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.5,
      );

      final double emojiX = bgX + _emojiBgPadding;
      final double emojiY = anchor.dy - _emojiSize / 2;
      _drawEmojiIcon(
        canvas,
        Offset(emojiX, emojiY),
        _emojiSize,
        stateColor.withValues(alpha: opacity),
        isWinning,
      );
    }
  }

  // ==================== Emoji 矢量绘制 ====================

  /// 表情 SVG viewBox 尺寸。
  static const double _emojiViewBoxSize = 20;

  /// 赢的表情 Path（笑脸，viewBox 20x20）。
  static final Path _winEmojiPath = Path()
    ..addOval(const Rect.fromLTWH(5.6, 6.8, 2.4, 2.4)) // 左眼
    ..addOval(const Rect.fromLTWH(12, 6.8, 2.4, 2.4)) // 右眼
    // 外圈
    ..moveTo(10, 18)
    ..cubicTo(5.58172, 18, 2, 14.4182, 2, 10)
    ..cubicTo(2, 5.58172, 5.58172, 2, 10, 2)
    ..cubicTo(14.4182, 2, 18, 5.58172, 18, 10)
    ..cubicTo(18, 14.4182, 14.4182, 18, 10, 18)
    // 内圈（镂空）
    ..moveTo(10, 16.4)
    ..cubicTo(13.5346, 16.4, 16.4, 13.5346, 16.4, 10)
    ..cubicTo(16.4, 6.46538, 13.5346, 3.6, 10, 3.6)
    ..cubicTo(6.46538, 3.6, 3.6, 6.46538, 3.6, 10)
    ..cubicTo(3.6, 13.5346, 6.46538, 16.4, 10, 16.4)
    ..close()
    // 嘴巴（微笑弧线 + 下面闭合）
    ..moveTo(6, 10.8)
    ..lineTo(7.6, 10.8)
    ..cubicTo(7.6, 12.1255, 8.67448, 13.2, 10, 13.2)
    ..cubicTo(11.3255, 13.2, 12.4, 12.1255, 12.4, 10.8)
    ..lineTo(14, 10.8)
    ..cubicTo(14, 13.0091, 12.2091, 14.8, 10, 14.8)
    ..cubicTo(7.79086, 14.8, 6, 13.0091, 6, 10.8)
    ..close()
    ..fillType = PathFillType.evenOdd;

  /// 输的表情 Path（哭脸，viewBox 20x20）。
  static final Path _lossEmojiPath = Path()
    ..addOval(const Rect.fromLTWH(5.4165, 6.66675, 2.5, 2.5)) // 左眼
    ..addOval(const Rect.fromLTWH(12.0832, 6.66675, 2.5, 2.5)) // 右眼
    // 外圈
    ..moveTo(9.99984, 18.3334)
    ..cubicTo(5.39746, 18.3334, 1.6665, 14.6024, 1.6665, 10.0001)
    ..cubicTo(1.6665, 5.39771, 5.39746, 1.66675, 9.99984, 1.66675)
    ..cubicTo(14.6022, 1.66675, 18.3332, 5.39771, 18.3332, 10.0001)
    ..cubicTo(18.3332, 14.6024, 14.6022, 18.3334, 9.99984, 18.3334)
    // 内圈（镂空）
    ..moveTo(9.99984, 16.6667)
    ..cubicTo(13.6818, 16.6667, 16.6665, 13.682, 16.6665, 10.0001)
    ..cubicTo(16.6665, 6.31818, 13.6818, 3.33341, 9.99984, 3.33341)
    ..cubicTo(6.31794, 3.33341, 3.33317, 6.31818, 3.33317, 10.0001)
    ..cubicTo(3.33317, 13.682, 6.31794, 16.6667, 9.99984, 16.6667)
    ..close()
    // 嘴巴（倒弧线，哭脸）
    ..moveTo(5.83317, 14.1667)
    ..cubicTo(5.83317, 11.8656, 7.69865, 10.0001, 9.99984, 10.0001)
    ..cubicTo(12.301, 10.0001, 14.1665, 11.8656, 14.1665, 14.1667)
    ..lineTo(12.4998, 14.1667)
    ..cubicTo(12.4998, 12.786, 11.3806, 11.6667, 9.99984, 11.6667)
    ..cubicTo(8.61909, 11.6667, 7.49984, 12.786, 7.49984, 14.1667)
    ..close()
    ..fillType = PathFillType.evenOdd;

  final Paint _emojiPaint = Paint();

  /// 绘制矢量表情图标。
  void _drawEmojiIcon(
    Canvas canvas,
    Offset topLeft,
    double size,
    Color color,
    bool isWinning,
  ) {
    final double scale = size / _emojiViewBoxSize;
    canvas
      ..save()
      ..translate(topLeft.dx, topLeft.dy)
      ..scale(scale);
    _emojiPaint.color = color;
    canvas.drawPath(
      isWinning ? _winEmojiPath : _lossEmojiPath,
      _emojiPaint,
    );
    canvas.restore();
  }

  void _drawStartPoint(
    Canvas canvas,
    Size size,
    ChartTheme theme,
    ChartMarker marker,
    Offset anchor,
    MarkerStyle style,
    double zoom,
    double opacity,
  ) {
    if (marker.quote != 0) {
      paintStartMarker(
        canvas,
        anchor - Offset(20 * zoom / 2, 20 * zoom),
        style.backgroundColor.withValues(alpha: opacity),
        20 * zoom,
      );
    }

    if (marker.text != null) {
      final TextStyle textStyle = TextStyle(
        color:
            (marker.color ?? style.backgroundColor).withValues(alpha: opacity),
        fontSize: style.activeMarkerText.fontSize! * zoom,
        fontWeight: FontWeight.bold,
        backgroundColor: theme.backgroundColor.withValues(alpha: opacity),
      );

      final TextPainter textPainter = makeTextPainter(marker.text!, textStyle);

      final Offset iconShift =
          Offset(textPainter.width / 2, 20 * zoom + textPainter.height);

      paintWithTextPainter(
        canvas,
        painter: textPainter,
        anchor: anchor - iconShift,
        anchorAlignment: Alignment.centerLeft,
      );
    }
  }

  void _drawCollapsedTimeLine(
    Canvas canvas,
    ChartMarker marker,
    Offset anchor,
    MarkerStyle style,
    ChartTheme theme,
    double zoom,
    double opacity,
  ) {
    final double radius = 2.5 * zoom;
    final Color color = marker.direction == MarkerDirection.up
        ? theme.markerStyle.upColorProminent
        : theme.markerStyle.downColorProminent;
    final Paint paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(anchor, radius, paint);
  }

  // ==================== 连线与进度线绘制 ====================

  /// 绘制所有连线（barriers）。
  void _drawBarriers(
    Canvas canvas,
    Size size,
    Map<MarkerType, Offset> points,
    MarkerGroup markerGroup,
    MarkerStyle style,
    ChartTheme theme,
    double opacity,
    PainterProps painterProps,
    Paint paint,
    EpochToX epochToX,
    String? markerId,
  ) {
    final Offset? contractMarkerOffset = points[MarkerType.contractMarker];
    final Offset? startCollapsedOffset = points[MarkerType.startTimeCollapsed];
    final Offset? exitCollapsedOffset = points[MarkerType.exitTimeCollapsed];
    final Offset? entrySpotOffset = points[MarkerType.entrySpot];
    final Offset? exitSpotOffset = points[MarkerType.exitSpot];

    final Color lineColor = markerGroup.direction == MarkerDirection.up
        ? theme.markerStyle.upColorProminent
        : theme.markerStyle.downColorProminent;

    final Color finalLineColor = lineColor.withValues(alpha: opacity);

    final double contractMarkerRadius =
        markerConfig.outerRadius(painterProps.zoom);

    YAxisConfig.instance.yAxisClipping(canvas, size, () {
      // 绘制从合约标记到开始时间的价格虚线
      if (showContractToStartDashedLine &&
          contractMarkerOffset != null &&
          startCollapsedOffset != null) {
        final double lineStartX =
            contractMarkerOffset.dx + contractMarkerRadius;
        if (lineStartX < startCollapsedOffset.dx) {
          paintHorizontalDashedLine(
            canvas,
            lineStartX,
            startCollapsedOffset.dx,
            contractMarkerOffset.dy,
            finalLineColor,
            1,
            dashWidth: 2,
            dashSpace: 2,
          );
        }
      }

      // 绘制合约进度线（从开始到结束的水平线）
      _drawContractProgressLine(
        canvas,
        size,
        startCollapsedOffset,
        exitCollapsedOffset,
        finalLineColor,
        markerGroup,
        epochToX,
        painterProps.granularity,
      );

      // 绘制从结束时间到屏幕边缘的价格虚线
      if (showExitToEdgeDashedLine &&
          contractMarkerOffset != null &&
          exitCollapsedOffset != null) {
        final double rightEdgeX = size.width;
        paintHorizontalDashedLine(
          canvas,
          exitCollapsedOffset.dx,
          rightEdgeX,
          exitCollapsedOffset.dy,
          finalLineColor,
          1,
          dashWidth: 2,
          dashSpace: 2,
        );
      }

      // 绘制从入场点标记到开始时间标记的垂直虚线
      if (entrySpotOffset != null &&
          startCollapsedOffset != null &&
          startCollapsedOffset.dy != entrySpotOffset.dy) {
        paintVerticalDashedLine(
          canvas,
          entrySpotOffset.dx,
          math.min(startCollapsedOffset.dy, entrySpotOffset.dy),
          math.max(startCollapsedOffset.dy, entrySpotOffset.dy),
          finalLineColor,
          1,
          dashWidth: 2,
          dashSpace: 2,
        );
      }

      // 绘制从出场点标记到结束时间标记的垂直虚线
      if (exitSpotOffset != null &&
          exitCollapsedOffset != null &&
          exitCollapsedOffset.dy != exitSpotOffset.dy) {
        paintVerticalDashedLine(
          canvas,
          exitSpotOffset.dx,
          math.min(exitCollapsedOffset.dy, exitSpotOffset.dy),
          math.max(exitCollapsedOffset.dy, exitSpotOffset.dy),
          finalLineColor,
          1,
          dashWidth: 2,
          dashSpace: 2,
        );
      }
    });
  }

  /// 绘制合约进度线（从开始到结束的水平线）。
  void _drawContractProgressLine(
    Canvas canvas,
    Size size,
    Offset? startOffset,
    Offset? exitOffset,
    Color lineColor,
    MarkerGroup markerGroup,
    EpochToX epochToX,
    int granularity,
  ) {
    if (startOffset == null) return;

    final double strokeWidth = 1;
    final Paint solidLinePaint = Paint()
      ..color = lineColor
      ..strokeWidth = strokeWidth;

    final int? currentEpoch = markerGroup.currentEpoch;

    if (currentEpoch != null && exitOffset != null) {
      int? startEpoch;
      int? endEpoch;
      for (final ChartMarker marker in markerGroup.markers) {
        if (marker.markerType == MarkerType.startTimeCollapsed) {
          startEpoch = marker.epoch;
        } else if (marker.markerType == MarkerType.exitTimeCollapsed) {
          endEpoch = marker.epoch;
        }
      }

      if (startEpoch != null && endEpoch != null && endEpoch > startEpoch) {
        final double currentX = _calculateInterpolatedX(
          currentEpoch,
          granularity,
          epochToX,
        ).clamp(startOffset.dx, exitOffset.dx);

        // 背景线（50% 白色，从开始到结束）
        final Paint backgroundPaint = Paint()
          ..color = Colors.white.withValues(alpha: 0.5)
          ..strokeWidth = strokeWidth;
        canvas.drawLine(startOffset, exitOffset, backgroundPaint);

        // 进度线（lineColor，从开始到当前时间）
        final Offset currentOffset = Offset(currentX, startOffset.dy);
        canvas.drawLine(startOffset, currentOffset, solidLinePaint);
      } else {
        canvas.drawLine(startOffset, exitOffset, solidLinePaint);
      }
    } else {
      if (exitOffset != null) {
        canvas.drawLine(startOffset, exitOffset, solidLinePaint);
      } else {
        final double rightEdgeX = size.width;
        canvas.drawLine(
          startOffset,
          Offset(rightEdgeX, startOffset.dy),
          solidLinePaint,
        );
      }
    }
  }

  /// 计算 epoch 对应的精确 X 坐标（在 K 线周期内进行插值）。
  ///
  /// epochToX 返回的是 K 线柱子的中心位置，对于大周期 K 线（如 5 秒、15 秒），
  /// 同一个 K 线周期内的所有时间点都会返回相同的 X 坐标。
  /// 此方法通过在相邻两个 K 线之间进行线性插值，实现平滑的进度显示。
  double _calculateInterpolatedX(
    int epoch,
    int granularity,
    EpochToX epochToX,
  ) {
    final int candleStartEpoch = (epoch ~/ granularity) * granularity;
    final int nextCandleEpoch = candleStartEpoch + granularity;

    final double currentCandleX = epochToX(candleStartEpoch);
    final double nextCandleX = epochToX(nextCandleEpoch);

    final double progress = (epoch - candleStartEpoch) / granularity;

    return currentCandleX + (nextCandleX - currentCandleX) * progress;
  }
}
