import 'dart:async';

import 'package:finality/common/constants/currencies.dart';
import 'package:finality/common/utils/beat_countdown.dart';
import 'package:finality/common/utils/color_scheme_extensions.dart';
import 'package:finality/common/utils/decimal_format.dart';
import 'package:finality/common/widgets/drag_handle.dart';
import 'package:finality/common/widgets/gradient_border_box.dart';
import 'package:finality/common/widgets/logo_image.dart';
import 'package:finality/common/widgets/touchable.dart';
import 'package:finality/core/notifier/computed_notifier.dart';
import 'package:finality/core/notifier/multi_value_listenable_builder.dart';
import 'package:finality/core/state/ui_state.dart';
import 'package:finality/data/socket/manic/manic_price_data.dart';
import 'package:finality/domain/options/close_position_estimator.dart';
import 'package:finality/domain/options/entities/opened_position.dart';
import 'package:finality/features/positions/model/opened_position_vo.dart';
import 'package:finality/features/positions/widgets/entry_compared_price_text.dart';
import 'package:finality/features/positions/widgets/postion_prop_row.dart';
import 'package:finality/generated/assets.dart';
import 'package:finality/theme/app_color_theme.dart';
import 'package:finality/theme/attrs/space_grotesk_font.dart';
import 'package:finality/theme/attrs/text_color_theme.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

// ---------------------------------------------------------------------------
// 共用布局函数（预测量和真实渲染共用，确保高度一致）
// ---------------------------------------------------------------------------

/// Header 行布局骨架
Widget _buildHeaderRow({
  required OpenedPositionVO vo,
  required Widget leadingImage,
  required TextStyle pairNameStyle,
  required TextStyle amountStyle,
  required Widget directionIcon,
  required Widget trailing,
}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Row(
        children: [
          leadingImage,
          Dimens.hGap8,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(vo.pairName, style: pairNameStyle),
              Row(
                children: [
                  Text(
                    vo.amount.formatWithDecimals(2).withUsdSymbol(),
                    style: amountStyle,
                  ),
                  Dimens.hGap2,
                  directionIcon,
                ],
              ),
            ],
          ),
        ],
      ),
      trailing,
    ],
  );
}

/// BottomCard 布局骨架
Widget _buildBottomCardLayout({
  BoxDecoration? decoration,
  required Widget payoutLabel,
  required Widget payoutValue,
  required Widget timer,
  required Widget button,
}) {
  return Container(
    padding: const EdgeInsets.only(top: 20, left: 1, right: 1, bottom: 1),
    decoration: decoration,
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  payoutLabel,
                  Dimens.vGap2,
                  payoutValue,
                ],
              ),
              timer,
            ],
          ),
        ),
        Dimens.vGap20,
        button,
      ],
    ),
  );
}

/// 展开区域的 properties（预测量和真实渲染共用）
Widget _buildProperties(BuildContext context, OpenedPositionVO vo,
    ValueNotifier<ManicPriceData?>? currentPriceNotifier) {
  final directionColor =
      vo.isHigh ? context.appColors.bullish : context.appColors.bearish;

  return Padding(
    padding: const EdgeInsets.only(bottom: 24),
    child: Column(
      children: [
        PostionPropRow(
          title: 'Expiry Type',
          value: vo.modeDisplay,
        ),
        Dimens.vGap16,
        PostionPropRow(
          title: 'Amount',
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                vo.isHigh
                    ? Assets.svgsIcTradingActionUp
                    : Assets.svgsIcTradingActionDown,
                width: 16,
                height: 16,
                colorFilter: ColorFilter.mode(
                  directionColor,
                  BlendMode.srcIn,
                ),
              ),
              Dimens.hGap2,
              Text(
                vo.amount.formatWithDecimals(2).withUsdSymbol(),
                style: PostionPropRow.valueTextStyle(context),
              ),
            ],
          ),
        ),
        Dimens.vGap16,
        PostionPropRow(
          title: 'Entry Price',
          value: vo.entryPrice.toStringAsFixed(vo.pipSize).withUsdSymbol(),
        ),
        Dimens.vGap16,
        PostionPropRow(
          title: 'Current Price',
          trailing: currentPriceNotifier == null
              ? Text(
                  "--",
                  style: PostionPropRow.valueTextStyle(context),
                )
              : ValueListenableBuilder(
                  valueListenable: currentPriceNotifier,
                  builder: (context, value, child) {
                    return EntryComparedPriceText(
                      price: value?.close,
                      entryPrice: vo.entryPrice,
                      formatPrice: (double p1) {
                        return Currencies.symbolUsd +
                            p1.toStringAsFixed(vo.pipSize);
                      },
                      increaseColor: context.appColors.bullish,
                      decreaseColor: context.appColors.bearish,
                      unchangedColor: context.textColorTheme.textColorSecondary,
                      textStyle: PostionPropRow.valueTextStyle(context),
                    );
                  }),
        ),
      ],
    ),
  );
}

// ---------------------------------------------------------------------------
// ActivePositionDetailsSheet
// ---------------------------------------------------------------------------

/// 活跃仓位详情底部弹窗（二级抽屉：底部卡片始终固定，上滑展开中间详情字段）
class ActivePositionDetailsSheet extends StatefulWidget {
  final OpenedPositionVO vo;
  final VoidCallback? onSellTap;
  final ValueNotifier<ManicPriceData?> currentPriceNotifier;
  final ValueNotifier<ClosePositionEstimateResult?> estimateNotifier;
  final ValueNotifier<UiState<void>> closeStateNotifier;

  /// 监听活跃仓位列表，当前仓位不在列表中时自动关闭 sheet
  final ValueListenable<List<OpenedPosition>> openedPositionsNotifier;

  /// 预测量的折叠态内容高度和展开区域额外高度（不含 bottomPadding）
  /// 仅 expandable: true 时使用
  final double collapsedContentHeight;
  final double expandedExtraHeight;

  /// 初始是否展开，默认 false（收起）
  final bool initialExpanded;

  /// 是否允许展开/收起，默认 true
  /// false 时渲染为普通 ModalBottomSheet，不使用 DraggableScrollableSheet
  final bool expandable;

  const ActivePositionDetailsSheet({
    super.key,
    required this.vo,
    this.onSellTap,
    required this.currentPriceNotifier,
    required this.estimateNotifier,
    required this.closeStateNotifier,
    required this.openedPositionsNotifier,
    this.collapsedContentHeight = 0,
    this.expandedExtraHeight = 0,
    this.initialExpanded = false,
    this.expandable = true,
  });

  @override
  State<ActivePositionDetailsSheet> createState() =>
      _ActivePositionDetailsSheetState();
}

class _ActivePositionDetailsSheetState
    extends State<ActivePositionDetailsSheet> {
  late final ValueListenable<int?> _beat;
  late BeatCountdown _countdown;
  late final ValueListenable<bool> _isWinningNotifier;
  final _sheetController = DraggableScrollableController();

  @override
  void initState() {
    super.initState();
    _beat = widget.currentPriceNotifier.toBeatNotifier();
    _countdown = BeatCountdown(
      endTime: widget.vo.endTime,
      beat: _beat,
    )..start();
    _isWinningNotifier = ComputedNotifier(
      source: widget.currentPriceNotifier,
      compute: (currentPriceData) {
        if (currentPriceData == null) return true;
        if (widget.vo.isHigh) {
          return currentPriceData.close >= widget.vo.entryPrice;
        } else {
          return currentPriceData.close < widget.vo.entryPrice;
        }
      },
    );
    widget.openedPositionsNotifier.addListener(_onPositionsChanged);
  }

  @override
  void dispose() {
    widget.openedPositionsNotifier.removeListener(_onPositionsChanged);
    _sheetController.dispose();
    _countdown.dispose();
    (_isWinningNotifier as ComputedNotifier).dispose();
    super.dispose();
  }

  /// 活跃仓位列表变化时，检查当前仓位是否还在列表中，不在则关闭 sheet
  void _onPositionsChanged() {
    final stillActive = widget.openedPositionsNotifier.value
        .any((p) => p.id == widget.vo.positionId);
    if (!stillActive && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.expandable) {
      return _buildSimpleSheetBody(context);
    }

    final screenHeight = MediaQuery.of(context).size.height;
    // sheet 内的 context 能拿到正确的底部安全区高度
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom + 16;
    final collapsedHeight = widget.collapsedContentHeight + bottomPadding;
    final minFraction = collapsedHeight / screenHeight;
    final maxFraction =
        (collapsedHeight + widget.expandedExtraHeight) / screenHeight;

    return DraggableScrollableSheet(
      controller: _sheetController,
      initialChildSize: widget.initialExpanded ? maxFraction : minFraction,
      minChildSize: minFraction * 0.3,
      maxChildSize: maxFraction,
      snap: true,
      expand: false,
      snapSizes: [minFraction, maxFraction],
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: context.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Dimens.sheetTopRadius,
            ),
            border: Border(
              top: BorderSide(
                color: context.colorScheme.outlineVariant,
                width: 1,
              ),
            ),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: _SheetContent(
              sheetController: _sheetController,
              minFraction: minFraction,
              maxFraction: maxFraction,
              header: _buildHeader(context),
              properties: _buildProperties(
                  context, widget.vo, widget.currentPriceNotifier),
              bottomCard: _buildBottomCard(context),
              bottomPadding: bottomPadding,
            ),
          ),
        );
      },
    );
  }

  /// expandable: false 时作为普通底部弹窗渲染，不使用 DraggableScrollableSheet
  Widget _buildSimpleSheetBody(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom + 16;
    return Container(
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Dimens.sheetTopRadius),
        border: Border(
          top: BorderSide(color: context.colorScheme.outlineVariant, width: 1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const DragHandle(),
          Padding(
            padding: Dimens.edgeInsetsA16,
            child: Column(
              children: [
                _buildHeader(context),
                Dimens.vGap24,
                if (widget.initialExpanded)
                  _buildProperties(
                      context, widget.vo, widget.currentPriceNotifier),
                _buildBottomCard(context),
              ],
            ),
          ),
          SizedBox(height: bottomPadding),
        ],
      ),
    );
  }

  /// 头部：左侧 token + 交易对 + 金额方向，右侧预期收益
  Widget _buildHeader(BuildContext context) {
    final bullishColor = context.appColors.bullish;
    final bearishColor = context.appColors.bearish;
    final directionColor = widget.vo.isHigh ? bullishColor : bearishColor;

    return _buildHeaderRow(
      vo: widget.vo,
      leadingImage: LogoImage(
        symbol: widget.vo.baseAsset,
        width: 40,
        height: 40,
        iconURL: widget.vo.pairImageUrl,
      ),
      pairNameStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        height: 1.25,
        color: context.textColorTheme.textColorTertiary,
      ),
      amountStyle: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.2142,
        color: context.textColorTheme.textColorSecondary,
      ),
      directionIcon: SvgPicture.asset(
        widget.vo.isHigh
            ? Assets.svgsIcTradingActionUp
            : Assets.svgsIcTradingActionDown,
        width: 16,
        height: 16,
        colorFilter: ColorFilter.mode(directionColor, BlendMode.srcIn),
      ),
      trailing: ValueListenableBuilder<bool>(
        valueListenable: _isWinningNotifier,
        builder: (context, isWin, _) {
          final color = isWin ? bullishColor : bearishColor;
          final display =
              isWin ? widget.vo.winPayoutDisplay : widget.vo.lossPayoutDisplay;
          return Text(
            display,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              height: 1.25,
              color: color,
              shadows: [Shadow(color: color, blurRadius: 4)],
            ),
          );
        },
      ),
    );
  }

  /// 底部卡片：Payout After Sell + 倒计时 + SELL 按钮
  Widget _buildBottomCard(BuildContext context) {
    final bullishColor = context.appColors.bullish;
    final bearishColor = context.appColors.bearish;
    final directionColor = widget.vo.isHigh ? bullishColor : bearishColor;

    return GradientBorderBox(
      borderRadius: BorderRadius.circular(6),
      gradient: LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          directionColor.withValues(alpha: 0),
          directionColor.withValues(alpha: 0.3)
        ],
      ),
      child: _buildBottomCardLayout(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF161616), Color(0xFF0F0F0F)],
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        payoutLabel: Text(
          'Payout After Sell',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: context.textColorTheme.textColorQuaternary,
          ),
        ),
        payoutValue: ValueListenableBuilder<ClosePositionEstimateResult?>(
          valueListenable: widget.estimateNotifier,
          builder: (context, estimate, _) {
            final payout = estimate?.estimatedPayoutUsdc ?? 0;
            final formatted = payout.formatWithDecimals(2);
            final isPositive = payout > 0;
            final display =
                '${isPositive ? '+' : ''}${formatted.withUsdSymbol()}';
            var canClose = estimate?.canClose == true;
            return Text(
              canClose ? display : '--',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: context.textColorTheme.textColorSecondary,
              ),
            );
          },
        ),
        timer: ValueListenableBuilder<int>(
          valueListenable: _countdown.remainingMs,
          builder: (context, remainingMs, _) {
            final remainingSeconds = remainingMs ~/ 1000;
            final isProcessing = remainingMs <= 0;
            return Text(
              isProcessing ? 'Processing' : _formattedTime(remainingSeconds),
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                fontFamily: SpaceGroteskFont.fontFamily,
                fontFeatures: const [
                  FontFeature.liningFigures(),
                  FontFeature.tabularFigures(),
                ],
                color: !isProcessing && remainingSeconds <= 5
                    ? context.appColors.bearish
                    : context.textColorTheme.textColorSecondary,
              ),
            );
          },
        ),
        button: _buildSellButton(context, directionColor),
      ),
    );
  }

  /// SELL 按钮（根据估算和平仓状态切换）
  Widget _buildSellButton(BuildContext context, Color directionColor) {
    return ValueListenableBuilder2(
      first: widget.estimateNotifier,
      second: widget.closeStateNotifier,
      builder: (context, estimate, closeState, _) {
        if (closeState.isSuccess) {
          return _sellButtonWidget(
            context,
            enabled: false,
            directionColor: directionColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.black,
                  ),
                ),
                Dimens.hGap8,
                Text(
                  'CONFIRMING',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          );
        }

        if (closeState.isLoading) {
          return _sellButtonWidget(
            context,
            enabled: false,
            directionColor: directionColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.black,
                  ),
                ),
                Dimens.hGap8,
                Text(
                  'SELLING...',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          );
        }

        if (estimate == null || !estimate.canClose) {
          return _sellButtonWidget(
            context,
            enabled: false,
            directionColor: directionColor,
            child: Text(
              estimate != null && !estimate.canClose
                  ? (estimate.error ?? 'Unavailable')
                  : 'SELL',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black.withValues(alpha: 0.5),
              ),
            ),
          );
        }

        return Touchable.plain(
          onTap: widget.onSellTap,
          child: _sellButtonWidget(
            context,
            enabled: true,
            directionColor: directionColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'SELL',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                Dimens.hGap4,
                SvgPicture.asset(
                  Assets.svgsIcSellPositionCoin,
                  width: 16,
                  height: 16,
                  colorFilter: const ColorFilter.mode(
                    Colors.black,
                    BlendMode.srcIn,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sellButtonWidget(BuildContext context,
      {required bool enabled,
      required Widget child,
      required Color directionColor}) {
    return Container(
      height: 40,
      width: double.infinity,
      decoration: BoxDecoration(
        color: enabled ? directionColor : directionColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Center(child: child),
    );
  }

  String _formattedTime(int value) {
    if (value <= 0) return '00:00';
    final minutes = value ~/ 60;
    final seconds = value % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

// ---------------------------------------------------------------------------
// Sheet 内容布局
// ---------------------------------------------------------------------------

/// Sheet 内容布局：通过监听 DraggableScrollableController 动态控制 properties 的显隐
///
/// 核心思路：
/// - 整个内容放在 SingleChildScrollView 内（为了绑定 scrollController 响应拖拽）
/// - properties 区域通过 ClipRect + Align(heightFactor) 实现平滑展开/收起
/// - heightFactor 从 0（折叠）到 1（展开），跟随 sheet extent 线性变化
/// - 底部卡片始终在 properties 下方，视觉上随 properties 展开而下推，始终贴近 sheet 底部
class _SheetContent extends StatelessWidget {
  final DraggableScrollableController sheetController;
  final double minFraction;
  final double maxFraction;
  final Widget header;
  final Widget properties;
  final Widget bottomCard;
  final double bottomPadding;

  const _SheetContent({
    required this.sheetController,
    required this.minFraction,
    required this.maxFraction,
    required this.header,
    required this.properties,
    required this.bottomCard,
    required this.bottomPadding,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const DragHandle(),
        Padding(
          padding: Dimens.edgeInsetsA16,
          child: Column(
            children: [
              header,
              Dimens.vGap24,
              // 详情字段：根据 sheet extent 动态裁剪高度
              ListenableBuilder(
                listenable: sheetController,
                builder: (context, child) {
                  final progress = sheetController.isAttached
                      ? ((sheetController.size - minFraction) /
                              (maxFraction - minFraction))
                          .clamp(0.0, 1.0)
                      : 0.0;
                  return ClipRect(
                    child: Align(
                      heightFactor: progress,
                      alignment: Alignment.topCenter,
                      child: child,
                    ),
                  );
                },
                child: properties,
              ),
              bottomCard,
            ],
          ),
        ),
        SizedBox(height: bottomPadding),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// 预测量
// ---------------------------------------------------------------------------

/// 折叠态测量目标（不含 bottomPadding，由 sheet 内部补上）
///
/// 复用 [_buildHeaderRow] 和 [_buildBottomCardLayout] 确保与真实渲染高度一致，
/// 仅用占位 widget 替代动态/主题相关内容（颜色、图片、Listener）
Widget _buildCollapsedMeasureTarget(
  BuildContext context,
  OpenedPositionVO vo,
) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      const DragHandle(),
      Padding(
        padding: Dimens.edgeInsetsA16,
        child: Column(
          children: [
            _buildHeaderRow(
              vo: vo,
              leadingImage: const SizedBox(width: 40, height: 40),
              pairNameStyle: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                height: 1.25,
              ),
              amountStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.2142,
              ),
              directionIcon: const SizedBox(width: 16, height: 16),
              trailing: Text(
                vo.winPayoutDisplay,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  height: 1.25,
                ),
              ),
            ),
            Dimens.vGap24,
            _buildBottomCardLayout(
              payoutLabel: const Text(
                'Payout After Sell',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
              payoutValue: const Text(
                '\$0.00',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              timer: Text(
                '00:00',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  fontFamily: SpaceGroteskFont.fontFamily,
                  fontFeatures: const [
                    FontFeature.liningFigures(),
                    FontFeature.tabularFigures(),
                  ],
                ),
              ),
              button: const SizedBox(height: 40, width: double.infinity),
            ),
          ],
        ),
      ),
    ],
  );
}

/// 通过 Offstage OverlayEntry 预测量 sheet 的折叠态内容高度和展开区域高度
///
/// 原理：将测量目标 widget 插入 Overlay 的 Offstage 中，Flutter 会完整 layout
/// 但不 paint，等一帧后即可通过 GlobalKey 读取 RenderBox.size，测量完立即移除。
/// 返回的高度不含 bottomPadding，由 sheet 内部的 build 补上。
Future<({double collapsed, double expandedExtra})> _measureSheetHeights(
  BuildContext context, {
  required OpenedPositionVO vo,
}) async {
  final collapsedKey = GlobalKey();
  final expandedKey = GlobalKey();
  final screenWidth = MediaQuery.of(context).size.width;

  final entry = OverlayEntry(
    builder: (_) => Offstage(
      offstage: true,
      child: SizedBox(
        width: screenWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            KeyedSubtree(
              key: collapsedKey,
              child: _buildCollapsedMeasureTarget(context, vo),
            ),
            KeyedSubtree(
              key: expandedKey,
              child: _buildProperties(context, vo, null),
            ),
          ],
        ),
      ),
    ),
  );

  Overlay.of(context).insert(entry);

  // 等待一帧完成 layout
  final completer = Completer<void>();
  WidgetsBinding.instance.addPostFrameCallback((_) => completer.complete());
  await completer.future;

  final collapsed = collapsedKey.currentContext?.size?.height ?? 280;
  final expandedExtra = expandedKey.currentContext?.size?.height ?? 130;

  entry.remove();
  entry.dispose();

  return (collapsed: collapsed, expandedExtra: expandedExtra);
}

// ---------------------------------------------------------------------------
// 入口
// ---------------------------------------------------------------------------

/// 显示活跃仓位详情底部弹窗
Future<void> showActivePositionDetailsSheet(
  BuildContext context, {
  required OpenedPositionVO vo,
  required ValueNotifier<ManicPriceData?> currentPriceNotifier,
  required ValueNotifier<ClosePositionEstimateResult?> estimateNotifier,
  required ValueNotifier<UiState<void>> closeStateNotifier,
  required ValueListenable<List<OpenedPosition>> openedPositionsNotifier,
  VoidCallback? onSellTap,
  bool initialExpanded = false,
  bool expandable = true,
}) async {
  double collapsedContentHeight = 0;
  double expandedExtraHeight = 0;

  if (expandable) {
    // 可展开时需要预测量高度，sheet 内部会补上 bottomPadding
    final heights = await _measureSheetHeights(context, vo: vo);
    if (!context.mounted) return;
    collapsedContentHeight = heights.collapsed;
    expandedExtraHeight = heights.expandedExtra;
  }

  if (!context.mounted) return;

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: expandable
        ? Colors.black.withValues(alpha: 0.2)
        : Theme.of(context).bottomSheetTheme.modalBarrierColor,
    builder: (_) => ActivePositionDetailsSheet(
      vo: vo,
      currentPriceNotifier: currentPriceNotifier,
      estimateNotifier: estimateNotifier,
      closeStateNotifier: closeStateNotifier,
      openedPositionsNotifier: openedPositionsNotifier,
      onSellTap: onSellTap,
      collapsedContentHeight: collapsedContentHeight,
      expandedExtraHeight: expandedExtraHeight,
      initialExpanded: initialExpanded,
      expandable: expandable,
    ),
  );
}
