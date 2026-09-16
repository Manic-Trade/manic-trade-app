import 'package:easy_refresh/easy_refresh.dart';
import 'package:finality/common/utils/color_scheme_extensions.dart';
import 'package:finality/common/utils/value_listenable_removable.dart';
import 'package:finality/common/widgets/touchable.dart';
import 'package:finality/core/error/exception_handler.dart';
import 'package:finality/data/drift/entities/options_trading_pair.dart';
import 'package:finality/data/network/model/manic/position_history_item.dart';
import 'package:finality/domain/options/entities/opened_position.dart';
import 'package:finality/features/highlow/trading_pairs/vm/options_trading_pairs_vm.dart';
import 'package:finality/features/main/main_controller.dart';
import 'package:finality/features/positions/details/active_position_details_sheet.dart';
import 'package:finality/features/positions/details/settled_position_details_sheet.dart';
import 'package:finality/features/positions/item_widgets/active_position_list_item.dart';
import 'package:finality/features/positions/item_widgets/active_positions_summary_bar.dart';
import 'package:finality/features/positions/item_widgets/settled_position_list_item.dart';
import 'package:finality/features/positions/model/history_position_vo.dart';
import 'package:finality/features/positions/model/opened_position_vo.dart';
import 'package:finality/features/positions/settled_positions_screen.dart';
import 'package:finality/features/positions/vm/close_position_vm.dart';
import 'package:finality/features/positions/vm/opened_positions_vm.dart';
import 'package:finality/features/positions/vm/trading_history_recent_vm.dart';
import 'package:finality/features/positions/widgets/empty_active_positions.dart';
import 'package:finality/features/positions/widgets/error_settled_positions.dart';
import 'package:finality/generated/assets.dart';
import 'package:finality/theme/attrs/text_color_theme.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:store_scope/store_scope.dart';

/// Positions 页面
///
/// 包含两个区块：
/// 1. Open Position - 活跃仓位列表（含汇总栏）
/// 2. Trading History - 最近 5 条已结算记录
class PositionsPage extends StatefulWidget {
  const PositionsPage({super.key});

  @override
  State<PositionsPage> createState() => _PositionsPageState();
}

class _PositionsPageState extends State<PositionsPage> with ScopedStateMixin {
  late final OpenedPositionsVM _openedPositionsVM;
  late final ClosePositionVM _closePositionVM;
  late final TradingHistoryRecentVM _tradingHistoryRecentVM;
  late final OptionsTradingPairsVM _optionsTradingPairsVM;

  /// 缓存 tradingPair notifier
  final Map<String, ValueNotifier<OptionsTradingPair?>> _tradingPairNotifiers =
      {};
  Removable? _tradingPairsRemovable;

  @override
  void initState() {
    super.initState();
    _openedPositionsVM =
        context.store.bindWithScoped(openedPositionsVMProvider, this);
    _closePositionVM =
        context.store.bindWithScoped(closePositionVMProvider, this);
    _tradingHistoryRecentVM =
        context.store.bindWithScoped(tradingHistoryRecentVMProvider, this);
    _optionsTradingPairsVM =
        context.store.bindWithScoped(optionsTradingPairsVMProvider, this);

    // 监听交易对数据变化，更新 tradingPair notifier
    _tradingPairsRemovable =
        _optionsTradingPairsVM.tradingPairsState.listen((state) {
      state.valueOrFallback?.forEach((element) {
        _getTradingPairNotifier(element.raw.pair.baseAsset).value =
            element.raw.pair;
      });
    }, immediate: true);
  }

  @override
  void dispose() {
    _tradingPairsRemovable?.remove();
    super.dispose();
  }

  ValueNotifier<OptionsTradingPair?> _getTradingPairNotifier(String asset) {
    return _tradingPairNotifiers.putIfAbsent(
      asset,
      () => ValueNotifier(null),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: ValueListenableBuilder(
            valueListenable: _openedPositionsVM.openedPositions,
            builder: (context, positions, child) {
              return _buildOpenPositionTitle(context, positions.length);
            }),
      ),
      body: SafeArea(
        child: EasyRefresh.builder(
          onRefresh: () async {
            await Future.wait([
              _openedPositionsVM.refresh(),
              _tradingHistoryRecentVM.refreshRecentHistory(),
            ]);
          },
          childBuilder: (context, physics) {
            return CustomScrollView(
              // 用 EasyRefresh 提供的 physics 作为基底（保留刷新指示器联动），
              // 叠加 RangeMaintainingScrollPhysics：进行中订单批量结算时
              // Open Position section 会骤然收缩，maxScrollExtent 缩小后
              // 自动把 pixels 拉回合法范围，避免 overscroll 断言
              physics: const RangeMaintainingScrollPhysics().applyTo(physics),
              slivers: [
                // Open Position 区块
                _buildOpenPositionSection(),
                // Trading History 区块
                _buildTradingHistorySection(),
                // 底部间距
                const SliverToBoxAdapter(child: Dimens.vGap32),
              ],
            );
          },
        ),
      ),
    );
  }

  // ==================== Open Position 区块 ====================

  Widget _buildOpenPositionSection() {
    return SliverToBoxAdapter(
      child: ValueListenableBuilder(
        valueListenable: _openedPositionsVM.openedPositions,
        builder: (context, positions, _) {
          // 用 AnimatedSize 平滑高度变化，避免批量结算时 list 瞬间塌陷
          // 引发 CustomScrollView maxScrollExtent 突变 → 物理引擎 overscroll 断言
          return AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            alignment: Alignment.topCenter,
            child: Padding(
              padding: Dimens.edgeInsetsH16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: positions.isNotEmpty
                    ? [
                        ActivePositionsSummaryBar(
                          investedNotifier: _openedPositionsVM
                              .totalPendingPositionAssetValue,
                          estPayoutNotifier: _openedPositionsVM.totalEstPayout,
                        ),
                        Dimens.vGap8,
                        _buildActivePositionsList(context, positions),
                        Dimens.vGap24,
                      ]
                    : [
                        EmptyActivePositions(onGoToTrade: _goToTrade),
                        Dimens.vGap24,
                      ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// "Open Position · {count}" 标题
  Widget _buildOpenPositionTitle(BuildContext context, int count) {
    return Text(
      'Open Position${count > 0 ? ' · $count' : ''}',
      style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: context.textColorTheme.textColorPrimary,
          height: 1.1),
    );
  }

  /// 活跃仓位列表
  Widget _buildActivePositionsList(
    BuildContext context,
    List<OpenedPosition> positions,
  ) {
    return Column(
      children: positions.map((position) {
        final vo = OpenedPositionVO.fromOpenedPosition(position);
        var currentPriceNotifier =
            _openedPositionsVM.getPriceNotifier(vo.baseAsset);
        var estimateNotifier =
            _openedPositionsVM.getEstimateNotifier(vo.positionId);
        var stateNotifier = _closePositionVM.getStateNotifier(vo.positionId);
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: ActivePositionListItem(
            key: ValueKey(vo.positionId),
            vo: vo,
            currentPriceNotifier: currentPriceNotifier,
            estimateNotifier: estimateNotifier,
            closeStateNotifier: stateNotifier,
            onSellTap: () => _onSellTap(vo),
            onTap: () => showActivePositionDetailsSheet(context,
                vo: vo,
                openedPositionsNotifier: _openedPositionsVM.openedPositions,
                currentPriceNotifier: currentPriceNotifier,
                estimateNotifier: estimateNotifier,
                closeStateNotifier: stateNotifier,
                onSellTap: () => _onSellTap(vo),
                initialExpanded: true,
                expandable: false),
          ),
        );
      }).toList(),
    );
  }

  void _onSellTap(OpenedPositionVO vo) {
    _closePositionVM
        .closePosition(positionId: vo.positionId, asset: vo.baseAsset)
        .ignore();
  }

  void _goToTrade() {
    if (Get.isRegistered<MainController>()) {
      Get.find<MainController>().goToTrade();
    }
  }

  // ==================== Trading History 区块 ====================

  Widget _buildTradingHistorySection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: Dimens.edgeInsetsH16,
        child: ValueListenableBuilder(
          valueListenable: _tradingHistoryRecentVM.recentHistoryState,
          builder: (context, state, _) {
            return state.buildWidget(
              onLoading: (_) => _buildTradingHistoryLoading(context),
              onSuccess: (success) =>
                  _buildTradingHistoryContent(context, success.value),
              onFailure: (failure) => _buildTradingHistoryError(
                context,
                failure.retry,
                ErrorHandler.getMessage(context, failure.throwable),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTradingHistoryHeader(BuildContext context, bool showToAll) {
    return SizedBox(
      height: 56,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Trading History',
            style: TextStyle(
              fontSize: 20,
              height: 1.1,
              fontWeight: FontWeight.w600,
              color: context.textColorTheme.textColorPrimary,
            ),
          ),
          if (showToAll)
            Touchable.plain(
              onTap: _goToAllHistory,
              child: Row(
                children: [
                  Text(
                    'All History',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: context.textColorTheme.textColorTertiary,
                    ),
                  ),
                  Dimens.hGap4,
                  SvgPicture.asset(
                    Assets.svgsIcArrowRightCommonSmall,
                    color: context.textColorTheme.textColorTertiary,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTradingHistoryLoading(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsetsGeometry.all(20),
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: context.textColorTheme.textColorTertiary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTradingHistoryContent(
    BuildContext context,
    List<PositionHistoryItem> items,
  ) {
    if (items.isEmpty) {
      return Dimens.emptyBox;
    }

    // 取最近 5 条已结算记录
    var recentItems = items.take(5).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTradingHistoryHeader(context, items.length > 5),
        // 已结算记录列表
        ...recentItems.map((item) {
          final vo = HistoryPositionVO.fromPositionHistoryItem(
            item,
            _getTradingPairNotifier(item.asset),
          );
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: SettledPositionListItem(
              item: vo,
              onTap: () {
                showSettledPositionDetailsSheet(context, item: vo, isAgent: false);
              },
            ),
          );
        }),
        if (items.length > 5) _buildShowAllHistoryButton(context),
      ],
    );
  }

  Widget _buildTradingHistoryError(
    BuildContext context,
    Function()? retry,
    String message,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTradingHistoryHeader(context, false),
        ErrorSettledPositions(onRetry: retry, message: message),
      ],
    );
  }

  /// "Show All History" 按钮
  Widget _buildShowAllHistoryButton(BuildContext context) {
    return Touchable.plain(
      onTap: _goToAllHistory,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: context.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: context.colorScheme.outlineVariant,
            width: 0.5,
          ),
        ),
        child: Center(
          child: Text(
            'Show All History',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: context.textColorTheme.textColorTertiary,
            ),
          ),
        ),
      ),
    );
  }

  void _goToAllHistory() {
    Get.to(() => const SettledPositionsScreen());
  }
}
