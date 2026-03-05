import 'package:finality/common/utils/color_scheme_extensions.dart';
import 'package:finality/common/utils/localization_extensions.dart';
import 'package:finality/common/widgets/touchable.dart';
import 'package:finality/data/model/token_position.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:finality/common/utils/decimal_format.dart';
import 'package:finality/common/widgets/logo_image.dart';
import 'package:finality/data/drift/entities/token.dart';
import 'package:finality/theme/dimens.dart';

class TokenBalanceButton extends StatelessWidget {
  // 静态 balance 的构造函数
  const TokenBalanceButton({
    super.key,
    required this.token,
    required String balance,
    this.onTokenAssetSelected,
    this.allowedTokens,
    this.enable = true,
  })  : _balanceNotifier = null,
        _balanceStream = null,
        _staticBalance = balance;

  // 动态 balance 的构造函数
  const TokenBalanceButton.withListener({
    super.key,
    required this.token,
    required ValueListenable<String> balanceNotifier,
    this.onTokenAssetSelected,
    this.allowedTokens,
    this.enable = true,
  })  : _balanceNotifier = balanceNotifier,
        _balanceStream = null,
        _staticBalance = null;

  // Stream balance 的构造函数
  const TokenBalanceButton.withStream({
    super.key,
    required this.token,
    required Stream<String> balanceStream,
    this.onTokenAssetSelected,
    this.allowedTokens,
    this.enable = true,
  })  : _balanceStream = balanceStream,
        _balanceNotifier = null,
        _staticBalance = null;

  final Token token;
  final ValueListenable<String>? _balanceNotifier;
  final Stream<String>? _balanceStream;
  final String? _staticBalance;
  final ValueChanged<TokenPosition>? onTokenAssetSelected;
  //允许选择的代币列表,如果不为空且有item，就只能选择这个参数里的tokens
  final List<Token>? allowedTokens;
  final bool enable;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !enable,
      child: Touchable.plain(
        onTap: onTokenAssetSelected != null
            ? () async {
                
              }
            : null,
        child: Container(
          decoration: BoxDecoration(
            color: context.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(32),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              LogoImage(
                width: 16,
                height: 16,
                iconURL: token.iconUrl,
                symbol: token.symbol,
              ),
              Dimens.hGap8,
              if (_balanceNotifier != null)
                ValueListenableBuilder<String>(
                  valueListenable: _balanceNotifier,
                  builder: (context, value, child) =>
                      _buildBalanceText(context, value),
                )
              else if (_balanceStream != null)
                StreamBuilder<String>(
                  stream: _balanceStream,
                  initialData: "0",
                  builder: (context, snapshot) =>
                      _buildBalanceText(context, snapshot.data!),
                )
              else
                _buildBalanceText(context, _staticBalance!),
              if (onTokenAssetSelected != null) Dimens.hGap4,
              if (onTokenAssetSelected != null)
                const Icon(Icons.keyboard_arrow_down),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceText(BuildContext context, String balance) {
    return Text(
      _formatBalance(context, balance, token),
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
    );
  }

  String _formatBalance(BuildContext context, String balance, Token token) {
    return "${context.strings.flag_balance} ${balance.formatWithDecimals(token.decimals, symbol: token.symbol)}";
  }
}
