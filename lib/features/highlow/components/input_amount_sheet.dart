import 'package:dart_extensions_methods/dart_extension_methods.dart';
import 'package:finality/common/utils/color_scheme_extensions.dart';
import 'package:finality/common/utils/decimal_format.dart';
import 'package:finality/common/utils/haptic_feedback_utils.dart';
import 'package:finality/common/widgets/drag_handle.dart';
import 'package:finality/common/widgets/touchable.dart';
import 'package:finality/common/widgets/blinking_cursor.dart';
import 'package:finality/features/assets/transfer/widgets/numeric_keypad.dart';
import 'package:finality/theme/app_color_theme.dart';
import 'package:finality/theme/attrs/text_color_theme.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/context_extensions.dart';

class InputAmountSheet extends StatefulWidget {
  final double initialAmount;
  final double balance;
  final double minAmount;
  final double? maxAmount;
  final List<double> presetAmounts;

  const InputAmountSheet({
    super.key,
    required this.initialAmount,
    required this.balance,
    this.minAmount = 1,
    this.maxAmount,
    this.presetAmounts = const [10, 20, 50, 100],
  });

  @override
  State<InputAmountSheet> createState() => _InputAmountSheetState();
}

class _InputAmountSheetState extends State<InputAmountSheet> {
  final ValueNotifier<String> _amountNotifier = ValueNotifier<String>('');
  @override
  void initState() {
    super.initState();

    _amountNotifier.value = _formatAmount(widget.initialAmount);
  }

  @override
  void dispose() {
    _amountNotifier.dispose();
    super.dispose();
  }

  String _formatAmount(double amount) {
    if (amount == amount.roundToDouble()) {
      return amount.toInt().toString();
    }
    return amount.toStringAsFixed(2);
  }

  String _formatBalance(double balance) {
    return balance.formatWithDecimals(2);
  }

  void _onPresetTap(double amount) {
    _amountNotifier.value = _formatAmount(amount);
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
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const DragHandle(),
            Padding(
              padding: Dimens.edgeInsetsA16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  Dimens.vGap40,
                  _buildInputAmount(context, _amountNotifier),
                  Dimens.vGap24,
                  _buildDivider(context),
                  Dimens.vGap24,
                  _buildPresetAmounts(context),
                  Dimens.vGap16,
                  SizedBox(
                    height: 260,
                    child: NumericKeypad(
                      onNumberPressed: (number) {
                        _onNumberPressed(number);
                      },
                      onDeletePressed: () {
                        return onDeletePressed();
                      },
                      fontScale: 1,
                      enable: true,
                      maxFontSize: 32,
                      minFontSize: 16,
                      fontWeight: FontWeight.w500,
                      textColor: context.textColorTheme.textColorSecondary,
                    ),
                  ),
                  Dimens.vGap16,
                  _buildConfirmButton(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const int priceDecimalPlaces = 2; // 价格的最大小数位数
  void _onNumberPressed(
    String number,
  ) {
    final currentValue = _amountNotifier.value;
    if (currentValue.isNotEmpty &&
        (currentValue.toDoubleOrNull() ?? 0) > widget.balance) {
      return;
    }
    if (currentValue == '0' && number == '0') return;
    if (number == '.' && currentValue.contains('.')) return;
    // 价格输入限制最多输入 priceDecimalPlaces 位小数
    if (currentValue.contains('.')) {
      final decimalPlaces = currentValue.split('.')[1].length;
      if (decimalPlaces >= priceDecimalPlaces && number != '.') return;
    }

    if (currentValue == '' && number == '.') {
      _amountNotifier.value = "0.";
    } else {
      _amountNotifier.value =
          currentValue == '0' && number != '.' ? number : currentValue + number;
    }
  }

  bool onDeletePressed() {
    final currentValue = _amountNotifier.value;
    if (currentValue.isEmpty) return false;
    _amountNotifier.value = currentValue.length > 1
        ? currentValue.substring(0, currentValue.length - 1)
        : '';
    return true;
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Amount',
          style: context.textTheme.titleLarge?.copyWith(
            color: context.appColors.bottomSheetTitle,
          ),
        ),
        Text(
          'Balance: ${_formatBalance(widget.balance)}',
          style: context.textTheme.labelMedium?.copyWith(
            color: context.appColors.bottomSheetSubtitle,
          ),
        ),
      ],
    );
  }

  Widget _buildInputAmount(
      BuildContext context, ValueListenable<String> amountNotifier) {
    return Center(
      child: SizedBox(
        height: 60,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: ValueListenableBuilder<String>(
            valueListenable: amountNotifier,
            builder: (context, amount, child) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '\$',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                      color: context.textColorTheme.textColorTertiary,
                      height: 1.21875,
                    ),
                  ),
                  Dimens.hGap4,
                  Text(
                    amount.isEmpty ? '0' : amount,
                    style: TextStyle(
                        fontSize: 48,
                        color: amount.isEmpty
                            ? context.textColorTheme.textColorHelper
                            : context.textColorTheme.textColorPrimary,
                        fontWeight: FontWeight.w600,
                        height: 1.2291),
                  ),
                  SizedBox(
                    height: 57,
                    width: 9,
                    child: Center(
                      child: BlinkingCursor(
                        duration: const Duration(milliseconds: 600),
                        child: Container(
                          width: 2,
                          height: 40,
                          color: context.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  Dimens.hGap6,
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Container(
      height: 1,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          stops: [0.05, 0.5, 0.95],
          colors: [
            Color(0xFF101010),
            Color(0xFF2C2C2C),
            Color(0xFF101010),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetAmounts(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemCount = widget.presetAmounts.length;
        const spacing = 16.0;
        final itemWidth =
            (constraints.maxWidth - spacing * (itemCount - 1)) / itemCount;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: widget.presetAmounts.map((amount) {
            return SizedBox(
              width: itemWidth,
              child: _buildPresetAmountItem(
                  context, amount, false), //isSelected 加了抢用户注意力
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildPresetAmountItem(
      BuildContext context, double amount, bool isSelected) {
    return Touchable.plain(
      onTap: () {
        _onPresetTap(amount);
      },
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: isSelected
              ? context.colorScheme.primary.withValues(alpha: 0.05)
              : context.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected
                ? context.colorScheme.primary
                : context.colorScheme.outlineVariant,
            width: isSelected ? 1 : 0.8,
          ),
        ),
        child: Center(
          child: Text(
            '\$${_formatAmount(amount)}',
            style: context.textTheme.labelLarge?.copyWith(
              color: isSelected
                  ? context.textColorTheme.textColorPrimary
                  : context.textColorTheme.textColorSecondary,
            ),
          ),
        ),
      ),
    );
  }

  String? _getErrorText(double? amount) {
    if (amount == null) return null;
    if (amount < widget.minAmount) {
      return 'Min \$${widget.minAmount.toInt()} required';
    }
    if (amount > widget.balance) return 'Insufficient balance';
    if (widget.maxAmount != null && amount > widget.maxAmount!) {
      return 'Max \$${widget.maxAmount!.toInt()} exceeded';
    }
    return null;
  }

  Widget _buildConfirmButton(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: _amountNotifier,
        builder: (context, currentAmount, child) {
          final amount = currentAmount.toDoubleOrNull();
          final errorText = _getErrorText(amount);
          final isValid = amount != null && errorText == null;
          return Touchable.button(
            enable: isValid,
            child: SizedBox(
                width: double.infinity,
                height: 40,
                child: FilledButton(
                  onPressed: isValid
                      ? () {
                          HapticFeedbackUtils.lightImpact();
                          Navigator.of(context).pop(amount);
                        }
                      : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: context.colorScheme.primary,
                    foregroundColor: context.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: Text(
                    errorText ?? 'Confirm',
                    style: context.textTheme.labelMedium?.copyWith(
                      color: context.colorScheme.onPrimary,
                    ),
                  ),
                )),
          );
        });
  }
}

/// 显示 Amount 选择底部弹窗
Future<double?> showAmountSheet(
  BuildContext context, {
  required double initialAmount,
  required double balance,
  double minAmount = 1,
  double? maxAmount,
  List<double> presetAmounts = const [10, 20, 50, 100],
}) {
  return showModalBottomSheet<double>(
    context: context,
    isScrollControlled: true,
    constraints: null,
    backgroundColor: Colors.transparent,
    builder: (_) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: InputAmountSheet(
        initialAmount: initialAmount,
        balance: balance,
        minAmount: minAmount,
        maxAmount: maxAmount,
        presetAmounts: presetAmounts,
      ),
    ),
  );
}
