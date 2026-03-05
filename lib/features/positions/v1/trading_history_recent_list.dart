import 'package:finality/common/constants/currencies.dart';
import 'package:finality/common/utils/decimal_format.dart';
import 'package:finality/common/utils/localization_extensions.dart';
import 'package:finality/common/utils/value_listenable_removable.dart';
import 'package:finality/common/widgets/touchable.dart';
import 'package:finality/core/error/exception_handler.dart';
import 'package:finality/data/drift/options_database.dart';
import 'package:finality/data/network/model/manic/position_history_item.dart';
import 'package:finality/features/activity/position_history_detail_screen.dart';
import 'package:finality/features/highlow/trading_pairs/vm/options_trading_pairs_vm.dart';
import 'package:finality/features/positions/model/history_position_vo.dart';
import 'package:finality/features/positions/v1/widgets/error_history_recent.dart';
import 'package:finality/features/positions/v1/widgets/history_list_item.dart';
import 'package:finality/features/positions/vm/trading_history_recent_vm.dart';
import 'package:finality/features/utilities/share/profit_loss_share_sheet.dart';
import 'package:finality/theme/attrs/text_color_theme.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_scope/store_scope.dart';

/// 最近交易历史列表 Widget
/// 显示最近 5 条已结算的交易记录
class TradingHistoryRecentList extends StatefulWidget {
  const TradingHistoryRecentList({
    super.key,
    this.onViewAllTap,
  });

  /// 点击查看全部
  final VoidCallback? onViewAllTap;

  @override
  State<TradingHistoryRecentList> createState() =>
      _TradingHistoryRecentListState();
}

class _TradingHistoryRecentListState extends State<TradingHistoryRecentList>
    with ScopedStateMixin {
  late final TradingHistoryRecentVM _vm;
  late final OptionsTradingPairsVM _optionsTradingPairsVM;

  final Map<String, ValueNotifier<OptionsTradingPair?>> _currentTradingPair =
      {};
  Removable? _tradingPairsStateRemovable;

  @override
  void initState() {
    super.initState();
    _vm = context.store.bindWithScoped(tradingHistoryRecentVMProvider, this);
    _optionsTradingPairsVM =
        context.store.bindWithScoped(optionsTradingPairsVMProvider, this);
    _tradingPairsStateRemovable =
        _optionsTradingPairsVM.tradingPairsState.listen((tradingPairsState) {
      tradingPairsState.valueOrFallback?.forEach((element) {
        _getCurrentTradingPair(element.raw.pair.baseAsset).value =
            element.raw.pair;
      });
    }, immediate: true);
  }

  @override
  void dispose() {
    _tradingPairsStateRemovable?.remove();
    super.dispose();
  }

  ValueNotifier<OptionsTradingPair?> _getCurrentTradingPair(String asset) {
    var notifier = _currentTradingPair[asset];
    if (notifier == null) {
      notifier = ValueNotifier(null);
      _currentTradingPair[asset] = notifier;
    }
    return notifier;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: _vm.recentHistoryState,
        builder: (context, state, child) {
          return state.buildWidget(onLoading: (loading) {
            return _buildLoadingWidget(context);
          }, onSuccess: (success) {
            return _buildContent(context, success.value);
          }, onFailure: (failure) {
            return _buildErrorWidget(context, failure.retry,
                ErrorHandler.getMessage(context, failure.throwable));
          });
        });
  }

  Widget _buildLoadingWidget(BuildContext context) {
    return Container(
        width: double.infinity,
        padding: const EdgeInsets.only(top: 16),
        child: const Center(
          child: SizedBox(
              width: 20, height: 20, child: CircularProgressIndicator()),
        ));
  }

  Widget _buildEmptyWidget(BuildContext context) {
    return Dimens.emptyBox;
  }

  Widget _buildErrorWidget(
      BuildContext context, Function()? retry, String message) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeader(context),
        ErrorHistoryRecent(onRetry: retry, message: message),
      ],
    );
  }

  Widget _buildContent(BuildContext context, List<PositionHistoryItem> items) {
    if (items.isEmpty) {
      return _buildEmptyWidget(context);
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeader(context),
        ...items.map((item) {
          var historyPositionVO = HistoryPositionVO.fromPositionHistoryItem(
            item,
            _getCurrentTradingPair(item.asset),
          );
          return HistoryListItem(
            item: historyPositionVO,
            onTap: () {
              Get.to(() => PositionHistoryDetailScreen(item: item));
            },
            onSharePressed: () {
              final isWin = item.isWin;

              showProfitLossShareSheet(context,
                  imageUrl: item.asset.toUpperCase(),
                  symbol: item.asset,
                  profitLossPctText: historyPositionVO.payoutDisplay,
                  isWin: isWin,
                  since:
                      DateTime.fromMillisecondsSinceEpoch(item.endTime * 1000));
            },
          );
        }),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.only(left: 16),
      child: Center(
        child: Baseline(
          baseline: 18,
          baselineType: TextBaseline.alphabetic,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                context.strings.title_trading_history,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const Spacer(),
              Touchable.plain(
                onTap: widget.onViewAllTap,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Text(
                        context.strings.action_see_all,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: context.textColorTheme.textColorTertiary,
                        ),
                      ),
                      Dimens.hGap8,
                      Icon(Icons.arrow_forward_ios,
                          size: 12,
                          color: context.textColorTheme.textColorTertiary),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
