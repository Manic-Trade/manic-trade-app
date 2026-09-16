import 'package:collection/collection.dart';
import 'package:finality/common/utils/color_scheme_extensions.dart';
import 'package:finality/common/widgets/bottom_sheet_navigator.dart';
import 'package:finality/common/widgets/bottom_sheet_scroll_physics.dart';
import 'package:finality/common/widgets/error_view.dart';
import 'package:finality/core/error/exception_handler.dart';
import 'package:finality/core/state/ui_data.dart';
import 'package:finality/core/state/ui_state.dart';
import 'package:finality/domain/options/entities/options_trading_pair_detail.dart';
import 'package:finality/domain/options/entities/options_trading_pair_identify.dart';
import 'package:finality/features/highlow/trading_pairs/models/options_trading_pair_vo.dart';
import 'package:finality/features/highlow/trading_pairs/vm/options_trading_pairs_vm.dart';
import 'package:finality/features/highlow/trading_pairs/widgets/options_trading_pair_item.dart';
import 'package:finality/features/highlow/trading_pairs/widgets/options_trading_pair_search_bar.dart';
import 'package:finality/features/highlow/trading_pairs/widgets/options_trading_pairs_table_header.dart';
import 'package:finality/features/highlow/trading_pairs/widgets/table_header_inactive.dart';
import 'package:finality/theme/attrs/text_color_theme.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:store_scope/store_scope.dart';

class _OptionsTradingPairsSheet extends StatefulWidget {
  final OptionsTradingPairIdentify? currentPairIdentify;

  const _OptionsTradingPairsSheet({
    this.currentPairIdentify,
  });

  @override
  State<_OptionsTradingPairsSheet> createState() =>
      _OptionsTradingPairsSheetState();
}

class _OptionsTradingPairsSheetState extends State<_OptionsTradingPairsSheet>
    with SingleTickerProviderStateMixin, ScopedSpaceStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late OptionsTradingPairsVM _viewModel;
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _viewModel = space.bind(optionsTradingPairsVMProvider);
    _viewModel.refreshTradingPairs();
    // _searchController.addListener(() {
    //   setState(() {
    //     _searchQuery = _searchController.text;
    //   });
    // });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: context.colorScheme.surfaceContainerHigh,
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(context),
            Expanded(
              child: ValueListenableBuilder(
                  valueListenable: _viewModel.tradingPairsState,
                  builder: (context, value, child) {
                    return value.buildWidget(
                      onLoading: (state) => _buildLoading(context),
                      onSuccess: (state) => ValueListenableBuilder(
                          valueListenable: _searchController,
                          builder: (context, value, child) {
                            return _buildSuccess(
                                context, state.value, value.text);
                          }),
                      onFailure: (state) => _buildError(context, state),
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return OptionsTradingPairSearchBar(
      controller: _searchController,
      onCancel: () {
        _searchController.clear();
      },
    );
  }

  Widget _buildLoading(BuildContext context) {
    // 生成占位数据列表
    final placeholderPairs = List.generate(
      6,
      (index) => OptionsTradingPairVO.placeholder,
    );

    return Column(
      children: [
        _buildSkeletonTabBar(context),
        OptionsTradingPairsTableHeader(isLoading: true),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: placeholderPairs.length,
            itemBuilder: (context, index) {
              return OptionsTradingPairItem(
                asset: placeholderPairs[index],
                isSelected: false,
                isLoading: true,
                onTap: () {},
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSkeletonTabBar(BuildContext context) {
    // 生成占位的 tab 项
    final placeholderTabs = [
      'All',
      'Crypto',
      'Commodites',
    ];

    final tabLength = placeholderTabs.length;
    if (_tabController == null || _tabController!.length != tabLength) {
      _tabController?.dispose();
      _tabController = null; // 先置空，确保完全释放
      _tabController = TabController(length: tabLength, vsync: this);
    }
    return Skeletonizer(
      enabled: true,
      child: _buildTabBar(context, _tabController!,
          placeholderTabs.map((e) => MapEntry(e, 0)).toList()),
    );
  }

  Widget _buildError(BuildContext context, Failure state) {
    return ErrorView(
      onRetry: state.retry,
      message: ErrorHandler.getMessage(context, state.throwable),
    );
  }

  Widget _buildSuccess(
      BuildContext context,
      List<UiData<OptionsTradingPairDetail, OptionsTradingPairVO>> pairs,
      String searchQuery) {
    Map<String, List<UiData<OptionsTradingPairDetail, OptionsTradingPairVO>>>
        assetTypesWithPairs = {};

    for (var pair in pairs) {
      List<UiData<OptionsTradingPairDetail, OptionsTradingPairVO>> pairs =
          (assetTypesWithPairs[pair.raw.pair.type] ?? []).toList();
      pairs.add(pair);
      assetTypesWithPairs[pair.raw.pair.type] = pairs;
    }
    List<
            MapEntry<String,
                List<UiData<OptionsTradingPairDetail, OptionsTradingPairVO>>>>
        assetTypeWithPairsList = assetTypesWithPairs.entries.toList();
    assetTypeWithPairsList.insert(0, MapEntry("All", pairs));

    // 管理 TabController：如果已存在且长度相同则复用，否则释放旧的并创建新的
    final tabLength = assetTypeWithPairsList.length;
    if (_tabController == null || _tabController!.length != tabLength) {
      _tabController?.dispose();
      _tabController = null; // 先置空，确保完全释放
      _tabController = TabController(length: tabLength, vsync: this);
    }

    final tabController = _tabController!;
    return Column(
      children: [
        _buildTabBar(
            context,
            tabController,
            assetTypeWithPairsList
                .map((e) => MapEntry(e.key, e.value.length))
                .toList()),
        Expanded(
          child: TabBarView(
            controller: tabController,
            physics: const BouncingScrollPhysics(),
            children: assetTypeWithPairsList.map((typeWithPairs) {
              return _buildAssetList(
                  context, typeWithPairs.key, typeWithPairs.value, searchQuery);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar(BuildContext context, TabController tabController,
      List<MapEntry<String, int>> assetTypeWithPairsCountList) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: TabBar(
        padding: Dimens.edgeInsetsH8,
        controller: tabController,
        tabAlignment: TabAlignment.start,
        isScrollable: true,
        labelColor: context.textColorTheme.textColorPrimary,
        unselectedLabelColor: context.textColorTheme.textColorSecondary,
        indicatorColor: context.colorScheme.primary,
        indicatorWeight: 0,
        indicator: const BoxDecoration(),
        labelStyle: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        tabs: assetTypeWithPairsCountList.mapIndexed((index, typeWithPairs) {
          return _buildTabBarItem(context, tabController, typeWithPairs.key,
              typeWithPairs.value, index);
        }).toList(),
      ),
    );
  }

  Widget _buildTabBarItem(BuildContext context, TabController tabController,
      String type, int count, int index) {
    return Tab(
      child: AnimatedBuilder(
        animation: tabController.animation!,
        builder: (context, child) {
          // 计算当前 tab 与动画值的距离
          final animationValue = tabController.animation!.value;
          final distance = (animationValue - index).abs();

          // 根据距离计算透明度：距离为 0 时透明度为 1.0，距离为 1 时透明度为 0.5
          // 使用 clamp 确保值在 0.5 到 1.0 之间
          final opacity = (1.0 - distance * 0.5).clamp(0.5, 1.0);

          return Opacity(
            opacity: opacity,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(type),
                Dimens.hGap8,
                count > 0
                    ? Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: context.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(2.34),
                        ),
                        child: Center(
                          child: Text(
                            '$count',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      )
                    : SizedBox(
                        width: 16,
                        height: 16,
                      ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAssetList(
      BuildContext context,
      String type,
      List<UiData<OptionsTradingPairDetail, OptionsTradingPairVO>> pairs,
      String searchQuery) {
    pairs = pairs
        .where((a) =>
            a.uiModel.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
            a.uiModel.ticker.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
    if (pairs.isEmpty) {
      return Column(
        children: [
          Container(
            constraints: const BoxConstraints(maxHeight: 100),
            child: Center(
              child: Text(
                'No assets found',
                style: TextStyle(
                  color: context.textColorTheme.textColorHelper,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      );
    }
    final activeAssets = pairs.where((a) => a.raw.pair.isActive).toList();
    final inactiveAssets = pairs.where((a) => !a.raw.pair.isActive).toList();

    // 计算总 item 数：已激活资产 + 未激活部分(表头+分割线+资产列表)
    final activeCount = activeAssets.length;
    final inactiveHeaderCount =
        inactiveAssets.isNotEmpty ? 2 : 0; // TableHeaderInactive + Divider
    final inactiveCount = inactiveAssets.length;
    final itemCount = activeCount + inactiveHeaderCount + inactiveCount;

    return Column(
      children: [
        // 固定在顶部的表头
        OptionsTradingPairsTableHeader(),
        // 可滚动的列表
        Expanded(
          child: NotificationListener<ScrollNotification>(
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
                physics: const AlwaysScrollableScrollPhysics(
                  parent: TopBlockedBouncingScrollPhysics(),
                ),
                itemCount: itemCount,
                itemBuilder: (context, index) {
                // 已激活资产列表 (index 0 到 activeCount - 1)
                if (index < activeCount) {
                  return _buildAssetItem(context, activeAssets[index]);
                }

                // 未激活资产部分
                if (inactiveAssets.isEmpty) {
                  return const SizedBox.shrink();
                }

                final inactiveStartIndex = activeCount;

                // 未激活表头
                if (index == inactiveStartIndex) {
                  return TableHeaderInactive(
                      inactiveAssetsCount: inactiveAssets.length);
                }

                // 分割线
                if (index == inactiveStartIndex + 1) {
                  return Divider();
                }

                // 未激活资产列表
                final assetIndex = index - inactiveStartIndex - 2;
                if (assetIndex >= 0 && assetIndex < inactiveAssets.length) {
                  return _buildAssetItem(context, inactiveAssets[assetIndex]);
                }

                return const SizedBox.shrink();
              },
            ),
          ),
          ),
        ),
      ],
    );
  }

  Widget _buildAssetItem(BuildContext context,
      UiData<OptionsTradingPairDetail, OptionsTradingPairVO> asset) {
    final isSelected =
        widget.currentPairIdentify?.feedId == asset.raw.pair.feedId;
    return OptionsTradingPairItem(
        asset: asset.uiModel,
        isSelected: isSelected,
        isLoading: false,
        onTap: () {
          Navigator.pop(context, asset.raw);
        });
  }
}

Future<OptionsTradingPairDetail?> showOptionsAssetSelectionSheet(
  BuildContext context, {
  OptionsTradingPairIdentify? currentPairIdentify,
}) {
  return showCupertinoModalBottomSheet<OptionsTradingPairDetail?>(
    context: context,
    expand: true,
    enableDrag: true,
    backgroundColor: context.colorScheme.surfaceContainerHigh,
    duration: const Duration(milliseconds: 250),
    topRadius: Dimens.sheetTopRadius,
    builder: (_) => BottomSheetNavigator(
      backgroundColor: context.colorScheme.surfaceContainerHigh,
      useNavigator: false,
      builder: (_) {
        return _OptionsTradingPairsSheet(
          currentPairIdentify: currentPairIdentify,
        );
      },
    ),
  );
}
