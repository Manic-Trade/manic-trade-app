import 'package:deriv_chart/deriv_chart.dart';
import 'package:finality/generated/assets.dart';
import 'package:finality/theme/attrs/clash_display_font.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;

/// 合约标记的尺寸配置。
///
/// 用于统一管理合约标记的各种尺寸参数，避免在代码中重复定义。
class ContractMarkerConfig {
  const ContractMarkerConfig({
    this.baseRadius = 12,
    this.borderPadding = 0,
    this.strokeWidth = 2,
    this.progressBackgroundOpacity = 0.2,
  });

  /// 内圆基础半径
  final double baseRadius;

  /// 边框与内圆的间距
  final double borderPadding;

  /// 边框和进度条的线宽
  final double strokeWidth;

  /// 进度条背景透明度
  final double progressBackgroundOpacity;

  /// 计算应用 zoom 后的内圆半径
  double radius(double zoom) => baseRadius * zoom;

  /// 计算应用 zoom 后的边框半径
  double borderRadius(double zoom) => radius(zoom) + (borderPadding * zoom);

  /// 计算应用 zoom 后的线宽
  double scaledStrokeWidth(double zoom) => strokeWidth * zoom;

  /// 计算标记的外半径（用于定位和碰撞检测）
  double outerRadius(double zoom) =>
      borderRadius(zoom) + scaledStrokeWidth(zoom) / 2;

  /// 计算标记的直径
  double diameter(double zoom) => outerRadius(zoom) * 2;

  /// 默认配置
  static const ContractMarkerConfig defaultConfig = ContractMarkerConfig();
}

/// A specialized painter for rendering tick-based contract markers on financial charts.
///
/// `TickMarkerIconPainter` extends the abstract `MarkerGroupIconPainter` class to provide
/// specific rendering logic for tick-based contracts. Tick-based contracts are financial
/// contracts where the outcome depends on price movements at specific time intervals (ticks).
///
/// This painter visualizes various aspects of tick contracts on the chart, including:
/// - The starting point of the contract
/// - Entry and exit points
/// - Individual price ticks
/// - Barrier lines connecting significant points
///
/// The painter uses different visual representations for different marker types:
/// - Start markers are shown as location pins with optional labels
/// - Entry points are shown as circles with a distinctive border
/// - Tick points are shown as small dots
/// - Exit points are shown as circles
/// - End points are shown as flag icons
///
/// This class is part of the chart's visualization pipeline and works in conjunction
/// with `MarkerGroupPainter` to render marker groups on the chart canvas.
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
  });

  /// 合约标记的尺寸配置
  final ContractMarkerConfig markerConfig;

  // ==================== 图片资源缓存 ====================

  /// 盈利表情图片缓存
  static ui.Image? _winEmojiImage;

  /// 亏损表情图片缓存
  static ui.Image? _lossEmojiImage;

  /// 出场点旗帜图标缓存
  static ui.Image? _exitFlagHighImage;

  /// 出场点旗帜图标缓存
  static ui.Image? _exitFlagLowImage;

  /// 图片是否已加载
  static bool _imagesLoaded = false;

  /// 预加载出场点标记所需的图片资源。
  ///
  /// 应在使用 painter 之前调用此方法，通常在页面初始化时调用。
  /// 此方法是幂等的，多次调用只会加载一次。
  static Future<void> loadImages() async {
    if (_imagesLoaded) return;

    await Future.wait([
      _loadImage(Assets.emojiOptionsWin).then((img) => _winEmojiImage = img),
      _loadImage(Assets.emojiOptionsLoss).then((img) => _lossEmojiImage = img),
      _loadImage(Assets.icExitEpotFlagHigh)
          .then((img) => _exitFlagHighImage = img),
      _loadImage(Assets.icExitEpotFlagLow)
          .then((img) => _exitFlagLowImage = img),
    ]);

    _imagesLoaded = true;
  }

  /// 从 assets 加载图片并转换为 ui.Image。
  static Future<ui.Image> _loadImage(String assetPath) async {
    final ByteData data = await rootBundle.load(assetPath);
    final ui.Codec codec =
        await ui.instantiateImageCodec(data.buffer.asUint8List());
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    return frameInfo.image;
  }

  /// 是否绘制从合约标记到开始时间的价格虚线。
  final bool showContractToStartDashedLine;

  /// 是否绘制从结束时间到屏幕边缘的价格虚线。
  final bool showExitToEdgeDashedLine;

  /// 是否启用重叠处理。
  /// 当为 true 时，价格接近的合约标记会自动横向排列以避免重叠。
  /// 当为 false 时，保持原有行为，标记会直接重叠显示。
  final bool enableOverlapHandling;

  /// 是否在出场点显示旗帜图标和倒计时。
  /// 当为 true 时，显示旗帜图标、倒计时和胜负表情。
  /// 当为 false 时，只显示胜负表情。
  final bool showExitCountdown;

  // ==================== 激活状态管理 ====================

  /// 当前激活的标记 ID。
  String? _activeMarkerId;

  /// 激活标记显示的文本（如 "$10 Entry 95100"）。
  String? _activeMarkerText;

  /// 激活时间戳，用于计算动画进度。
  int? _activationTimestamp;

  /// 动画时长（毫秒）。
  static const int _animationDurationMs = 400;

  /// 设置激活的标记。
  ///
  /// [markerId] 要激活的标记 ID。
  /// [text] 激活后显示的文本。
  void setActiveMarker(String markerId, String text) {
    _activeMarkerId = markerId;
    _activeMarkerText = text;
    _activationTimestamp = DateTime.now().millisecondsSinceEpoch;
  }

  /// 清除激活状态。
  void clearActiveMarker() {
    _activeMarkerId = null;
    _activeMarkerText = null;
    _activationTimestamp = null;
  }

  /// 检查是否有激活的标记。
  bool get hasActiveMarker => _activeMarkerId != null;

  /// 检查指定标记是否是激活状态。
  bool isActiveMarker(String? markerId) =>
      markerId != null && _activeMarkerId == markerId;

  /// 计算当前动画进度 (0.0 到 1.0)。
  double _getAnimationProgress() {
    if (_activationTimestamp == null) return 0.0;
    final int elapsed =
        DateTime.now().millisecondsSinceEpoch - _activationTimestamp!;
    final double progress = (elapsed / _animationDurationMs).clamp(0.0, 1.0);
    // 使用 ease-out 缓动函数
    return 1.0 - math.pow(1.0 - progress, 3);
  }

  /// A map to store the previous remaining duration for each marker group.
  /// This is used to create smooth animations between updates by interpolating
  /// from the actual previous value instead of calculating an estimated one.
  /// Key: marker group ID, Value: previous remaining duration (0.0 to 1.0)
  final Map<String, double> _previousRemainingDurations = <String, double>{};

  /// 存储当前帧所有 contractMarker 的位置信息（预注册阶段收集）。
  /// 用于检测重叠并计算横向偏移。
  /// 包含：Rect（标记的边界矩形）和 markerId（用于排除自身）
  final List<_DrawnContractMarker> _currentFrameContractMarkers =
      <_DrawnContractMarker>[];

  /// 存储已计算好的偏移后位置。
  /// Key: markerId, Value: 偏移后的锚点位置。
  final Map<String, Offset> _markerAdjustedPositions = <String, Offset>{};

  /// 存储每个标记的位置索引。
  /// Key: markerId, Value: positionIndex（0 表示最靠近 startTimeCollapsed）。
  final Map<String, int> _markerPositionIndices = <String, int>{};

  /// 标记偏移位置是否已计算完成。
  bool _positionsCalculated = false;

  // ==================== 位置计算常量 ====================

  /// 合约标记与 startTimeCollapsed 之间的间距
  static const double _contractMarkerSpacing = 24;

  /// 每帧开始时调用，清空上一帧的状态。
  @override
  void onFrameStart() {
    if (enableOverlapHandling) {
      _currentFrameContractMarkers.clear();
      _markerAdjustedPositions.clear();
      _markerPositionIndices.clear();
      _positionsCalculated = false;
    }
  }

  /// 统一计算所有标记的偏移后位置。
  ///
  /// 此方法在所有 MarkerGroup 预注册完成后、第一次绑制前调用。
  /// 根据 `_currentFrameContractMarkers` 中的信息计算每个标记的偏移后位置。
  ///
  /// 对于重叠的标记组，使用统一的基准 X 位置（最大的原始 X），
  /// 确保所有重叠标记紧挨着排列，没有大间隙。
  void _calculateAllAdjustedPositions() {
    if (_positionsCalculated || !enableOverlapHandling) return;

    const double markerSpacing = 4;

    // 第一步：为每个标记找到其重叠组中最大的原始 X 位置（作为基准）
    final Map<String, double> baseXPositions = {};

    for (final _DrawnContractMarker marker in _currentFrameContractMarkers) {
      if (marker.markerId == null) continue;

      // 找到与当前标记重叠的所有标记中，原始 X 最大的那个
      double maxX = marker.bounds.center.dx;

      for (final _DrawnContractMarker other in _currentFrameContractMarkers) {
        if (other.markerId == marker.markerId) continue;
        if (!_wouldOverlap(marker.bounds, other.bounds,
            spacing: markerSpacing)) {
          continue;
        }
        // 找到重叠组中最大的 X（最靠近 startTimeCollapsed 的位置）
        if (other.bounds.center.dx > maxX) {
          maxX = other.bounds.center.dx;
        }
      }

      baseXPositions[marker.markerId!] = maxX;
    }

    // 第二步：使用统一的基准 X 位置计算偏移后的位置
    for (final _DrawnContractMarker marker in _currentFrameContractMarkers) {
      if (marker.markerId == null) continue;

      // 计算位置索引
      final int positionIndex = _calculatePositionIndex(
        marker.bounds,
        marker.entryEpoch,
        marker.markerId,
        spacing: markerSpacing,
      );

      // 存储位置索引（用于判断是否绘制连线）
      _markerPositionIndices[marker.markerId!] = positionIndex;

      // 使用重叠组的基准 X 位置，而不是当前标记的原始 X 位置
      final double baseX = baseXPositions[marker.markerId!]!;
      final double markerWidthWithSpacing = marker.bounds.width + markerSpacing;
      final double xOffset = positionIndex * markerWidthWithSpacing;

      final Offset adjustedPosition = Offset(
        baseX - xOffset,
        marker.bounds.center.dy,
      );

      _markerAdjustedPositions[marker.markerId!] = adjustedPosition;
    }

    _positionsCalculated = true;
  }

  /// 获取标记的偏移后位置。
  ///
  /// [markerId] 标记的 ID。
  /// [originalAnchor] 原始锚点位置（如果没有偏移后的位置则返回此值）。
  Offset _getAdjustedPosition(String? markerId, Offset originalAnchor) {
    if (markerId == null || !enableOverlapHandling) return originalAnchor;
    return _markerAdjustedPositions[markerId] ?? originalAnchor;
  }

  /// 准备 MarkerGroup 数据，用于后续的绑制（如位置计算、重叠处理等）。
  ///
  /// 此方法在所有 MarkerGroup 绑制之前被调用，确保位置计算时能看到所有标记，
  /// 不受 zIndex 绘制顺序的影响。
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
        // 使用配置类计算尺寸
        final double zoom = painterProps.zoom;
        final int granularity = painterProps.granularity;
        final double markerDiameter = markerConfig.diameter(zoom);
        final double contractOuterRadius = markerConfig.outerRadius(zoom);

        // 计算原始 Y 坐标
        final double originalY = quoteToY(marker.quote);

        // 计算原始锚点位置：基于 startTimeCollapsed 前面偏移
        final double anchorX;
        if (startTimeCollapsedEpoch != null) {
          // 新位置：startTimeCollapsed 前面（使用插值计算精确位置）
          anchorX = _calculateInterpolatedX(
                startTimeCollapsedEpoch,
                granularity,
                epochToX,
              ) -
              _contractMarkerSpacing -
              contractOuterRadius;
        } else {
          // 回退到原来的固定左边位置
          anchorX =
              markerGroup.props.contractMarkerLeftPadding + contractOuterRadius;
        }
        final Offset anchor = Offset(anchorX, originalY);

        // 注册标记信息（使用原始位置，实际绘制位置会在 _calculateAllAdjustedPositions 中计算）
        final Rect bounds = Rect.fromCenter(
          center: anchor,
          width: markerDiameter,
          height: markerDiameter,
        );

        _registerDrawnContractMarker(
          bounds,
          markerGroup.id,
          originalY,
          marker.epoch,
        );
        break; // 每个 MarkerGroup 只有一个 contractMarker
      }
    }
  }

  /// 绘制 markerGroup 的底层（线/barriers）。
  ///
  /// 此方法在所有 markerGroup 的标记绑制之前被调用，
  /// 确保所有线都在所有标记下面，不会盖住任何标记。
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
    _calculateAllAdjustedPositions();

    final Map<MarkerType, Offset> points = <MarkerType, Offset>{};
    final double contractOuterRadius =
        markerConfig.outerRadius(painterProps.zoom);
    final int granularity = painterProps.granularity;

    // 先找到 startTimeCollapsed 的 X 坐标（使用插值计算精确位置）
    double? startTimeCollapsedX;
    for (final ChartMarker marker in markerGroup.markers) {
      if (marker.markerType == MarkerType.startTimeCollapsed) {
        startTimeCollapsedX = _calculateInterpolatedX(
          marker.epoch,
          granularity,
          epochToX,
        );
        break;
      }
    }

    // 收集所有标记的位置
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
        center = _getAdjustedPosition(markerGroup.id, originalCenter);
      } else if (marker.markerType == MarkerType.startTimeCollapsed ||
          marker.markerType == MarkerType.exitTimeCollapsed) {
        // 对于开始和结束时间标记，使用插值计算精确的 X 坐标
        center = Offset(
          _calculateInterpolatedX(marker.epoch, granularity, epochToX),
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
    _drawBarriers(canvas, size, points, markerGroup, markerGroup.style, theme,
        opacity, painterProps, paint, epochToX, markerGroup.id);

    // 绘制除 contractMarker 之外的所有标记
    for (final ChartMarker marker in markerGroup.markers) {
      // 跳过 contractMarker，它将在 paintMarkerGroupHigh 中绘制
      if (marker.markerType == MarkerType.contractMarker) {
        continue;
      }

      final Offset center = points[marker.markerType!] ??
          Offset(epochToX(marker.epoch), quoteToY(marker.quote));

      if (marker.markerType == MarkerType.entry &&
          points[MarkerType.entrySpot] != null) {
        continue;
      }

      _drawMarker(
          canvas,
          size,
          theme,
          marker,
          center,
          markerGroup.style,
          painterProps.zoom,
          painterProps.granularity,
          opacity,
          paint,
          animationInfo,
          markerGroup.id,
          markerGroup);
    }
  }

  /// Renders a group of tick contract markers on the chart canvas.
  ///
  /// This method is called by the chart's rendering system to paint a group of
  /// related markers (representing a single tick contract) on the canvas. It:
  /// 1. Converts marker positions from market data (epoch/quote) to canvas coordinates
  /// 2. Calculates the opacity based on marker positions
  /// 3. Draws barrier lines connecting significant points
  /// 4. Delegates the rendering of individual markers to specialized methods
  ///
  /// @param canvas The canvas on which to paint.
  /// @param size The size of the drawing area.
  /// @param theme The chart's theme, which provides colors and styles.
  /// @param markerGroup The group of markers to render.
  /// @param epochToX A function that converts epoch timestamps to X coordinates.
  /// @param quoteToY A function that converts price quotes to Y coordinates.
  /// @param painterProps Properties that affect how markers are rendered.
  /// @param animationInfo Information about any ongoing animations.
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
    // 确保所有标记的偏移后位置已计算完成（在第一次绑制时计算）
    _calculateAllAdjustedPositions();

    final Map<MarkerType, Offset> points = <MarkerType, Offset>{};
    // 使用配置类计算合约标记的外半径
    final double contractOuterRadius =
        markerConfig.outerRadius(painterProps.zoom);

    // 先找到 startTimeCollapsed 的 X 坐标
    double? startTimeCollapsedX;
    for (final ChartMarker marker in markerGroup.markers) {
      if (marker.markerType == MarkerType.startTimeCollapsed) {
        startTimeCollapsedX = epochToX(marker.epoch);
        break;
      }
    }

    // 收集所有标记的位置（contractMarker 使用已计算好的偏移后位置）
    for (final ChartMarker marker in markerGroup.markers) {
      final Offset center;

      if (marker.markerType == MarkerType.contractMarker) {
        // contractMarker 使用基于 startTimeCollapsed 的位置
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
        center = _getAdjustedPosition(markerGroup.id, originalCenter);
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

    final Offset? startPoint = points[MarkerType.start];
    final Offset? exitPoint = points[MarkerType.exit];
    final Offset? endPoint = points[MarkerType.exitSpot];

    double opacity = 1;

    if (startPoint != null && (endPoint != null || exitPoint != null)) {
      opacity = calculateOpacity(startPoint.dx, exitPoint?.dx);
    }

    final Paint paint = Paint()
      ..color = markerGroup.style.backgroundColor.withValues(alpha: opacity);

    // 注意：线（barriers）和其他标记已经在 paintMarkerGroup 中绘制
    // 这里只绘制 contractMarker，确保它在最顶层
    for (final ChartMarker marker in markerGroup.markers) {
      // 只绘制 contractMarker
      if (marker.markerType != MarkerType.contractMarker) {
        continue;
      }

      final Offset center = _getAdjustedPosition(
        markerGroup.id,
        Offset(
          startTimeCollapsedX != null
              ? startTimeCollapsedX -
                  _contractMarkerSpacing -
                  contractOuterRadius
              : markerGroup.props.contractMarkerLeftPadding +
                  contractOuterRadius,
          quoteToY(marker.quote),
        ),
      );

      _drawMarker(
          canvas,
          size,
          theme,
          marker,
          center,
          markerGroup.style,
          painterProps.zoom,
          painterProps.granularity,
          opacity,
          paint,
          animationInfo,
          markerGroup.id,
          markerGroup);
    }
  }

  /// Draws barrier lines connecting significant points in the contract.
  ///
  /// This private method renders various lines that connect important points in the
  /// contract, such as the contract marker, entry tick, and end point.
  /// These lines help visualize the contract's progression and price movement.
  ///
  /// The method draws different types of lines:
  /// - A dashed horizontal line from the contract marker to the entry tick
  /// - A solid line from the entry tick to the end marker
  /// - A dashed horizontal line from the end marker to the chart's right edge
  ///
  /// @param canvas The canvas on which to paint.
  /// @param size The size of the drawing area.
  /// @param points A map of marker types to their positions on the canvas.
  /// @param markerGroup The group of markers to render.
  /// @param style The style to apply to the barriers.
  /// @param opacity The opacity to apply to the barriers.
  /// @param painterProps Properties that affect how barriers are rendered.
  /// @param epochToX A function that converts epoch timestamps to X coordinates.
  /// @param markerId The ID of the marker group, used to determine if the line should be drawn.
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
      String? markerId) {
    final Offset? _contractMarkerOffset = points[MarkerType.contractMarker];
    final Offset? _startCollapsedOffset = points[MarkerType.startTimeCollapsed];
    final Offset? _exitCollapsedOffset = points[MarkerType.exitTimeCollapsed];
    final Offset? _entrySpotOffset = points[MarkerType.entrySpot];
    final Offset? _exitSpotOffset = points[MarkerType.exitSpot];

    // 从 markerGroup 的方向确定线条颜色
    final Color lineColor = markerGroup.direction == MarkerDirection.up
        ? theme.markerStyle.upColorProminent
        : theme.markerStyle.downColorProminent;

    final Color finalLineColor = lineColor.withValues(alpha: opacity);

    // 使用配置类计算合约标记的半径
    final double contractMarkerRadius =
        markerConfig.outerRadius(painterProps.zoom);

    YAxisConfig.instance.yAxisClipping(canvas, size, () {
      // 绘制从合约标记到开始时间的价格虚线
      // 连线从标记的右边缘开始，不穿过标记本身
      if (showContractToStartDashedLine &&
          _contractMarkerOffset != null &&
          _startCollapsedOffset != null) {
        final double lineStartX =
            _contractMarkerOffset.dx + contractMarkerRadius;
        // 只有当起点在终点左边时才画线
        if (lineStartX < _startCollapsedOffset.dx) {
          paintHorizontalDashedLine(
            canvas,
            lineStartX,
            _startCollapsedOffset.dx,
            _contractMarkerOffset.dy,
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
        _startCollapsedOffset,
        _exitCollapsedOffset,
        finalLineColor,
        markerGroup,
        epochToX,
        painterProps.granularity,
      );

      // 绘制从结束时间到屏幕边缘的价格虚线
      if (showExitToEdgeDashedLine &&
          _contractMarkerOffset != null &&
          _exitCollapsedOffset != null) {
        final double rightEdgeX = size.width;

        paintHorizontalDashedLine(
          canvas,
          _exitCollapsedOffset.dx,
          rightEdgeX,
          _exitCollapsedOffset.dy,
          finalLineColor,
          1,
          dashWidth: 2,
          dashSpace: 2,
        );
      }

      // 绘制从入场点标记到开始时间标记的垂直虚线
      if (_entrySpotOffset != null &&
          _startCollapsedOffset != null &&
          _startCollapsedOffset.dy != _entrySpotOffset.dy) {
        paintVerticalDashedLine(
          canvas,
          _entrySpotOffset.dx,
          math.min(_startCollapsedOffset.dy, _entrySpotOffset.dy),
          math.max(_startCollapsedOffset.dy, _entrySpotOffset.dy),
          finalLineColor,
          1,
          dashWidth: 2,
          dashSpace: 2,
        );
      }

      // 绘制从出场点标记到结束时间标记的垂直虚线
      if (_exitSpotOffset != null &&
          _exitCollapsedOffset != null &&
          _exitCollapsedOffset.dy != _exitSpotOffset.dy) {
        paintVerticalDashedLine(
          canvas,
          _exitSpotOffset.dx,
          math.min(_exitCollapsedOffset.dy, _exitSpotOffset.dy),
          math.max(_exitCollapsedOffset.dy, _exitSpotOffset.dy),
          finalLineColor,
          1,
          dashWidth: 2,
          dashSpace: 2,
        );
      }
    });
  }

  /// Renders an individual marker based on its type.
  ///
  /// This private method handles the rendering of different types of markers
  /// (start, entry, tick, exit, end) with their specific visual representations.
  /// It delegates to specialized methods for each marker type.
  ///
  /// @param canvas The canvas on which to paint.
  /// @param size The size of the drawing area.
  /// @param theme The chart's theme, which provides colors and styles.
  /// @param marker The marker to render.
  /// @param anchor The position on the canvas where the marker should be rendered.
  /// @param style The style to apply to the marker.
  /// @param zoom The current zoom level of the chart.
  /// @param opacity The opacity to apply to the marker.
  /// @param animationInfo Information about any ongoing animations.
  /// @param markerGroupId The ID of the marker group for animation tracking.
  /// @param markerGroup The marker group containing all related markers for this contract.
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
      MarkerGroup markerGroup) {
    YAxisConfig.instance.yAxisClipping(canvas, size, () {
      switch (marker.markerType) {
        // Use a fixed zoom value of 1.2 for contract markers to provide a
        // consistently larger size, improving tap target accessibility.
        case MarkerType.contractMarker:
          _drawContractMarker(canvas, marker, anchor, style, zoom, granularity,
              opacity, animationInfo, markerGroupId, markerGroup);
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
          );
          break;
        case MarkerType.exit:
          canvas.drawCircle(
            anchor,
            3 * zoom,
            paint,
          );
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
            canvas,
            marker,
            anchor,
            style,
            theme,
            zoom,
            opacity,
          );
          break;
        case MarkerType.exitTimeCollapsed:
          _drawCollapsedTimeLine(
            canvas,
            marker,
            anchor,
            style,
            theme,
            zoom,
            opacity,
          );
          break;
        case MarkerType.profitAndLossLabel:
          _drawProfitAndLossLabel(
            canvas,
            theme,
            markerGroup,
            marker,
            anchor,
            style,
            1,
            opacity,
            fixedLeftAligned: false,
          );
          break;
        case MarkerType.profitAndLossLabelFixed:
          _drawProfitAndLossLabel(
            canvas,
            theme,
            markerGroup,
            marker,
            anchor,
            style,
            1,
            opacity,
            fixedLeftAligned: true,
          );
          break;
        default:
          break;
      }
    });
  }

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

  /// Calculate remaining duration with smooth animation transitions.
  ///
  /// This method calculates the remaining duration for the contract progress arc
  /// with smooth interpolation between updates using currentTickPercent from AnimationInfo.
  /// It takes granularity into account for accurate timing calculations.
  ///
  /// @param markerGroup The marker group containing contract information.
  /// @param animationInfo Animation information containing currentTickPercent.
  /// @param granularity The time interval between data points in milliseconds.
  /// @return The animated remaining duration as a value between 0.0 and 1.0.
  double _calculateAnimatedRemainingDuration(
    MarkerGroup markerGroup,
    AnimationInfo animationInfo,
    int granularity,
  ) {
    // Default to full arc duration
    double baseRemainingDuration = 1;

    if (markerGroup.currentEpoch != null) {
      // Find entryTick and end marker epochs
      int? entryTickEpoch;
      int? endEpoch;

      for (final ChartMarker groupMarker in markerGroup.markers) {
        if (groupMarker.markerType == MarkerType.entrySpot) {
          entryTickEpoch ??= groupMarker.epoch;
        } else if (groupMarker.markerType == MarkerType.startTimeCollapsed) {
          entryTickEpoch ??= groupMarker.epoch;
        } else if (groupMarker.markerType == MarkerType.exitSpot) {
          endEpoch ??= groupMarker.epoch;
        } else if (groupMarker.markerType == MarkerType.exitTimeCollapsed) {
          endEpoch ??= groupMarker.epoch;
        }
        if (entryTickEpoch != null && endEpoch != null) {
          break;
        }
      }

      // Calculate base remaining duration
      if (entryTickEpoch != null && endEpoch != null) {
        final int totalDuration = endEpoch - entryTickEpoch;
        final int baseElapsed = markerGroup.currentEpoch! - entryTickEpoch;
        final double baseProgress = baseElapsed / totalDuration;
        baseRemainingDuration = (1.0 - baseProgress).clamp(0.0, 1.0);

        // Get the marker group ID for tracking animation state
        final String? groupId = markerGroup.id;

        if (groupId != null) {
          // Get the actual previous remaining duration from our stored values
          final double? previousRemainingDuration =
              _previousRemainingDurations[groupId];

          // Apply smooth animation transition using currentTickPercent
          // Only interpolate if we have a previous value to interpolate from
          if (previousRemainingDuration != null &&
              animationInfo.currentTickPercent < 1.0) {
            // Interpolate between the actual previous value and current value
            baseRemainingDuration = ui.lerpDouble(
                  previousRemainingDuration,
                  baseRemainingDuration,
                  animationInfo.currentTickPercent,
                ) ??
                baseRemainingDuration;
          }
          _previousRemainingDurations[groupId] = baseRemainingDuration;
        }
      }
    }

    return baseRemainingDuration;
  }

  /// 判断两个标记是否会在视觉上重叠。
  ///
  /// 主要检查 Y 方向的重叠：因为所有 contractMarker 最终都会被放置在各自的
  /// startTimeCollapsed 附近，不同合约的 startTimeCollapsed 可能不同，
  /// 但视觉上它们都在同一个区域内，所以重叠检测主要关注 Y 方向。
  ///
  /// [bounds1] 第一个标记的边界矩形。
  /// [bounds2] 第二个标记的边界矩形。
  /// [spacing] 标记之间的最小间距。
  bool _wouldOverlap(
    Rect bounds1,
    Rect bounds2, {
    double spacing = 4,
  }) {
    // 计算 Y 方向的距离
    final double yDistance = (bounds1.center.dy - bounds2.center.dy).abs();

    // 计算不重叠所需的最小 Y 距离
    final double minYDistance = (bounds1.height + bounds2.height) / 2 + spacing;

    // 只要 Y 方向有重叠就认为需要横向排列
    return yDistance < minYDistance;
  }

  /// 计算当前标记在重叠组中的位置索引。
  ///
  /// 基于入场时间排序：入场时间早的在左边（索引大，偏移多）。
  /// 时间早的标记需要更多的偏移量，给时间晚的标记腾出位置。
  /// 当入场时间相同时，使用 markerId 字符串比较来决定顺序。
  ///
  /// [currentBounds] 当前标记的边界矩形。
  /// [entryEpoch] 当前标记的入场时间。
  /// [markerId] 当前标记的 ID，用于排除自身和决定同时间标记的顺序。
  /// [spacing] 标记之间的最小间距。
  /// 返回位置索引（索引越大，偏移越多，位置越左）。
  int _calculatePositionIndex(
    Rect currentBounds,
    int entryEpoch,
    String? markerId, {
    double spacing = 4,
  }) {
    int positionIndex = 0;

    for (final _DrawnContractMarker drawnMarker
        in _currentFrameContractMarkers) {
      // 排除自身
      if (drawnMarker.markerId == markerId && markerId != null) {
        continue;
      }

      // 只考虑会产生重叠的标记（检查 Y 方向）
      if (!_wouldOverlap(currentBounds, drawnMarker.bounds, spacing: spacing)) {
        continue;
      }

      // 比较入场时间，时间早的排在左边（positionIndex 大）
      // 当入场时间相同时，使用 markerId 字符串比较来决定顺序
      if (drawnMarker.entryEpoch > entryEpoch) {
        // 其他标记时间更晚，当前标记排在左边
        positionIndex++;
      } else if (drawnMarker.entryEpoch == entryEpoch) {
        // 时间相同时，比较 markerId（字符串比较）
        // markerId 更大的排在左边
        if (markerId != null &&
            drawnMarker.markerId != null &&
            drawnMarker.markerId!.compareTo(markerId) > 0) {
          positionIndex++;
        }
      }
    }

    return positionIndex;
  }

  /// 注册已绘制的合约标记位置。
  ///
  /// 如果已存在相同 ID 的记录（例如 ActiveMarkerGroup 和普通 MarkerGroup），
  /// 则不重复注册，避免位置计算出错。
  ///
  /// [bounds] 标记的边界矩形。
  /// [markerId] 标记的唯一标识符。
  /// [originalY] 标记的原始 Y 坐标（用于判断是否是同一价格）。
  /// [entryEpoch] 入场时间戳。
  void _registerDrawnContractMarker(
    Rect bounds,
    String? markerId,
    double originalY,
    int entryEpoch,
  ) {
    // 检查是否已存在相同 ID 的记录，避免重复注册
    // （当同一个标记作为 ActiveMarkerGroup 和普通 MarkerGroup 被绘制时会出现这种情况）
    if (markerId != null) {
      final bool alreadyExists = _currentFrameContractMarkers
          .any((marker) => marker.markerId == markerId);
      if (alreadyExists) {
        return; // 已存在，不重复注册
      }
    }

    _currentFrameContractMarkers.add(_DrawnContractMarker(
      bounds: bounds,
      markerId: markerId,
      originalY: originalY,
      entryEpoch: entryEpoch,
    ));
  }

  /// Renders a contract marker with circular duration display.
  ///
  /// This method draws a circular marker that shows the contract progress
  /// with a circular progress indicator representing the remaining duration.
  /// The marker includes a background circle, progress arc, and a directional
  /// arrow icon in the center.
  ///
  /// @param canvas The canvas on which to paint.
  /// @param theme The chart's theme, which provides colors and styles.
  /// @param marker The marker object containing direction and progress.
  /// @param anchor The position on the canvas where the marker should be rendered.
  /// @param style The style to apply to the marker.
  /// @param zoom The current zoom level of the chart.
  /// @param opacity The opacity to apply to the marker.
  /// @param animationInfo Information about any ongoing animations.
  /// @param markerGroupId The ID of the marker group for animation tracking.
  /// @param markerGroup The marker group containing all related markers for this contract.
  void _drawContractMarker(
    Canvas canvas,
    ChartMarker marker,
    Offset anchor,
    MarkerStyle style,
    double zoom,
    int granularity,
    double opacity,
    AnimationInfo animationInfo,
    String? markerGroupId,
    MarkerGroup markerGroup,
  ) {
    // ========== 使用配置类计算实际尺寸 ==========
    final double radius = markerConfig.radius(zoom);
    final double borderRadius = markerConfig.borderRadius(zoom);
    final double scaledStrokeWidth = markerConfig.scaledStrokeWidth(zoom);
    final double progressBackgroundOpacity =
        markerConfig.progressBackgroundOpacity;

    // 注意：位置计算已在 _calculateAllAdjustedPositions() 中统一完成
    // 传入的 anchor 已经是偏移后的位置，直接使用即可
    final Offset effectiveAnchor = anchor;

    // ========== 激活状态处理 ==========
    final bool isActive = isActiveMarker(markerGroupId);
    // 如果有激活标记，非激活的标记变半透明
    final double effectiveOpacity =
        (hasActiveMarker && !isActive) ? opacity * 0.5 : opacity;

    // ========== 颜色配置 ==========
    final Color markerColor = marker.direction == MarkerDirection.up
        ? style.upColor
        : style.downColor;
    final Color progressBackgroundColor =
        Colors.black.withOpacity(progressBackgroundOpacity * effectiveOpacity);

    // ========== 绘制背景圆 ==========
    final Paint backgroundPaint = Paint()
      ..color = markerColor.withOpacity(effectiveOpacity)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(effectiveAnchor, radius, backgroundPaint);

    // ========== 绘制边框圆 ==========
    final Paint borderPaint = Paint()
      ..color = markerColor.withOpacity(effectiveOpacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = scaledStrokeWidth;
    canvas.drawCircle(effectiveAnchor, borderRadius, borderPaint);

    // ========== 绘制进度条背景（未填充部分） ==========
    final Paint progressBackgroundPaint = Paint()
      ..color = progressBackgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = scaledStrokeWidth;
    canvas.drawCircle(effectiveAnchor, radius, progressBackgroundPaint);

    // ========== 计算并绘制进度弧 ==========
    final double remainingDuration = _calculateAnimatedRemainingDuration(
      markerGroup,
      animationInfo,
      granularity,
    );

    final Paint progressPaint = Paint()
      ..color = style.backgroundColor.withOpacity(effectiveOpacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = scaledStrokeWidth
      ..strokeCap = StrokeCap.round;

    final double sweepAngle = -2 * math.pi * remainingDuration;
    canvas.drawArc(
      Rect.fromCircle(center: effectiveAnchor, radius: radius),
      -math.pi / 2, // 从顶部开始
      sweepAngle,
      false,
      progressPaint,
    );

    // ========== 绘制中心内容（标签或箭头） ==========
    if (markerGroup.props.markerLabel != null) {
      _drawMarkerLabel(canvas, effectiveAnchor, markerGroup.props.markerLabel!,
          effectiveOpacity, zoom, style);
    } else {
      _drawArrowIcon(canvas, effectiveAnchor, marker,
          Colors.white.withOpacity(effectiveOpacity), zoom, 22);
    }

    // ========== 绘制激活药丸（如果是激活状态） ==========
    if (isActive && _activeMarkerText != null) {
      _drawActivePill(
        canvas,
        effectiveAnchor,
        borderRadius,
        markerColor,
        _activeMarkerText!,
        zoom,
      );
    }

    // 更新点击区域（使用调整后的位置，如果激活则包含药丸区域）
    marker.tapArea =
        Rect.fromCircle(center: effectiveAnchor, radius: borderRadius);
  }

  /// 绘制激活状态的药丸（显示文本信息）。
  ///
  /// [canvas] 画布。
  /// [center] 标记的中心位置。
  /// [iconRadius] 标记的半径（用于确定药丸起始位置）。
  /// [color] 药丸边框颜色（与标记颜色一致）。
  /// [text] 要显示的文本。
  /// [zoom] 缩放级别。
  void _drawActivePill(
    Canvas canvas,
    Offset center,
    double iconRadius,
    Color color,
    String text,
    double zoom,
  ) {
    // 获取动画进度
    final double animationProgress = _getAnimationProgress();
    if (animationProgress <= 0) return;

    // 药丸配置
    const double pillFillColorValue = 0xFF181C25;
    const double textLeftPadding = 8;
    const double textRightPadding = 12;
    final double pillRadius = iconRadius;

    // 文本绘制（透明度随动画变化）
    final TextStyle textStyle = TextStyle(
      color: Colors.white.withOpacity(animationProgress),
      fontSize: 12 * zoom,
      fontWeight: FontWeight.w500,
    );
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      textDirection: ui.TextDirection.ltr,
    )..layout();

    // 计算药丸尺寸（宽度随动画展开）
    final double arcRightX = center.dx + iconRadius;
    final double fullTextWidth =
        (textLeftPadding + textPainter.width + textRightPadding) * zoom;
    // 动画期间药丸宽度从 0 展开到完整宽度
    final double pillWidth = fullTextWidth * animationProgress;
    final double rightEndX = arcRightX + pillWidth;
    final Offset rightEndCenter = Offset(rightEndX - pillRadius, center.dy);

    // 构建药丸路径（从标记右侧开始，向右延伸）
    final Path pillPath = Path()
      // 从标记顶部开始
      ..moveTo(center.dx, center.dy - iconRadius)
      // 标记右半圆（从顶到底）
      ..arcTo(
        Rect.fromCircle(center: center, radius: iconRadius),
        -math.pi / 2,
        math.pi,
        false,
      )
      // 底边延伸到右端
      ..lineTo(rightEndCenter.dx, center.dy + pillRadius)
      // 右端圆角（从底到顶）
      ..arcTo(
        Rect.fromCircle(center: rightEndCenter, radius: pillRadius),
        math.pi / 2,
        -math.pi,
        false,
      )
      // 顶边回到起点
      ..lineTo(center.dx, center.dy - iconRadius)
      ..close();

    // 绘制药丸背景
    canvas.drawPath(
      pillPath,
      Paint()..color = Color(pillFillColorValue.toInt()),
    );

    // 绘制药丸边框（不包含与标记重叠的左侧弧）
    final Path pillBorderPath = Path()
      ..moveTo(center.dx, center.dy + pillRadius)
      ..lineTo(rightEndCenter.dx, center.dy + pillRadius)
      ..arcTo(
        Rect.fromCircle(center: rightEndCenter, radius: pillRadius),
        math.pi / 2,
        -math.pi,
        false,
      )
      ..lineTo(center.dx, center.dy - pillRadius);
    canvas.drawPath(
      pillBorderPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round
        ..color = color,
    );

    // 绘制文本（裁剪到药丸区域内）
    canvas.save();
    canvas.clipPath(pillPath);
    textPainter.paint(
      canvas,
      Offset(arcRightX + textLeftPadding * zoom,
          center.dy - textPainter.height / 2),
    );
    canvas.restore();
  }

  void _drawMarkerLabel(Canvas canvas, Offset anchor, String label,
      double opacity, double zoom, MarkerStyle style) {
    // Base radius used in _drawContractMarker
    final double radius = 12 * zoom;
    final double padding = 5 * zoom; // small padding from circle border
    final double maxWidth = (radius - padding) * 2;
    final double maxHeight = (radius - padding) * 2;

    final TextStyle baseTextStyle = style.markerLabelTextStyle.copyWith(
      fontSize: style.markerLabelTextStyle.fontSize! * zoom,
      color: style.markerLabelTextStyle.color!.withOpacity(opacity),
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

  /// Draws a diagonal arrow icon inside the contract marker.
  ///
  /// @param canvas The canvas on which to paint.
  /// @param center The center position of the arrow.
  /// @param marker The marker object containing direction information.
  /// @param color The color of the arrow.
  /// @param zoom The current zoom level of the chart.
  void _drawArrowIcon(Canvas canvas, Offset center, ChartMarker marker,
      Color color, double zoom, double size) {
    final double dir = marker.direction == MarkerDirection.up ? 1 : -1;
    final double iconSize = size * zoom;

    final Path path = Path();

    canvas
      ..save()
      ..translate(
        center.dx - iconSize / 2,
        center.dy - (iconSize / 2) * dir,
      )
      // Scale from 24x24 original SVG size to desired icon size
      ..scale(
        iconSize / 24,
        (iconSize / 24) * dir,
      );

    // Arrow-up path (will be flipped for down direction)
    path
      ..moveTo(17, 8)
      ..lineTo(17, 15)
      ..cubicTo(17, 15.5625, 16.5312, 16, 16, 16)
      ..cubicTo(15.4375, 16, 15, 15.5625, 15, 15)
      ..lineTo(15, 10.4375)
      ..lineTo(8.6875, 16.7188)
      ..cubicTo(8.3125, 17.125, 7.65625, 17.125, 7.28125, 16.7188)
      ..cubicTo(6.875, 16.3438, 6.875, 15.6875, 7.28125, 15.3125)
      ..lineTo(13.5625, 9)
      ..lineTo(9, 9)
      ..cubicTo(8.4375, 9, 8, 8.5625, 8, 8)
      ..cubicTo(8, 7.46875, 8.4375, 7, 9, 7)
      ..lineTo(16, 7)
      ..cubicTo(16.5312, 7, 17, 7.46875, 17, 8)
      ..close();

    canvas
      ..drawPath(path, Paint()..color = color)
      ..restore();
  }

  /// Renders a tick point marker.
  ///
  /// This private method draws a small circular dot representing a price tick.
  /// Tick points are used to visualize individual price updates in the contract.
  ///
  /// @param canvas The canvas on which to paint.
  /// @param anchor The position on the canvas where the tick point should be rendered.
  /// @param paint The paint object to use for drawing.
  /// @param zoom The current zoom level of the chart.
  void _drawTickPoint(Canvas canvas, Offset anchor, Paint paint, double zoom) {
    canvas.drawCircle(
      anchor,
      1.5 * zoom,
      paint,
    );
  }

  /// Renders an entry point marker.
  ///
  /// This private method draws a circular marker with a distinctive design
  /// representing the entry point of the contract. The entry point marks
  /// the price and time at which the contract started. It consists of an
  /// outer circle with marker direction color and an inner white circle.
  ///
  /// @param canvas The canvas on which to paint.
  /// @param marker The marker object containing direction information.
  /// @param anchor The position on the canvas where the entry point should be rendered.
  /// @param style The style to apply to the marker.
  /// @param zoom The current zoom level of the chart.
  /// @param opacity The opacity to apply to the entry point.
  void _drawSpotPoint(Canvas canvas, ChartMarker marker, Offset anchor,
      MarkerStyle style, ChartTheme theme, double zoom, double opacity) {
    // Draw white filled circle
    final Paint fillPaint = Paint()
      ..color = (marker.direction == MarkerDirection.up
              ? theme.markerStyle.upColorProminent
              : theme.markerStyle.downColorProminent)
          .withValues(alpha: opacity)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(anchor, 2.5 * zoom, fillPaint);
  }

  /// 绘制出场点标记，包含倒计时和胜负状态。
  ///
  /// 显示格式：[日历图标] MM:SS [胜负表情]
  ///
  /// [canvas] 画布。
  /// [marker] 出场点标记。
  /// [anchor] 锚点位置（出场点的坐标）。
  /// [style] 标记样式。
  /// [theme] 图表主题。
  /// [zoom] 缩放级别。
  /// [opacity] 透明度。
  /// [markerGroup] 标记组，包含 currentEpoch、currentQuote 等信息。
  void _drawExitSpotWithCountdown(
    Canvas canvas,
    ChartMarker marker,
    Offset anchor,
    MarkerStyle style,
    ChartTheme theme,
    double zoom,
    double opacity,
    MarkerGroup markerGroup,
  ) {
    // 获取当前时间和结束时间
    final int? currentEpoch = markerGroup.currentEpoch;
    final int endEpoch = marker.epoch;

    // 如果没有当前时间，不绘制倒计时
    if (currentEpoch == null) return;

    // 计算剩余时间（毫秒）
    final int remainingMs = endEpoch - currentEpoch;

    // 如果已经结束，不绘制
    if (remainingMs <= 0) return;

    // 转换为分钟和秒
    final int totalSeconds = (remainingMs / 1000).ceil();
    final int minutes = totalSeconds ~/ 60;
    final int seconds = totalSeconds % 60;
    final String countdownText =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    // 判断当前胜负状态
    final double? currentQuote = markerGroup.currentQuote;
    final MarkerDirection direction = markerGroup.direction;

    // 查找入场价（从 entrySpot 或 contractMarker 获取）
    double? entryPrice;
    for (final ChartMarker m in markerGroup.markers) {
      if (m.markerType == MarkerType.entrySpot ||
          m.markerType == MarkerType.contractMarker ||
          m.markerType == MarkerType.startTimeCollapsed) {
        entryPrice = m.quote;
        break;
      }
    }

    // 判断胜负状态
    bool? isWinning;
    if (currentQuote != null && entryPrice != null) {
      if (direction == MarkerDirection.up) {
        // 看涨：当前价 > 入场价 则盈利
        isWinning = currentQuote > entryPrice;
      } else {
        // 看跌：当前价 < 入场价 则盈利
        isWinning = currentQuote < entryPrice;
      }
    }

    // 获取标记颜色
    final Color markerColor = direction == MarkerDirection.up
        ? theme.markerStyle.upColorProminent
        : theme.markerStyle.downColorProminent;

    // ========== 绘制配置 ==========
    const double fontSize = 12;
    const double iconSize = 12; // 旗帜图标尺寸
    const double emojiSize = 12; // 表情尺寸
    const double spacing = 4; // 元素之间的间距
    const double leftPadding = 6; // 左侧距离锚点的间距

    // 用于绘制图片的 Paint（支持透明度）
    final Paint imagePaint = Paint()
      ..colorFilter = ColorFilter.mode(
        Colors.white.withValues(alpha: opacity),
        BlendMode.modulate,
      );

    double currentX = anchor.dx + leftPadding;

    // ========== 绘制旗帜图标和倒计时（可选） ==========
    if (showExitCountdown) {
      final ui.Image? exitFlagImage = direction == MarkerDirection.up
          ? _exitFlagHighImage
          : _exitFlagLowImage;
      // 绘制旗帜图标
      if (exitFlagImage != null) {
        final double iconY = anchor.dy - iconSize / 2;
        final Rect srcRect = Rect.fromLTWH(
          0,
          0,
          exitFlagImage.width.toDouble(),
          exitFlagImage.height.toDouble(),
        );
        final Rect dstRect = Rect.fromLTWH(currentX, iconY, iconSize, iconSize);
        canvas.drawImageRect(exitFlagImage, srcRect, dstRect, imagePaint);
        currentX += iconSize + spacing;
      }

      // 绘制倒计时文本
      final TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: countdownText,
          style: TextStyle(
            color: markerColor.withValues(alpha: opacity),
            fontSize: fontSize,
            fontWeight: FontWeight.w500,
            fontFamily: ClashDisplayFont.fontFamily,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(currentX, anchor.dy - textPainter.height / 2),
      );
      currentX += textPainter.width + spacing;
    }

    // ========== 绘制胜负表情 ==========
    if (isWinning != null) {
      final ui.Image? emojiImage = isWinning ? _winEmojiImage : _lossEmojiImage;

      if (emojiImage != null) {
        final double emojiY = anchor.dy - emojiSize / 2;
        final Rect srcRect = Rect.fromLTWH(
          0,
          0,
          emojiImage.width.toDouble(),
          emojiImage.height.toDouble(),
        );
        final Rect dstRect =
            Rect.fromLTWH(currentX, emojiY, emojiSize, emojiSize);
        canvas.drawImageRect(emojiImage, srcRect, dstRect, imagePaint);
      }
    }
  }

  /// Renders the starting point of a tick contract.
  ///
  /// This private method draws a location pin marker at the starting point of
  /// the contract, with an optional text label. The marker's opacity is adjusted
  /// based on its position relative to other markers.
  ///
  /// @param canvas The canvas on which to paint.
  /// @param size The size of the drawing area.
  /// @param theme The chart's theme, which provides colors and styles.
  /// @param marker The marker to render.
  /// @param anchor The position on the canvas where the marker should be rendered.
  /// @param style The style to apply to the marker.
  /// @param zoom The current zoom level of the chart.
  /// @param opacity The opacity to apply to the marker.
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

  /// 在 [anchor] 位置画一个小圆点。
  ///
  /// 用于 startTimeCollapsed 和 exitTimeCollapsed，作为合约时间线两端的端点标记。
  /// 画： ●━━━━━━━━━━━━━━━━━━━━━● 中的 2 端的圆点
  void _drawCollapsedTimeLine(
    Canvas canvas,
    ChartMarker marker,
    Offset anchor,
    MarkerStyle style,
    ChartTheme theme,
    double zoom,
    double opacity,
  ) {
    final double radius = 2.5 * zoom; // 圆点半径
    final Color color = marker.direction == MarkerDirection.up
        ? theme.markerStyle.upColorProminent
        : theme.markerStyle.downColorProminent;
    final Paint paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(anchor, radius, paint);
  }


  /// 绘制合约进度线（从开始到结束的水平线）。
  ///
  /// 这条线连接 startTimeCollapsed 和 exitTimeCollapsed 两个端点。
  ///
  /// @param canvas 画布
  /// @param size 绘制区域大小
  /// @param startOffset 开始位置（startTimeCollapsed）
  /// @param exitOffset 结束位置（exitTimeCollapsed），可能为 null
  /// @param lineColor 线条颜色
  /// @param markerGroup marker 组，包含当前时间等信息
  /// @param epochToX 将 epoch 转换为 X 坐标的函数
  /// @param granularity K 线的时间间隔（毫秒），用于计算进度线的精确位置
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
      // 有当前时间信息：绘制类似进度条效果的水平线
      // 1. 先从 markers 中获取开始和结束的 epoch
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
        // 2. 计算当前时间的精确 X 坐标
        // epochToX 返回的是 K 线柱子的中心位置，在大周期 K 线下需要进行插值
        final double currentX = _calculateInterpolatedX(
          currentEpoch,
          granularity,
          epochToX,
        ).clamp(startOffset.dx, exitOffset.dx);

        // 3. 先画背景线（50% 白色，从开始到结束）
        final Paint backgroundPaint = Paint()
          ..color = Colors.white.withValues(alpha: 0.5)
          ..strokeWidth = strokeWidth;
        canvas.drawLine(startOffset, exitOffset, backgroundPaint);

        // 4. 再画进度线（lineColor，从开始到当前时间）
        final Offset currentOffset = Offset(currentX, startOffset.dy);
        canvas.drawLine(startOffset, currentOffset, solidLinePaint);
      } else {
        // epoch 数据不完整，退回到普通绘制
        canvas.drawLine(startOffset, exitOffset, solidLinePaint);
      }
    } else {
      // 没有当前时间信息：画从开始到结束的纯色线
      if (exitOffset != null) {
        // 有结束点：画从开始到结束的实线
        canvas.drawLine(startOffset, exitOffset, solidLinePaint);
      } else {
        // 没有结束点：画从开始到画布右边缘的实线
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
  ///
  /// @param epoch 当前时间戳（毫秒）
  /// @param granularity K 线的时间间隔（毫秒）
  /// @param epochToX 将 epoch 转换为 X 坐标的函数
  double _calculateInterpolatedX(
    int epoch,
    int granularity,
    EpochToX epochToX,
  ) {
    // 计算当前 K 线的起始时间（向下取整到 granularity 的整数倍）
    final int candleStartEpoch = (epoch ~/ granularity) * granularity;
    // 下一个 K 线的起始时间
    final int nextCandleEpoch = candleStartEpoch + granularity;

    // 获取当前 K 线和下一个 K 线的中心 X 坐标
    final double currentCandleX = epochToX(candleStartEpoch);
    final double nextCandleX = epochToX(nextCandleEpoch);

    // 计算当前时间在 K 线周期内的进度比例 (0.0 ~ 1.0)
    final double progress = (epoch - candleStartEpoch) / granularity;

    // 线性插值计算精确的 X 坐标
    return currentCandleX + (nextCandleX - currentCandleX) * progress;
  }
}

/// 用于跟踪已绘制的合约标记位置信息的内部数据类。
///
/// 使用 `Rect bounds` 而非 `center + radius`，以支持任意形状（圆形、矩形等）的边界检测。
class _DrawnContractMarker {
  _DrawnContractMarker({
    required this.bounds,
    required this.markerId,
    required this.originalY,
    required this.entryEpoch,
  });

  /// 标记的边界矩形（包含 left、top、right、bottom）。
  /// 支持任意形状的标记，不局限于圆形。
  final Rect bounds;

  /// 标记的唯一标识符。
  final String? markerId;

  /// 标记的原始 Y 坐标（用于判断是否是同一价格）。
  final double originalY;

  /// 入场时间戳（用于排序，时间早的在左边）。
  final int entryEpoch;

  /// 标记的宽度。
  double get width => bounds.width;

  /// 标记的高度。
  double get height => bounds.height;

  /// 标记的中心位置。
  Offset get center => bounds.center;
}
