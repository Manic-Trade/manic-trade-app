import 'package:finality/common/utils/haptic_feedback_utils.dart';
import 'package:flutter/cupertino.dart';

class CupertinoRefreshSliver extends StatefulWidget {
  final RefreshControlIndicatorBuilder? builder;

  final RefreshCallback? onRefresh;

  final bool enabled;

  const CupertinoRefreshSliver(
      {super.key, this.builder, this.onRefresh, this.enabled = true});

  @override
  State<CupertinoRefreshSliver> createState() => _CupertinoRefreshSliverState();
}

class _CupertinoRefreshSliverState extends State<CupertinoRefreshSliver> {
  // 跟踪上一个刷新状态，用于确定何时触发振动
  RefreshIndicatorMode _previousRefreshState = RefreshIndicatorMode.inactive;

  @override
  Widget build(BuildContext context) {
    return CupertinoSliverRefreshControl(
      builder: (BuildContext context,
          RefreshIndicatorMode refreshState,
          double pulledExtent,
          double refreshTriggerPullDistance,
          double refreshIndicatorExtent) {
        if (!widget.enabled || widget.onRefresh == null) {
          return const SizedBox.shrink();
        }
        // 当状态从非 armed 变为 armed 时触发振动
        if (refreshState == RefreshIndicatorMode.armed &&
            _previousRefreshState != RefreshIndicatorMode.armed) {
          HapticFeedbackUtils.willRefresh();
        }
        // 更新上一个状态
        _previousRefreshState = refreshState;
        return widget.builder != null
            ? widget.builder!(context, refreshState, pulledExtent,
                refreshTriggerPullDistance, refreshIndicatorExtent)
            : CupertinoSliverRefreshControl.buildRefreshIndicator(
                context,
                refreshState,
                pulledExtent,
                refreshTriggerPullDistance,
                refreshIndicatorExtent);
      },
      onRefresh: widget.enabled ? widget.onRefresh : null,
    );
  }
}
