import 'package:finality/common/constants/currencies.dart';
import 'package:finality/common/utils/beat_countdown.dart';
import 'package:finality/common/utils/color_scheme_extensions.dart';
import 'package:finality/common/utils/decimal_format.dart';
import 'package:finality/common/widgets/logo_image.dart';
import 'package:finality/common/widgets/touchable.dart';
import 'package:finality/core/notifier/computed_notifier.dart';
import 'package:finality/core/notifier/multi_value_listenable_builder.dart';
import 'package:finality/core/state/ui_state.dart';
import 'package:finality/data/socket/manic/manic_price_data.dart';
import 'package:finality/domain/options/close_position_estimator.dart';
import 'package:finality/features/positions/model/opened_position_vo.dart';
import 'package:finality/generated/assets.dart';
import 'package:finality/theme/app_color_theme.dart';
import 'package:finality/theme/attrs/text_color_theme.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// 活跃仓位列表项（卡片式 UI）
///
/// 包含：交易对信息、倒计时、预估收益、提前平仓收益、SELL 按钮
class ActivePositionListItem extends StatefulWidget {
  final OpenedPositionVO vo;
  final bool isLoading;
  final VoidCallback? onTap;
  final VoidCallback? onSellTap;
  final ValueNotifier<ManicPriceData?> currentPriceNotifier;
  final ValueNotifier<ClosePositionEstimateResult?> estimateNotifier;
  final ValueNotifier<UiState<void>> closeStateNotifier;

  const ActivePositionListItem({
    super.key,
    required this.vo,
    this.isLoading = false,
    this.onTap,
    this.onSellTap,
    required this.currentPriceNotifier,
    required this.estimateNotifier,
    required this.closeStateNotifier,
  });

  @override
  State<ActivePositionListItem> createState() => _ActivePositionListItemState();
}

class _ActivePositionListItemState extends State<ActivePositionListItem> {
  late final ValueListenable<int?> _beat;
  late BeatCountdown _countdown;
  late final ValueListenable<bool> _isWinningNotifier;

  @override
  void initState() {
    super.initState();
    if (!widget.isLoading) {
      _beat = widget.currentPriceNotifier.toBeatNotifier();
      _countdown = _createCountdown()..start();
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
    } else {
      _beat = ValueNotifier(null);
      _countdown = _createCountdown();
      _isWinningNotifier = ValueNotifier(true);
    }
  }

  BeatCountdown _createCountdown() {
    return BeatCountdown(
      endTime: widget.vo.endTime,
      beat: _beat,
    );
  }

  @override
  void dispose() {
    _countdown.dispose();
    if (_isWinningNotifier is ComputedNotifier) {
      (_isWinningNotifier as ComputedNotifier).dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: widget.isLoading,
      child: Touchable.plain(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: context.colorScheme.outlineVariant,
              width: 0.5,
            ),
          ),
          child: Column(
            children: [
              _buildTopRow(context),
              Dimens.vGap12,
              Divider(
                height: 0.5,
                thickness: 0.5,
                color: context.colorScheme.outline,
              ),
              Dimens.vGap12,
              _buildBottomRow(context),
            ],
          ),
        ),
      ),
    );
  }

  /// 上半部分：左侧交易对 + 右侧倒计时和预估收益
  Widget _buildTopRow(BuildContext context) {
    final bullishColor = context.appColors.bullish;
    final bearishColor = context.appColors.bearish;
    final directionColor = widget.vo.isHigh ? bullishColor : bearishColor;

    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              if (!widget.isLoading)
                LogoImage(
                  symbol: widget.vo.baseAsset,
                  width: 34,
                  height: 34,
                  iconURL: widget.vo.pairImageUrl,
                ),
              if (widget.isLoading) const SizedBox(width: 34, height: 34),
              Dimens.hGap4,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.vo.pairName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: context.textColorTheme.textColorQuaternary,
                    ),
                  ),
                  Dimens.vGap2,
                  Row(
                    children: [
                      Text(
                        widget.vo.amount.formatWithDecimals(2).withUsdSymbol(),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: context.textColorTheme.textColorSecondary,
                        ),
                      ),
                      Dimens.hGap2,
                      if (!widget.isLoading)
                        SvgPicture.asset(
                          widget.vo.isHigh
                              ? Assets.svgsIcTradingActionUp
                              : Assets.svgsIcTradingActionDown,
                          width: 16,
                          height: 16,
                          colorFilter: ColorFilter.mode(
                            directionColor,
                            BlendMode.srcIn,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ValueListenableBuilder<int>(
              valueListenable: _countdown.remainingMs,
              builder: (context, remainingMs, _) {
                final remainingSeconds = remainingMs ~/ 1000;
                final isProcessing = remainingMs <= 0;
                return Text(
                  isProcessing
                      ? 'Processing'
                      : _formattedTime(remainingSeconds),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: context.textColorTheme.textColorSecondary,
                  ),
                );
              },
            ),
            Dimens.vGap2,
            ValueListenableBuilder<bool>(
              valueListenable: _isWinningNotifier,
              builder: (context, isWin, _) {
                final color = isWin ? bullishColor : bearishColor;
                final display = isWin
                    ? widget.vo.winPayoutDisplay
                    : widget.vo.lossPayoutDisplay;
                return Text(
                  display,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  /// 下半部分：Payout After Sell + SELL 按钮
  Widget _buildBottomRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Payout After Sell',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: context.textColorTheme.textColorQuaternary,
                ),
              ),
              Dimens.vGap2,
              ValueListenableBuilder<ClosePositionEstimateResult?>(
                valueListenable: widget.estimateNotifier,
                builder: (context, estimate, _) {
                  final payout = estimate?.estimatedPayoutUsdc ?? 0;
                  var isPositive = payout > 0;
                  var formatted = payout.formatWithDecimals(2);
                  final display =
                      '${isPositive ? '+' : ''}${formatted.withUsdSymbol()}';
                  var canClose = estimate?.canClose == true;
                  return Text(
                    canClose ? display : '--',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.2142,
                      color: context.textColorTheme.textColorSecondary,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        _buildSellButton(context),
      ],
    );
  }

  Widget _buildSellButton(BuildContext context) {
    return ValueListenableBuilder2(
      first: widget.estimateNotifier,
      second: widget.closeStateNotifier,
      builder: (context, estimate, closeState, _) {
        if (closeState.isLoading) {
          return _sellButtonContainer(
            context,
            child: SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: context.textColorTheme.textColorSecondary,
              ),
            ),
          );
        }

        if (closeState.isSuccess) {
          return _sellButtonContainer(
            context,
            child: Text(
              'SOLD',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: context.textColorTheme.textColorQuaternary,
              ),
            ),
          );
        }

        if (estimate == null || !estimate.canClose) {
          return _sellButtonContainer(
            context,
            child: Text(
              'SELL',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: context.textColorTheme.textColorQuaternary,
              ),
            ),
          );
        }

        return Touchable.plain(
          onTap: widget.onSellTap,
          child: _sellButtonContainer(
            context,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'SELL',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: context.textColorTheme.textColorSecondary,
                  ),
                ),
                Dimens.hGap4,
                SvgPicture.asset(
                  Assets.svgsIcSellPositionCoin,
                  width: 12,
                  height: 12,
                  colorFilter: ColorFilter.mode(
                    context.textColorTheme.textColorSecondary,
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

  Widget _sellButtonContainer(
    BuildContext context, {
    required Widget child,
  }) {
    return Container(
      height: 30,
      width: 80,
      decoration: BoxDecoration(
        color: context.appColors.cardSecondary,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: context.colorScheme.outline,
          width: 0.5,
        ),
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
