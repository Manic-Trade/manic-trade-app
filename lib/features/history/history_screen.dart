import 'package:collection/collection.dart';
import 'package:finality/common/utils/color_scheme_extensions.dart';
import 'package:finality/features/history/deposit_list_page.dart';
import 'package:finality/features/history/withdraw_list_page.dart';
import 'package:finality/theme/attrs/druk_wide_font.dart';
import 'package:finality/theme/attrs/text_color_theme.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/material.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'HISTORY',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: context.textColorTheme.textColorPrimary,
            letterSpacing: 0.5,
          ).toDrukWide(),
        ),
      ),
      body: Column(
        children: [
          _buildTabBar(context, _tabController, ['Deposit', 'Withdraw']),
          Expanded(
            child: TabBarView(
              physics: const BouncingScrollPhysics(),
              controller: _tabController,
              children: [
                DepositListPage(),
                WithdrawListPage(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(
      BuildContext context, TabController tabController, List<String> types) {
    return Padding(
      padding: Dimens.edgeInsetsH12.copyWith(top: 8, bottom: 8),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          // background/secondary
          color: context.colorScheme.surface,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            // line/primary
            color: context.colorScheme.outlineVariant,
            width: 0.5,
          ),
        ),
        padding: const EdgeInsets.all(4.5),
        child: AnimatedBuilder(
          animation: tabController.animation!,
          builder: (context, child) {
            final animValue = tabController.animation!.value;
            return Stack(
              children: [
                // 滑动背景指示器
                LayoutBuilder(
                  builder: (context, constraints) {
                    final tabWidth = constraints.maxWidth / types.length;
                    return Transform.translate(
                      offset: Offset(tabWidth * animValue, 0),
                      child: Container(
                        width: tabWidth,
                        decoration: BoxDecoration(
                          color: context.colorScheme.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    );
                  },
                ),
                // Tab 文字
                Row(
                  children: types.mapIndexed((index, type) {
                    return _buildTabBarItem(
                        context, tabController, type, index);
                  }).toList(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTabBarItem(BuildContext context, TabController tabController,
      String type, int index) {
    // activity: 滑动时从 0.0（完全未选）到 1.0（完全选中）的连续值
    final activity =
        (1.0 - (tabController.animation!.value - index).abs()).clamp(0.0, 1.0);
    // 透明度：0.3（未选）～ 1.0（选中）
    final opacity = 0.3 + activity * 0.7;

    return Expanded(
      child: GestureDetector(
        onTap: () => tabController.animateTo(index),
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: Text(
            type,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: context.textColorTheme.textColorPrimary
                  .withValues(alpha: opacity),
            ),
          ),
        ),
      ),
    );
  }
}
