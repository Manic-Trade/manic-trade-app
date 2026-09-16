import 'package:finality/common/utils/color_scheme_extensions.dart';
import 'package:finality/common/widgets/drag_handle.dart';
import 'package:finality/common/widgets/logo_image.dart';
import 'package:finality/common/widgets/touchable.dart';
import 'package:finality/core/state/ui_data.dart';
import 'package:finality/data/drift/entities/options_trading_pair.dart';
import 'package:finality/domain/options/entities/options_trading_pair_detail.dart';
import 'package:finality/features/analysis/sheet/analysis_assets_search_bar.dart';
import 'package:finality/features/highlow/trading_pairs/models/options_trading_pair_vo.dart';
import 'package:finality/features/highlow/trading_pairs/vm/options_trading_pairs_vm.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:store_scope/store_scope.dart';

/// 资产筛选结果
/// - [tradingPair] 为 null 表示选择了 "All Assets"
/// - [tradingPair] 有值表示选择了某个具体资产
/// - show 函数返回 null 表示用户关闭了弹窗没有选择
class AssetsFilterResult {
  final OptionsTradingPair? tradingPair;
  const AssetsFilterResult({this.tradingPair});
}

/// 显示资产筛选 Bottom Sheet
Future<AssetsFilterResult?> showAnalysisAssetsFilterSheet(
  BuildContext context, {
  String? selectedAsset,
}) {
  return showCupertinoModalBottomSheet<AssetsFilterResult>(
    context: context,
    expand: true,
    duration: const Duration(milliseconds: 250),
    topRadius: Dimens.sheetTopRadius,
    builder: (_) => _AnalysisAssetsFilterSheet(selectedAsset: selectedAsset),
  );
}

class _AnalysisAssetsFilterSheet extends StatefulWidget {
  final String? selectedAsset;
  const _AnalysisAssetsFilterSheet({this.selectedAsset});

  @override
  State<_AnalysisAssetsFilterSheet> createState() =>
      _AnalysisAssetsFilterSheetState();
}

class _AnalysisAssetsFilterSheetState extends State<_AnalysisAssetsFilterSheet>
    with ScopedSpaceStateMixin {
  late final OptionsTradingPairsVM _vm;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _vm = space.bind(optionsTradingPairsVMProvider);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        border: Border(
          top: BorderSide(
            color: context.colorScheme.outlineVariant,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          const DragHandle(),
          Expanded(
            child: Scaffold(
              resizeToAvoidBottomInset: false,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                automaticallyImplyLeading: false,
                elevation: 0,
                centerTitle: false,
                title: Text(
                  'Assets',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFD1D1D6),
                  ),
                ),
              ),
              body: Column(
                children: [
                  Expanded(
                    child: SafeArea(
                      top: false,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // // 标题
                          // const Text(
                          //   'Assets',
                          //   style: TextStyle(
                          //     fontSize: 20,
                          //     fontWeight: FontWeight.w600,
                          //     color: Color(0xFFD1D1D6),
                          //   ),
                          // ),
                          Dimens.vGap16,
                          // 搜索栏
                          AnalysisAssetsSearchBar(
                            controller: _searchController,
                            onCancel: () => Navigator.pop(context),
                          ),
                          Dimens.vGap8,
                          // 资产列表
                          Expanded(child: _buildAssetList()),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetList() {
    return ValueListenableBuilder(
      valueListenable: _vm.tradingPairsState,
      builder: (context, state, _) {
        final pairs = state.valueOrFallback ?? [];
        return ValueListenableBuilder(
          valueListenable: _searchController,
          builder: (context, searchValue, _) {
            return _buildFilteredList(pairs, searchValue.text);
          },
        );
      },
    );
  }

  Widget _buildFilteredList(
    List<UiData<OptionsTradingPairDetail, OptionsTradingPairVO>> pairs,
    String searchQuery,
  ) {
    final hasSearch = searchQuery.isNotEmpty;
    final filtered = hasSearch
        ? pairs
            .where((p) =>
                p.uiModel.baseAsset
                    .toLowerCase()
                    .contains(searchQuery.toLowerCase()) ||
                p.uiModel.name
                    .toLowerCase()
                    .contains(searchQuery.toLowerCase()))
            .toList()
        : pairs;

    return NotificationListener(
      onNotification: (notification) {
        // 当开始滚动时关闭软键盘
        if (notification is ScrollStartNotification) {
          FocusScope.of(context).unfocus();
        }
        return false;
      },
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          overscroll: false,
        ),
        child: ListView.builder(
          padding: EdgeInsets.zero,
          // 没有搜索时第一项是 "All Assets"
          itemCount: filtered.length + (hasSearch ? 0 : 1),
          itemBuilder: (context, index) {
            if (!hasSearch && index == 0) {
              return _buildAllAssetsItem();
            }
            final pairIndex = hasSearch ? index : index - 1;
            return _buildAssetItem(filtered[pairIndex]);
          },
        ),
      ),
    );
  }

  Widget _buildAllAssetsItem() {
    final isSelected = widget.selectedAsset == null;
    return Touchable(
      enable: !isSelected,
      onTap: () => Navigator.pop(context, const AssetsFilterResult()),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          height: 48,
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.white.withValues(alpha: 0.04)
                : Colors.transparent,
            borderRadius: isSelected ? BorderRadius.circular(6) : null,
          ),
          child: Row(
            children: [
              // Container(
              //   width: 24,
              //   height: 24,
              //   decoration: BoxDecoration(
              //     shape: BoxShape.circle,
              //     border: Border.all(
              //         color: isSelected
              //             ? const Color(0xFFDB8300)
              //             : const Color(0xFF969696),
              //         width: 2),
              //   ),
              //   child: Center(
              //     child: SvgPicture.asset(
              //       Assets.svgsRemixApps2Fill,
              //       width: 16,
              //       height: 16,
              //       colorFilter: ColorFilter.mode(
              //           isSelected
              //               ? const Color(0xFFDB8300)
              //               : const Color(0xFF969696),
              //           BlendMode.srcIn),
              //     ),
              //   ),
              // ),
              // Dimens.hGap12,
              Text(
                'All Assets',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? const Color(0xFFDB8300)
                      : const Color(0xFF969696),
                  letterSpacing: 0.4,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAssetItem(
    UiData<OptionsTradingPairDetail, OptionsTradingPairVO> item,
  ) {
    final isSelected = widget.selectedAsset == item.uiModel.baseAsset;
    return Touchable(
      enable: !isSelected,
      onTap: () => Navigator.pop(
        context,
        AssetsFilterResult(tradingPair: item.raw.pair),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          height: 48,
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.white.withValues(alpha: 0.04)
                : Colors.transparent,
            borderRadius: isSelected ? BorderRadius.circular(6) : null,
          ),
          child: Row(
            children: [
              LogoImage(
                  iconURL: item.uiModel.iconUrl,
                  symbol: item.uiModel.baseAsset,
                  width: 24,
                  height: 24),
              Dimens.hGap12,
              Text(
                item.uiModel.baseAsset.toUpperCase(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? const Color(0xFFDB8300)
                      : const Color(0xFF969696),
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
