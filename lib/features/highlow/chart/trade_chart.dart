import 'package:deriv_chart/deriv_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// A wrapper around the [Chart] which handles adding indicators to the chart.
class TradeChart extends StatefulWidget {
  /// Initializes
  const TradeChart({
    required this.mainSeries,
    required this.granularity,
    required this.activeSymbol,
    this.markerSeries,
    this.controller,
    this.onCrosshairAppeared,
    this.onCrosshairDisappeared,
    this.onCrosshairHover,
    this.onCrosshairTickChanged,
    this.onCrosshairTickEpochChanged,
    this.onVisibleAreaChanged,
    this.onQuoteAreaChanged,
    this.theme,
    this.isLive = false,
    this.dataFitEnabled = false,
    this.showCrosshair = true,
    this.annotations,
    this.opacity = 1.0,
    this.pipSize = 4,
    this.chartAxisConfig = const ChartAxisConfig(),
    this.drawingTools,
    this.msPerPx,
    this.minIntervalWidth = 0.8,
    this.maxIntervalWidth = 32,
    this.dataFitPadding,
    this.currentTickAnimationDuration,
    this.quoteBoundsAnimationDuration,
    this.showCurrentTickBlinkAnimation,
    this.verticalPaddingFraction,
    this.bottomChartTitleMargin,
    this.showDataFitButton,
    this.showScrollToLastTickButton,
    this.loadingAnimationColor,
    this.crosshairVariant = CrosshairVariant.smallScreen,
    this.interactiveLayerBehaviour,
    this.useDrawingToolsV2 = false,
    this.showLoadingAnimationForHistoricalData = true,
    this.chartLowLayerConfig,
    this.onDoubleTapAbovePrice,
    this.onDoubleTapBelowPrice,
    this.currentPrice,
    super.key,
  });

  /// Whether to use the new drawing tools v2 or not.
  final bool useDrawingToolsV2;

  /// Chart's main data series
  final DataSeries<Tick> mainSeries;

  /// Open position marker series.
  /// Can be [MarkerSeries] or [MarkerGroupSeries] depending on the trade type.
  final dynamic markerSeries;

  /// Current active symbol.
  final String activeSymbol;

  /// Chart's controller
  final ChartController? controller;

  /// Number of digits after decimal point in price.
  final int pipSize;

  /// For candles: Duration of one candle in ms.
  /// For ticks: Average ms difference between two consecutive ticks.
  final int granularity;

  /// Called when crosshair details appear after long press.
  final VoidCallback? onCrosshairAppeared;

  /// Called when the crosshair is dismissed.
  final VoidCallback? onCrosshairDisappeared;

  /// Called when the crosshair cursor is hovered/moved.
  final OnCrosshairHoverCallback? onCrosshairHover;

  /// Called when the selected tick/candle changes during crosshair interaction.
  final OnCrosshairTickChangedCallback? onCrosshairTickChanged;

  /// Called when the selected tick/candle epoch changes during crosshair interaction.
  final OnCrosshairTickEpochChangedCallback? onCrosshairTickEpochChanged;

  /// Called when chart is scrolled or zoomed.
  final VisibleAreaChangedCallback? onVisibleAreaChanged;

  /// Callback provided by library user.
  final VisibleQuoteAreaChangedCallback? onQuoteAreaChanged;

  /// Chart's theme.
  final ChartTheme? theme;

  /// Chart's annotations
  final List<ChartAnnotation<ChartObject>>? annotations;

  /// Configurations for chart's axes.
  final ChartAxisConfig chartAxisConfig;

  /// Whether the chart should be showing live data or not.
  /// In case of being true the chart will keep auto-scrolling when its visible
  /// area is on the newest ticks/candles.
  final bool isLive;

  /// Starts in data fit mode and adds a data-fit button.
  final bool dataFitEnabled;

  /// Chart's opacity, Will be applied on the [mainSeries].
  final double opacity;

  /// Whether the crosshair should be shown or not.
  final bool showCrosshair;

  /// Specifies the zoom level of the chart.
  final double? msPerPx;

  /// Specifies the minimum interval width
  /// that is used for calculating the maximum msPerPx.
  final double? minIntervalWidth;

  /// Specifies the maximum interval width
  /// that is used for calculating the maximum msPerPx.
  final double? maxIntervalWidth;

  /// Padding around data used in data-fit mode.
  final EdgeInsets? dataFitPadding;

  /// Duration of the current tick animated transition.
  final Duration? currentTickAnimationDuration;

  /// Duration of quote bounds animated transition.
  final Duration? quoteBoundsAnimationDuration;

  /// Whether to show current tick blink animation or not.
  final bool? showCurrentTickBlinkAnimation;

  /// Fraction of the chart's height taken by top or bottom padding.
  /// Quote scaling (drag on quote area) is controlled by this variable.
  final double? verticalPaddingFraction;

  /// Specifies the margin to prevent overlap.
  final EdgeInsets? bottomChartTitleMargin;

  /// Whether the data fit button is shown or not.
  final bool? showDataFitButton;

  /// Whether to show the scroll to last tick button or not.
  final bool? showScrollToLastTickButton;

  /// The color of the loading animation.
  final Color? loadingAnimationColor;

  /// Drawing tools
  final DrawingTools? drawingTools;

  /// The variant of the crosshair to be used.
  /// This is used to determine the type of crosshair to display.
  /// The default is [CrosshairVariant.smallScreen].
  /// [CrosshairVariant.largeScreen] is mostly for web.
  final CrosshairVariant crosshairVariant;

  /// Defines the behaviour that interactive layer should have.
  ///
  /// Interactive layer is the layer on top of the chart responsible for
  /// handling components that user can interact with them. such as cross-hair,
  /// drawing tools, etc.
  ///
  /// If not set it will be set internally to [InteractiveLayerDesktopBehaviour]
  /// on web and [InteractiveLayerMobileBehaviour] on mobile or other platforms.
  final InteractiveLayerBehaviour? interactiveLayerBehaviour;

  /// Whether to show the loading animation for historical data or not.
  final bool showLoadingAnimationForHistoricalData;

  final ChartLowLayerConfig? chartLowLayerConfig;

  /// Called when a double tap is detected above the current price line.
  /// The [quote] parameter is the price at the tap position.
  final void Function(double quote)? onDoubleTapAbovePrice;

  /// Called when a double tap is detected below the current price line.
  /// The [quote] parameter is the price at the tap position.
  final void Function(double quote)? onDoubleTapBelowPrice;

  /// The current price used to determine if the double tap is above or below.
  /// If not provided, double tap callbacks will not be triggered.
  final double? currentPrice;

  @override
  State<TradeChart> createState() => _TradeChartState();
}

class _TradeChartState extends State<TradeChart> {
  final DrawingTools _drawingTools = DrawingTools();

  late final InteractiveLayerBehaviour _interactiveLayerBehaviour;
  late AddOnsRepository<IndicatorConfig> _indicatorsRepo;

  late AddOnsRepository<DrawingToolConfig> _drawingToolsRepo;

  @override
  void initState() {
    super.initState();

    _interactiveLayerBehaviour = widget.interactiveLayerBehaviour ??
        (kIsWeb
            ? InteractiveLayerDesktopBehaviour(
                controller: InteractiveLayerController())
            : InteractiveLayerMobileBehaviour(
                controller: InteractiveLayerController()));
    _initRepos();
  }

  void _initRepos() {
    _indicatorsRepo = AddOnsRepository<IndicatorConfig>(
      createAddOn: (Map<String, dynamic> map) => IndicatorConfig.fromJson(map),
      onEditCallback: (_) {},
      sharedPrefKey: widget.activeSymbol,
    );

    _drawingToolsRepo = AddOnsRepository<DrawingToolConfig>(
      createAddOn: (Map<String, dynamic> map) =>
          DrawingToolConfig.fromJson(map),
      onEditCallback: (_) {},
      sharedPrefKey: widget.activeSymbol,
    );
  }

  @override
  Widget build(BuildContext context) => MultiProvider(
        providers: <ChangeNotifierProvider<Repository<AddOnConfig>>>[
          ChangeNotifierProvider<Repository<IndicatorConfig>>.value(
              value: _indicatorsRepo),
          ChangeNotifierProvider<Repository<DrawingToolConfig>>.value(
              value: _drawingToolsRepo),
        ],
        child: Builder(
          builder: (BuildContext context) => Stack(
            children: <Widget>[
              Chart(
                mainSeries: widget.mainSeries,
                pipSize: widget.pipSize,
                granularity: widget.granularity,
                controller: widget.controller,
                overlayConfigs: <IndicatorConfig>[
                  ...context
                      .watch<Repository<IndicatorConfig>>()
                      .items
                      .where((IndicatorConfig config) => config.isOverlay)
                ],
                bottomConfigs: <IndicatorConfig>[
                  ...context
                      .watch<Repository<IndicatorConfig>>()
                      .items
                      .where((IndicatorConfig config) => !config.isOverlay)
                ],
                drawingTools: widget.drawingTools ?? _drawingTools,
                markerSeries: widget.markerSeries,
                theme: widget.theme,
                onCrosshairAppeared: widget.onCrosshairAppeared,
                onCrosshairDisappeared: widget.onCrosshairDisappeared,
                onCrosshairHover: widget.onCrosshairHover,
                onCrosshairTickChanged: widget.onCrosshairTickChanged,
                onCrosshairTickEpochChanged: widget.onCrosshairTickEpochChanged,
                onVisibleAreaChanged: widget.onVisibleAreaChanged,
                onQuoteAreaChanged: widget.onQuoteAreaChanged,
                isLive: widget.isLive,
                dataFitEnabled: widget.dataFitEnabled,
                opacity: widget.opacity,
                annotations: widget.annotations,
                showCrosshair: widget.showCrosshair,
                indicatorsRepo: _indicatorsRepo,
                msPerPx: widget.msPerPx,
                minIntervalWidth: widget.minIntervalWidth,
                maxIntervalWidth: widget.maxIntervalWidth,
                dataFitPadding: widget.dataFitPadding,
                currentTickAnimationDuration:
                    widget.currentTickAnimationDuration,
                quoteBoundsAnimationDuration:
                    widget.quoteBoundsAnimationDuration,
                showCurrentTickBlinkAnimation:
                    widget.showCurrentTickBlinkAnimation,
                verticalPaddingFraction: widget.verticalPaddingFraction,
                bottomChartTitleMargin: widget.bottomChartTitleMargin,
                showDataFitButton: widget.showDataFitButton,
                showScrollToLastTickButton: widget.showScrollToLastTickButton,
                loadingAnimationColor: widget.loadingAnimationColor,
                chartAxisConfig: widget.chartAxisConfig,
                crosshairVariant: widget.crosshairVariant,
                interactiveLayerBehaviour: _interactiveLayerBehaviour,
                useDrawingToolsV2: widget.useDrawingToolsV2,
                showLoadingAnimationForHistoricalData:
                    widget.showLoadingAnimationForHistoricalData,
                chartLowLayerConfig: widget.chartLowLayerConfig,
                onDoubleTap: _handleDoubleTap,
              )
            ],
          ),
        ),
      );

  void _handleDoubleTap(Offset localPosition, double quote, int epoch) {
    final double? currentPrice = widget.currentPrice;
    if (currentPrice == null) return;

    if (quote > currentPrice) {
      // 双击在当前价格线上方 - 看涨
      widget.onDoubleTapAbovePrice?.call(quote);
    } else {
      // 双击在当前价格线下方 - 看跌
      widget.onDoubleTapBelowPrice?.call(quote);
    }
  }
}
