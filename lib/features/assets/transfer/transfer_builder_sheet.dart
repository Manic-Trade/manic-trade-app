import 'dart:async';
import 'dart:ui';

import 'package:dart_extensions_methods/dart_extension_methods.dart';
import 'package:finality/common/constants/blockchain.dart';
import 'package:finality/common/constants/currencies.dart';
import 'package:finality/common/utils/color_scheme_extensions.dart';
import 'package:finality/common/utils/localization_extensions.dart';
import 'package:finality/common/widgets/bottom_sheet_navigator.dart';
import 'package:finality/data/drift/entities/token.dart';
import 'package:finality/data/drift/token_database.dart';
import 'package:finality/di/injector.dart';
import 'package:finality/domain/wallet/entities/account_network.dart';
import 'package:finality/features/assets/transfer/widgets/token_balance_button.dart';
import 'package:finality/features/assets/transfer/transfer_address_sheet.dart';
import 'package:finality/features/assets/transfer/transfer_builder_logic.dart';
import 'package:finality/features/assets/transfer/widgets/action_slider_button.dart';
import 'package:finality/common/widgets/blinking_cursor.dart';
import 'package:finality/features/assets/transfer/widgets/numeric_keypad.dart';
import 'package:finality/features/assets/transfer/widgets/percentage_selector.dart';
import 'package:finality/features/assets/transfer/widgets/transaction_status_text.dart';
import 'package:finality/routes/app_pages.dart';
import 'package:finality/routes/navigation_helper.dart';
import 'package:finality/services/wallet/token_position_service.dart';
import 'package:finality/services/wallet/wallet_service.dart';
import 'package:finality/theme/attrs/text_color_theme.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

Future<void> _showTransferBuilderSheet(BuildContext context,
    {required Token token}) async {
  var walletAccounts = injector<WalletService>().walletAccounts.value;
  if (walletAccounts == null) return;

  var account = walletAccounts.accounts
      .firstWhereOrNull((account) => account.networkCode == token.networkCode);
  if (account == null) return;
  var network = Networks.getNetwork(token.networkCode);
  if (network == null) return;
  if (!context.mounted) return;
  return showCupertinoModalBottomSheet<void>(
    context: context,
    expand: true,
    settings: const RouteSettings(name: RouteNames.transfer),
    duration: const Duration(milliseconds: 250),
    topRadius: Dimens.sheetTopRadius,
    builder: (_) => BottomSheetNavigator(
      useNavigator: false,
      builder: (_) {
        return _TransferBuilderSheet(
          token: token,
          accountNetwork: AccountNetwork(account, network),
        );
      },
    ),
  );
}

/// Show token send builder sheet
///
/// Logic explanation:
/// 1. If a token is passed from outside, use it directly
/// 2. If no token is passed, use the token with the largest balance
/// 3. If all token balances are 0, default to SOL
/// 4. Other available tokens are alternatives, users can switch manually
Future<void> showSendBuilderSheet(BuildContext context, {Token? token}) async {
  // If a token is passed from outside, use it directly
  if (token != null) {
    if (!context.mounted) return;
    return _showTransferBuilderSheet(context, token: token);
  }

  // Get wallet account information
  var walletAccounts = injector<WalletService>().walletAccounts.value;
  if (walletAccounts == null) return;

  // Default to SOL network account
  var account = walletAccounts.accounts.firstWhereOrNull(
      (account) => account.networkCode == Tokens.sol.networkCode);
  if (account == null) {
    // If no SOL account, use default SOL token
    if (!context.mounted) return;
    return _showTransferBuilderSheet(context, token: Tokens.sol);
  }

  var holderDao = injector<TokenDatabase>().tokenHolderDao;

  // First check priority tokens: SOL -> USDC -> USDT
  List<Token> priorityTokens = [Tokens.sol, Tokens.usdc, Tokens.usdt];

  for (var priorityToken in priorityTokens) {
    var holding = await holderDao.loadHolding(priorityToken.contractAddress,
        priorityToken.networkCode, account.address);
    var balance = double.tryParse(holding?.balance ?? "0") ?? 0;

    if (balance > 0) {
      if (!context.mounted) return;
      return _showTransferBuilderSheet(context, token: priorityToken);
    }
  }

  // If priority tokens have no balance, use the token with the largest balance
  var tokenPositions = injector<TokenPositionService>().tokenPositions.value;
  if (tokenPositions.isNotEmpty) {
    var maxTokenPosition = tokenPositions.firstOrNull;
    if (maxTokenPosition != null) {
      if (!context.mounted) return;
      return _showTransferBuilderSheet(context, token: maxTokenPosition.token);
    }
  }

  // If all token balances are 0, default to SOL
  if (!context.mounted) return;
  return _showTransferBuilderSheet(context, token: Tokens.sol);
}

class _TransferBuilderSheet extends StatefulWidget {
  final Token token;
  final AccountNetwork accountNetwork;
  const _TransferBuilderSheet({
    required this.token,
    required this.accountNetwork,
  });

  @override
  State<_TransferBuilderSheet> createState() => _TransferBuilderSheetState();
}

class _TransferBuilderSheetState extends State<_TransferBuilderSheet> {
  late final TransferBuilderLogic logic;

  @override
  void initState() {
    super.initState();
    logic = TransferBuilderLogic(
        accountNetwork: widget.accountNetwork,
        initialToken: widget.token);
    logic.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(context.strings.action_send),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              children: [
                Dimens.vGap8,
                _buildTokenBalanceButton(),
                _buildInputSection(context),
                Dimens.vGap28,
                Padding(
                  padding: Dimens.edgeInsetsH28,
                  child: ValueListenableBuilder<String>(
                      valueListenable: logic.inputAmountNotifier,
                      builder: (_, amount, __) {
                        var balance = logic.tokenBalanceNotifier.value;
                        var amountDouble = (double.tryParse(amount) ?? 0);
                        var balanceDouble = double.tryParse(balance) ?? 0;
                        var isEnough = amountDouble <= balanceDouble;
                        return _buildSendButton(
                            amount.isNotEmpty && amountDouble > 0 && isEnough);
                      }),
                ),
                Dimens.vGap16,
                _buildStatusText(context),
                Dimens.vGap16,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputSection(BuildContext context) {
    return Expanded(
      child: LayoutBuilder(builder: (context, constraints) {
        final availableHeight = constraints.maxHeight;
        const minKeypadHeight = 260.0;
        const maxKeypadHeight = 350.0;
        const minAmountPriceSectionHeight = 128.0;
        const standardAmountPriceSectionHeight = 140.0;

        // Minimum required total height
        const minTotalHeight = minKeypadHeight + minAmountPriceSectionHeight;

        // If available height is less than minimum required height, use minimum height
        if (availableHeight <= minTotalHeight) {
          return Column(
            children: [
              const SizedBox(
                height: minAmountPriceSectionHeight,
                child: SizedBox.shrink(),
              ),
              SizedBox(
                height: minKeypadHeight,
                child: _buildKeypadSection(0),
              ),
            ],
          );
        }

        // Calculate remaining allocable space
        var remainingHeight = availableHeight - minTotalHeight;
        var keypadHeight = minKeypadHeight;
        var amountSectionHeight = minAmountPriceSectionHeight;

        // Prioritize allocation to Keypad until maximum height is reached
        const additionalKeypadSpace = maxKeypadHeight - minKeypadHeight;
        if (remainingHeight > 0) {
          if (remainingHeight <= additionalKeypadSpace) {
            keypadHeight += remainingHeight;
            remainingHeight = 0;
          } else {
            keypadHeight = maxKeypadHeight;
            remainingHeight -= additionalKeypadSpace;
            amountSectionHeight += remainingHeight;
          }
        }

        final keypadFontScale = ((keypadHeight - minKeypadHeight) /
                (maxKeypadHeight - minKeypadHeight))
            .clamp(0.0, 1.0);
        final amountPriceSectionFontScale =
            ((amountSectionHeight - minAmountPriceSectionHeight) /
                    (standardAmountPriceSectionHeight -
                        minAmountPriceSectionHeight))
                .clamp(0.0, 1.0);

        return Column(
          children: [
            SizedBox(
              height: amountSectionHeight,
              child: _buildAmountPriceSection(
                  context, amountPriceSectionFontScale),
            ),
            SizedBox(
              height: keypadHeight,
              child: _buildKeypadSection(keypadFontScale),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildKeypadSection(double fontScale) {
    return Column(
      children: [
        PercentageSelector(
          onPercentageSelected: (percentage) {
            logic.setAmountToPercentageBalance(percentage);
          },
        ),
        Dimens.vGap24,
        Expanded(
          child: NumericKeypad(
            fontScale: fontScale,
            onNumberPressed: (number) {
              logic.onNumberPressed(number);
            },
            onDeletePressed: () {
              return logic.onDeletePressed();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatusText(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: logic.inputAmountNotifier,
      builder: (_, amount, __) {
        var balance = logic.tokenBalanceNotifier.value;
        var amountDouble = (double.tryParse(amount) ?? 0);
        var balanceDouble = double.tryParse(balance) ?? 0;
        var isEnough = amountDouble <= balanceDouble;
        if (!isEnough) {
          return Text(
            context.strings.message_insufficient_balance,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: context.textColorTheme.textColorSecondary),
          );
        }
        return _buildRealStatusText();
      },
    );
  }

  Widget _buildRealStatusText() {
    return const TransactionStatusText(status: null);
  }

  Widget _buildAmountPriceSection(BuildContext context, double fontScale) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ValueListenableBuilder(
              valueListenable: logic.isInputAmountNotifier,
              builder: (_, isInputAmount, __) {
                return Column(
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: isInputAmount
                          ? _buildInputAmount(
                              lerpDouble(38, 48, fontScale) ?? 48)
                          : _buildInputPrice(
                              lerpDouble(38, 48, fontScale) ?? 48),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTokenBalanceButton() {
    return TokenBalanceButton.withListener(
      token: widget.token,
      balanceNotifier: logic.tokenBalanceNotifier,
      onTokenAssetSelected: null,
    );
  }

  Widget _buildInputAmount(double fontSize) {
    return ValueListenableBuilder<String>(
      valueListenable: logic.inputAmountNotifier,
      builder: (context, amount, child) {
        return Row(
          children: [
            Text(
              amount.isEmpty ? '0' : amount,
              style: TextStyle(
                fontSize: fontSize,
                color: amount.isEmpty
                    ? context.textColorTheme.textColorTertiary
                    : context.textColorTheme.textColorPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            Dimens.hGap6,
            SizedBox(
              height: fontSize,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Spacer(),
                  BlinkingCursor(
                    size: fontSize * 0.4,
                    color: context.colorScheme.primary,
                    duration: const Duration(milliseconds: 600),
                  ),
                  Dimens.vGap6,
                ],
              ),
            ),
            Dimens.hGap6,
            ValueListenableBuilder<Token>(
              valueListenable: logic.tokenNotifier,
              builder: (context, token, child) {
                return Text(
                  token.symbol,
                  style: TextStyle(
                    fontSize: fontSize,
                    color: context.textColorTheme.textColorSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildInputPrice(double fontSize) {
    return ValueListenableBuilder<String>(
      valueListenable: logic.inputPriceNotifier,
      builder: (context, price, child) {
        var priceString = price.isEmpty ? '0' : price;
        return Row(
          children: [
            Text(
              priceString.withUsdSymbol(),
              style: TextStyle(
                fontSize: fontSize,
                color: price.isEmpty
                    ? context.textColorTheme.textColorTertiary
                    : context.textColorTheme.textColorPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            Dimens.hGap6,
            SizedBox(
              height: fontSize,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Spacer(),
                  BlinkingCursor(
                    size: fontSize * 0.4,
                    color: context.colorScheme.primary,
                    duration: const Duration(milliseconds: 600),
                  ),
                  Dimens.vGap6,
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSendButton(bool enabled) {
    return ActionSliderButton(
      enabled: enabled,
      context: context,
      noSwap: true,
      onSuccess: () {
        NavigationHelper.exitTransactionProcess(context);
      },
      action: () async {
        await navigateToTransferAddress();
        return true;
      },
      child: Text(
        context.strings.next,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: context.colorScheme.onPrimary,
        ),
      ),
    );
  }

  Future<void> navigateToTransferAddress() async {
    var network = Networks.getNetwork(logic.tokenNotifier.value.networkCode);
    if (network == null) {
      return;
    }
    if (context.mounted) {
      await showTransferAddressSheet(context,
          accountNetwork: widget.accountNetwork,
          token: logic.tokenNotifier.value,
          amount: logic.inputAmountNotifier.value);
    }
  }

  @override
  void dispose() {
    logic.dispose();
    super.dispose();
  }
}
