import 'dart:async';

import 'package:finality/common/constants/blockchain.dart';
import 'package:finality/common/toast/app_toast_manager.dart';
import 'package:finality/common/utils/color_scheme_extensions.dart';
import 'package:finality/common/utils/haptic_feedback_utils.dart';
import 'package:finality/common/widgets/drag_handle.dart';
import 'package:finality/common/widgets/touchable.dart';
import 'package:finality/di/injector.dart';
import 'package:finality/domain/wallet/entities/account_network.dart';
import 'package:finality/features/withdraw/withdraw_logic.dart';
import 'package:finality/generated/assets.dart';
import 'package:finality/services/wallet/wallet_service.dart';
import 'package:finality/theme/app_color_theme.dart';
import 'package:finality/theme/attrs/text_color_theme.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:remixicon/remixicon.dart';

/// 显示提现页面
Future<void> showWithdrawSheet(BuildContext context) async {
  final walletService = injector<WalletService>();
  final walletAccounts = walletService.walletAccounts.value;
  if (walletAccounts == null) return;

  final account = walletAccounts.accounts.firstWhere(
    (a) => a.networkCode == Tokens.usdc.networkCode,
  );
  final network = Networks.getNetwork(Tokens.usdc.networkCode);
  if (network == null) return;
  if (!context.mounted) return;

  await showCupertinoModalBottomSheet<void>(
    context: context,
    expand: true,
    duration: const Duration(milliseconds: 250),
    topRadius: Dimens.sheetTopRadius,
    builder: (_) => WithdrawSheet(
      accountNetwork: AccountNetwork(account, network),
    ),
  );
}

class WithdrawSheet extends StatefulWidget {
  final AccountNetwork accountNetwork;

  const WithdrawSheet({super.key, required this.accountNetwork});

  @override
  State<WithdrawSheet> createState() => _WithdrawSheetState();
}

class _WithdrawSheetState extends State<WithdrawSheet> {
  late final WithdrawLogic _logic;
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final FocusNode _amountFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _logic = WithdrawLogic(accountNetwork: widget.accountNetwork);
    _logic.init();
    _addressController.addListener(_onAddressChanged);
    _amountController.addListener(_onAmountChanged);
  }

  @override
  void dispose() {
    _addressController.removeListener(_onAddressChanged);
    _amountController.removeListener(_onAmountChanged);
    _addressController.dispose();
    _amountController.dispose();
    _focusNode.dispose();
    _amountFocusNode.dispose();
    _logic.dispose();
    super.dispose();
  }

  void _onAddressChanged() {
    _logic.validateAddress(_addressController.text.trim());
  }

  void _onAmountChanged() {
    _logic.amountNotifier.value = _amountController.text.trim();
  }

  Future<void> _onConfirm() async {
    final address = _addressController.text.trim();
    final error = _logic.validateSubmit(address);
    if (error != null) {
      AppToastManager.showFailed(title: error);
      return;
    }

    // 关闭弹窗
    Navigator.pop(context);

    // 显示 loading toast
    final toastId = AppToastManager.showLoading(
      title: 'Processing withdrawal...',
      subtitle: 'Your withdrawal is being processed.',
    );

    try {
      await _logic.executeWithdraw(toAddress: address);
      AppToastManager.updateToSuccess(toastId, title: 'Withdrawal submitted');
      HapticFeedbackUtils.vibration(HapticsType.success);
    } catch (_) {
      AppToastManager.updateToFailed(toastId, title: 'Withdrawal failed');
      HapticFeedbackUtils.vibration(HapticsType.error);
    }
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
              body: SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: IgnorePointer(
                        child: SingleChildScrollView(
                          padding: Dimens.edgeInsetsH16,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Dimens.vGap16,
                              _buildHeader(context),
                              Dimens.vGap32,
                              _buildRecipientAddressField(context),
                              Dimens.vGap24,
                              _buildAmountField(context),
                              Dimens.vGap24,
                              _buildInfoCard(context),
                              Dimens.vGap24,
                              _buildTooltip(context),
                              Dimens.vGap16,
                            ],
                          ),
                        ),
                      ),
                    ),
                    _buildBottomButton(context),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== 标题区域 ====================

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'WITHDRAW',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                color: context.textColorTheme.textColorPrimary,
              ),
        ),
        Text(
          'Transfer funds to an external wallet',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: context.textColorTheme.textColorTertiary,
              ),
        ),
      ],
    );
  }

  // ==================== 收款地址 ====================

  Widget _buildRecipientAddressField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recipient Address',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: context.textColorTheme.textColorTertiary,
          ),
        ),
        Dimens.vGap4,
        GestureDetector(
          onTap: () => _focusNode.requestFocus(),
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: context.colorScheme.surfaceContainerHigh,
              borderRadius: Dimens.radius6,
              border: Border.all(
                color: context.colorScheme.outlineVariant,
                width: 0.5,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _addressController,
                    focusNode: _focusNode,
                    autocorrect: false,
                    enableSuggestions: false,
                    keyboardType: TextInputType.visiblePassword,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: context.textColorTheme.textColorPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Available in Beta',
                      hintStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: context.textColorTheme.textColorHelper
                            .withValues(alpha: 0.5),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 10),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
                // 粘贴/清除按钮
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _addressController,
                  builder: (context, value, _) {
                    if (value.text.isEmpty) {
                      return Touchable(
                        onTap: _onPaste,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            'Paste',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: context.colorScheme.primary,
                            ),
                          ),
                        ),
                      );
                    }
                    return Touchable.iconButton(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Icon(
                          RemixIcons.close_circle_fill,
                          size: 16,
                          color: context.textColorTheme.textColorQuaternary,
                        ),
                      ),
                      onTap: () => _addressController.clear(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        // 地址校验提示
        ValueListenableBuilder<bool?>(
          valueListenable: _logic.addressValidNotifier,
          builder: (context, isValid, _) {
            if (isValid == null) return const SizedBox.shrink();
            if (isValid) return const SizedBox.shrink();
            return Padding(
              padding: Dimens.edgeInsetsT4,
              child: Text(
                'Invalid Solana address',
                style: TextStyle(
                  fontSize: 11,
                  color: context.appColors.bearish,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  void _onPaste() {
    Clipboard.getData(Clipboard.kTextPlain).then((data) {
      final text = data?.text;
      if (text != null) {
        _addressController.text = text;
      }
    });
  }

  // ==================== 金额输入 ====================

  Widget _buildAmountField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标签行：Amount ... Balance X USDC
        Row(
          children: [
            Expanded(
              child: Text(
                'Amount',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: context.textColorTheme.textColorTertiary,
                ),
              ),
            ),
            Text(
              'Balance ',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: context.textColorTheme.textColorTertiary,
              ),
            ),
            ValueListenableBuilder<String>(
              valueListenable: _logic.balanceNotifier,
              builder: (context, balance, _) {
                return Text(
                  '$balance USDC',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: context.textColorTheme.textColorPrimary,
                  ),
                );
              },
            ),
          ],
        ),
        Dimens.vGap4,
        // 金额输入框
        GestureDetector(
          onTap: () => _amountFocusNode.requestFocus(),
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: context.colorScheme.surfaceContainerHigh,
              borderRadius: Dimens.radius6,
              border: Border.all(
                color: context.colorScheme.outlineVariant,
                width: 0.5,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _amountController,
                    focusNode: _amountFocusNode,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,6}')),
                    ],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: context.textColorTheme.textColorPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Available in Beta',
                      hintStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: context.textColorTheme.textColorHelper
                            .withValues(alpha: 0.5),
                      ),
                      contentPadding: EdgeInsets.zero,
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
                // MAX 按钮
                Touchable(
                  onTap: () {
                    _logic.setMaxAmount();
                    _amountController.text = _logic.amountNotifier.value;
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDB8300).withValues(alpha: 0.1),
                      borderRadius: Dimens.radius4,
                    ),
                    child: const Text(
                      'MAX',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFDB8300),
                      ),
                    ),
                  ),
                ),
                Dimens.hGap8,
                // USDC 标识
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  decoration: BoxDecoration(
                    color: context.colorScheme.outlineVariant,
                    borderRadius: Dimens.radius4,
                    border: Border.all(
                      color: context.colorScheme.outlineVariant,
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        Assets.tokenIconUsdc,
                        width: 12,
                        height: 12,
                      ),
                      Dimens.hGap4,
                      Text(
                        'USDC',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: context.textColorTheme.textColorPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ==================== 信息卡片 ====================

  Widget _buildInfoCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHigh,
        borderRadius: Dimens.radius6,
        border: Border.all(
          color: context.colorScheme.outlineVariant,
          width: 0.5,
        ),
      ),
      child: ValueListenableBuilder(
        valueListenable: _logic.withdrawInfoNotifier,
        builder: (context, info, _) {
          return Column(
            children: [
              _buildInfoRow(
                context,
                label: 'Network',
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipOval(
                      child: Image.asset(
                        Assets.tokenIconSol,
                        width: 16,
                        height: 16,
                      ),
                    ),
                    Dimens.hGap4,
                    Text(
                      'Solana',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: context.textColorTheme.textColorTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              Dimens.vGap8,
              _buildInfoRow(
                context,
                label: 'Network Fee',
                trailing: Text(
                  _logic.networkFeeText,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: context.textColorTheme.textColorTertiary,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context,
      {required String label, required Widget trailing}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: context.textColorTheme.textColorHelper,
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  // ==================== 提示信息 ====================

  Widget _buildTooltip(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHigh,
        borderRadius: Dimens.radius6,
        border: Border.all(
          color: context.colorScheme.outlineVariant,
          width: 0.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(3.0),
            child: Icon(
              RemixIcons.information_line,
              size: 16,
              color: context.textColorTheme.textColorTertiary,
            ),
          ),
          Dimens.hGap10,
          Expanded(
            child: Text(
              'Your funds are locked during the Alpha Trading Tournament and will be withdrawable in the Beta phase.',
              style: TextStyle(
                fontSize: 12,
                height: 1.4,
                fontWeight: FontWeight.w400,
                color: context.textColorTheme.textColorTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== 底部按钮 ====================

  Widget _buildBottomButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: ListenableBuilder(
        listenable: Listenable.merge([
          _amountController,
          _logic.addressValidNotifier,
        ]),
        builder: (context, _) {
          final hasAmount = _logic.amountNotifier.value.isNotEmpty &&
              (double.tryParse(_logic.amountNotifier.value) ?? 0) > 0;
          final isAddressValid = _logic.addressValidNotifier.value == true;
          final enabled = hasAmount && isAddressValid;

          return Touchable(
            onTap: enabled ? _onConfirm : null,
            child: Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                color: enabled
                    ? context.colorScheme.primary
                    : context.colorScheme.outlineVariant,
                borderRadius: Dimens.radius6,
              ),
              alignment: Alignment.center,
              child: Text(
                'Withdraw USDC',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: enabled
                      ? Colors.black
                      : context.textColorTheme.textColorQuaternary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
