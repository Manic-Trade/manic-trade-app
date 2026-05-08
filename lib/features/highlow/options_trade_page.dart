import 'package:deriv_chart/deriv_chart.dart';
import 'package:dio/dio.dart';
import 'package:finality/common/toast/app_toast_manager.dart';
import 'package:finality/common/utils/haptic_feedback_utils.dart';
import 'package:finality/common/utils/value_listenable_removable.dart';
import 'package:finality/common/widgets/cupertion_refresh_sliver.dart';
import 'package:finality/core/error/exception_handler.dart';
import 'package:finality/core/logger.dart';
import 'package:finality/core/notifier/multi_value_listenable_builder.dart';
import 'package:finality/data/drift/entities/options_trading_pair.dart';
import 'package:finality/data/network/model/manic/prepare_position_response.dart';
import 'package:finality/di/injector.dart';
import 'package:finality/domain/options/entities/opened_position.dart';
import 'package:finality/domain/options/entities/options_time_mode.dart';
import 'package:finality/domain/options/entities/options_trading_pair_identify.dart';
import 'package:finality/domain/options/entities/time_bar.dart';
import 'package:finality/env/env_config.dart';
import 'package:finality/features/highlow/chart/builds/chart_annotation_builder.dart';
import 'package:finality/features/highlow/chart/builds/chart_config_builder.dart';
import 'package:finality/features/highlow/chart/custom_chart_theme.dart';
import 'package:finality/features/highlow/chart/options_chart_style.dart';
import 'package:finality/features/highlow/chart/positions/contract_marker_renderer.dart';
import 'package:finality/features/highlow/chart/positions/custom_tick_marker_icon_painter.dart';
import 'package:finality/features/highlow/chart/positions/position_marker_builder.dart';
import 'package:finality/features/highlow/chart/trade_chart.dart';
import 'package:finality/features/highlow/chart/widgets/chart_price_source_mark.dart';
import 'package:finality/features/highlow/chart/widgets/chart_setting_bar.dart';
import 'package:finality/features/highlow/chart/widgets/chart_state_overlay.dart';
import 'package:finality/features/highlow/components/trade_pace_order_panel.dart';
import 'package:finality/features/highlow/components/trade_top_bar.dart';
import 'package:finality/features/highlow/config/high_low_settings_store.dart';
import 'package:finality/features/highlow/config/options_chart_config.dart';
import 'package:finality/features/highlow/config/options_chart_config_store.dart';
import 'package:finality/features/highlow/model/settlement_time.dart';
import 'package:finality/features/highlow/trading_pairs/options_trading_pairs_sheet.dart';
import 'package:finality/features/highlow/trading_pairs/vm/options_trading_pairs_vm.dart';
import 'package:finality/features/highlow/viewmodel/deriv_chart_candles_vm.dart';
import 'package:finality/features/highlow/viewmodel/premium_vm.dart';
import 'package:finality/features/highlow/viewmodel/selected_trading_pair_vm.dart';
import 'package:finality/features/main/main_controller.dart';
import 'package:finality/features/positions/details/active_position_details_sheet.dart';
import 'package:finality/features/positions/live_position/live_position_bar.dart';
import 'package:finality/features/positions/live_position/live_position_bar_vm.dart';
import 'package:finality/features/positions/model/opened_position_vo.dart';
import 'package:finality/features/positions/vm/close_position_vm.dart';
import 'package:finality/features/positions/vm/opened_positions_vm.dart';
import 'package:finality/features/positions/vm/place_order_vm.dart';
import 'package:finality/services/wallet/token_position_service.dart';
import 'package:finality/theme/app_color_theme.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:store_scope/store_scope.dart';

class OptionsTradePage extends StatefulWidget {
  final OptionsTradingPair? tradingPair;
  const OptionsTradePage({super.key, this.tradingPair});

  @override
  State<OptionsTradePage> createState() => _OptionsTradePageState();
}

class _OptionsTradePageState extends State<OptionsTradePage>
    with ScopedSpaceStateMixin {
  // ==================== ViewModels ====================
  late final SelectedTradingPairVM selectedPairVM;
  late final DerivChartCandlesVM candlesVM;
  late final PlaceOrderVM openPositionVM;
  late final OpenedPositionsVM gameStatusVM;
  late final ClosePositionVM closePositionVM;
  late final PremiumVM premiumVM;
  late final LivePositionBarVM livePositionBarVM;
  late final OptionsTradingPairsVM _optionsTradingPairsVM;

  // ==================== 交易参数 ====================
  double _payoutMultiplier = 1;
  int _durationSecs = 60;
  SettlementTime? _settlementTime;

  // ==================== 图表相关 ====================
  final HighLowSettingsStore settingsStore = injector<HighLowSettingsStore>();
  final OptionsChartConfigStore _chartConfigStore =
      injector<OptionsChartConfigStore>();
  final ChartController _chartController = ChartController();
  late final ValueNotifier<OptionsChartStyle> chartStyleNotifier;

  /// 自定义的标记绘制器，支持激活状态管理
  final CustomTickMarkerIconPainter _tickMarkerIconPainter =
      CustomTickMarkerIconPainter();

  // ==================== Builders ====================
  late final PositionMarkerBuilder _positionMarkerBuilder;
  final ChartConfigBuilder _chartConfigBuilder = const ChartConfigBuilder();

  // ==================== 其他状态 ====================
  late Removable currentAssetRemovable;

  /// 交易面板控制器，用于外部触发交易操作
  final TradePaceOrderPanelController _tradePanelController =
      TradePaceOrderPanelController();

  @override
  void initState() {
    super.initState();
    _initViewModels();
    _initBuilders();
    _setupListeners();
    // 预加载标记背景图片资源
    ContractMarkerRenderer.loadImages();
    // 埋点：首页加载
  }

  void _initViewModels() {
    _optionsTradingPairsVM = space.bind(optionsTradingPairsVMProvider);
    selectedPairVM = space.bind(selectedTradingPairVMProvider);
    candlesVM = space.bind(derivChartCandlesVMProvider);
    openPositionVM = space.bind(placeOrderVMProvider);
    gameStatusVM = space.bind(openedPositionsVMProvider);
    closePositionVM = space.bind(closePositionVMProvider);
    premiumVM = space.bind(premiumVMProvider);
    livePositionBarVM = space.bind(livePositionBarVMProvider);
    chartStyleNotifier = ValueNotifier(settingsStore.getHighLowChartStyle());
  }

  void _initBuilders() {
    _positionMarkerBuilder = PositionMarkerBuilder(
      tickMarkerIconPainter: _tickMarkerIconPainter,
      onMarkerTap: _onMarkerTap,
      onTapOutside: () {
        setState(() {
          _tickMarkerIconPainter.clearActiveMarker();
        });
      },
    );
  }

  void _setupListeners() {
    _onPriceOrParamsChanged();
    candlesVM.currentPrice.addListener(_onPriceOrParamsChanged);
    candlesVM.lastBeat.addListener(_onPriceOrParamsChanged);
    currentAssetRemovable = selectedPairVM.currentPair.listen((pair) {
      premiumVM.setTradingPair(pair);
    }, immediate: true);
  }

  void _onPriceOrParamsChanged() {
    final currentPrice = candlesVM.currentPrice.value;
    final lastBeat = candlesVM.lastBeat.value;
    premiumVM.calculatePremium(
      spotPrice: currentPrice ?? 0,
      durationSecs: _durationSecs,
      payoutMultiplier: _payoutMultiplier,
      currentTimestamp: lastBeat,
    );
  }

  @override
  void dispose() {
    currentAssetRemovable.remove();
    candlesVM.currentPrice.removeListener(_onPriceOrParamsChanged);
    candlesVM.lastBeat.removeListener(_onPriceOrParamsChanged);
    super.dispose();
  }

  // ==================== Build Methods ====================

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    _positionMarkerBuilder.markerStyle = MarkerStyle(
      upColor: appColors.bullish,
      downColor: appColors.bearish,
      upColorProminent: appColors.bullish,
      downColorProminent: appColors.bearish,
    );
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final availableHeight = constraints.maxHeight;
            return CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                CupertinoRefreshSliver(
                  onRefresh: () async {
                    candlesVM.refreshData();
                    _optionsTradingPairsVM.refreshTradingPairs();
                    gameStatusVM.refreshBalance();
                    await gameStatusVM.fetchInitialPositions();
                  },
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: availableHeight,
                    child: _buildCandlesChart(context),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    final tokenPositionService = injector<TokenPositionService>();
    return AppBar(
      titleSpacing: 0,
      // actions: [
      //   // === 调试按钮：模拟 5 秒后关盘（直接操作状态，不经过 API 验证） ===
      //   IconButton(
      //     icon: const Icon(Icons.lock_outline, size: 18),
      //     tooltip: '模拟关盘',
      //     onPressed: () {
      //       final pair = selectedPairVM.currentPair.value;
      //       if (pair == null) return;
      //       AppToastManager.showSuccess(title: '[Debug] 5秒后模拟关盘');
      //       Future.delayed(const Duration(seconds: 5), () {
      //         final nowSecs = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      //         selectedPairVM.canTradeNotifier.value = false;
      //         selectedPairVM.currentPair.value = pair.copyWith(
      //           isActive: false,
      //           tradingSchedule: drift.Value<OptionsTradingSchedule?>(
      //             pair.tradingSchedule?.copyWith(
      //                   currentStatus: 'closed',
      //                   nextOpenTime: nowSecs + 60, // 60 秒后开盘
      //                 ) ??
      //                 OptionsTradingSchedule(
      //                   timezone: 'UTC',
      //                   currentStatus: 'closed',
      //                   regularHours: '00:00-23:59',
      //                   nextOpenTime: nowSecs + 60,
      //                   isHoliday: false,
      //                 ),
      //           ),
      //         );
      //       });
      //     },
      //   ),
      //   // === 调试按钮：模拟 5 秒后开盘（直接操作状态，不经过 API 验证） ===
      //   IconButton(
      //     icon: const Icon(Icons.lock_open, size: 18),
      //     tooltip: '模拟开盘',
      //     onPressed: () {
      //       final pair = selectedPairVM.currentPair.value;
      //       if (pair == null) return;
      //       AppToastManager.showSuccess(title: '[Debug] 5秒后模拟开盘');
      //       Future.delayed(const Duration(seconds: 5), () {
      //         selectedPairVM.canTradeNotifier.value = true;
      //         selectedPairVM.currentPair.value = pair.copyWith(
      //           isActive: true,
      //           tradingSchedule: drift.Value<OptionsTradingSchedule?>(
      //             pair.tradingSchedule?.copyWith(
      //               currentStatus: 'open',
      //             ),
      //           ),
      //         );
      //       });
      //     },
      //   ),
      // ],
      title: ValueListenableBuilder2(
        first: selectedPairVM.currentPair,
        second: selectedPairVM.canTradeNotifier,
        builder: (context, pair, canTrade, child) {
          return TradeTopBar(
            onTap: () async {
              final newPairDetail = await showOptionsAssetSelectionSheet(
                context,
                currentPairIdentify: pair != null
                    ? OptionsTradingPairIdentify(
                        feedId: pair.feedId,
                        baseAsset: pair.baseAsset,
                      )
                    : null,
              );
              if (newPairDetail != null) {
                selectedPairVM.switchAsset(newPairDetail.pair);
              }
            },
            onBalanceTap: () {
              Get.find<MainController>().goToAccount();
            },
            asset: pair?.baseAsset ?? "--",
            pairName: pair?.pairName ?? "--",
            iconUrl: pair?.iconUrl,
            currentPrice: candlesVM.currentPrice,
            canTrade: canTrade,
            pipSize: pair?.pipSize ?? 2,
            balance: tokenPositionService.totalAssetValue,
          );
        },
      ),
    );
  }

  Widget _buildCandlesChart(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        ChartSettingBar(
          currentTimeBar: candlesVM.currentTimeBar,
          chartStyleNotifier: chartStyleNotifier,
          onChartStyleSelected: _onChartStyleSelected,
          onTapTimeBar: _onTimeBarSelected,
        ),
        Expanded(
            child: Stack(children: [
          _buildChart(context),
          _buildLivePositionBar(context),
          // Positioned(
          //   left: 8,
          //   bottom: 24,
          //   child: ChartSettingVerticalMenu(
          //     chartStyleNotifier: chartStyleNotifier,
          //     onChartStyleSelected: _onChartStyleSelected,
          //     currentTimeBar: candlesVM.currentTimeBar,
          //     onTapTimeBar: _onTimeBarSelected,
          //   ),
          // ),
        ])),
        const Divider(),
        _buildTradePaceOrderPanel(context),
      ],
    );
  }

  void _onTimeBarSelected(TimeBar timeBar) {
    var chartStyle = chartStyleNotifier.value;
    // 1秒周期强制使用线图
    if (timeBar == TimeBar.s1 && !chartStyle.isLine) {
      var lineChartHasArea = settingsStore.getLineChartHasArea();
      if (lineChartHasArea) {
        chartStyle = OptionsChartStyle.area;
      } else {
        chartStyle = OptionsChartStyle.line;
      }
      chartStyleNotifier.value = chartStyle;
      settingsStore.setHighLowChartStyle(chartStyle);
    }
    candlesVM.switchKlineTimeBar(timeBar);
  }

  /// 选择图表样式
  void _onChartStyleSelected(OptionsChartStyle chartStyle) {
    chartStyleNotifier.value = chartStyle;
    settingsStore.setHighLowChartStyle(chartStyle);

    // 1s 周期不支持 candles，自动切换到 5s
    if (candlesVM.currentTimeBar.value == TimeBar.s1 &&
        chartStyle == OptionsChartStyle.candles) {
      candlesVM.switchKlineTimeBar(TimeBar.s5);
    }
  }

  /// 构建 Live Position Bar
  Widget _buildLivePositionBar(BuildContext context) {
    return ValueListenableBuilder4(
      first: gameStatusVM.openedPositions,
      second: gameStatusVM.displaySettledEvents,
      third: selectedPairVM.currentPair,
      fourth: _chartConfigStore.configNotifier,
      builder:
          (context, openedPositions, settledEvents, currentPair, config, _) {
        if (currentPair == null) return Dimens.emptyBox;

        final asset = currentPair.baseAsset;
        return LivePositionBar(
          currentPrice: gameStatusVM.getPriceNotifier(asset),
          openedPositions: openedPositions,
          settledEvents: settledEvents,
          currentAsset: asset,
          livePositionBarVM: livePositionBarVM,
          onlyShowProcessing: !config.showLivePositionsBar,
          onActiveItemTap: (position) {
            showActivePositionDetails(context, position);
          },
        );
      },
    );
  }

  /// 构建K线图表
  Widget _buildChart(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: ValueListenableBuilder3(
            first: gameStatusVM.openedPositions,
            second: selectedPairVM.currentPair,
            third: candlesVM.isLiveNotifier,
            builder: (context, openedPositions, currentPair, isLive, child) {
              return StreamBuilder(
                stream: candlesVM.candlesStream,
                builder: (context, snapshot) {
                  if (currentPair == null) return Dimens.emptyBox;
                  final candles = snapshot.data ?? [];
                  if (candles.isEmpty) return Dimens.emptyBox;
                  return Stack(
                    children: [
                      ClipRect(
                        child: _buildTradeChart(
                          context,
                          candles: candles,
                          currentPair: currentPair,
                          openedPositions: openedPositions,
                          isLive: isLive,
                        ),
                      ),
                      const Positioned(
                        left: 10,
                        top: 10,
                        child: ChartPriceSourceMark(),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
        Positioned.fill(
          child: ValueListenableBuilder2(
            first: candlesVM.initialDataState,
            second: candlesVM.hasCandles,
            builder: (context, uiState, hasCandles, child) {
              return ChartStateOverlay(
                uiState: uiState,
                hasCandles: hasCandles,
              );
            },
          ),
        ),
      ],
    );
  }

  /// 构建 TradeChart 组件
  Widget _buildTradeChart(
    BuildContext context, {
    required List<Candle> candles,
    required OptionsTradingPair currentPair,
    required List<OpenedPosition> openedPositions,
    required bool isLive,
  }) {
    return ValueListenableBuilder<OptionsChartConfig>(
      valueListenable: _chartConfigStore.configNotifier,
      builder: (context, chartConfig, _) {
        return ValueListenableBuilder6(
          first: candlesVM.noMoreHistoryNotifier,
          second: chartStyleNotifier,
          third: candlesVM.currentTimeBar,
          fourth: premiumVM.premium,
          fifth: gameStatusVM.displaySettledEvents,
          sixth: selectedPairVM.canTradeNotifier,
          builder: (
            context,
            noMoreHistory,
            chartStyle,
            currentTimeBar,
            premium,
            displaySettledEvents,
            canTrade,
            child,
          ) {
            final annotationBuilder = ChartAnnotationBuilder(
              pipSize: currentPair.pipSize,
              granularityMs: candlesVM.granularityMs,
              showCountdown: chartConfig.showCountdown,
              showLongEntryPrice: chartConfig.showLongEntryPrice,
              showShortEntryPrice: chartConfig.showShortEntryPrice,
              showSettlementLine: chartConfig.showSettlementLine,
              showCurrentEpochLine: chartConfig.showCurrentEpochLine,
              entryPriceYAxisAdaptive: chartConfig.entryPriceYAxisAdaptive,
              settlementXAxisAdaptive: chartConfig.settlementXAxisAdaptive,
              latestPriceLineFullScreen: chartConfig.latestPriceLineFullScreen,
            );

            // 双击快捷下单开关
            final enableDoubleTapOrder =
                canTrade && chartConfig.showDoubleClickQuickOrder;

            return TradeChart(
              mainSeries: _chartConfigBuilder.getDataSeries(
                context: context,
                candles: candles,
                chartStyle: chartStyle,
              ),
              onCrosshairTickEpochChanged: (epoch) {
                if (epoch != null) {
                  HapticFeedbackUtils.selectionClick();
                }
              },
              chartAxisConfig: _chartConfigBuilder.buildChartAxisConfig(
                lastCandle: candles.last,
                currentTimeBar: candlesVM.currentTimeBar.value,
              ),
              pipSize: currentPair.pipSize,
              granularity: candlesVM.granularityMs,
              controller: _chartController,
              isLive: isLive,
              showCurrentTickBlinkAnimation: canTrade,
              theme:
                  getCustomChartTheme(context, showGrid: chartConfig.showGrid),
              annotations: annotationBuilder.buildAnnotations(
                context: context,
                candles: candles,
                chartStyle: chartStyle,
                canTrade: canTrade,
                premium: premium,
                settlementTime: _settlementTime,
                currentAsset: currentPair.baseAsset,
                openedPositions: openedPositions,
              ),
              onVisibleAreaChanged: (leftEpoch, rightEpoch) {
                if (candles.isNotEmpty &&
                    leftEpoch < candles.first.epoch &&
                    !candlesVM.initialDataState.value.isLoading &&
                    !candlesVM.historyDataState.value.isLoading) {
                  candlesVM.loadHistoryCandles();
                }
              },
              activeSymbol: currentPair.baseAsset,
              markerSeries: _positionMarkerBuilder.buildMarkerSeries(
                openedPositions: openedPositions,
                displaySettledEvents: displaySettledEvents,
                currentAsset: currentPair.baseAsset,
                candles: candles,
              ),
              showCrosshair: true,
              crosshairVariant: chartStyle.isLine
                  ? CrosshairVariant.smallScreen
                  : CrosshairVariant.largeScreen,
              useDrawingToolsV2: true,
              showLoadingAnimationForHistoricalData: !noMoreHistory,
              chartLowLayerConfig: _chartConfigBuilder.buildChartLowLayerConfig(
                context: context,
                candles: candles,
                canTrade: canTrade,
                settlementTime: _settlementTime,
                showSettlementLine: chartConfig.showSettlementLine,
                showCurrentEpochLine: chartConfig.showCurrentEpochLine,
              ),
              currentPrice: candles.last.close,
              onDoubleTapAbovePrice: enableDoubleTapOrder
                  ? (quote) {
                      logger.d('双击看涨开单，点击位置价格: $quote');
                      HapticFeedbackUtils.willRefresh();
                      _tradePanelController.triggerHigher();
                    }
                  : null,
              onDoubleTapBelowPrice: enableDoubleTapOrder
                  ? (quote) {
                      logger.d('双击看跌开单，点击位置价格: $quote');
                      HapticFeedbackUtils.willRefresh();
                      _tradePanelController.triggerLower();
                    }
                  : null,
            );
          },
        );
      },
    );
  }

  Widget _buildTradePaceOrderPanel(BuildContext context) {
    final tokenPositionService = injector<TokenPositionService>();
    return ValueListenableBuilder3(
      first: selectedPairVM.currentPair,
      second: premiumVM.stakeAmountRange,
      third: selectedPairVM.canTradeNotifier,
      builder: (context, currentPair, minMaxStakeAmount, canTrade, child) {
        return TradePaceOrderPanel(
          controller: _tradePanelController,
          premium: premiumVM.premium,
          balance: tokenPositionService.totalAssetValue,
          canTrade: canTrade,
          tradingSchedule: currentPair?.tradingSchedule,
          leverageMax: currentPair?.leverageMax.toDouble() ?? 100.0,
          minAmount: minMaxStakeAmount.min,
          maxAmount: minMaxStakeAmount.max,
          onHigherPressed: (data) {
            _openPositionV2(data, isHigh: true);
          },
          onLowerPressed: (data) {
            _openPositionV2(data, isHigh: false);
          },
          lastBeat: candlesVM.lastBeat,
          onPayoutMultiplierChanged: (payoutMultiplier) {
            _payoutMultiplier = payoutMultiplier;
            _onPriceOrParamsChanged();
          },
          onSettleTimeChanged: (durationSeconds, settleTime) {
            if (durationSeconds != null) {
              _durationSecs = durationSeconds;
              _settlementTime = SettlementTime.fromDurationSeconds(
                durationSeconds,
                id: "duration_$durationSeconds",
              );
              _onPriceOrParamsChanged();
            } else if (settleTime != null) {
              final endTimestamp = settleTime.millisecondsSinceEpoch;
              final startTimestamp = DateTime.now().millisecondsSinceEpoch;
              final durationSeconds = (endTimestamp - startTimestamp) ~/ 1000;
              _durationSecs = durationSeconds;
              _settlementTime = SettlementTime.fromSettleTime(
                settleTime,
                id: settleTime.millisecondsSinceEpoch.toString(),
              );
              _onPriceOrParamsChanged();
            }
          },
        );
      },
    );
  }

  // ==================== 事件处理 ====================

  /// 点击持仓标记时的回调
  void _onMarkerTap({
    required OpenedPosition position,
    required String positionId,
    required String amountText,
  }) {
    // setState(() {
    //   if (_tickMarkerIconPainter.isActiveMarker(positionId)) {
    //     _tickMarkerIconPainter.clearActiveMarker();
    //   } else {

    //   }
    // });
    showActivePositionDetails(context, position);
  }

  void showActivePositionDetails(
      BuildContext context, OpenedPosition position) async {
    _tickMarkerIconPainter.setActiveMarker(position.id, null);
    await showActivePositionDetailsSheet(
      context,
      vo: OpenedPositionVO.fromOpenedPosition(position),
      currentPriceNotifier:
          gameStatusVM.getPriceNotifier(position.tradingPair.baseAsset),
      estimateNotifier: gameStatusVM.getEstimateNotifier(position.id),
      closeStateNotifier: closePositionVM.getStateNotifier(position.id),
      openedPositionsNotifier: gameStatusVM.openedPositions,
      onSellTap: () {
        _closePosition(position);
      },
      initialExpanded: false,
      expandable: true,
    );
    _tickMarkerIconPainter.clearActiveMarker();
  }

  void _closePosition(OpenedPosition position) {
    closePositionVM
        .closePosition(
            positionId: position.id, asset: position.tradingPair.baseAsset)
        .ignore();
  }

  /// 下单
  Future<void> _openPositionV2(
    TradePaceOrderData data, {
    required bool isHigh,
  }) async {
    final currentPair = selectedPairVM.currentPair.value;
    if (currentPair == null) return;

    // Pre-flight check: verify sufficient USDC balance before hitting the API.
    final balance = injector<TokenPositionService>().totalAssetValue.value;
    if (data.amount > balance) {
      AppToastManager.showFailed(title: 'Insufficient balance');
      return;
    }

    // 添加 Processing 状态
    final processingId = livePositionBarVM.addProcessingPosition(
      isHigh: isHigh,
      amount: data.amount.toStringAsFixed(2),
      tradingPairBaseAsset: currentPair.baseAsset,
      endTime: data.endTimeSecs,
    );

    _trackBetClick(data,
        isHigh: isHigh, asset: currentPair.baseAsset, positionId: processingId);

    void onFailed(Object error, [StackTrace? stackTrace]) {
      livePositionBarVM.removeProcessingPosition(processingId);
      logger.e(
        "options_trade_page.dart: _openPosition failed",
        error: error,
        stackTrace: stackTrace,
      );
      // 检测 "Asset is not active" 错误，刷新币对状态（DB 更新后会自动传导到 currentPair）
      if (_isAssetNotActiveError(error)) {
        _optionsTradingPairsVM.refreshTradingPairs();
      }
      if (context.mounted) {
        HapticFeedbackUtils.vibration(HapticsType.error);
        _showErrorSnackbar(
          'Failed to open position',
          ErrorHandler.getMessage(context, error),
        );
      }
    }

    try {
      // 1. prepare：服务端仅 fee_payer 签名，back_authority 留到 submit 阶段签
      final prepareResp = await openPositionVM.preparePosition(
        expiryType: data.expiryType,
        durationSeconds: data.duration.seconds,
        settleTime: data.settleTime,
        payoutMultiplier: data.payoutMultiplier,
        amount: data.amount,
        asset: currentPair.baseAsset,
        isHigh: isHigh,
        positionId: processingId,
      );

      // 2. Turnkey 签名（user）
      final signResult =
          await openPositionVM.signTransaction(prepareResp.unsignedTx);

      // 3. submit：服务端补签 back_authority + send_and_confirm 上链
      //    必须在 prepare 后 expires_in（5s）内完成，否则服务端返回 Request expired
      final submitResp = await openPositionVM.submitPosition(
        requestId: prepareResp.requestId,
        unsignedTxHex: prepareResp.unsignedTx,
        signedTxHex: signResult.signedTransaction,
      );
      logger.d('Position confirmed on-chain, tx_hash: ${submitResp.txHash}');

      // 兜底：12s 内 WS 仍未把这单同步进 openedPositions，主动拉一次 REST；
      // 若 REST 也查不到则在 VM 内强制移除 processing，避免 UI 一直 loading
      livePositionBarVM.armConfirmationTimeout(
        processingId,
        onTimeout: () async {
          logger.w(
            'options_trade_page.dart: WS confirmation timeout, fallback to REST refresh, id=$processingId',
          );
          await gameStatusVM.fetchInitialPositions();
          // 直接读最新的 openedPositions（fetch 后已同步更新，无需等 rebuild）
          return gameStatusVM.openedPositions.value
              .any((p) => p.id == processingId);
        },
        onForceRemove: () {
          logger.e(
            'options_trade_page.dart: order confirmation force-removed, id=$processingId',
          );
          _showErrorSnackbar(
            'Order confirmation timeout',
            'Server did not confirm in time. Your order may not have been placed.',
          );
        },
      );
    } catch (error, stackTrace) {
      onFailed(error, stackTrace);
    }
  }

  /// 下单
  Future<void> _openPositionV1(
    TradePaceOrderData data, {
    required bool isHigh,
  }) async {
    final currentPair = selectedPairVM.currentPair.value;
    if (currentPair == null) return;

    // Pre-flight check: verify sufficient USDC balance before hitting the API.
    final balance = injector<TokenPositionService>().totalAssetValue.value;
    if (data.amount > balance) {
      AppToastManager.showFailed(title: 'Insufficient balance');
      return;
    }

    // 添加 Processing 状态
    final processingId = livePositionBarVM.addProcessingPosition(
      isHigh: isHigh,
      amount: data.amount.toStringAsFixed(2),
      tradingPairBaseAsset: currentPair.baseAsset,
      endTime: data.settleTime != null
          ? data.settleTime!.millisecondsSinceEpoch ~/ 1000
          : (DateTime.now().millisecondsSinceEpoch ~/ 1000) +
              data.duration.seconds,
    );

    _trackBetClick(data,
        isHigh: isHigh, asset: currentPair.baseAsset, positionId: processingId);

    void onFailed(Object error, [StackTrace? stackTrace]) {
      livePositionBarVM.removeProcessingPosition(processingId);
      logger.e(
        "options_trade_page.dart: _openPosition failed",
        error: error,
        stackTrace: stackTrace,
      );
      // 检测 "Asset is not active" 错误，刷新币对状态（DB 更新后会自动传导到 currentPair）
      if (_isAssetNotActiveError(error)) {
        _optionsTradingPairsVM.refreshTradingPairs();
      }
      if (context.mounted) {
        HapticFeedbackUtils.vibration(HapticsType.error);
        _showErrorSnackbar(
          'Failed to open position',
          ErrorHandler.getMessage(context, error),
        );
      }
    }

    try {
      final positionResponse = await openPositionVM.openPosition(
        expiryType: data.expiryType,
        durationSeconds: data.duration.seconds,
        settleTime: data.settleTime,
        payoutMultiplier: data.payoutMultiplier,
        amount: data.amount,
        asset: currentPair.baseAsset,
        isHigh: isHigh,
        positionId: processingId,
      );

      // 1. 签名交易
      final signResult =
          await openPositionVM.signTransaction(positionResponse.signedTx);

      // 2. 广播交易到 Solana 网络
      final txSignature =
          await openPositionVM.sendTransaction(signResult.signedTransaction);
      logger.d('Transaction broadcasted, signature: $txSignature');
    } catch (error, stackTrace) {
      onFailed(error, stackTrace);
    }
  }

  /// 埋点：买涨/买跌按钮点击，与 Web 端 payload 结构对齐
  void _trackBetClick(
    TradePaceOrderData data, {
    required bool isHigh,
    required String asset,
    required String positionId,
  }) {
    final isSingle = data.expiryType == OptionsTimeMode.timer;
  }

  /// 检测后端是否返回了 "Asset is not active" 类似的错误
  bool _isAssetNotActiveError(Object error) {
    if (error is DioException && error.type == DioExceptionType.badResponse) {
      final data = error.response?.data;
      if (data is Map<String, dynamic>) {
        final message = data["message"];
        if (message is String && message.contains("not active")) {
          return true;
        }
      }
    }
    return false;
  }

  void _showErrorSnackbar(String title, String message) {
    AppToastManager.showFailed(
      title: title,
      subtitle: message,
    );
  }
}
