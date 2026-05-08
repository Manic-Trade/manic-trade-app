import 'package:finality/common/constants/currencies.dart';
import 'package:finality/common/utils/color_scheme_extensions.dart';
import 'package:finality/common/utils/decimal_format.dart';
import 'package:finality/common/utils/haptic_feedback_utils.dart';
import 'package:finality/common/utils/value_listenable_removable.dart';
import 'package:finality/common/widgets/touchable.dart';
import 'package:finality/core/notifier/computed_notifier.dart';
import 'package:finality/data/drift/entities/options_trading_schedule.dart';
import 'package:finality/features/highlow/components/input_expiry_type_sheet.dart';
import 'package:finality/features/highlow/components/market_closed_overlay.dart';
import 'package:finality/features/highlow/components/trade_direction_button.dart';
import 'package:finality/features/highlow/components/v1/input_amount_sheet.dart';
import 'package:finality/features/highlow/components/v1/input_payout_multiplier_sheet.dart';
import 'package:finality/features/highlow/components/v1/input_time_by_clock_sheet.dart';
import 'package:finality/features/highlow/components/v1/input_time_by_duration_sheet.dart';
import 'package:finality/domain/options/entities/options_time_mode.dart';
import 'package:finality/domain/options/entities/options_duration.dart';
import 'package:finality/domain/premium/entities/premium_result_pair.dart';
import 'package:finality/features/highlow/utils/settle_time_utils.dart';
import 'package:finality/generated/assets.dart';
import 'package:finality/theme/attrs/text_color_theme.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

/// 交易面板回调数据
class TradePaceOrderData {
  final OptionsTimeMode expiryType;
  final TimerDuration duration;
  final DateTime? settleTime;
  final double amount;
  final double payoutMultiplier;

  const TradePaceOrderData({
    required this.expiryType,
    required this.duration,
    this.settleTime,
    required this.amount,
    required this.payoutMultiplier,
  });

  int get endTimeSecs => settleTime != null
      ? settleTime!.millisecondsSinceEpoch ~/ 1000
      : (DateTime.now().millisecondsSinceEpoch ~/ 1000) + duration.seconds;
}

/// 交易面板控制器，用于外部触发交易操作
class TradePaceOrderPanelController {
  _TradePaceOrderPanelState? _state;

  /// 内部方法：注册 State 实例
  void _registerState(_TradePaceOrderPanelState state) {
    _state = state;
  }

  /// 内部方法：注销 State 实例
  void _unregisterState() {
    _state = null;
  }

  /// 触发 HIGHER 按钮点击
  /// 返回 true 表示成功触发，false 表示无法触发（如数据无效或正在加载）
  bool triggerHigher() {
    if (_state == null) return false;
    return _state!._triggerHigher();
  }

  /// 触发 LOWER 按钮点击
  /// 返回 true 表示成功触发，false 表示无法触发（如数据无效或正在加载）
  bool triggerLower() {
    if (_state == null) return false;
    return _state!._triggerLower();
  }
}

/// 横向布局交易面板 Widget（标签在左，值在右，节省纵向空间）
class TradePaceOrderPanel extends StatefulWidget {
  /// 点击 HIGHER 按钮回调
  final void Function(TradePaceOrderData data)? onHigherPressed;

  /// 点击 LOWER 按钮回调
  final void Function(TradePaceOrderData data)? onLowerPressed;

  /// 是否正在加载（下单中）
  final bool isLoading;
  final bool canTrade;

  final OptionsTradingSchedule? tradingSchedule;

  final double initialPayoutMultiplier;
  final double leverageMax;
  final TimerDuration initialDuration;

  /// 默认金额
  final double initialAmount;

  /// 金额步进值
  final double amountStep;

  /// 最小金额
  final double minAmount;

  /// 最大金额
  final double? maxAmount;

  /// 余额
  final ValueListenable<double> balance;

  final ValueListenable<int?> lastBeat;

  final ValueListenable<PremiumResultPair> premium;

  /// 赔付倍数变化回调
  final void Function(double payoutMultiplier)? onPayoutMultiplierChanged;

  /// 持仓时长变化回调
  final void Function(int? durationSeconds, DateTime? settleTime)?
      onSettleTimeChanged;

  /// 控制器，用于外部触发交易操作
  final TradePaceOrderPanelController? controller;

  const TradePaceOrderPanel({
    super.key,
    this.onHigherPressed,
    this.onLowerPressed,
    this.isLoading = false,
    this.canTrade = true,
    this.tradingSchedule,
    this.initialPayoutMultiplier = 1.0,
    this.leverageMax = 100.0,
    this.initialDuration = TimerDuration.m1,
    this.initialAmount = 10.0,
    this.amountStep = 10.0,
    this.minAmount = 1.0,
    this.maxAmount,
    required this.balance,
    required this.lastBeat,
    required this.premium,
    this.onPayoutMultiplierChanged,
    this.onSettleTimeChanged,
    this.controller,
  });

  @override
  State<TradePaceOrderPanel> createState() => _TradePaceOrderPanelState();
}

class _TradePaceOrderPanelState extends State<TradePaceOrderPanel> {
  OptionsTimeMode _expiryType = OptionsTimeMode.timer;

  late final ValueNotifier<TimerDuration> _durationNotifier =
      ValueNotifier(widget.initialDuration);

  late final ValueNotifier<TimerDuration> _unifiedDurationNotifier =
      ValueNotifier(TimerDuration.m1);

  late final ComputedNotifier2<DateTime?, int?, TimerDuration>
      _settleTimeNotifier = ComputedNotifier2(
    source1: widget.lastBeat,
    source2: _unifiedDurationNotifier,
    compute: (lastBeat, duration) {
      if (lastBeat == null) return null;
      return SettleTimeUtils.calculateSettleTimeBySeconds(
          lastBeat, duration.seconds);
    },
  );
  // Payout Multiplier（杠杆倍率）
  late double _payoutMultiplier;
  final double _minMultiplier = 1.0;
  double _maxMultiplier = 100.0;

  late double _amount;

  Removable? _durationRemovable;
  Removable? lastBeatRemovable;

  @override
  void initState() {
    super.initState();
    _maxMultiplier = widget.leverageMax;
    _amount = widget.initialAmount
        .clamp(widget.minAmount, widget.maxAmount ?? double.infinity);
    updateExpiryType(OptionsTimeMode.timer);
    updatePayoutMultiplier(
        widget.initialPayoutMultiplier.clamp(_minMultiplier, _maxMultiplier));
    widget.controller?._registerState(this);
  }

  @override
  void didUpdateWidget(TradePaceOrderPanel oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.leverageMax != oldWidget.leverageMax) {
      _maxMultiplier = widget.leverageMax;
    }

    if (widget.initialPayoutMultiplier != oldWidget.initialPayoutMultiplier) {
      updatePayoutMultiplier(
          widget.initialPayoutMultiplier.clamp(_minMultiplier, _maxMultiplier));
    } else if (widget.leverageMax != oldWidget.leverageMax) {
      final clamped = _payoutMultiplier.clamp(_minMultiplier, _maxMultiplier);
      if (clamped != _payoutMultiplier) {
        updatePayoutMultiplier(clamped);
      }
    }

    if (widget.initialAmount != oldWidget.initialAmount) {
      _amount = widget.initialAmount
          .clamp(widget.minAmount, widget.maxAmount ?? double.infinity);
    } else if (widget.maxAmount != oldWidget.maxAmount ||
        widget.minAmount != oldWidget.minAmount) {
      _amount =
          _amount.clamp(widget.minAmount, widget.maxAmount ?? double.infinity);
    }
  }

  void updatePayoutMultiplier(double payoutMultiplier) {
    _payoutMultiplier = payoutMultiplier;
    widget.onPayoutMultiplierChanged?.call(payoutMultiplier);
  }

  void updateExpiryType(OptionsTimeMode expiryType) {
    _expiryType = expiryType;
    _durationRemovable?.remove();
    lastBeatRemovable?.remove();
    if (_expiryType == OptionsTimeMode.timer) {
      _durationRemovable = _durationNotifier.listen((duration) {
        widget.onSettleTimeChanged?.call(duration.seconds, null);
      }, immediate: true);
    } else {
      lastBeatRemovable = _settleTimeNotifier.listen((settleTime) {
        if (settleTime == null) return;
        widget.onSettleTimeChanged?.call(null, settleTime);
      }, immediate: true);
    }
  }

  @override
  void dispose() {
    widget.controller?._unregisterState();
    _durationRemovable?.remove();
    lastBeatRemovable?.remove();
    _durationNotifier.dispose();
    _unifiedDurationNotifier.dispose();
    _settleTimeNotifier.dispose();
    super.dispose();
  }

  String _durationDisplayText(TimerDuration duration) {
    final seconds = duration.seconds;
    if (seconds < 60) {
      return '$seconds sec';
    } else {
      return '${seconds ~/ 60} min';
    }
  }

  TradePaceOrderData? _buildPanelData() {
    if (_expiryType == OptionsTimeMode.timer) {
      return TradePaceOrderData(
        expiryType: _expiryType,
        duration: _durationNotifier.value,
        amount: _amount,
        payoutMultiplier: _payoutMultiplier,
      );
    } else {
      var lastBeat = widget.lastBeat.value;
      if (lastBeat == null) return null;
      return TradePaceOrderData(
        expiryType: _expiryType,
        settleTime: _settleTimeNotifier.value,
        amount: _amount,
        duration: _unifiedDurationNotifier.value,
        payoutMultiplier: _payoutMultiplier,
      );
    }
  }

  /// 触发 HIGHER 按钮（供 Controller 调用）
  bool _triggerHigher() {
    if (widget.isLoading || !widget.canTrade) return false;
    var data = _buildPanelData();
    if (data != null) {
      widget.onHigherPressed?.call(data);
      return true;
    }
    return false;
  }

  /// 触发 LOWER 按钮（供 Controller 调用）
  bool _triggerLower() {
    if (widget.isLoading || !widget.canTrade) return false;
    var data = _buildPanelData();
    if (data != null) {
      widget.onLowerPressed?.call(data);
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return MarketClosedOverlay(
      tradingSchedule: widget.tradingSchedule,
      canTrade: widget.canTrade,
      child: IgnorePointer(
        ignoring: !widget.canTrade,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Dimens.vGap12,
              _buildFirstConfigRow(context),
              Dimens.vGap12,
              _buildSecondConfigRow(context),
              Dimens.vGap12,
              _buildTradeButtonsWithPayout(context),
              Dimens.vGap12,
            ],
          ),
        ),
      ),
    );
  }

  /// 第一行配置：Expiry Type (左) | Payout Multiplier (右)
  Widget _buildFirstConfigRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildExpiryTypeField(context),
        ),
        Dimens.hGap12,
        Expanded(
          child: _buildPayoutMultiplierField(context),
        ),
      ],
    );
  }

  /// 第二行配置：Duration (左) | Amount (右)
  Widget _buildSecondConfigRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _expiryType == OptionsTimeMode.timer
              ? _buildDurationField(context)
              : _buildSettleTimeField(context),
        ),
        Dimens.hGap12,
        Expanded(
          child: _buildAmountField(context),
        ),
      ],
    );
  }

  /// 横向标签-值字段（通用样式）
  Widget _buildLabelValueField(
    BuildContext context, {
    required String label,
    required String value,
    Color? valueColor,
    FontWeight? valueFontWeight,
    required VoidCallback onTap,
  }) {
    return Touchable.plain(
      onTap: onTap,
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: context.colorScheme.surfaceContainerHigh,
          borderRadius: Dimens.radius6,
          border:
              Border.all(color: context.colorScheme.outlineVariant, width: 0.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: context.textTheme.labelSmall?.copyWith(
                color: context.textColorTheme.textColorQuaternary,
                height: 1,
              ),
            ),
            Text(
              value,
              style: context.textTheme.labelMedium?.copyWith(
                color: valueColor ?? context.textColorTheme.textColorSecondary,
                height: 1,
                fontWeight: valueFontWeight ?? FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Expiry Type 字段
  Widget _buildExpiryTypeField(BuildContext context) {
    return _buildLabelValueField(
      context,
      label: 'Expiry Type',
      value: _expiryType.label,
      onTap: () async {
        final newType =
            await showExpiryTypeSheet(context, initialExpiryType: _expiryType);
        if (newType != null && newType != _expiryType) {
          HapticFeedbackUtils.lightImpact();
          setState(() => updateExpiryType(newType));
        }
      },
    );
  }

  /// Payout Multiplier 字段
  Widget _buildPayoutMultiplierField(BuildContext context) {
    return _buildLabelValueField(
      context,
      label: 'Payout Multiplier',
      value: '${_payoutMultiplier.toStringAsFixed(1)}x',
      valueColor: context.colorScheme.primary,
      valueFontWeight: FontWeight.w600,
      onTap: () async {
        var newPayoutMultiplier = await showPayoutMultiplierSheet(context,
            initialPayoutMultiplier: _payoutMultiplier,
            leverageMax: widget.leverageMax);
        if (newPayoutMultiplier != null) {
          setState(() {
            updatePayoutMultiplier(newPayoutMultiplier);
          });
        }
      },
    );
  }

  /// Duration 字段（Individual 模式）
  Widget _buildDurationField(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _durationNotifier,
      builder: (context, duration, child) {
        return _buildLabelValueField(
          context,
          label: 'Duration',
          value: _durationDisplayText(duration),
          onTap: () async {
            var newDuration = await showInputTimeByDurationSheet(context,
                initialDuration: duration);
            if (newDuration != null) {
              _durationNotifier.value = newDuration;
            }
          },
        );
      },
    );
  }

  /// Settle Time 字段（Unified 模式）
  Widget _buildSettleTimeField(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _settleTimeNotifier,
      builder: (context, settleTime, child) {
        return _buildLabelValueField(
          context,
          label: 'Settle Time',
          value: settleTime == null
              ? '--:--'
              : SettleTimeUtils.formatSettleTime(settleTime),
          onTap: () async {
            var newSettleTime = await showInputTimeByClockSheet(context,
                lastBeatSeconds: widget.lastBeat,
                initialDuration: _unifiedDurationNotifier.value);
            if (newSettleTime != null) {
              _unifiedDurationNotifier.value = newSettleTime;
            }
          },
        );
      },
    );
  }

  /// Amount 字段
  Widget _buildAmountField(BuildContext context) {
    return _buildLabelValueField(
      context,
      label: 'Amount',
      value: Currencies.symbolUsd + _amount.formatWithDecimals(2),
      onTap: () async {
        var newAmount = await showAmountSheet(context,
            initialAmount: _amount,
            balance: widget.balance.value,
            minAmount: widget.minAmount,
            maxAmount: widget.maxAmount);
        if (newAmount != null) {
          setState(() {
            _amount = newAmount;
          });
        }
      },
    );
  }

  /// Duration 减少（保留逻辑供外部调用）
  void decreaseDuration() {
    final duration = _durationNotifier.value;
    final index = TimerDuration.values.indexOf(duration);
    if (index > 0) {
      HapticFeedbackUtils.lightImpact();
      _durationNotifier.value = TimerDuration.values[index - 1];
    }
  }

  /// Duration 增加（保留逻辑供外部调用）
  void increaseDuration() {
    final duration = _durationNotifier.value;
    final index = TimerDuration.values.indexOf(duration);
    if (index < TimerDuration.values.length - 1) {
      HapticFeedbackUtils.lightImpact();
      _durationNotifier.value = TimerDuration.values[index + 1];
    }
  }

  /// Unified Duration 减少（保留逻辑供外部调用）
  void decreaseUnifiedDuration() {
    var duration = _unifiedDurationNotifier.value;
    final index = TimerDuration.values.indexOf(duration);
    if (index > 0) {
      HapticFeedbackUtils.lightImpact();
      _unifiedDurationNotifier.value = TimerDuration.values[index - 1];
    }
  }

  /// Unified Duration 增加（保留逻辑供外部调用）
  void increaseUnifiedDuration() {
    var duration = _unifiedDurationNotifier.value;
    final index = TimerDuration.values.indexOf(duration);
    if (index < TimerDuration.values.length - 1) {
      HapticFeedbackUtils.lightImpact();
      _unifiedDurationNotifier.value = TimerDuration.values[index + 1];
    }
  }

  /// Payout Multiplier 减少（保留逻辑供外部调用）
  void decreasePayoutMultiplier({double step = 0.5}) {
    if (_payoutMultiplier > _minMultiplier) {
      HapticFeedbackUtils.lightImpact();
      setState(() {
        updatePayoutMultiplier(
            (_payoutMultiplier - step).clamp(_minMultiplier, _maxMultiplier));
      });
    }
  }

  /// Payout Multiplier 增加（保留逻辑供外部调用）
  void increasePayoutMultiplier({double step = 0.5}) {
    if (_payoutMultiplier < _maxMultiplier) {
      HapticFeedbackUtils.lightImpact();
      setState(() {
        updatePayoutMultiplier(
            (_payoutMultiplier + step).clamp(_minMultiplier, _maxMultiplier));
      });
    }
  }

  /// Amount 减少（保留逻辑供外部调用）
  void decreaseAmount() {
    if (_amount > widget.minAmount) {
      HapticFeedbackUtils.lightImpact();
      setState(() {
        _amount = (_amount - widget.amountStep)
            .clamp(widget.minAmount, widget.maxAmount ?? double.infinity);
      });
    }
  }

  /// Amount 增加（保留逻辑供外部调用）
  void increaseAmount() {
    if (widget.maxAmount == null || _amount < widget.maxAmount!) {
      HapticFeedbackUtils.lightImpact();
      setState(() {
        _amount = (_amount + widget.amountStep)
            .clamp(widget.minAmount, widget.maxAmount ?? double.infinity);
      });
    }
  }

  /// 交易按钮区域（包含预期收益信息）
  Widget _buildTradeButtonsWithPayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: ValueListenableBuilder(
            valueListenable: widget.premium,
            builder: (context, value, child) {
              return _buildTradeCard(
                context,
                isHigher: true,
                earningsPercent: value.higher.targetEarningsPercent,
                earnings: value.higher.targetEarnings(_amount),
                onPressed: () {
                  var data = _buildPanelData();
                  if (data != null) {
                    widget.onHigherPressed?.call(data);
                  }
                },
              );
            },
          ),
        ),
        Dimens.hGap12,
        Expanded(
          child: ValueListenableBuilder(
            valueListenable: widget.premium,
            builder: (context, value, child) {
              return _buildTradeCard(
                context,
                isHigher: false,
                earningsPercent: value.lower.targetEarningsPercent,
                earnings: value.lower.targetEarnings(_amount),
                onPressed: () {
                  var data = _buildPanelData();
                  if (data != null) {
                    widget.onLowerPressed?.call(data);
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }

  /// 交易卡片（预期收益信息 + 交易按钮）
  Widget _buildTradeCard(
    BuildContext context, {
    required bool isHigher,
    required double earningsPercent,
    required double earnings,
    required VoidCallback onPressed,
  }) {
    final Color primaryColor =
        isHigher ? const Color(0xFF00D385) : const Color(0xFFFF412C);
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF161616), Color(0xFF0F0F0F)],
        ),
        borderRadius: Dimens.radius6,
        border:
            Border.all(color: context.colorScheme.outlineVariant, width: 0.5),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.10),
                    borderRadius: Dimens.radius4,
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      isHigher
                          ? Assets.svgsIcTradingUp
                          : Assets.svgsIcTradingDown,
                      colorFilter:
                          ColorFilter.mode(primaryColor, BlendMode.srcIn),
                      width: 12,
                      height: 12,
                    ),
                  ),
                ),
                Dimens.hGap8,
                Text(
                  '\$${(earnings + _amount).formatWithDecimals(2)}',
                  style: TextStyle(
                    color: context.textColorTheme.textColorSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.10),
                    borderRadius: Dimens.radius4,
                  ),
                  child: Text(
                    '+${(earningsPercent + 100).formatWithDecimals(2)}%',
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 8,
                      fontWeight: FontWeight.w500,
                      height: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
          TradeDirectionButton(
            isHigher: isHigher,
            isLoading: widget.isLoading,
            height: 52,
            onPressed: onPressed,
          ),
        ],
      ),
    );
  }
}
