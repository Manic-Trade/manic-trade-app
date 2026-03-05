import 'dart:collection';

import 'package:deriv_chart/deriv_chart.dart';
import 'package:finality/domain/options/entities/opened_position.dart';
import 'package:finality/features/highlow/chart/positions/custom_tick_marker_icon_painter.dart';
import 'package:finality/features/highlow/model/settled_position_event.dart';
import 'package:flutter/foundation.dart';

/// 持仓标记构建器
/// 负责将持仓数据转换为图表上的标记
class PositionMarkerBuilder {
  PositionMarkerBuilder({
    required CustomTickMarkerIconPainter tickMarkerIconPainter,
    required this.onMarkerTap,
    required this.onTapOutside,
  }) : _tickMarkerIconPainter = tickMarkerIconPainter;

  final CustomTickMarkerIconPainter _tickMarkerIconPainter;

  /// 点击标记时的回调
  final void Function({
    required OpenedPosition position,
    required String markerId,
    required String amountText,
  }) onMarkerTap;

  /// 点击标记外部区域时的回调
  final VoidCallback onTapOutside;

  // 持仓标记在持仓时间结束后最多再保留 10 秒显示时间
  static const int _markerDisplayDelayMs = 10000; // 10秒
  // 盈亏标签显示时间
  static const int _pnlLabelLifetimeMs = 3000; // 4秒

  /// 根据持仓列表构建标记组序列
  /// Rise/Fall 模式会显示：开始时间、入场价格、结束时间、盈亏信息
  MarkerGroupSeries? buildMarkerSeries({
    required List<OpenedPosition> openedPositions,
    required List<SettledPositionEvent> displaySettledEvents,
    required String currentAsset,
    required List<Candle> candles,
  }) {
    if (openedPositions.isEmpty && displaySettledEvents.isEmpty) {
      // 没有持仓时清除激活状态
      _tickMarkerIconPainter.clearActiveMarker();
      return null;
    }

    // 根据当前选中的资产过滤持仓
    final filteredPositions = openedPositions
        .where((p) =>
            p.tradingPair.baseAsset.toUpperCase() == currentAsset.toUpperCase())
        .toList();
    final settledEvents = displaySettledEvents
        .where((e) =>
            e.position.tradingPair.baseAsset.toUpperCase() ==
            currentAsset.toUpperCase())
        .toList();

    if (filteredPositions.isEmpty) {
      // 当前资产没有持仓时清除激活状态
      _tickMarkerIconPainter.clearActiveMarker();
    }
    if (filteredPositions.isEmpty && settledEvents.isEmpty) {
      return null;
    }

    // 使用 lastCandle.currentEpoch 作为时间源，确保进度线和时间线对齐
    final int currentEpoch = candles.last.currentEpoch;

    final List<MarkerGroup> markerGroups = _convertPositionsToMarkerGroups(
        filteredPositions, settledEvents, currentEpoch, candles.last.close);

    if (markerGroups.isEmpty) {
      return null;
    }

    // 不再使用库的 activeMarkerGroup，激活状态由 _tickMarkerIconPainter 自己管理
    return MarkerGroupSeries(
      SplayTreeSet<Marker>(),
      markerGroupIconPainter: _tickMarkerIconPainter,
      markerGroupList: markerGroups,
      // 点击标记外部区域时清除激活状态
      onTapOutside: () {
        if (_tickMarkerIconPainter.hasActiveMarker) {
          onTapOutside();
        }
      },
    );
  }

  /// 将持仓列表转换为 MarkerGroup 列表
  List<MarkerGroup> _convertPositionsToMarkerGroups(
    List<OpenedPosition> positions,
    List<SettledPositionEvent> settledEvents,
    int currentEpoch,
    double currentQuote,
  ) {
    return [
      ...positions.map((position) =>
          _buildPositionMarkerGroup(position, currentEpoch, currentQuote)),
      ...settledEvents
          .where((e) => _isSettledEventVisible(e, currentEpoch))
          .map((e) => _buildSettledMarkerGroup(e, currentEpoch)),
    ];
  }

  /// 构建单个持仓的 MarkerGroup
  MarkerGroup _buildPositionMarkerGroup(
      OpenedPosition position, int currentEpoch, double currentQuote) {
    // 时间转换：API 返回的是秒级时间戳，需要转换为毫秒
    final startEpoch = position.startTime * 1000;
    final endEpoch = position.endTime * 1000;
    final entryPrice = position.entryPrice;
    // 确定方向：isHigh 为 true 时是 Rise(上涨)，否则是 Fall(下跌)
    final direction =
        position.isHigh ? MarkerDirection.up : MarkerDirection.down;
    final markerId = 'position_${position.id}';

    final chartMarkers = <ChartMarker>[];
    // Show the standard markers until a short time after end
    final showStandardMarkers = currentEpoch < endEpoch + _markerDisplayDelayMs;

    if (showStandardMarkers) {
      //标记的绘制顺序和 Stack 的绘制顺序一样，下标越小越先绘制
      chartMarkers.addAll([
        // 开始时间标记（折叠状态）
        ChartMarker(
          epoch: startEpoch,
          quote: entryPrice,
          direction: direction,
          markerType: MarkerType.startTimeCollapsed,
        ),

        // 结束时间标记（折叠状态）
        ChartMarker(
          epoch: endEpoch,
          quote: entryPrice,
          direction: direction,
          markerType: MarkerType.exitTimeCollapsed,
        ),

        // 出场点标记
        ChartMarker(
          epoch: endEpoch,
          quote: entryPrice,
          direction: direction,
          markerType: MarkerType.exitSpot,
        ),

        // 合约标记（用于显示合约区域，可点击）
        ChartMarker(
          epoch: startEpoch,
          quote: entryPrice,
          direction: direction,
          markerType: MarkerType.contractMarker,
          onTap: () => onMarkerTap(
            position: position,
            markerId: markerId,
            amountText: position.amountDisplay,
          ),
        ),
      ]);
    }

    // 激活的标记 zIndex 设为 1，确保绘制在其他标记上方
    final bool isActive = _tickMarkerIconPainter.isActiveMarker(markerId);

    return MarkerGroup(
      chartMarkers,
      type: 'tick',
      direction: direction,
      id: markerId,
      currentEpoch: currentEpoch,
      currentQuote: currentQuote,
      zIndex: isActive ? 1 : 0,
    );
  }

  /// 判断已结算事件是否应该显示
  bool _isSettledEventVisible(
      SettledPositionEvent settledEvent, int currentEpoch) {
    final notificationTimestamp = settledEvent.notificationtimestamp;
    final maxEpoch = notificationTimestamp + _pnlLabelLifetimeMs;
    //TODO: 严格来说这里需要使用服务器时间
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    return currentTime >= notificationTimestamp && currentTime < maxEpoch;
  }

  /// 构建已结算事件的 MarkerGroup
  MarkerGroup _buildSettledMarkerGroup(
      SettledPositionEvent settledEvent, int currentEpoch) {
    final direction =
        settledEvent.event.isHigh ? MarkerDirection.up : MarkerDirection.down;
    final spotPrice = settledEvent.event.spotPrice;
    final startTimeEpoch = settledEvent.position.startTime * 1000;
    final endTimeEpoch = settledEvent.position.endTime * 1000;
    final midEpoch = ((startTimeEpoch + endTimeEpoch) / 2).toInt();

    final chartMarkers = [
      ChartMarker(
        epoch: midEpoch,
        quote: spotPrice,
        direction: direction,
        markerType: MarkerType.profitAndLossLabel,
      ),
    ];

    return MarkerGroup(
      chartMarkers,
      type: 'tick',
      direction: direction,
      id: 'settled_event_${settledEvent.position.id}',
      currentEpoch: currentEpoch,
      props: MarkerProps(isProfit: settledEvent.event.isWin),
      profitAndLossText: _buildPnLText(settledEvent),
    );
  }

  /// 构建盈亏文本
  String _buildPnLText(SettledPositionEvent settledEvent) {
    if (settledEvent.event.isWin) {
      return '+\$${settledEvent.position.winPayoutDisplay}';
    } else {
      return '+\$0.00';
    }
  }
}
