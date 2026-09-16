import 'dart:async';

import 'package:finality/features/positions/live_position/model/live_position_item_data.dart';
import 'package:finality/domain/options/entities/opened_position.dart';
import 'package:finality/features/highlow/model/settled_position_event.dart';
import 'package:finality/features/positions/vm/place_order_vm.dart';
import 'package:flutter/foundation.dart';
import 'package:store_scope/store_scope.dart';

final livePositionBarVMProvider = ViewModelProvider<LivePositionBarVM>((ref) {
  return LivePositionBarVM();
});

/// Live Position Bar 的 ViewModel
/// 负责管理 Processing 状态和数据转换
class LivePositionBarVM extends ViewModel {
  // ==================== Mock 数据开关 ====================
  // 设置为 true 使用 mock 数据调试 UI，上线前删除
  static const bool _useMockData = false;
  // ========================================================

  /// Processing 状态的订单列表
  /// key: processingId, value: LivePositionItemData
  final Map<String, ProcessingItemData> _processingPositions = {};

  /// Processing 订单的通知器
  final ValueNotifier<List<ProcessingItemData>> processingPositions =
      ValueNotifier([]);

  /// Settled 状态显示时长（毫秒）
  static const int settledDisplayDurationMs = 3000; // 4秒

  /// 已安排移除的 Settled 订单 ID 集合（防止重复安排）
  final Set<String> _scheduledSettledRemovals = {};

  /// submit 成功后等待 WS / 外部状态确认开仓的超时时长。
  /// 超时仍未被自然清理则触发 REST 兜底刷新。
  static const Duration confirmationTimeout = Duration(seconds: 12);

  /// processingId -> 兜底确认 Timer
  final Map<String, Timer> _confirmationTimers = {};

  /// 添加 Processing 状态的订单
  /// 返回 processingId，用于后续移除
  String addProcessingPosition({
    required bool isHigh,
    required String amount,
    required String tradingPairBaseAsset,
    int? endTime,
  }) {
    final processingId = generatePositionId();
    final nowSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    final itemData = ProcessingItemData(
      id: processingId,
      baseAsset: tradingPairBaseAsset,
      isHigh: isHigh,
      amount: amount,
      startTime: nowSeconds,
    );

    _processingPositions[processingId] = itemData;
    _notifyProcessingPositions();
    return processingId;
  }

  /// 移除 Processing 状态的订单
  /// 当收到开仓确认或超时时调用
  void removeProcessingPosition(String processingId) {
    _confirmationTimers.remove(processingId)?.cancel();
    if (_processingPositions.remove(processingId) != null) {
      _notifyProcessingPositions();
    }
  }

  /// 清空所有 Processing 状态
  void clearAllProcessingPositions() {
    if (_processingPositions.isNotEmpty) {
      for (final timer in _confirmationTimers.values) {
        timer.cancel();
      }
      _confirmationTimers.clear();
      _processingPositions.clear();
      _notifyProcessingPositions();
    }
  }

  /// submit 成功后调用：在 [confirmationTimeout] 内若该 processingId 仍未被清理，
  /// 触发 [onTimeout]（页面侧负责拉一次 REST 兜底）。
  ///
  /// [onTimeout] 返回 `true` 表示 REST 已确认该订单存在（无需弹错），
  /// 返回 `false` 或抛异常则视为后端无该订单，调用 [onForceRemove] 后强制移除 pending。
  ///
  /// 注意：不能用 `_processingPositions.containsKey` 判断 REST 是否成功——
  /// 那个 map 的清理依赖 Widget rebuild（在 `buildLivePositionList` 里），
  /// 而 rebuild 是下一帧才发生，比 await fetch 慢一拍。
  void armConfirmationTimeout(
    String processingId, {
    required Future<bool> Function() onTimeout,
    VoidCallback? onForceRemove,
  }) {
    _confirmationTimers.remove(processingId)?.cancel();
    _confirmationTimers[processingId] = Timer(confirmationTimeout, () async {
      _confirmationTimers.remove(processingId);
      // 已经被 WS / 状态联动清掉就不用兜底
      if (!_processingPositions.containsKey(processingId)) return;
      bool confirmed = false;
      try {
        confirmed = await onTimeout();
      } catch (_) {
        // REST 失败视为未确认
      }
      if (confirmed) {
        // REST 拉到了，pending 会随下一帧 rebuild 被自动替换，主动移除让状态更早一致
        removeProcessingPosition(processingId);
        return;
      }
      if (_processingPositions.containsKey(processingId)) {
        onForceRemove?.call();
        removeProcessingPosition(processingId);
      }
    });
  }

  void _notifyProcessingPositions() {
    processingPositions.value = _processingPositions.values.toList();
  }

  /// 安排 Settled 订单的自动移除
  /// 在指定时间后触发 processingPositions 通知，让 UI 重新构建
  void _scheduleSettledRemoval(String positionId, int delayMs) {
    if (_scheduledSettledRemovals.contains(positionId)) return;
    _scheduledSettledRemovals.add(positionId);

    Future.delayed(Duration(milliseconds: delayMs), () {
      _scheduledSettledRemovals.remove(positionId);
      // 触发 UI 刷新（通过通知 processingPositions 变化）
      _notifyProcessingPositions();
    });
  }

  /// 构建完整的 Live Position 列表
  /// 合并 Processing、Active、Settled 三种状态的数据
  /// 按当前选中的交易对过滤
  /// 相同 ID 时优先级：Settled > Active > Processing
  List<LivePositionItemData> buildLivePositionList({
    required List<OpenedPosition> openedPositions,
    required List<SettledPositionEvent> settledEvents,
    required String currentAsset,
  }) {
    // Mock 数据模式
    if (_useMockData) {
      return _generateMockData(currentAsset);
    }

    final List<LivePositionItemData> result = [];
    final Set<String> addedIds = {};
    final currentAssetUpper = currentAsset.toUpperCase();
    final nowMs = DateTime.now().millisecondsSinceEpoch;

    // 1. 优先添加 Settled 状态的订单（过滤当前交易对，超过显示时长不显示）
    for (final event in settledEvents) {
      if (event.position.tradingPair.baseAsset.toUpperCase() ==
          currentAssetUpper) {
        final elapsedMs = nowMs - event.notificationtimestamp;
        if (elapsedMs < settledDisplayDurationMs) {
          result.add(SettledItemData.fromSettledEvent(event));
          addedIds.add(event.position.id);
          removeProcessingPosition(event.position.id);
          // 安排自动刷新（触发 UI 移除）
          _scheduleSettledRemoval(
              event.position.id, settledDisplayDurationMs - elapsedMs);
        }
      }
    }

    // 2. 添加 Active 状态的订单（过滤当前交易对，跳过已 Settled 的）
    for (final position in openedPositions) {
      if (position.tradingPair.baseAsset.toUpperCase() == currentAssetUpper) {
        if (!addedIds.contains(position.id)) {
          result.add(ActiveItemData.fromOpenedPosition(position));
          addedIds.add(position.id);
          removeProcessingPosition(position.id);
        }
      }
    }

    // 3. 添加 Processing 状态的订单（过滤当前交易对，跳过已存在的）
    for (final item in _processingPositions.values) {
      if (item.baseAsset.toUpperCase() == currentAssetUpper) {
        if (!addedIds.contains(item.id)) {
          result.add(item);
          addedIds.add(item.id);
        }
      }
    }

    // 4. 按下单时间排序（最新的在前）
    result.sort((a, b) => b.startTime.compareTo(a.startTime));

    return result;
  }

  /// 生成 Mock 数据，用于调试 UI
  /// 包含所有状态：Processing、Active、Settled (Win/Lose)
  List<LivePositionItemData> _generateMockData(String currentAsset) {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    return [
      // Processing 状态 - 看涨
      ProcessingItemData(
        id: 'mock_processing_1',
        baseAsset: currentAsset,
        isHigh: true,
        amount: '10.00',
        startTime: now,
      ),

      // Active 状态 - 看涨，30秒后结束
      ActiveItemData(
        id: 'mock_active_higher_1',
        isHigh: true,
        entryPrice: 95393.08,
        entryPriceDisplay: '95393.08',
        amount: '5.00',
        startTime: now,
        endTime: now + 30,
        baseAsset: currentAsset,
        wonProfit: '+\$133.08',
        lostLoss: '\$0.00',
      ),

      // Active 状态 - 看跌，5秒后结束
      ActiveItemData(
        id: 'mock_active_lower_1',
        isHigh: false,
        entryPrice: 95393.08,
        entryPriceDisplay: '95393.08',
        amount: '8.00',
        startTime: now,
        endTime: now + 5,
        baseAsset: currentAsset,
        wonProfit: '+\$5.00',
        lostLoss: '\$0.00',
      ),

      // Active 状态 - 看涨，90秒后结束（超过1分钟）
      ActiveItemData(
        id: 'mock_active_higher_2',
        isHigh: true,
        entryPrice: 95500.00,
        entryPriceDisplay: '95500.00',
        amount: '15.00',
        startTime: now,
        endTime: now + 90,
        baseAsset: currentAsset,
        wonProfit: '+\$133.08',
        lostLoss: '\$0.00',
      ),

      // Settled 状态 - 盈利
      SettledItemData(
        id: 'mock_settled_win_1',
        isHigh: true,
        isWin: true,
        pnlText: '+\$133.08',
        baseAsset: currentAsset,
        startTime: now - 60,
      ),

      // Settled 状态 - 亏损
      SettledItemData(
        id: 'mock_settled_lose_1',
        isHigh: false,
        isWin: false,
        pnlText: '-\$5.00',
        baseAsset: currentAsset,
        startTime: now - 120,
      ),
    ];
  }

  @override
  void dispose() {
    for (final timer in _confirmationTimers.values) {
      timer.cancel();
    }
    _confirmationTimers.clear();
    processingPositions.dispose();
    super.dispose();
  }
}
