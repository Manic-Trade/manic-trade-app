import 'dart:async';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:finality/common/widgets/error_view.dart';
import 'package:finality/common/widgets/loading_view.dart';
import 'package:finality/core/notifier/multi_value_listenable_builder.dart';
import 'package:finality/core/state/ui_state.dart';
import 'package:finality/features/analysis/models/analysis_vo.dart';
import 'package:finality/features/analysis/models/premium_analysis_vo.dart';
import 'package:finality/features/analysis/share/analysis_share_sheet.dart';
import 'package:finality/features/analysis/vm/analysis_vm.dart';
import 'package:finality/features/analysis/vm/premium_analysis_vm.dart';
import 'package:finality/features/analysis/widgets/analysis_filter_bar.dart';
import 'package:finality/features/analysis/widgets/premium/directional_bias_card.dart';
import 'package:finality/features/analysis/widgets/premium/duration_efficiency_card.dart';
import 'package:finality/features/analysis/widgets/premium/hero_win_rate_card.dart';
import 'package:finality/features/analysis/widgets/premium/performance_matrix_card.dart';
import 'package:finality/features/analysis/widgets/premium/asset_exposure_card.dart';
import 'package:finality/features/analysis/widgets/premium/mode_efficiency_card.dart';
import 'package:finality/features/analysis/widgets/premium/premium_calendar_grid.dart';
import 'package:finality/features/analysis/widgets/premium/rhythm_stat_blocks.dart';
import 'package:finality/features/analysis/widgets/premium/section_title.dart';
import 'package:finality/features/analysis/widgets/premium/summary_metric_cards.dart';
import 'package:finality/features/analysis/widgets/premium/time_analysis_card.dart';
import 'package:finality/features/analysis/widgets/premium/trade_tape_bar.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/material.dart';
import 'package:store_scope/store_scope.dart';

/// PREMIUM 模式的分析页面（自包含：VM + 筛选 + 刷新 + 内容）
class AnalysisPremiumPage extends StatefulWidget {
  const AnalysisPremiumPage({super.key});

  @override
  State<AnalysisPremiumPage> createState() => _AnalysisPremiumPageState();
}

class _AnalysisPremiumPageState extends State<AnalysisPremiumPage>
    with ScopedSpaceStateMixin {
  late final PremiumAnalysisVM _vm;
  late final AnalysisVM _analysisVM;
  late final EasyRefreshController _controller = EasyRefreshController();
  StreamSubscription<void>? _filterChangedSub;

  @override
  void initState() {
    super.initState();
    _vm = space.bind(premiumAnalysisVMProvider);
    _analysisVM = space.bind(analysisVMProvider);
    _filterChangedSub = _vm.filterChanged.listen((_) {
      // 同步筛选条件到 AnalysisVM，触发 overview 接口刷新
      _analysisVM.updatePair(_vm.selectedPair.value);
      _analysisVM.updateMode(_vm.selectedMode.value);
      _analysisVM.updateTimeRange(_vm.selectedTimeRange.value);
      _analysisVM.refresh();
      _controller.callRefresh();
    });
    _vm.initOrRefresh();
  }

  @override
  void dispose() {
    _filterChangedSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildFilterBar(),
        Dimens.vGap10,
        Expanded(child: _buildContent()),
      ],
    );
  }

  Widget _buildFilterBar() {
    return ValueListenableBuilder3(
      first: _vm.selectedPair,
      second: _vm.selectedMode,
      third: _vm.selectedTimeRange,
      builder: (context, pair, mode, timeRange, _) {
        return AnalysisFilterBar(
          selectedPair: pair,
          selectedMode: mode,
          selectedTimeRange: timeRange,
          onPairChanged: _vm.updatePair,
          onModeChanged: _vm.updateMode,
          onTimeRangeChanged: _vm.updateTimeRange,
        );
      },
    );
  }

  Widget _buildContent() {
    return EasyRefresh.builder(
      controller: _controller,
      onRefresh: _vm.refresh,
      childBuilder: (context, physics) {
        return ValueListenableBuilder<UiState<PremiumAnalysisData>>(
          valueListenable: _vm.dataState,
          builder: (context, state, _) {
            return state.buildWidget(
              onLoading: (_) => const LoadingView(),
              onFailure: (failure) => ErrorView(onRetry: failure.retry),
              onSuccess: (_) => _buildSuccessContent(physics),
            );
          },
        );
      },
    );
  }

  Widget _buildSuccessContent(ScrollPhysics physics) {
    final data = _vm.data!;
    final items = _buildItems(data, _analysisVM.winRateVO.winRatePercentile);
    return ListView.builder(
      physics: physics,
      padding: const EdgeInsets.only(bottom: 40),
      itemCount: items.length,
      itemBuilder: (context, index) => items[index],
    );
  }

  /// 将所有 card 打平为独立 item，配合 ListView.builder 实现懒加载 + RepaintBoundary 隔离重绘
  List<Widget> _buildItems(PremiumAnalysisData data, int winRatePercentile) {
    return [
      Dimens.vGap6,
      const PremiumSectionTitle(
        title: 'OVERVIEW',
      ),
      Dimens.vGap16,
      Padding(
        padding: Dimens.edgeInsetsH16,
        child: RepaintBoundary(
          child: HeroWinRateCard(
            data: data.summary.winRate,
            wins: data.summary.wins,
            losses: data.summary.losses,
            winRatePercentile: winRatePercentile,
            onShareTap: () {
              _onShareTap(context, _analysisVM.winRateVO);
            },
          ),
        ),
      ),
      Dimens.vGap12,
      Padding(
        padding: Dimens.edgeInsetsH16,
        child: SummaryMetricCards(metrics: data.summary.asList),
      ),
      Dimens.vGap16,
      RepaintBoundary(child: TradeTapeBar(items: data.tradeTape)),
      Dimens.vGap16,
      Padding(
        padding: Dimens.edgeInsetsH16,
        child: RepaintBoundary(
          child: PerformanceMatrixCard(
            points: data.performancePoints,
            timeRange: _vm.selectedTimeRange.value,
          ),
        ),
      ),
      Dimens.vGap32,
      const PremiumSectionTitle(
        title: 'BEHAVIOR',
      ),
      Dimens.vGap16,
      Padding(
        padding: Dimens.edgeInsetsH16,
        child: RepaintBoundary(
          child: DirectionalBiasCard(items: data.directionalBias),
        ),
      ),
      Dimens.vGap12,
      Padding(
        padding: Dimens.edgeInsetsH16,
        child: RepaintBoundary(
          child: DurationEfficiencyCard(items: data.durationEfficiency),
        ),
      ),
      Dimens.vGap12,
      Padding(
        padding: Dimens.edgeInsetsH16,
        child: RepaintBoundary(
          child: TimeAnalysisCard(
            hourly: data.hourlyPerformance,
            weekday: data.weekdayPerformance,
          ),
        ),
      ),
      Dimens.vGap32,
      const PremiumSectionTitle(
        title: 'EXPOSURE',
      ),
      Dimens.vGap16,
      Padding(
        padding: Dimens.edgeInsetsH16,
        child: RepaintBoundary(
          child: AssetExposureCard(assets: data.assetBreakdown),
        ),
      ),
      Dimens.vGap12,
      Padding(
        padding: Dimens.edgeInsetsH16,
        child: RepaintBoundary(
          child: ModeEfficiencyCard(
            modes: data.modeEfficiency,
            insights: data.insights,
          ),
        ),
      ),
      Dimens.vGap32,
      const PremiumSectionTitle(
        title: 'RHYTHM',
      ),
      Dimens.vGap16,
      Divider(
          color: Colors.white.withValues(alpha: 0.08), height: 1, thickness: 1),
      Dimens.vGap20,
      Padding(
        padding: Dimens.edgeInsetsH16,
        child: RepaintBoundary(
          child: PremiumCalendarGrid(activities: data.activity),
        ),
      ),
      Dimens.vGap12,
      Padding(
        padding: Dimens.edgeInsetsH16,
        child: RhythmStatBlocks(stats: data.rhythmStats),
      ),
      Dimens.vGap16,
      Dimens.vGap16,
    ];
  }

  void _onShareTap(BuildContext context, WinRateVO winRateVO) {
    showAnalysisShareSheet(
      context,
      winRateVO,
      timeRange: _analysisVM.selectedTimeRange.value,
      modeFilter: _analysisVM.selectedMode.value,
      asset: _analysisVM.selectedPair.value?.baseAsset,
    );
  }
}
