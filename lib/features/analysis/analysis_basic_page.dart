import 'package:finality/features/analysis/vm/analysis_vm.dart';
import 'package:finality/features/analysis/models/analysis_vo.dart';
import 'package:finality/features/analysis/share/analysis_share_sheet.dart';
import 'package:finality/features/analysis/widgets/basic/activity_calendar.dart';
import 'package:finality/features/analysis/widgets/basic/premium_upsell_card.dart';
import 'package:finality/features/analysis/widgets/basic/win_rate_card.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/material.dart';

/// BASIC 模式的分析页面内容
class AnalysisBasicPage extends StatelessWidget {
  final AnalysisVM vm;
  final ScrollPhysics physics;

  const AnalysisBasicPage({
    super.key,
    required this.vm,
    required this.physics,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final winRateVO = vm.winRateVO;
    final showUpsell = vm.userTier == UserTier.basic;
    return Stack(
      children: [
        ListView(
          physics: physics,
          padding: EdgeInsets.only(bottom: showUpsell ? 240 : 40),
          children: [
            Dimens.vGap6,
            WinRateCard(
              data: winRateVO,
              onShareTap: () {
                _onShareTap(context, winRateVO);
              },
            ),
            Dimens.vGap16,
            ActivityCalendar(
              activities: vm.activityList,
              month: now,
            ),
            Dimens.vGap16,
          ],
        ),
        if (showUpsell)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                PremiumUpsellCard(
                  onDepositTap: () {},
                ),
                Dimens.safeBottomSpace,
              ],
            ),
          ),
      ],
    );
  }

  void _onShareTap(BuildContext context, WinRateVO winRateVO) {
    showAnalysisShareSheet(
      context,
      winRateVO,
      timeRange: vm.selectedTimeRange.value,
      modeFilter: vm.selectedMode.value,
      asset: vm.selectedPair.value?.baseAsset,
    );
  }
}
