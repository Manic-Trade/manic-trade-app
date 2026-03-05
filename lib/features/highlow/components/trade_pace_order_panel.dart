import 'package:finality/common/constants/currencies.dart';
import 'package:finality/common/utils/color_scheme_extensions.dart';
import 'package:finality/common/utils/decimal_format.dart';
import 'package:finality/common/utils/haptic_feedback_utils.dart';
import 'package:finality/common/utils/value_listenable_removable.dart';
import 'package:finality/common/widgets/touchable.dart';
import 'package:finality/core/notifier/computed_notifier.dart';
import 'package:finality/data/drift/entities/options_trading_schedule.dart';
import 'package:finality/features/highlow/components/function_description_sheet.dart';
import 'package:finality/features/highlow/components/input_amount_sheet.dart';
import 'package:finality/features/highlow/components/input_payout_multiplier_sheet.dart';
import 'package:finality/features/highlow/components/input_time_by_clock_sheet.dart';
import 'package:finality/features/highlow/components/input_time_by_duration_sheet.dart';
import 'package:finality/features/highlow/components/market_closed_overlay.dart';
import 'package:finality/features/highlow/components/trade_direction_button.dart';
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

/// Trade panel callback data
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
}

/// Trade panel controller for external triggering of trade operations
class TradePaceOrderPanelController {
  _TradePaceOrderPanelState? _state;

  /// Internal method: Register State instance
  void _registerState(_TradePaceOrderPanelState state) {
    _state = state;
  }

  /// Internal method: Unregister State instance
  void _unregisterState() {
    _state = null;
  }

  /// Trigger HIGHER button click
  /// Returns true if successfully triggered, false if cannot trigger (e.g. invalid data or loading)
  bool triggerHigher() {
    if (_state == null) return false;
    return _state!._triggerHigher();
  }

  /// Trigger LOWER button click
  /// Returns true if successfully triggered, false if cannot trigger (e.g. invalid data or loading)
  bool triggerLower() {
    if (_state == null) return false;
    return _state!._triggerLower();
  }
}

/// Vertical layout trade panel Widget (title on left, controls on right, arranged top to bottom)
class TradePaceOrderPanel extends StatefulWidget {
  /// HIGHER button click callback
  final void Function(TradePaceOrderData data)? onHigherPressed;

  /// LOWER button click callback
  final void Function(TradePaceOrderData data)? onLowerPressed;

  /// Whether loading (placing order)
  final bool isLoading;
  final bool canTrade;

  final OptionsTradingSchedule? tradingSchedule;

  final double initialPayoutMultiplier;
  final double leverageMax;
  final TimerDuration initialDuration;

  /// Default amount
  final double initialAmount;

  /// Amount step value
  final double amountStep;

  /// Minimum amount
  final double minAmount;

  /// Maximum amount
  final double? maxAmount;

  /// Balance
  final ValueListenable<double> balance;

  final ValueListenable<int?> lastBeat;

  final ValueListenable<PremiumResultPair> premium;

  /// Payout multiplier change callback
  final void Function(double payoutMultiplier)? onPayoutMultiplierChanged;

  /// Position duration change callback
  final void Function(int? durationSeconds, DateTime? settleTime)?
      onSettleTimeChanged;

  /// Controller for external triggering of trade operations
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
  // Payout Multiplier (leverage ratio)
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
    // Register Controller
    widget.controller?._registerState(this);
  }

  @override
  void didUpdateWidget(TradePaceOrderPanel oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update _maxMultiplier
    if (widget.leverageMax != oldWidget.leverageMax) {
      _maxMultiplier = widget.leverageMax;
    }

    // External update to initialPayoutMultiplier → apply new value (clamp to current range)
    if (widget.initialPayoutMultiplier != oldWidget.initialPayoutMultiplier) {
      updatePayoutMultiplier(
          widget.initialPayoutMultiplier.clamp(_minMultiplier, _maxMultiplier));
    } else if (widget.leverageMax != oldWidget.leverageMax) {
      // leverageMax changed but initialPayoutMultiplier didn't, re-clamp current value
      final clamped = _payoutMultiplier.clamp(_minMultiplier, _maxMultiplier);
      if (clamped != _payoutMultiplier) {
        updatePayoutMultiplier(clamped);
      }
    }

    // External update to initialAmount → apply new value (clamp to current range)
    if (widget.initialAmount != oldWidget.initialAmount) {
      _amount = widget.initialAmount
          .clamp(widget.minAmount, widget.maxAmount ?? double.infinity);
    } else if (widget.maxAmount != oldWidget.maxAmount ||
        widget.minAmount != oldWidget.minAmount) {
      // maxAmount or minAmount changed, re-clamp current _amount
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
    // Unregister Controller
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

  /// Trigger HIGHER button (for Controller call)
  bool _triggerHigher() {
    if (widget.isLoading || !widget.canTrade) return false;
    var data = _buildPanelData();
    if (data != null) {
      widget.onHigherPressed?.call(data);
      return true;
    }
    return false;
  }

  /// Trigger LOWER button (for Controller call)
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
              Dimens.vGap10,
            ],
          ),
        ),
      ),
    );
  }

  /// First row config: Expiry Type (left) | Payout Multiplier (right)
  Widget _buildFirstConfigRow(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left: Expiry Type
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionLabel(context, 'Expiry Type', onTap: () {
                showFunctionDescriptionSheet(context,
                    title: 'Expiry Type',
                    description:
                        'Each trade settles independently based on its own specific timeline.');
              }),
              Dimens.vGap8,
              _buildExpiryTypeSelector(context),
            ],
          ),
        ),
        Dimens.hGap12,
        // Right: Payout Multiplier
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionLabel(context, 'Payout Multiplier', onTap: () {
                showFunctionDescriptionSheet(context,
                    title: 'Payout Multiplier',
                    description:
                        'Payout Multiplier affects the entry price offset. A higher multiplier increases the gap between your entry price and the current price, raising the difficulty to win while also boosting potential returns. Choose wisely based on your market outlook.');
              }),
              Dimens.vGap8,
              _buildPayoutMultiplierSelector(context),
            ],
          ),
        ),
      ],
    );
  }

  /// Second row config: Duration (left) | Amount (right)
  Widget _buildSecondConfigRow(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left: Duration
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _expiryType == OptionsTimeMode.timer
                  ? _buildSectionLabel(context, 'Duration', onTap: () {
                      showFunctionDescriptionSheet(context,
                          title: 'Duration',
                          description:
                              'Set the duration for your trade. Each trade settles independently based on its own specific timeline.');
                    })
                  : _buildSectionLabel(context, 'Settle Time'),
              Dimens.vGap8,
              _expiryType == OptionsTimeMode.timer
                  ? _buildDurationSelector(context)
                  : _buildSettleTimeSelector(context),
            ],
          ),
        ),
        Dimens.hGap12,
        // Right: Amount
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildSectionLabel(context, 'Amount'),
                  const Spacer(),
                  // Balance displayed at top right
                  ValueListenableBuilder(
                    valueListenable: widget.balance,
                    builder: (context, value, child) {
                      return Text(
                        Currencies.symbolUsd + value.formatWithDecimals(2),
                        style: context.textTheme.labelSmall?.copyWith(
                          height: 1,
                          color: context.textColorTheme.textColorTertiary,
                        ),
                      );
                    },
                  ),
                ],
              ),
              Dimens.vGap8,
              _buildAmountSelectorRow(context),
            ],
          ),
        ),
      ],
    );
  }

  /// Section title (with question mark icon)
  Widget _buildSectionLabel(BuildContext context, String label,
      {VoidCallback? onTap}) {
    return Touchable.plain(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: context.textTheme.labelSmall?.copyWith(
              height: 1,
              color: context.textColorTheme.textColorTertiary,
            ),
          ),
          if (onTap != null) ...[
            Dimens.hGap4,
            Icon(
              Icons.help_outline,
              color: context.textColorTheme.textColorTertiary,
              size: 12,
            ),
          ],
        ],
      ),
    );
  }

  /// Expiry Type selector
  Widget _buildExpiryTypeSelector(BuildContext context) {
    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHigh,
        borderRadius: Dimens.radius4,
        border:
            Border.all(color: context.colorScheme.outlineVariant, width: 0.5),
      ),
      child: Row(
        children: [
          _buildExpiryTypeOption(
              context, OptionsTimeMode.timer, OptionsTimeMode.timer.label),
          _buildExpiryTypeOption(
              context, OptionsTimeMode.clock, OptionsTimeMode.clock.label),
        ],
      ),
    );
  }

  Widget _buildExpiryTypeOption(
      BuildContext context, OptionsTimeMode type, String label) {
    final isSelected = _expiryType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (isSelected) return;
          HapticFeedbackUtils.lightImpact();
          setState(() => updateExpiryType(type));
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color:
                isSelected ? context.colorScheme.primary : Colors.transparent,
            borderRadius: Dimens.radius4,
          ),
          child: Center(
            child: Text(
              label,
              style: context.textTheme.labelSmall?.copyWith(
                color: isSelected
                    ? context.colorScheme.onPrimary
                    : context.textColorTheme.textColorTertiary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Duration selector (Individual mode)
  Widget _buildDurationSelector(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: _durationNotifier,
        builder: (context, duration, child) {
          return _buildDropdownSelector(
            context,
            value: _durationDisplayText(duration),
            onTap: () async {
              var newDuration = await showInputTimeByDurationSheet(context,
                  initialDuration: duration);
              if (newDuration != null) {
                _durationNotifier.value = newDuration;
              }
            },
          );
        });
  }

  /// Decrease Duration (reserve logic for external call)
  void decreaseDuration() {
    final duration = _durationNotifier.value;
    final index = TimerDuration.values.indexOf(duration);
    if (index > 0) {
      HapticFeedbackUtils.lightImpact();
      _durationNotifier.value = TimerDuration.values[index - 1];
    }
  }

  /// Increase Duration (reserve logic for external call)
  void increaseDuration() {
    final duration = _durationNotifier.value;
    final index = TimerDuration.values.indexOf(duration);
    if (index < TimerDuration.values.length - 1) {
      HapticFeedbackUtils.lightImpact();
      _durationNotifier.value = TimerDuration.values[index + 1];
    }
  }

  /// Settle Time selector (Unified mode)
  Widget _buildSettleTimeSelector(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _settleTimeNotifier,
      builder: (context, settleTime, child) {
        return _buildDropdownSelector(
          context,
          value: settleTime == null
              ? "--:--"
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

  /// Decrease Unified Duration (reserve logic for external call)
  void decreaseUnifiedDuration() {
    var duration = _unifiedDurationNotifier.value;
    final index = TimerDuration.values.indexOf(duration);
    if (index > 0) {
      HapticFeedbackUtils.lightImpact();
      _unifiedDurationNotifier.value = TimerDuration.values[index - 1];
    }
  }

  /// Increase Unified Duration (reserve logic for external call)
  void increaseUnifiedDuration() {
    var duration = _unifiedDurationNotifier.value;
    final index = TimerDuration.values.indexOf(duration);
    if (index < TimerDuration.values.length - 1) {
      HapticFeedbackUtils.lightImpact();
      _unifiedDurationNotifier.value = TimerDuration.values[index + 1];
    }
  }

  /// Payout Multiplier selector
  Widget _buildPayoutMultiplierSelector(BuildContext context) {
    return Touchable.plain(
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
      child: Container(
        height: 32,
        decoration: BoxDecoration(
          color: context.colorScheme.surfaceContainerHigh,
          borderRadius: Dimens.radius4,
          border:
              Border.all(color: context.colorScheme.outlineVariant, width: 0.5),
        ),
        alignment: Alignment.center,
        child: Text(
          '${_payoutMultiplier.toStringAsFixed(1)}x',
          style: context.textTheme.labelMedium?.copyWith(
            color: context.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// Decrease Payout Multiplier (reserve logic for external call)
  void decreasePayoutMultiplier({double step = 0.5}) {
    if (_payoutMultiplier > _minMultiplier) {
      HapticFeedbackUtils.lightImpact();
      setState(() {
        updatePayoutMultiplier(
            (_payoutMultiplier - step).clamp(_minMultiplier, _maxMultiplier));
      });
    }
  }

  /// Increase Payout Multiplier (reserve logic for external call)
  void increasePayoutMultiplier({double step = 0.5}) {
    if (_payoutMultiplier < _maxMultiplier) {
      HapticFeedbackUtils.lightImpact();
      setState(() {
        updatePayoutMultiplier(
            (_payoutMultiplier + step).clamp(_minMultiplier, _maxMultiplier));
      });
    }
  }

  /// Amount selector row
  Widget _buildAmountSelectorRow(BuildContext context) {
    return _buildDropdownSelector(
      context,
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

  /// Decrease Amount (reserve logic for external call)
  void decreaseAmount() {
    if (_amount > widget.minAmount) {
      HapticFeedbackUtils.lightImpact();
      setState(() {
        _amount = (_amount - widget.amountStep)
            .clamp(widget.minAmount, widget.maxAmount ?? double.infinity);
      });
    }
  }

  /// Increase Amount (reserve logic for external call)
  void increaseAmount() {
    if (widget.maxAmount == null || _amount < widget.maxAmount!) {
      HapticFeedbackUtils.lightImpact();
      setState(() {
        _amount = (_amount + widget.amountStep)
            .clamp(widget.minAmount, widget.maxAmount ?? double.infinity);
      });
    }
  }

  /// Dropdown selector style widget (pops up after click)
  Widget _buildDropdownSelector(
    BuildContext context, {
    required String value,
    required VoidCallback onTap,
  }) {
    return Touchable.plain(
      onTap: onTap,
      child: Container(
        height: 32,
        decoration: BoxDecoration(
          color: context.colorScheme.surfaceContainerHigh,
          borderRadius: Dimens.radius4,
          border:
              Border.all(color: context.colorScheme.outlineVariant, width: 0.5),
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                value,
                style: context.textTheme.labelSmall?.copyWith(
                  color: context.textColorTheme.textColorSecondary,
                  fontSize: 12,
                  height: 1,
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: Center(
                    child: SvgPicture.asset(
                      Assets.svgsIcArrowDownCommonSmall,
                      width: 10,
                      height: 10,
                      color: context.textColorTheme.textColorTertiary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Trade button area (includes expected earnings information)
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
        // LOWER area
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

  /// Trade card (includes expected earnings and button)
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
        color: context.colorScheme.surfaceContainerHigh,
        borderRadius: Dimens.radius6,
        border:
            Border.all(color: context.colorScheme.outlineVariant, width: 0.5),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
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
                          color: primaryColor,
                          width: 12,
                          height: 12,
                        ),
                      ),
                    ),
                    Dimens.hGap8,
                    Text(
                      'EXPECTED EARNING',
                      style: TextStyle(
                          color: context.textColorTheme.textColorHelper,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          height: 1),
                    ),
                  ],
                ),
                Dimens.vGap8,
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Container(
                    //   width: 20,
                    //   height: 20,
                    //   decoration: BoxDecoration(
                    //     color: primaryColor.withValues(alpha: 0.10),
                    //     borderRadius: Dimens.radius4,
                    //   ),
                    //   child: Center(
                    //     child: SvgPicture.asset(
                    //       isHigher
                    //           ? Assets.svgsIcTradingUp
                    //           : Assets.svgsIcTradingDown,
                    //       color: primaryColor,
                    //       width: 12,
                    //       height: 12,
                    //     ),
                    //   ),
                    // ),
                    // Dimens.hGap8,
                    Text(
                      '\$${(earnings + _amount).formatWithDecimals(2)}',
                      style: TextStyle(
                        color: context.textColorTheme.textColorSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Spacer(),
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
                        '+${(earningsPercent + 100).formatWithDecimals(2)}% Return',
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
              ],
            ),
          ),
          // Button
          TradeDirectionButton(
            isHigher: isHigher,
            isLoading: widget.isLoading,
            onPressed: onPressed,
          ),
        ],
      ),
    );
  }
}
