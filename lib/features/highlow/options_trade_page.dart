import 'package:deriv_chart/deriv_chart.dart';
import 'package:finality/common/toast/app_toast_manager.dart';
import 'package:finality/common/utils/haptic_feedback_utils.dart';
import 'package:finality/common/utils/value_listenable_removable.dart';
import 'package:finality/common/widgets/cupertion_refresh_sliver.dart';
import 'package:finality/core/error/exception_handler.dart';
import 'package:finality/core/logger.dart';
import 'package:finality/core/notifier/multi_value_listenable_builder.dart';
import 'package:finality/data/drift/options_database.dart';
import 'package:finality/di/injector.dart';
import 'package:finality/domain/options/entities/opened_position.dart';
import 'package:finality/domain/options/entities/options_trading_pair_identify.dart';
import 'package:finality/domain/options/entities/time_bar.dart';
import 'package:finality/features/highlow/chart/builds/chart_annotation_builder.dart';
import 'package:finality/features/highlow/chart/builds/chart_config_builder.dart';
import 'package:finality/features/highlow/chart/custom_chart_theme.dart';
import 'package:finality/features/highlow/chart/options_chart_style.dart';
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
import 'package:finality/features/highlow/viewmodel/deriv_chart_candles_vm.dart';
import 'package:finality/features/highlow/viewmodel/premium_vm.dart';
import 'package:finality/features/positions/vm/opened_positions_vm.dart';
import 'package:finality/features/positions/vm/place_order_vm.dart';
import 'package:finality/routes/app_pages.dart';
import 'package:finality/services/wallet/token_position_service.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:store_scope/store_scope.dart';

/// # Binary Options Trading Screen
///
/// The main trading interface of Manic Trade. Displays a real-time candlestick
/// chart with open position markers and a bottom panel for placing HIGHER/LOWER
/// binary option orders on Solana.
///
/// ## Screen Layout
///
/// ```
/// ┌─────────────────────────┐
/// │  AppBar (asset picker)  │
/// ├─────────────────────────┤
/// │  Chart Settings Bar     │
/// │  (timeframe, style)     │
/// ├─────────────────────────┤
/// │                         │
/// │   Candlestick Chart     │
/// │   + Position Markers    │
/// │   + Price Annotations   │
/// │                         │
/// ├─────────────────────────┤
/// │  Order Panel            │
/// │  [HIGHER]    [LOWER]    │
/// └─────────────────────────┘
/// ```
///
/// ## Reactive Data Flow
///
/// The screen coordinates multiple ViewModels and WebSocket streams:
///
/// - **DerivChartCandlesVM** – Manages candlestick data from WebSocket price
///   feeds with automatic history loading on scroll.
/// - **PremiumVM** – Computes real-time option premiums using Black-Scholes
///   digital pricing. Recalculates on every price tick or parameter change.
/// - **PlaceOrderVM** – Handles the order lifecycle: API call → Turnkey
///   signing → Solana broadcast.
/// - **OpenedPositionsVM** – Tracks open positions via WebSocket events and
///   renders entry/settlement markers on the chart.
///
/// ## Mobile Optimization
///
/// - Double-tap on chart to quick-order (HIGHER above price, LOWER below)
/// - Haptic feedback on crosshair interaction and order placement
/// - Pull-to-refresh for data sync
/// - Bounce physics for native iOS feel
class OptionsTradePage extends StatefulWidget {
  final OptionsTradingPair? tradingPair;
  const OptionsTradePage({super.key, this.tradingPair});

  @override
  State<OptionsTradePage> createState() => _OptionsTradePageState();
}

class _OptionsTradePageState extends State<OptionsTradePage>
    with ScopedStateMixin {
  // -- ViewModels (scoped to this screen's lifecycle) ------------------------

  late final DerivChartCandlesVM candlesVM;      // Candlestick data & WebSocket
  late final PlaceOrderVM openPositionVM;         // Order placement → Solana
  late final OpenedPositionsVM gameStatusVM;       // Live position tracking
  late final PremiumVM premiumVM;                  // Black-Scholes pricing

  // -- Trading Parameters (controlled by the order panel) --------------------

  double _payoutMultiplier = 1;     // Target payout multiplier (e.g. 2x)
  int _durationSecs = 60;           // Option duration in seconds
  SettlementTime? _settlementTime;  // Settlement time for chart annotations

  // -- Chart Configuration ---------------------------------------------------

  final HighLowSettingsStore settingsStore = injector<HighLowSettingsStore>();
  final OptionsChartConfigStore _chartConfigStore =
      injector<OptionsChartConfigStore>();
  final ChartController _chartController = ChartController();
  late final ValueNotifier<OptionsChartStyle> chartStyleNotifier;

  /// Custom marker painter that supports an "active" state for tapped markers,
  /// showing expanded payout info on the chart.
  final CustomTickMarkerIconPainter _tickMarkerIconPainter =
      CustomTickMarkerIconPainter();

  // -- Builders --------------------------------------------------------------

  late final PositionMarkerBuilder _positionMarkerBuilder;
  final ChartConfigBuilder _chartConfigBuilder = const ChartConfigBuilder();

  // -- Other State -----------------------------------------------------------

  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  late Removable currentAssetRemovable;

  /// Controller for the order panel — allows external triggers (e.g. chart
  /// double-tap) to invoke HIGHER/LOWER order actions.
  final TradePaceOrderPanelController _tradePanelController =
      TradePaceOrderPanelController();

  @override
  void initState() {
    super.initState();
    _initViewModels();
    _initBuilders();
    _setupListeners();
    // Preload image resources needed for exit point markers
    CustomTickMarkerIconPainter.loadImages();
  }

  void _initViewModels() {
    candlesVM = context.store
        .bindWithScoped(derivChartCandlesVMProvider(widget.tradingPair), this);
    openPositionVM = context.store.bindWithScoped(placeOrderVMProvider, this);
    gameStatusVM =
        context.store.bindWithScoped(openedPositionsVMProvider, this);
    premiumVM = context.store.bindWithScoped(premiumVMProvider, this);
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

  /// Sets up reactive listeners that trigger premium recalculation whenever
  /// the spot price, time, or trading pair changes.
  ///
  /// DESIGN: Premium is recalculated on every WebSocket price tick (~100ms)
  /// to keep the displayed barrier price and payout in sync with the market.
  /// This matches the on-chain Anchor program's pricing, so what the user
  /// sees is what they get when the transaction lands.
  void _setupListeners() {
    _onPriceOrParamsChanged();
    candlesVM.currentPrice.addListener(_onPriceOrParamsChanged);
    candlesVM.lastBeat.addListener(_onPriceOrParamsChanged);
    currentAssetRemovable = candlesVM.currentPair.listen((pair) {
      premiumVM.setTradingPair(pair);
    }, immediate: true);
  }

  /// Recalculates the option premium using Black-Scholes digital pricing.
  /// Called on every price tick and whenever the user changes duration or
  /// payout multiplier.
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
    return AppBar(
      titleSpacing: 0,
      title: ValueListenableBuilder2(
        first: candlesVM.currentPair,
        second: candlesVM.canTradeNotifier,
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
                candlesVM.switchAsset(newPairDetail.pair);
              }
            },
            onTransactionsTap: () {
              Get.toNamed(Routes.transactions);
            },
            asset: pair?.baseAsset ?? "--",
            pairName: pair?.pairName ?? "--",
            iconUrl: pair?.iconUrl,
            currentPrice: candlesVM.currentPrice,
            canTrade: canTrade,
            pipSize: pair?.pipSize ?? 2,
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
        Expanded(child: _buildChart(context)),
        const Divider(),
        _buildTradePaceOrderPanel(context),
      ],
    );
  }

  void _onTimeBarSelected(TimeBar timeBar) {
    var chartStyle = chartStyleNotifier.value;
    // 1-second timeframe forces line chart
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

  /// Select chart style
  void _onChartStyleSelected(OptionsChartStyle chartStyle) {
    chartStyleNotifier.value = chartStyle;
    settingsStore.setHighLowChartStyle(chartStyle);

    // 1s timeframe doesn't support candles, automatically switch to 5s
    if (candlesVM.currentTimeBar.value == TimeBar.s1 &&
        chartStyle == OptionsChartStyle.candles) {
      candlesVM.switchKlineTimeBar(TimeBar.s5);
    }
  }

  /// Build candlestick chart
  Widget _buildChart(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: ValueListenableBuilder3(
            first: gameStatusVM.openedPositions,
            second: candlesVM.currentPair,
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

  /// Build TradeChart component
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
          sixth: candlesVM.canTradeNotifier,
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

            // Double-tap quick order switch
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
                      logger.d('Double-tap to open HIGHER order, tapped price: $quote');
                      HapticFeedbackUtils.willRefresh();
                      _tradePanelController.triggerHigher();
                    }
                  : null,
              onDoubleTapBelowPrice: enableDoubleTapOrder
                  ? (quote) {
                      logger.d('Double-tap to open LOWER order, tapped price: $quote');
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
      first: isLoading,
      second: candlesVM.currentPair,
      third: premiumVM.stakeAmountRange,
      builder: (context, isLoading, currentPair, minMaxStakeAmount, child) {
        return TradePaceOrderPanel(
          controller: _tradePanelController,
          premium: premiumVM.premium,
          balance: tokenPositionService.totalAssetValue,
          isLoading: isLoading,
          canTrade: currentPair?.isActive ?? true,
          tradingSchedule: currentPair?.tradingSchedule,
          leverageMax: currentPair?.leverageMax.toDouble() ?? 100.0,
          minAmount: minMaxStakeAmount.min,
          maxAmount: minMaxStakeAmount.max,
          onHigherPressed: (data) {
            _openPosition(data, isHigh: true);
          },
          onLowerPressed: (data) {
            _openPosition(data, isHigh: false);
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

  // -- Event Handlers --------------------------------------------------------

  /// Toggles the active state of a position marker on the chart.
  /// When active, the marker expands to show the position's payout amount.
  void _onMarkerTap({
    required OpenedPosition position,
    required String markerId,
    required String amountText,
  }) {
    setState(() {
      if (_tickMarkerIconPainter.isActiveMarker(markerId)) {
        _tickMarkerIconPainter.clearActiveMarker();
      } else {
        _tickMarkerIconPainter.setActiveMarker(markerId, '\$$amountText');
      }
    });
  }

  /// Opens a binary option position on Solana.
  ///
  /// ### Transaction Flow (3 steps):
  ///
  /// ```
  /// 1. API Request     →  Server constructs an unsigned Solana transaction
  ///                        with the Anchor program instruction
  /// 2. Turnkey Sign    →  Transaction is signed via Turnkey's secure enclave
  ///                        (no private key touches the device)
  /// 3. Solana Broadcast →  Signed transaction is sent to Solana RPC for
  ///                        on-chain execution
  /// ```
  ///
  /// WHY this architecture: The server constructs the transaction because it
  /// holds the market maker's co-signer authority. The client signs with the
  /// user's Turnkey wallet, then broadcasts directly to Solana for minimum
  /// latency (critical for time-sensitive options trading).
  Future<void> _openPosition(
    TradePaceOrderData data, {
    required bool isHigh,
  }) async {
    final currentPair = candlesVM.currentPair.value;
    if (currentPair == null) return;

    // Pre-flight check: verify sufficient USDC balance before hitting the API.
    final balance = injector<TokenPositionService>().totalAssetValue.value;
    if (data.amount > balance) {
      AppToastManager.showFailed(title: 'Insufficient balance');
      return;
    }

    isLoading.value = true;

    void onFailed(Object error, [StackTrace? stackTrace]) {
      logger.e(
        "options_trade_page.dart: _openPosition failed",
        error: error,
        stackTrace: stackTrace,
      );
      if (context.mounted) {
        // MOBILE: Haptic error feedback for failed orders
        HapticFeedbackUtils.vibration(HapticsType.error);
        _showErrorSnackbar(
          'Failed to open position',
          ErrorHandler.getMessage(context, error),
        );
      }
    }

    try {
      // Step 1: Request the server to build an unsigned Solana transaction.
      // The server calculates the on-chain parameters (barrier price, premium,
      // settlement epoch) and constructs an Anchor CPI instruction.
      final positionResponse = await openPositionVM.openPosition(
        expiryType: data.expiryType,
        durationSeconds: data.duration.seconds,
        settleTime: data.settleTime,
        payoutMultiplier: data.payoutMultiplier,
        amount: data.amount,
        asset: currentPair.baseAsset,
        isHigh: isHigh,
      );

      if (positionResponse == null) {
        onFailed('Server returned null response');
        return;
      }

      // Step 2: Sign the transaction via Turnkey's secure enclave.
      // SECURITY: The private key never leaves Turnkey's infrastructure.
      final signResult =
          await openPositionVM.signTransaction(positionResponse.signedTx);

      // Step 3: Broadcast the signed transaction directly to Solana.
      final txSignature =
          await openPositionVM.sendTransaction(signResult.signedTransaction);
      logger.d('Transaction broadcasted, signature: $txSignature');
    } catch (error, stackTrace) {
      onFailed(error, stackTrace);
    } finally {
      isLoading.value = false;
    }
  }

  void _showErrorSnackbar(String title, String message) {
    AppToastManager.showFailed(
      title: title,
      subtitle: message,
    );
  }
}
