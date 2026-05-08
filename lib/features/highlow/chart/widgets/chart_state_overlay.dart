import 'package:finality/common/widgets/kline_empty_view.dart';
import 'package:finality/common/widgets/kline_error_view.dart';
import 'package:finality/common/widgets/kline_loading_view.dart';
import 'package:finality/core/error/exception_handler.dart';
import 'package:finality/core/state/ui_state.dart';
import 'package:finality/features/highlow/chart/widgets/chart_status_label.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/material.dart';

/// 图表状态覆盖层
/// 根据加载状态显示不同的 UI（加载中、错误、空数据等）
class ChartStateOverlay extends StatelessWidget {
  const ChartStateOverlay({
    super.key,
    required this.uiState,
    required this.hasCandles,
  });

  final UiState<bool> uiState;
  final bool hasCandles;

  @override
  Widget build(BuildContext context) {
    if (uiState.isLoading) {
      return _buildLoadingState(context);
    } else if (uiState is Failure<bool>) {
      return _buildErrorState(context, uiState as Failure<bool>);
    } else if (uiState.isSuccess && !hasCandles) {
      return const Center(child: KlineEmptyView());
    } else {
      return Dimens.emptyBox;
    }
  }

  Widget _buildLoadingState(BuildContext context) {
    if (hasCandles) {
      final isRefresh = uiState.valueOrFallback == true;
      return Center(
        child: ChartStatusLabel(
          text: isRefresh ? 'Refreshing...' : 'Connecting...',
        ),
      );
    } else {
      return Center(
        child: KlineLoadingView(
          progressBgColor: const Color(0xFF2F2F2F),
          valueColor: const Color(0xFFFFFFFF),
        ),
      );
    }
  }

  Widget _buildErrorState(BuildContext context, Failure<bool> failure) {
    if (hasCandles) {
      final isRefresh = failure.valueOrFallback == true;
      return Center(
        child: ChartStatusLabel(
          text: isRefresh
              ? 'Refreshing failed, please try again later.'
              : 'Connection lost, please try again later.',
        ),
      );
    } else {
      return Center(
        child: KlineErrorView(
          errorMessage: ErrorHandler.getMessage(context, failure.throwable),
          onRetry: failure.retry,
        ),
      );
    }
  }
}
