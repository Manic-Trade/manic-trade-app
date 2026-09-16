import 'dart:async';
import 'dart:convert';

import 'package:convert/convert.dart';
import 'package:decimal/decimal.dart';
import 'package:finality/common/constants/blockchain.dart';
import 'package:finality/common/utils/decimal_format.dart';
import 'package:finality/core/error/cancel_error.dart';
import 'package:finality/core/logger.dart';
import 'package:finality/data/drift/entities/token.dart';
import 'package:finality/data/model/network_address_pair.dart';
import 'package:finality/data/network/manic_trade_data_source.dart';
import 'package:finality/data/network/model/manic/withdraw_execute_request.dart';
import 'package:finality/data/network/model/manic/withdraw_info_response.dart';
import 'package:finality/data/network/solana_rpc_service.dart';
import 'package:finality/data/realtime/model/holding_request.dart';
import 'package:finality/data/realtime/realtime_holding_transport.dart';
import 'package:finality/data/repository/holdings_data_repository.dart';
import 'package:finality/di/injector.dart';
import 'package:finality/domain/crypto/solana_address_verify.dart';
import 'package:finality/domain/crypto/solana_withdraw_builder.dart';
import 'package:finality/domain/wallet/entities/account_network.dart';
import 'package:finality/generated/l10n.dart';
import 'package:finality/services/turnkey/turnkey_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:turnkey_sdk_flutter/turnkey_sdk_flutter.dart';

/// 提现页面业务逻辑
///
/// 职责：
/// 1. 管理金额输入和地址输入状态
/// 2. 加载 USDC 余额
/// 3. 加载提现配置信息（手续费等）
/// 4. 执行提现交易
class WithdrawLogic {
  final AccountNetwork accountNetwork;
  final Token token = Tokens.usdc;

  WithdrawLogic({required this.accountNetwork});

  // 依赖注入
  final ManicTradeDataSource _dataSource = injector<ManicTradeDataSource>();
  final HoldingsDataRepository _repository = injector<HoldingsDataRepository>();
  final SolanaRpcService _rpcService = injector<SolanaRpcService>();
  late final SolanaWithdrawBuilder _txBuilder =
      SolanaWithdrawBuilder(_rpcService);
  final RealtimeHoldingTransport _holdingTransport = injector();

  // 状态
  final ValueNotifier<String> amountNotifier = ValueNotifier('');
  final ValueNotifier<String> balanceNotifier = ValueNotifier('0');
  final ValueNotifier<WithdrawInfoResponse?> withdrawInfoNotifier =
      ValueNotifier(null);
  final ValueNotifier<bool?> addressValidNotifier = ValueNotifier(null);

  StreamSubscription? _holdingSubscription;
  Timer? _addressDebounceTimer;
  bool _isDisposed = false;

  void init() {
    _subscribeBalance();
    _fetchBalance();
    _loadWithdrawInfo();
  }

  // ==================== 余额相关 ====================

  void _subscribeBalance() {
    _holdingSubscription = _holdingTransport
        .subscribeHolding(HoldingRequest(
      contractAddress: token.contractAddress,
      networkCode: token.networkCode,
      holderAddress: accountNetwork.account.address,
    ))
        .listen((holding) {
      balanceNotifier.value = holding.balance;
    });
  }

  void _fetchBalance() {
    _repository.fetchTokenHoldingPrice(
      token.contractAddress,
      token.networkCode,
      accountNetwork.account.address,
    );
  }

  // ==================== 提现配置 ====================

  Future<void> _loadWithdrawInfo() async {
    try {
      final info = await _dataSource.getWithdrawInfo();
      if (!_isDisposed) {
        withdrawInfoNotifier.value = info;
      }
    } catch (e) {
      logger.e('加载提现配置失败', error: e);
    }
  }

  /// 格式化后的网络手续费（如 "0.1 USDC"）
  String get networkFeeText {
    final info = withdrawInfoNotifier.value;
    if (info == null) return '--';
    final feeAmount = info.withdrawFeeAmount;
    return '$feeAmount USDC';
  }

  /// 最小提现金额
  String get minAmountText {
    final info = withdrawInfoNotifier.value;
    if (info == null) return '--';
    return '${info.withdrawMinAmount} USDC';
  }

  // ==================== 金额输入 ====================

  void onNumberPressed(String number) {
    final current = amountNotifier.value;
    if (current == '0' && number == '0') return;
    if (number == '.' && current.contains('.')) return;

    // USDC 最多 6 位小数
    if (current.contains('.')) {
      final decimals = current.split('.').last;
      if (decimals.length >= 6 && number != '.') return;
    }

    if (current.isEmpty && number == '.') {
      amountNotifier.value = '0.';
    } else if (current == '0' && number != '.') {
      amountNotifier.value = number;
    } else {
      amountNotifier.value = current + number;
    }
  }

  bool onDeletePressed() {
    final current = amountNotifier.value;
    if (current.isEmpty) return false;
    amountNotifier.value =
        current.length > 1 ? current.substring(0, current.length - 1) : '';
    return amountNotifier.value.isNotEmpty;
  }

  void setMaxAmount() {
    final balance = balanceNotifier.value;
    final balanceDecimal = Decimal.tryParse(balance) ?? Decimal.zero;
    if (balanceDecimal > Decimal.zero) {
      amountNotifier.value = balanceDecimal.toString();
    }
  }

  // ==================== 地址验证 ====================

  void validateAddress(String text) {
    _addressDebounceTimer?.cancel();
    if (text.isEmpty) {
      addressValidNotifier.value = null;
      return;
    }
    _addressDebounceTimer = Timer(const Duration(milliseconds: 200), () async {
      addressValidNotifier.value = await SolanaAddressVerify.validate(text);
    });
  }

  // ==================== 校验 ====================

  /// 检查是否可以提交提现
  /// 返回 null 表示校验通过，否则返回错误信息
  String? validateSubmit(String address) {
    final amount = amountNotifier.value;
    final parsedAmount = Decimal.tryParse(amount);
    if (parsedAmount == null || parsedAmount <= Decimal.zero) {
      return 'Please enter an amount';
    }

    final balance = Decimal.tryParse(balanceNotifier.value) ?? Decimal.zero;
    if (parsedAmount > balance) {
      return S.current.message_insufficient_balance;
    }

    final info = withdrawInfoNotifier.value;
    if (info != null) {
      final minAmount = Decimal.tryParse(info.withdrawMinAmount) ?? Decimal.zero;
      if (parsedAmount < minAmount) {
        return 'Minimum withdrawal: ${info.withdrawMinAmount} USDC';
      }
    }

    if (address.isEmpty) {
      return 'Please enter a recipient address';
    }

    if (addressValidNotifier.value != true) {
      return S.current.message_transfer_invalid_address;
    }

    return null;
  }

  // ==================== 执行提现 ====================

  /// 执行提现，成功返回交易签名，失败抛出异常
  Future<String> executeWithdraw({required String toAddress}) async {
    // 构建交易
    final signaturePayload = await _buildTransaction(toAddress);
    if (_isDisposed) {
      throw CancelError(message: S.current.message_transfer_cancelled);
    }

    // 签名交易
    final signedTxBase64 = await _signTransaction(signaturePayload);
    if (_isDisposed) {
      throw CancelError(message: S.current.message_transfer_cancelled);
    }

    // 提交交易
    final response = await _dataSource.executeWithdraw(
      WithdrawExecuteRequest(
        transaction: signedTxBase64,
        to: toAddress,
        amount: amountNotifier.value,
      ),
    );

    // 刷新余额
    _refreshBalanceDelayed();

    return response.signature;
  }

  Future<List<int>> _buildTransaction(String toAddress) async {
    // 拉取后端动态配置（fee_payer、token_mint、decimals、手续费等）
    final withdrawInfo =
        withdrawInfoNotifier.value ?? await _dataSource.getWithdrawInfo();
    if (!_isDisposed && withdrawInfoNotifier.value == null) {
      withdrawInfoNotifier.value = withdrawInfo;
    }
    return _txBuilder.buildWithdrawTransaction(
      fromAddress: accountNetwork.account.address,
      toAddress: toAddress,
      tokenAddress: withdrawInfo.tokenMint,
      amountInLamports: amountNotifier.value
          .toBigIntWithDecimals(withdrawInfo.decimals)
          .toInt(),
      feePayerAddress: withdrawInfo.feePayer,
      withdrawFeeAmount: withdrawInfo.withdrawFeeAmount
          .toBigIntWithDecimals(withdrawInfo.decimals)
          .toInt(),
      feeRecipientAddress: withdrawInfo.withdrawFeeReceiver,
    );
  }

  Future<String> _signTransaction(List<int> signaturePayload) async {
    final hexString = hex.encode(signaturePayload);
    final turnkeyManager = injector<TurnkeyManager>();
    final response = await turnkeyManager.signTransaction(
      signWith: accountNetwork.account.address,
      unsignedTransaction: hexString,
      type: v1TransactionType.transaction_type_solana,
    );
    return base64Encode(hex.decode(response.signedTransaction));
  }

  void _refreshBalanceDelayed() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!_isDisposed) {
        _repository.fetchAllTokenAssets([
          NetworkAddressPair(accountNetwork.network.networkCode,
              accountNetwork.account.address)
        ]);
      }
    });
  }

  // ==================== 生命周期 ====================

  void dispose() {
    _isDisposed = true;
    _holdingSubscription?.cancel();
    _addressDebounceTimer?.cancel();
    amountNotifier.dispose();
    balanceNotifier.dispose();
    withdrawInfoNotifier.dispose();
    addressValidNotifier.dispose();
  }
}
