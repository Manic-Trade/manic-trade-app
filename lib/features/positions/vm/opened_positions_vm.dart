import 'dart:async';

import 'package:finality/common/toast/app_toast_manager.dart';
import 'package:finality/common/utils/haptic_feedback_utils.dart';
import 'package:finality/core/logger.dart';
import 'package:finality/core/state/ui_state.dart';
import 'package:finality/data/network/manic_trade_data_source.dart';
import 'package:finality/data/network/model/manic/pending_position_item_response.dart';
import 'package:finality/data/network/model/manic/position_history_item.dart';
import 'package:finality/data/realtime/realtime_market_account_transport.dart';
import 'package:finality/data/socket/game_status_socket_client.dart';
import 'package:finality/data/socket/manic/manic_price_data.dart';
import 'package:finality/data/socket/shared_price_stream_manager.dart';
import 'package:finality/di/injector.dart';
import 'package:finality/domain/options/close_position_estimator.dart';
import 'package:finality/domain/options/entities/opened_position.dart';
import 'package:finality/domain/options/options_trading_pair_selector.dart';
import 'package:finality/domain/premium/entities/market_account.dart';
import 'package:finality/features/highlow/model/settled_position_event.dart';
import 'package:finality/features/highlow/trading_pairs/vm/options_trading_pairs_vm.dart';
import 'package:finality/services/app_lifecycle_service.dart';
import 'package:finality/services/wallet/token_position_service.dart';
import 'package:finality/services/wallet/wallet_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:store_scope/store_scope.dart';

/// 兜底对账时复用已结算订单 VM 的历史接口；TradingHistoryRecentVM 通过
/// [OpenedPositionsVM.setHistoryDetailFetcher] 注册自身实现，避免双方重复请求
typedef HistoryDetailFetcher = Future<Map<String, PositionHistoryItem>>
    Function(List<String> ids);

final openedPositionsVMProvider = ViewModelProvider<OpenedPositionsVM>((ref) {
  return OpenedPositionsVM(
    injector<GameStatusSocketClient>(),
    injector<WalletService>(),
    injector<ManicTradeDataSource>(),
    injector<TokenPositionService>(),
    ref.bind(optionsTradingPairsVMProvider),
    injector<RealtimeMarketAccountTransport>(),
    injector<SharedPriceStreamManager>(),
    injector<OptionsTradingPairSelector>(),
    injector<AppLifecycleService>(),
    ClosePositionEstimator(),
  );
});

class OpenedPositionsVM extends ViewModel {
  OpenedPositionsVM(
    this._socketClient,
    this._walletService,
    this._dataSource,
    this._positionService,
    this._optionsTradingPairsVM,
    this._marketAccountTransport,
    this._sharedPriceStreamManager,
    this._pairSelector,
    this._lifecycleService,
    this._estimator,
  );

  final GameStatusSocketClient _socketClient;
  final WalletService _walletService;
  final ManicTradeDataSource _dataSource;
  final TokenPositionService _positionService;
  final OptionsTradingPairsVM _optionsTradingPairsVM;
  final RealtimeMarketAccountTransport _marketAccountTransport;
  final SharedPriceStreamManager _sharedPriceStreamManager;
  final OptionsTradingPairSelector _pairSelector;
  final AppLifecycleService _lifecycleService;

  final ClosePositionEstimator _estimator;

  /// 当前已开仓的仓位列表
  final ValueNotifier<List<OpenedPosition>> openedPositions = ValueNotifier([]);

  /// 是否正在加载初始数据
  final ValueNotifier<bool> isLoading = ValueNotifier(false);

  /// 获取仓位的请求状态（用于防重入）
  final ValueNotifier<UiState<void>> fetchPositionsState =
      ValueNotifier(UiState.initial());

  /// 各资产的 MarketAccount 数据（按 baseAsset 索引）
  final ValueNotifier<Map<String, MarketAccount>> marketAccounts =
      ValueNotifier({});

  // ==================== 实时价格 & 估算 ====================

  /// 每个 asset 的实时价格（共享，同币对仓位共用同一个）
  final Map<String, ValueNotifier<ManicPriceData?>> _priceNotifiers = {};

  /// 每个仓位的提前平仓估算结果
  final Map<String, ValueNotifier<ClosePositionEstimateResult?>>
      _estimateNotifiers = {};

  /// 获取指定 asset 的实时价格 Notifier（保证返回稳定的非空引用）
  ValueNotifier<ManicPriceData?> getPriceNotifier(String asset) {
    return _priceNotifiers.putIfAbsent(asset, () => ValueNotifier(null));
  }

  /// 获取指定仓位的提前平仓估算 Notifier（保证返回稳定的非空引用）
  ValueNotifier<ClosePositionEstimateResult?> getEstimateNotifier(
      String positionId) {
    return _estimateNotifiers.putIfAbsent(
        positionId, () => ValueNotifier(null));
  }

  // ==================== 内部订阅管理 ====================

  final Map<String, StreamSubscription<MarketAccount>> _marketAccountSubs = {};
  final Map<String, PriceSubscription> _priceSubscriptions = {};
  final Map<String, StreamSubscription> _priceStreamSubs = {};

  /// Socket 事件订阅
  StreamSubscription<GameStatusEvent>? _eventSubscription;

  /// 在 API 响应前缓存的 Socket 事件
  final List<GameStatusEvent> _pendingEvents = [];

  /// 已结算的仓位 ID 集合（用于过滤 API 返回的已结算仓位）
  final Set<String> _settledPositionIds = {};

  /// 结算事件流（供外部取消飞行中的请求）
  final _settleController = StreamController<String>.broadcast();
  Stream<String> get onPositionSettled => _settleController.stream;

  /// 正在手动平仓的仓位 ID（冻结 socket 结算提示）
  final Set<String> _manuallyClosingIds = {};

  final ValueNotifier<double> totalPendingPositionAssetValue =
      ValueNotifier(0.0); // 总未结算仓位资产价值

  /// 按当前价格 ITM/OTM 判断的预估总盈亏
  final ValueNotifier<double> totalEstPayout = ValueNotifier(0.0);

  /// 立刻全部卖出后的总净收益
  final ValueNotifier<double> totalPayoutAfterSell = ValueNotifier(0.0);

  /// 结算事件列表（外部可监听此列表变化来展示 UI 通知）
  final ValueNotifier<List<SettledPositionEvent>> displaySettledEvents =
      ValueNotifier([]);
  static const int kSettlePositionDisplayMillis = 8000; //8 秒

  final ValueNotifier<bool> chartOnTheFrontEnd = ValueNotifier(true); // 图表是否在前台

  // ==================== 结算兜底对账 ====================

  /// 仓位 endTime 到点后等待服务端完成结算的容差（秒）
  static const int _settleGraceSeconds = 5;

  /// 兜底对账：超过这个时间（秒）的结算视为"过旧"，不弹 toast/动画
  /// 适用场景：app 长时间后台后回来，一次性多个仓位过期，避免 UX 爆炸
  static const int _settleToastMaxAgeSeconds = 3 * 60;

  /// 兜底对账正在进行中（防并发重入）
  bool _reconciling = false;

  /// 兜底 Timer：基于最早一个 endTime + grace 调度
  Timer? _stalenessTimer;

  /// Socket 上一次的连接状态（用于检测 false → true 跳变）
  bool _lastSocketConnected = false;

  /// App resumed 事件订阅
  StreamSubscription<void>? _appResumedSub;

  /// 兜底对账时由 TradingHistoryRecentVM 注册，复用其 API 调用避免重复请求
  HistoryDetailFetcher? _historyDetailFetcher;

  @override
  void init() {
    super.init();
    openedPositions.addListener(_syncSubscriptions);
    openedPositions.addListener(_scheduleStalenessTimer);
    _appResumedSub = _lifecycleService.onResumed
        .listen((_) => _reconcileIfStale(reason: 'app_resumed'));
    _lastSocketConnected = _socketClient.isConnected.value;
    _socketClient.isConnected.addListener(_onSocketConnectionChange);
    _initializeData();
  }

  /// Socket 从断开恢复到连接时触发兜底对账
  void _onSocketConnectionChange() {
    final connected = _socketClient.isConnected.value;
    if (connected && !_lastSocketConnected) {
      _reconcileIfStale(reason: 'socket_reconnected');
    }
    _lastSocketConnected = connected;
  }

  /// 调度兜底 Timer：在最早一个仓位的 endTime + grace 时触发
  /// 仓位列表变化时会重新调度（新增/移除/替换）
  void _scheduleStalenessTimer() {
    _stalenessTimer?.cancel();
    _stalenessTimer = null;

    final positions = openedPositions.value;
    if (positions.isEmpty) return;

    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    int earliestFireAt = positions.first.endTime + _settleGraceSeconds;
    for (final p in positions) {
      final fireAt = p.endTime + _settleGraceSeconds;
      if (fireAt < earliestFireAt) earliestFireAt = fireAt;
    }

    final delay = earliestFireAt - now;
    _stalenessTimer = Timer(
      Duration(seconds: delay > 0 ? delay : 0),
      () => _reconcileIfStale(reason: 'timer'),
    );
  }

  /// 列表中是否存在「endTime 已过 + grace」的仓位
  bool _hasStalePosition() {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return openedPositions.value.any(
      (p) => now - p.endTime >= _settleGraceSeconds,
    );
  }

  /// 兜底对账：如有超期未结算仓位，拉取 API 并结合 history 补结算详情
  Future<void> _reconcileIfStale({required String reason}) async {
    if (_reconciling) return;
    if (fetchPositionsState.value.isLoading) return;
    if (!_hasStalePosition()) return;

    _reconciling = true;
    try {
      logger.d('OpenedPositionsVM: 兜底对账触发, reason=$reason');
      final response = await _dataSource.getPendingPositions();
      await _reconcileWithApi(response);
    } catch (e, stackTrace) {
      logger.e('OpenedPositionsVM: 兜底对账失败', error: e, stackTrace: stackTrace);
    } finally {
      _reconciling = false;
    }
  }

  /// 对账：本地超期 && API 中不存在 → 视为已结算，拉 history 补详情并走完整通知流程
  Future<void> _reconcileWithApi(PendingPositionsResponse response) async {
    final apiIds = response.positions.map((p) => p.id).toSet();
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    final current = openedPositions.value;
    final missingPositions = current
        .where((p) =>
            now - p.endTime >= _settleGraceSeconds && !apiIds.contains(p.id))
        .toList();

    if (missingPositions.isEmpty) return;

    final missingIds = missingPositions.map((p) => p.id).toList();
    logger.d('OpenedPositionsVM: 兜底清理 ${missingIds.length} 个超期仓位 $missingIds');

    // 拉最新 history 补结算详情（失败或拿不到匹配时会降级为静默移除）
    final historyMap = await _fetchHistoryDetailsFor(missingIds);

    // 先标记为已结算，防止后续事件/请求重复处理
    for (final id in missingIds) {
      _settledPositionIds.add(id);
    }
    final missingSet = missingIds.toSet();
    final remaining = current.where((p) => !missingSet.contains(p.id)).toList();
    _updateOpenedPositions(remaining);

    // 为每个 missing 仓位走完整通知流程（对齐 socket _handleSettle）
    for (final position in missingPositions) {
      final isManuallyClosing = _manuallyClosingIds.remove(position.id);
      final historyItem = historyMap[position.id];
      final isTooOld = now - position.endTime > _settleToastMaxAgeSeconds;

      if (historyItem != null) {
        final event = _positionEventFromHistoryItem(historyItem);
        // result 为空说明服务端结算结果还没落库，此时无法判断输赢，静默清理
        final isResultPending = historyItem.result == null;
        // 跳过 toast/动画的情况：手动平仓、跨端撤单（退款）、结算时间过久、结果未落库
        if (!isManuallyClosing &&
            !historyItem.isRefund &&
            !isTooOld &&
            !isResultPending) {
          _showSettleMessage(position, event);
          _onNewSettledEvent(position, event);
        } else if (isResultPending) {
          logger.d(
              'OpenedPositionsVM: 仓位 ${position.id} history result 为空，静默清理');
        } else if (isTooOld) {
          logger.d(
              'OpenedPositionsVM: 仓位 ${position.id} 结算时间过久（${now - position.endTime}s），静默清理');
        }
      }
      // 广播结算，让飞行中的平仓请求可以及时取消
      _settleController.add(position.id);
    }

    _positionService.fetchCurrentAccountsTokenPositions();
  }

  /// 拉最近一页历史，返回 id → item 映射，仅保留请求中的 id
  /// 通过 [setHistoryDetailFetcher] 注册的回调获取，未注册时降级为静默移除
  Future<Map<String, PositionHistoryItem>> _fetchHistoryDetailsFor(
      List<String> ids) async {
    final fetcher = _historyDetailFetcher;
    if (fetcher == null) return const {};
    try {
      return await fetcher(ids);
    } catch (e, stackTrace) {
      logger.w('OpenedPositionsVM: 拉取 recent history 失败, 将降级为静默移除',
          error: e, stackTrace: stackTrace);
      return const {};
    }
  }

  /// 注册兜底对账时使用的历史拉取回调
  /// 由 TradingHistoryRecentVM 在 init/dispose 中调用，复用其 API 避免重复请求
  void setHistoryDetailFetcher(HistoryDetailFetcher? fetcher) {
    _historyDetailFetcher = fetcher;
  }

  /// 从 history item 合成 PositionEvent，仅填充下游 show/notify 使用的字段
  PositionEvent _positionEventFromHistoryItem(PositionHistoryItem item) {
    return PositionEvent(
      boundaryPrice: item.boundaryPrice,
      id: item.positionId,
      premium: 0,
      side: item.side,
      spotPrice: 0,
      user: '',
      payout: item.payout,
      result: item.result,
      finalPrice: item.finalPrice,
    );
  }

  /// 初始化数据：并发请求 API 和连接 Socket
  Future<void> _initializeData() async {
    isLoading.value = true;

    try {
      // 获取钱包地址
      final walletAccounts = await _walletService.waitWalletAccounts();
      final solanaAccount = walletAccounts?.getSolanaAccount();
      if (solanaAccount == null) {
        logger.w('GameStatusVM: 无法获取 Solana 账户地址');
        isLoading.value = false;
        return;
      }

      final address = solanaAccount.address;

      // 并发执行：连接 Socket 和请求 API
      await Future.wait([
        _connectSocket(address),
        fetchInitialPositions(),
      ]);
    } catch (e) {
      logger.e('GameStatusVM: 初始化失败: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// 连接 Socket 并监听事件
  Future<void> _connectSocket(String address) async {
    try {
      // 先设置监听，再连接，确保不会丢失事件
      _eventSubscription = _socketClient.eventStream.listen(_onSocketEvent);
      await _socketClient.connect(address: address);
      logger.d('GameStatusVM: Socket 连接成功');
    } catch (e) {
      logger.e('GameStatusVM: Socket 连接失败: $e');
    }
  }

  /// 从 API 获取初始仓位数据
  Future<void> fetchInitialPositions() async {
    if (fetchPositionsState.value.isLoading) return;
    fetchPositionsState.value = UiState.loading();
    try {
      final response = await _dataSource.getPendingPositions();
      await _processApiResponse(response);
    } catch (error, stackTrace) {
      logger.e('GameStatusVM: 获取初始仓位失败: ',
          error: error, stackTrace: stackTrace);
      // 即使 API 失败，也标记为已初始化，让 Socket 事件正常处理
      fetchPositionsState.value = UiState.failure(error);

      _processPendingEvents();
    }
  }

  /// 更新仓位列表并排序（按 endTime 降序，越新的排上面）
  void _updateOpenedPositions(List<OpenedPosition> positions) {
    final sorted = List<OpenedPosition>.from(positions)
      ..sort((a, b) => b.endTime.compareTo(a.endTime));
    openedPositions.value = sorted;
    _updateTotalPendingPositionAssetValue(sorted);
  }

  /// 计算并更新总未结算仓位资产价值
  void _updateTotalPendingPositionAssetValue(List<OpenedPosition> positions) {
    double total = 0.0;
    for (final position in positions) {
      total += position.amount;
    }
    totalPendingPositionAssetValue.value = total;
  }

  /// 处理 API 响应数据
  Future<void> _processApiResponse(PendingPositionsResponse response) async {
    // 将 API 返回的数据转换为 OpenedPosition
    List<OpenedPosition> positions = [];

    for (var item in response.positions) {
      var feedId = item.feedId;
      if (feedId == null) {
        continue;
      }
      var optionsTradingPair =
          await _optionsTradingPairsVM.loadTradingPairsByFeedId(feedId);
      if (optionsTradingPair != null) {
        positions.add(
            OpenedPosition.fromPendingPositionItem(item, optionsTradingPair));
      }
    }

    // 过滤掉已经被 Socket 通知结算的仓位
    final filteredPositions =
        positions.where((p) => !_settledPositionIds.contains(p.id)).toList();

    // 更新仓位列表并排序
    _updateOpenedPositions(filteredPositions);

    fetchPositionsState.value = UiState.success(null);
    // 处理缓存的 Socket 事件
    _processPendingEvents();

    logger.d('GameStatusVM: API 初始化完成，当前仓位数: ${openedPositions.value.length}');
  }

  /// 处理缓存的 Socket 事件
  void _processPendingEvents() {
    if (_pendingEvents.isEmpty) return;

    logger.d('GameStatusVM: 处理 ${_pendingEvents.length} 个缓存的 Socket 事件');

    for (final event in _pendingEvents) {
      _handleSocketEvent(event);
    }
    _pendingEvents.clear();
  }

  /// Socket 事件回调
  void _onSocketEvent(GameStatusEvent event) {
    if (fetchPositionsState.value.isLoading) {
      // API 还未完成，先缓存事件

      logger.d('GameStatusVM: API 未完成，缓存 Socket 事件: ${event.flag}');

      if (event.isSettle) {
        //结算事件
        _settledPositionIds.add(event.event.id);
        //缓存事件，等待API完成后再处理
        _pendingEvents.add(event);
      } else if (event.isOpenPosition) {
        //开仓事件
        //直接处理
        _handleOpenPosition(event.event);
      }
      return;
    } else {
      // API 已完成，直接处理事件
      _handleSocketEvent(event);
    }
  }

  /// 处理 Socket 事件
  void _handleSocketEvent(GameStatusEvent event) {
    if (event.isOpenPosition) {
      _handleOpenPosition(event.event);
    } else if (event.isSettle) {
      _handleSettle(event.event);
    }
  }

  /// 处理开仓事件
  Future<void> _handleOpenPosition(PositionEvent event) async {
    try {
      var feedId = event.feedId;
      if (feedId == null) {
        return;
      }
      var optionsTradingPair =
          await _optionsTradingPairsVM.loadTradingPairsByFeedId(feedId);
      if (optionsTradingPair != null) {
        final newPosition =
            OpenedPosition.fromSocketEvent(event, optionsTradingPair);
        HapticFeedbackUtils.vibration(HapticsType.success);

        // 检查是否已存在（避免重复添加）
        final currentList = List<OpenedPosition>.from(openedPositions.value);
        if (currentList.any((p) => p.id == newPosition.id)) {
          logger.d('GameStatusVM: 仓位已存在，跳过: ${newPosition.id}');
          return;
        }

        // 添加新仓位并排序
        currentList.add(newPosition);
        _updateOpenedPositions(currentList);

        logger.d(
            'GameStatusVM: 新开仓位 id=${newPosition.id}, side=${event.side}, amount=${newPosition.amountDisplay}');
      }

      _positionService.fetchCurrentAccountsTokenPositions();
    } catch (e, stackTrace) {
      logger.e('GameStatusVM: 处理开仓事件失败', error: e, stackTrace: stackTrace);
    }
  }

  /// 处理结算事件
  void _handleSettle(PositionEvent event) {
    final positionId = event.id;

    // 记录已结算的 ID
    _settledPositionIds.add(positionId);

    // 正在手动平仓的仓位，跳过 snackbar 和结算动画，仅做列表清理
    final isManuallyClosing = _manuallyClosingIds.contains(positionId);

    // 从列表中移除已结算的仓位
    final currentList = List<OpenedPosition>.from(openedPositions.value);
    final removedPosition =
        currentList.firstWhereOrNull((p) => p.id == positionId);

    if (removedPosition != null) {
      currentList.removeWhere((p) => p.id == positionId);

      if (!isManuallyClosing) {
        // 弹出结算消息
        _showSettleMessage(removedPosition, event);
      }
      // 添加到结算事件列表，供外部监听
      _onNewSettledEvent(removedPosition, event);

      _updateOpenedPositions(currentList);

      logger.d('GameStatusVM: 仓位结算 id=$positionId, result=${event.result}'
          '${isManuallyClosing ? ' (手动平仓，跳过提示)' : ''}');
    } else {
      logger.d('GameStatusVM: 结算的仓位不存在列表中: $positionId');
    }

    if (!isManuallyClosing) {
      _positionService.fetchCurrentAccountsTokenPositions();
    }

    // 广播结算事件，让飞行中的平仓请求可以及时取消
    _settleController.add(positionId);
  }

  /// 添加结算事件到列表
  void _onNewSettledEvent(
    OpenedPosition position,
    PositionEvent event,
  ) {
    var currentSettledEvents = displaySettledEvents.value;
    var newSettledEvents = <SettledPositionEvent>[];
    var millisecondsSinceEpoch = DateTime.now().millisecondsSinceEpoch;
    for (var event in currentSettledEvents) {
      if (millisecondsSinceEpoch - event.notificationtimestamp <
          kSettlePositionDisplayMillis) {
        newSettledEvents.add(SettledPositionEvent(
            position: event.position,
            event: event.event,
            notificationtimestamp: event.notificationtimestamp));
      }
    }
    newSettledEvents.add(SettledPositionEvent(
        position: position,
        event: event,
        notificationtimestamp: millisecondsSinceEpoch));
    // 创建新列表并添加事件，触发 ValueNotifier 更新
    displaySettledEvents.value = newSettledEvents;
  }

  /// 显示结算消息
  void _showSettleMessage(
    OpenedPosition position,
    PositionEvent event,
  ) {
    final isWin = event.isWin;
    if (isWin) {
      HapticFeedbackUtils.vibration(HapticsType.success);
    } else {
      HapticFeedbackUtils.vibration(HapticsType.rigid).then((value) {
        HapticFeedbackUtils.lightImpact();
      });
    }

    if (chartOnTheFrontEnd.value &&
        _pairSelector.getSelectedPairId()?.baseAsset ==
            position.tradingPair.baseAsset) {
      return;
    }

    // 使用 GetX 的 SnackBar 显示消息
    if (isWin) {
      AppToastManager.showGameWon(
        title: 'You won the game!',
        subtitle: "Payout processed.",
        payout: "+\$${event.payoutAmount}",
      );
    } else {
      AppToastManager.showGameLost(
        title: 'You lost the game!',
        subtitle: "Better luck next time.",
        payout: "+\$${event.payoutAmount}",
      );
    }
  }

  // ==================== 统一订阅管理 ====================

  /// 根据当前持仓列表同步所有订阅：MarketAccount、价格流、估算 Notifier
  void _syncSubscriptions() {
    final positions = openedPositions.value;

    // 收集当前活跃的 asset 和 positionId
    final activeAssets = <String>{};
    final activePositionIds = <String>{};
    for (final p in positions) {
      activeAssets.add(p.tradingPair.baseAsset);
      activePositionIds.add(p.id);
    }

    // --- 1. MarketAccount 订阅 ---
    _syncMarketAccountSubs(activeAssets);

    // --- 2. 价格流订阅 ---
    _syncPriceSubs(activeAssets);

    // --- 3. 估算 Notifier ---
    _syncEstimateNotifiers(positions, activePositionIds);
  }

  void _syncMarketAccountSubs(Set<String> activeAssets) {
    // 取消不再需要的
    final toRemove = _marketAccountSubs.keys
        .where((a) => !activeAssets.contains(a))
        .toList();
    for (final asset in toRemove) {
      _marketAccountSubs[asset]?.cancel();
      _marketAccountSubs.remove(asset);
    }

    // 订阅新增的
    for (final asset in activeAssets) {
      if (!_marketAccountSubs.containsKey(asset)) {
        _marketAccountSubs[asset] =
            _marketAccountTransport.subscribe(asset).listen((account) {
          final updated = Map<String, MarketAccount>.from(marketAccounts.value);
          updated[asset] = account;
          marketAccounts.value = updated;
          // MarketAccount 更新后重算该 asset 所有仓位的估算
          final priceData = getPriceNotifier(asset).value;
          if (priceData != null) {
            _recalculateEstimatesForAsset(asset, priceData.close);
          }
        });
      }
    }
  }

  void _syncPriceSubs(Set<String> activeAssets) {
    // 取消不再需要的
    final toRemove = _priceSubscriptions.keys
        .where((a) => !activeAssets.contains(a))
        .toList();
    for (final asset in toRemove) {
      _priceStreamSubs[asset]?.cancel();
      _priceStreamSubs.remove(asset);
      _priceSubscriptions[asset]?.dispose();
      _priceSubscriptions.remove(asset);
      _priceNotifiers.remove(asset);
    }

    // 订阅新增的
    for (final asset in activeAssets) {
      if (!_priceSubscriptions.containsKey(asset)) {
        final sub = _sharedPriceStreamManager.subscribe(asset);
        _priceSubscriptions[asset] = sub;
        _priceStreamSubs[asset] = sub.priceStream.listen((data) {
          getPriceNotifier(asset).value = data;
          _recalculateEstimatesForAsset(asset, data.close);
        });
      }
    }
  }

  void _syncEstimateNotifiers(
      List<OpenedPosition> positions, Set<String> activePositionIds) {
    // 移除已不存在的仓位
    final toRemove = _estimateNotifiers.keys
        .where((id) => !activePositionIds.contains(id))
        .toList();
    for (final id in toRemove) {
      _estimateNotifiers.remove(id);
    }

    // 为新仓位创建 notifier，如果数据已就绪则立即计算
    for (final p in positions) {
      final isNew = !_estimateNotifiers.containsKey(p.id);
      getEstimateNotifier(p.id); // 保证 notifier 存在
      if (isNew) {
        final asset = p.tradingPair.baseAsset;
        final priceData = getPriceNotifier(asset).value;
        final ma = marketAccounts.value[asset];
        if (priceData != null && ma != null) {
          _calculateEstimateForPosition(p, ma, priceData.close);
        }
      }
    }
  }

  /// 重算某个 asset 下所有仓位的提前平仓估算
  void _recalculateEstimatesForAsset(String asset, double currentPrice) {
    final ma = marketAccounts.value[asset];
    if (ma == null) return;

    for (final p in openedPositions.value) {
      if (p.tradingPair.baseAsset != asset) continue;
      _calculateEstimateForPosition(p, ma, currentPrice);
    }
    _recalculateTotals();
  }

  /// 汇总所有仓位的预估盈亏和提前平仓收益
  void _recalculateTotals() {
    double estPayout = 0;
    double payoutAfterSell = 0;
    for (final p in openedPositions.value) {
      // Est Payout: 按当前价格判断 ITM/OTM
      final priceData = getPriceNotifier(p.tradingPair.baseAsset).value;
      if (priceData != null) {
        final isWinning = p.isHigh
            ? priceData.close >= p.entryPrice
            : priceData.close < p.entryPrice;
        estPayout += isWinning ? p.winPayout : -p.lossPayout;
      }
      // Payout After Sell: 提前平仓估算净收益
      final est = _estimateNotifiers[p.id]?.value;
      if (est != null) {
        payoutAfterSell += est.estimatedPayoutUsdc;
      }
    }
    totalEstPayout.value = estPayout;
    totalPayoutAfterSell.value = payoutAfterSell;
  }

  /// 计算单个仓位的提前平仓估算
  void _calculateEstimateForPosition(
    OpenedPosition position,
    MarketAccount marketAccount,
    double currentPrice,
  ) {
    final notifier = getEstimateNotifier(position.id);
    if (position.amountLamports == 0) {
      return;
    }

    notifier.value = _estimator.estimate(
      isHigh: position.isHigh,
      premiumAmountLamports: position.amountLamports,
      boundaryPrice: position.entryPrice,
      startTime: position.startTime,
      endTime: position.endTime,
      marketAccount: marketAccount,
      currentPrice: currentPrice,
    );
  }

  // ================================================================

  /// 刷新仓位数据
  Future<void> refresh() async {
    isLoading.value = true;
    _settledPositionIds.clear();
    _pendingEvents.clear();

    try {
      await fetchInitialPositions();
    } finally {
      isLoading.value = false;
    }
  }

  /// 标记仓位正在手动平仓（冻结 socket 结算提示）
  void markClosing(String positionId) {
    _manuallyClosingIds.add(positionId);
  }

  /// 取消标记（平仓失败时恢复 socket 正常处理）
  void unmarkClosing(String positionId) {
    _manuallyClosingIds.remove(positionId);
  }

  /// 平仓成功后移除仓位，[refreshBalance] 控制是否立即刷新余额
  void callOnPositionClosed(String positionId, {bool refreshBalance = true}) {
    _settledPositionIds.add(positionId);
    _manuallyClosingIds.remove(positionId);
    final currentList = List<OpenedPosition>.from(openedPositions.value);
    currentList.removeWhere((p) => p.id == positionId);
    _updateOpenedPositions(currentList);
    if (refreshBalance) {
      _positionService.fetchCurrentAccountsTokenPositions();
    }
  }

  /// 批量平仓完成后统一刷新余额
  void refreshBalance() {
    _positionService.fetchCurrentAccountsTokenPositions();
  }

  @override
  void dispose() {
    _appResumedSub?.cancel();
    _appResumedSub = null;
    _socketClient.isConnected.removeListener(_onSocketConnectionChange);
    _stalenessTimer?.cancel();
    _stalenessTimer = null;
    openedPositions.removeListener(_syncSubscriptions);
    openedPositions.removeListener(_scheduleStalenessTimer);
    fetchPositionsState.dispose();
    _eventSubscription?.cancel();
    for (final sub in _marketAccountSubs.values) {
      sub.cancel();
    }
    _marketAccountSubs.clear();
    for (final sub in _priceStreamSubs.values) {
      sub.cancel();
    }
    _priceStreamSubs.clear();
    for (final sub in _priceSubscriptions.values) {
      sub.dispose();
    }
    _priceSubscriptions.clear();
    _settleController.close();
    super.dispose();
  }
}
