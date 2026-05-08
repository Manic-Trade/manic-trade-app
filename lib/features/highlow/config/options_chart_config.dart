import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'options_chart_config.g.dart';

/// Options 图表配置
///
/// 负责管理期权交易页面 K 线图表的所有显示和行为配置。
/// 使用 JSON 序列化存储，支持 copyWith 更新。
@CopyWith()
@JsonSerializable()
class OptionsChartConfig extends Equatable {
  const OptionsChartConfig({
    this.showGrid = true,
    this.showCountdown = true,
    this.showYAxisTick = true,
    this.dragZoomYAxis = true,
    this.showCurrentEpochLine = true,
    this.showSettlementLine = true,
    this.showLongEntryPrice = true,
    this.showShortEntryPrice = true,
    this.showDoubleClickQuickOrder = true,
    this.entryPriceYAxisAdaptive = true,
    this.autoSwitchToLine = false,
    this.settlementXAxisAdaptive = true,
    this.latestPriceLineFullScreen = true,
    this.useCandleColorAsLatestBg = true,
    this.showLivePositionsBar = true,
  });

  // ==================== 图表显示 ====================

  /// 显示网格线
  final bool showGrid;

  /// 显示倒计时
  final bool showCountdown;

  /// 显示当前最新的 tick 所在的时间线
  final bool showCurrentEpochLine;

  /// 显示 Y 轴刻度
  final bool showYAxisTick;

  /// 拖拽缩放 y 轴
  final bool dragZoomYAxis;

  // ==================== 合约显示 ====================

  /// 显示看多入场价
  final bool showLongEntryPrice;

  /// 显示看空入场价
  final bool showShortEntryPrice;

  /// 显示双击快捷下单
  final bool showDoubleClickQuickOrder;

  /// 显示实时持仓栏
  final bool showLivePositionsBar;

  /// 入场价 y 轴自适应
  final bool entryPriceYAxisAdaptive;

  // ==================== 图表行为 ====================

  /// 缩放时自动切换为线图
  final bool autoSwitchToLine;

  // ==================== Settlement 线 ====================

  /// Settlement 线 x 轴自适应
  final bool settlementXAxisAdaptive;

  /// 显示 Settlement Time 线
  final bool showSettlementLine;

  // ==================== latest tick  ====================

  /// 显示全屏的最新价线
  final bool latestPriceLineFullScreen;

  /// 使用蜡烛颜色作为最新价背景
  final bool useCandleColorAsLatestBg;

  // ==================== JSON 序列化 ====================

  factory OptionsChartConfig.fromJson(Map<String, dynamic> json) =>
      _$OptionsChartConfigFromJson(json);

  Map<String, dynamic> toJson() => _$OptionsChartConfigToJson(this);

  // ==================== Equatable ====================

  @override
  List<Object?> get props => [
        showGrid,
        showCountdown,
        showYAxisTick,
        dragZoomYAxis,
        showCurrentEpochLine,
        showSettlementLine,
        showLongEntryPrice,
        showShortEntryPrice,
        showDoubleClickQuickOrder,
        entryPriceYAxisAdaptive,
        autoSwitchToLine,
        settlementXAxisAdaptive,
        latestPriceLineFullScreen,
        useCandleColorAsLatestBg,
        showLivePositionsBar,
      ];
}
