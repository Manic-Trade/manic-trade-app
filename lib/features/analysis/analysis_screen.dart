import 'dart:async';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:finality/common/utils/color_scheme_extensions.dart';
import 'package:finality/common/widgets/error_view.dart';
import 'package:finality/common/widgets/loading_view.dart';
import 'package:finality/core/notifier/multi_value_listenable_builder.dart';
import 'package:finality/core/state/ui_state.dart';
import 'package:finality/data/network/model/manic/pnl_overview_response.dart';
import 'package:finality/features/analysis/analysis_basic_page.dart';
import 'package:finality/features/analysis/analysis_premium_page.dart';
import 'package:finality/features/analysis/vm/analysis_vm.dart';
import 'package:finality/features/analysis/models/analysis_vo.dart';
import 'package:finality/features/analysis/widgets/analysis_filter_bar.dart';
import 'package:finality/theme/attrs/druk_wide_font.dart';
import 'package:finality/theme/attrs/text_color_theme.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/material.dart';
import 'package:store_scope/store_scope.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen>
    with ScopedSpaceStateMixin {
  late final AnalysisVM _vm;
  late final EasyRefreshController _controller = EasyRefreshController();
  StreamSubscription<void>? _filterChangedSub;

  @override
  void initState() {
    super.initState();
    _vm = space.bind(analysisVMProvider);
    _filterChangedSub = _vm.filterChanged.listen((_) {
      _controller.callRefresh();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _vm.initOrRefresh();
    });
  }

  @override
  void dispose() {
    _filterChangedSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF040404),
      appBar: AppBar(
        backgroundColor: const Color(0xFF040404),
        title: Column(
          children: [
            Text(
              'ANALYSIS',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: context.textColorTheme.textColorPrimary,
              ).toDrukWide(),
            ),
            Dimens.vGap2,
            _buildTierBadge(context),
          ],
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildTierBadge(BuildContext context) {
    var primary = context.colorScheme.primary;
    return ValueListenableBuilder<UiState<PnlOverviewResponse>>(
      valueListenable: _vm.dataState,
      builder: (context, state, _) {
        final tier = _vm.userTier;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
              color: Color.alphaBlend(
                  primary.withValues(alpha: 0.1), const Color(0xFF040404)),
              borderRadius: BorderRadius.circular(8),
              border: tier == UserTier.premium
                  ? Border.all(color: const Color(0x40DB8300), width: 1)
                  : null,
              boxShadow: tier == UserTier.premium
                  ? [
                      BoxShadow(
                        color: const Color(0x1ADB8300),
                        blurRadius: 14,
                      ),
                      BoxShadow(
                        color: const Color(0x40DB8300),
                        blurRadius: 6,
                      ),
                    ]
                  : null),
          child: Text(
            tier == UserTier.premium ? 'PREMIUM' : 'BASIC',
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: primary,
                letterSpacing: 1,
                height: 1.2),
          ),
        );
      },
    );
  }

  /// 根据 tier 切换整个 body 内容
  Widget _buildBody() {
    return ValueListenableBuilder<UiState<PnlOverviewResponse>>(
      valueListenable: _vm.dataState,
      builder: (context, state, _) {
        // 初始加载中，还不知道 tier
        if (!state.isSuccess) {
          return state.buildWidget(
            onLoading: (_) => const LoadingView(),
            onFailure: (failure) => ErrorView(onRetry: failure.retry),
            onSuccess: (_) => const SizedBox.shrink(),
          );
        }
        // 已知 tier，选择对应页面
        if (_vm.userTier == UserTier.premium) {
          return const AnalysisPremiumPage();
        }
        return _buildBasicBody();
      },
    );
  }

  /// Basic 模式：筛选栏 + EasyRefresh 包裹的内容
  Widget _buildBasicBody() {
    return Column(
      children: [
        _buildFilterBar(),
        Dimens.vGap10,
        Expanded(child: _buildBasicContent()),
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

  Widget _buildBasicContent() {
    return EasyRefresh.builder(
      controller: _controller,
      onRefresh: _vm.refresh,
      childBuilder: (context, physics) {
        return ValueListenableBuilder<UiState<PnlOverviewResponse>>(
          valueListenable: _vm.dataState,
          builder: (context, state, _) {
            return state.buildWidget(
              onLoading: (_) => const LoadingView(),
              onFailure: (failure) => ErrorView(onRetry: failure.retry),
              onSuccess: (_) => AnalysisBasicPage(vm: _vm, physics: physics),
            );
          },
        );
      },
    );
  }
}
