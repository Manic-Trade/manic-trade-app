import 'dart:ui';

/// 已绘制的合约标记位置信息。
///
/// 用于跟踪标记的边界、ID、原始 Y 坐标和入场时间，
/// 以便进行重叠检测和位置计算。
class DrawnContractMarker {
  DrawnContractMarker({
    required this.bounds,
    required this.markerId,
    required this.originalY,
    required this.entryEpoch,
  });

  /// 标记的边界矩形。
  final Rect bounds;

  /// 标记的唯一标识符。
  final String? markerId;

  /// 标记的原始 Y 坐标。
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

/// 负责处理标记之间的重叠检测与位置调度。
///
/// 管理两组数据：合约标记（contractMarker）和出场表情（exit emoji），
/// 分别计算它们的偏移后位置，避免视觉重叠。
///
/// 合约标记从右往左排列（index 0 最靠近 startTimeCollapsed）；
/// 出场表情从左往右排列（index 0 最靠近 exitSpot 锚点）。
class MarkerOverlapResolver {
  // ==================== 合约标记数据 ====================

  /// 当前帧所有 contractMarker 的位置信息（预注册阶段收集）。
  final List<DrawnContractMarker> _currentFrameContractMarkers =
      <DrawnContractMarker>[];

  /// 存储已计算好的偏移后位置。
  /// Key: markerId, Value: 偏移后的锚点位置。
  final Map<String, Offset> _markerAdjustedPositions = <String, Offset>{};

  /// 存储每个标记的位置索引。
  /// Key: markerId, Value: positionIndex（0 表示最靠近 startTimeCollapsed）。
  final Map<String, int> _markerPositionIndices = <String, int>{};

  /// 标记偏移位置是否已计算完成。
  bool _positionsCalculated = false;

  // ==================== Exit emoji 数据 ====================

  /// 当前帧的所有 exit emoji 标记信息（用于重叠检测）。
  final List<DrawnContractMarker> _currentFrameExitEmojis =
      <DrawnContractMarker>[];

  /// 存储每个 exit emoji 的偏移后位置。
  /// Key: markerId, Value: emoji 背景中心的调整后坐标。
  final Map<String, Offset> _emojiAdjustedPositions = <String, Offset>{};

  /// 存储每个 exit emoji 的位置索引。
  /// Key: markerId, Value: positionIndex（0 表示最靠近 exitSpot 锚点）。
  final Map<String, int> _emojiPositionIndices = <String, int>{};

  /// exit emoji 偏移位置是否已计算完成。
  bool _emojiPositionsCalculated = false;

  // ==================== 公共方法 ====================

  /// 每帧开始时调用，清空上一帧的状态。
  void onFrameStart() {
    _currentFrameContractMarkers.clear();
    _markerAdjustedPositions.clear();
    _markerPositionIndices.clear();
    _positionsCalculated = false;

    _currentFrameExitEmojis.clear();
    _emojiAdjustedPositions.clear();
    _emojiPositionIndices.clear();
    _emojiPositionsCalculated = false;
  }

  /// 注册已绘制的合约标记位置。
  ///
  /// 如果已存在相同 ID 的记录（例如 ActiveMarkerGroup 和普通 MarkerGroup），
  /// 则不重复注册，避免位置计算出错。
  void registerContractMarker(
    Rect bounds,
    String? markerId,
    double originalY,
    int entryEpoch,
  ) {
    // 检查是否已存在相同 ID 的记录，避免重复注册
    if (markerId != null) {
      final bool alreadyExists = _currentFrameContractMarkers
          .any((marker) => marker.markerId == markerId);
      if (alreadyExists) {
        return;
      }
    }

    _currentFrameContractMarkers.add(DrawnContractMarker(
      bounds: bounds,
      markerId: markerId,
      originalY: originalY,
      entryEpoch: entryEpoch,
    ));
  }

  /// 注册 exit emoji 的位置信息。
  void registerExitEmoji(
    Rect bounds,
    String? markerId,
    double originalY,
    int entryEpoch,
  ) {
    // 避免重复注册
    if (markerId != null) {
      final bool alreadyExists =
          _currentFrameExitEmojis.any((marker) => marker.markerId == markerId);
      if (alreadyExists) return;
    }

    _currentFrameExitEmojis.add(DrawnContractMarker(
      bounds: bounds,
      markerId: markerId,
      originalY: originalY,
      entryEpoch: entryEpoch,
    ));
  }

  /// 统一计算所有合约标记的偏移后位置。
  ///
  /// 此方法在所有 MarkerGroup 预注册完成后、第一次绑制前调用。
  /// 对于重叠的标记组，使用统一的基准 X 位置（最大的原始 X），
  /// 确保所有重叠标记紧挨着排列，没有大间隙。
  void calculateAllContractMarkerPositions() {
    if (_positionsCalculated) return;

    const double markerSpacing = 4;

    // 第一步：为每个标记找到其重叠组中最大的原始 X 位置（作为基准）
    final Map<String, double> baseXPositions = {};

    for (final DrawnContractMarker marker in _currentFrameContractMarkers) {
      if (marker.markerId == null) continue;

      double maxX = marker.bounds.center.dx;

      for (final DrawnContractMarker other in _currentFrameContractMarkers) {
        if (other.markerId == marker.markerId) continue;
        if (!_wouldOverlapY(marker.bounds, other.bounds,
            spacing: markerSpacing)) {
          continue;
        }
        if (other.bounds.center.dx > maxX) {
          maxX = other.bounds.center.dx;
        }
      }

      baseXPositions[marker.markerId!] = maxX;
    }

    // 第二步：使用统一的基准 X 位置计算偏移后的位置
    for (final DrawnContractMarker marker in _currentFrameContractMarkers) {
      if (marker.markerId == null) continue;

      final int positionIndex = _calculatePositionIndex(
        marker.bounds,
        marker.entryEpoch,
        marker.markerId,
        spacing: markerSpacing,
      );

      _markerPositionIndices[marker.markerId!] = positionIndex;

      final double baseX = baseXPositions[marker.markerId!]!;
      final double markerWidthWithSpacing = marker.bounds.width + markerSpacing;
      final double xOffset = positionIndex * markerWidthWithSpacing;

      final Offset adjustedPosition = Offset(
        baseX - xOffset,
        marker.originalY,
      );

      _markerAdjustedPositions[marker.markerId!] = adjustedPosition;
    }

    _positionsCalculated = true;
  }

  /// 统一计算所有 exit emoji 的偏移后位置。
  ///
  /// 按自然 X 位置从左到右排列，每个 emoji 保持在自己锚点右侧。
  /// 当发生重叠时，只会将 emoji 向右推，绝不会往左拉。
  void calculateAllExitEmojiPositions() {
    if (_emojiPositionsCalculated) return;
    if (_currentFrameExitEmojis.isEmpty) {
      _emojiPositionsCalculated = true;
      return;
    }

    const double emojiSpacing = 4;

    // 按自然 X 位置排序（X 相同时按 entryEpoch 排序，确保稳定）
    final List<DrawnContractMarker> sorted =
        List<DrawnContractMarker>.of(_currentFrameExitEmojis)
          ..sort((DrawnContractMarker a, DrawnContractMarker b) {
            final int xCmp = a.bounds.center.dx.compareTo(b.bounds.center.dx);
            if (xCmp != 0) return xCmp;
            return a.entryEpoch.compareTo(b.entryEpoch);
          });

    // 已放置的 emoji 边界列表
    final List<Rect> placedBounds = <Rect>[];

    for (final DrawnContractMarker emoji in sorted) {
      if (emoji.markerId == null) continue;

      Rect currentBounds = emoji.bounds;
      int positionIndex = 0;

      // 逐个检查与已放置的 emoji 是否重叠，重叠则右移
      bool shifted = true;
      while (shifted) {
        shifted = false;
        for (final Rect placed in placedBounds) {
          if (_wouldOverlap2D(currentBounds, placed, spacing: emojiSpacing)) {
            final double newCenterX =
                placed.right + emojiSpacing + currentBounds.width / 2;
            if (newCenterX > currentBounds.center.dx) {
              currentBounds = Rect.fromCenter(
                center: Offset(newCenterX, currentBounds.center.dy),
                width: currentBounds.width,
                height: currentBounds.height,
              );
              positionIndex++;
              shifted = true;
              break;
            }
          }
        }
      }

      placedBounds.add(currentBounds);
      _emojiPositionIndices[emoji.markerId!] = positionIndex;
      _emojiAdjustedPositions[emoji.markerId!] = currentBounds.center;
    }

    _emojiPositionsCalculated = true;
  }

  /// 获取合约标记的偏移后位置。
  Offset getAdjustedPosition(String? markerId, Offset originalAnchor) {
    if (markerId == null) return originalAnchor;
    return _markerAdjustedPositions[markerId] ?? originalAnchor;
  }

  /// 获取 exit emoji 的偏移后位置。
  Offset? getEmojiAdjustedPosition(String? markerId) {
    if (markerId == null) return null;
    return _emojiAdjustedPositions[markerId];
  }

  /// 获取 exit emoji 的位置索引。
  int getEmojiPositionIndex(String? markerId) {
    if (markerId == null) return 0;
    return _emojiPositionIndices[markerId] ?? 0;
  }

  // ==================== 私有方法 ====================

  /// 判断两个标记是否会在 Y 方向重叠。
  ///
  /// 主要检查 Y 方向：因为所有 contractMarker 最终都会被放置在各自的
  /// startTimeCollapsed 附近，视觉上它们都在同一个区域内。
  bool _wouldOverlapY(
    Rect bounds1,
    Rect bounds2, {
    double spacing = 4,
  }) {
    final double yDistance = (bounds1.center.dy - bounds2.center.dy).abs();
    final double minYDistance = (bounds1.height + bounds2.height) / 2 + spacing;
    return yDistance < minYDistance;
  }

  /// 检查两个矩形是否在 2D 空间中重叠（X 和 Y 方向都检查）。
  ///
  /// 用于 exit emoji 的重叠检测。
  bool _wouldOverlap2D(
    Rect bounds1,
    Rect bounds2, {
    double spacing = 4,
  }) {
    final Rect expanded1 = bounds1.inflate(spacing / 2);
    final Rect expanded2 = bounds2.inflate(spacing / 2);
    return expanded1.overlaps(expanded2);
  }

  /// 计算当前标记在重叠组中的位置索引。
  ///
  /// 基于入场时间排序：入场时间早的在左边（索引大，偏移多）。
  /// 当入场时间相同时，使用 markerId 字符串比较来决定顺序。
  int _calculatePositionIndex(
    Rect currentBounds,
    int entryEpoch,
    String? markerId, {
    double spacing = 4,
  }) {
    int positionIndex = 0;

    for (final DrawnContractMarker drawnMarker in _currentFrameContractMarkers) {
      if (drawnMarker.markerId == markerId && markerId != null) {
        continue;
      }

      if (!_wouldOverlapY(currentBounds, drawnMarker.bounds,
          spacing: spacing)) {
        continue;
      }

      if (drawnMarker.entryEpoch > entryEpoch) {
        positionIndex++;
      } else if (drawnMarker.entryEpoch == entryEpoch) {
        if (markerId != null &&
            drawnMarker.markerId != null &&
            drawnMarker.markerId!.compareTo(markerId) > 0) {
          positionIndex++;
        }
      }
    }

    return positionIndex;
  }
}
