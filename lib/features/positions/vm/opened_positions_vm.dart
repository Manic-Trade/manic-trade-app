import 'dart:async';

import 'package:finality/common/toast/app_toast_manager.dart';
import 'package:finality/common/utils/haptic_feedback_utils.dart';
import 'package:finality/core/logger.dart';
import 'package:finality/core/state/ui_state.dart';
import 'package:finality/data/network/manic_trade_data_source.dart';
import 'package:finality/data/network/model/manic/pending_position_item_response.dart';
import 'package:finality/data/realtime/realtime_market_account_transport.dart';
import 'package:finality/data/socket/game_status_socket_client.dart';
import 'package:finality/data/socket/shared_price_stream_manager.dart';
import 'package:finality/di/injector.dart';
import 'package:finality/domain/options/close_position_estimator.dart';
import 'package:finality/domain/options/entities/opened_position.dart';
import 'package:finality/domain/premium/entities/market_account.dart';
import 'package:finality/domain/premium/premium_calculator.dart';
import 'package:finality/features/highlow/model/settled_position_event.dart';
import 'package:finality/features/highlow/trading_pairs/vm/options_trading_pairs_vm.dart';
import 'package:finality/features/positions/vm/trading_history_recent_vm.dart';
import 'package:finality/features/positions/vm/trading_history_vm.dart';
import 'package:finality/services/wallet/token_position_service.dart';
import 'package:finality/services/wallet/wallet_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:store_scope/store_scope.dart';

final openedPositionsVMProvider = ViewModelProvider<OpenedPositionsVM>((ref) {
  return OpenedPositionsVM(
    injector<GameStatusSocketClient>(),
    injector<WalletService>(),
    injector<ManicTradeDataSource>(),
    injector<TokenPositionService>(),
    ref.bind(optionsTradingPairsVMProvider),
    injector<RealtimeMarketAccountTransport>(),
    injector<SharedPriceStreamManager>(),
    ClosePositionEstimator(PremiumCalculator()),
    (positionId) {
      ref.find(tradingHistoryRecentVMProvider)?.refreshRecentHistory();
      ref.find(tradingHistoryVMProvider)?.refresh();
    },
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
    this._estimator,
    this.onPositionClosed,
  );

  final GameStatusSocketClient _socketClient;
  final WalletService _walletService;
  final ManicTradeDataSource _dataSource;
  final TokenPositionService _positionService;
  final OptionsTradingPairsVM _optionsTradingPairsVM;
  final RealtimeMarketAccountTransport _marketAccountTransport;
  final SharedPriceStreamManager _sharedPriceStreamManager;
  final ClosePositionEstimator _estimator;
  final Function(String positionId)? onPositionClosed;

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
  final Map<String, ValueNotifier<double?>> _priceNotifiers = {};

  /// 每个仓位的提前平仓估算结果
  final Map<String, ValueNotifier<ClosePositionEstimateResult?>>
      _estimateNotifiers = {};

  /// 获取指定 asset 的实时价格 Notifier（保证返回稳定的非空引用）
  ValueNotifier<double?> getPriceNotifier(String asset) {
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

  // ==================== Mock 数据开关 ====================
  // 设置为 true 使用 mock 数据调试 UI，设置为 false 使用真实 API
  static const bool _useMockData = false;
  // ========================================================

  @override
  void init() {
    super.init();
    openedPositions.addListener(_syncSubscriptions);
    _initializeData();
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
      if (response.positions.isEmpty && _useMockData) {
        final mockResponse = _generateMockPositions();

        await _processApiResponse(mockResponse);
        logger.d(
            'GameStatusVM: 使用 Mock 数据，共 ${mockResponse.positions.length} 个仓位');
        return;
      }
      await _processApiResponse(response);
    } catch (error, stackTrace) {
      logger.e('GameStatusVM: 获取初始仓位失败: ',
          error: error, stackTrace: stackTrace);
      // 即使 API 失败，也标记为已初始化，让 Socket 事件正常处理
      fetchPositionsState.value = UiState.failure(error);

      _processPendingEvents();
    }
  }

  /// 生成 Mock 仓位数据用于 UI 调试
  /// 包含多种场景：不同资产、看涨/看跌、不同金额、不同结束时间
  PendingPositionsResponse _generateMockPositions() {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    return PendingPositionsResponse(
      positions: [
        // SOL 看涨仓位 - 30秒后结束
        PendingPositionItemResponse(
          id: 'mock_position_sol_call_1',
          feedId: 'H6ARHf6YXhGYeQfUzQNGk6rDNnLBQKrenN712K4AQJEG', // SOL
          user: 'mock_user_address',
          side: 'call',
          amount: 10000000, // 10 USDC (微单位)
          premium: 0.5,
          premiumAmount: 5000000, // 5 USDC
          boundaryPrice: 185.50,
          spotPrice: 185.00,
          startTime: now - 30,
          endTime: now + 30,
          mode: 'standard',
          multiplier: 2,
        ),
        // BTC 看跌仓位 - 60秒后结束
        PendingPositionItemResponse(
          id: 'mock_position_btc_put_1',
          feedId: 'GVXRSBjFk6e6J3NbVPXohDJetcTjaeeuykUpbQF8UoMU', // BTC
          user: 'mock_user_address',
          side: 'put',
          amount: 20000000, // 20 USDC
          premium: 0.45,
          premiumAmount: 9000000, // 9 USDC
          boundaryPrice: 95600.00,
          spotPrice: 96000.00,
          startTime: now - 60,
          endTime: now + 60,
          mode: 'standard',
          multiplier: 2,
        ),
        // ETH 看涨仓位 - 90秒后结束
        PendingPositionItemResponse(
          id: 'mock_position_eth_call_1',
          feedId: 'JBu1AL4obBcCMqKBBxhpWCNUt136ijcuMZLFvTP7iWdB', // ETH
          user: 'mock_user_address',
          side: 'call',
          amount: 15000000, // 15 USDC
          premium: 0.48,
          premiumAmount: 7200000, // 7.2 USDC
          boundaryPrice: 3250.00,
          spotPrice: 3240.00,
          startTime: now - 45,
          endTime: now + 90,
          mode: 'standard',
          multiplier: 2,
        ),
        // SOL 看跌仓位 - 120秒后结束
        PendingPositionItemResponse(
          id: 'mock_position_sol_put_1',
          feedId: 'H6ARHf6YXhGYeQfUzQNGk6rDNnLBQKrenN712K4AQJEG', // SOL
          user: 'mock_user_address',
          side: 'put',
          amount: 8000000, // 8 USDC
          premium: 0.52,
          premiumAmount: 4160000, // 4.16 USDC
          boundaryPrice: 184.00,
          spotPrice: 185.00,
          startTime: now - 20,
          endTime: now + 120,
          mode: 'standard',
          multiplier: 2,
        ),
        // BTC 看涨仓位 - 180秒后结束（大额）
        PendingPositionItemResponse(
          id: 'mock_position_btc_call_1',
          feedId: 'GVXRSBjFk6e6J3NbVPXohDJetcTjaeeuykUpbQF8UoMU', // BTC
          user: 'mock_user_address',
          side: 'call',
          amount: 50000000, // 50 USDC
          premium: 0.55,
          premiumAmount: 27500000, // 27.5 USDC
          boundaryPrice: 95739.00,
          spotPrice: 95000.00,
          startTime: now - 120,
          endTime: now + 180,
          mode: 'standard',
          multiplier: 2,
        ),
      ],
    );
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
      onPositionClosed?.call(positionId);
    }
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

    if (chartOnTheFrontEnd.value) {
      return;
    }
    final payout = event.payout ?? 0;
    final payoutAmount = (payout / 1000000).toStringAsFixed(2);


    // 使用 GetX 的 SnackBar 显示消息
    if (isWin) {
      AppToastManager.showGameWon(
        title: 'You won the game!',
        subtitle: "Payout processed.",
        payout: '+\$$payoutAmount',
      );
    } else {
      AppToastManager.showGameLost(
        title: 'You lost the game!',
        subtitle: "Better luck next time.",
        payout: '+\$0.00',
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
          final price = getPriceNotifier(asset).value;
          if (price != null) {
            _recalculateEstimatesForAsset(asset, price);
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
          getPriceNotifier(asset).value = data.close;
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
        final price = getPriceNotifier(asset).value;
        final ma = marketAccounts.value[asset];
        if (price != null && ma != null) {
          _calculateEstimateForPosition(p, ma, price);
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
      final price = getPriceNotifier(p.tradingPair.baseAsset).value;
      if (price != null) {
        final isWinning =
            p.isHigh ? price >= p.entryPrice : price < p.entryPrice;
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
    if (position.winPayoutLamports == 0 || position.amountLamports == 0) {
      return;
    }

    notifier.value = _estimator.estimate(
      isHigh: position.isHigh,
      winPayoutLamports: position.winPayoutLamports,
      amountLamports: position.amountLamports,
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
      onPositionClosed?.call(positionId);
    }
  }

  /// 批量平仓完成后统一刷新余额
  void refreshBalance() {
    _positionService.fetchCurrentAccountsTokenPositions();
  }

  @override
  void dispose() {
    openedPositions.removeListener(_syncSubscriptions);
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
    super.dispose();
  }
}
