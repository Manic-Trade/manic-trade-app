import 'dart:async';
import 'dart:convert';

import 'package:convert/convert.dart';
import 'package:dio/dio.dart';
import 'package:finality/common/utils/decimal_format.dart';
import 'package:finality/core/error/cancel_error.dart';
import 'package:finality/core/logger.dart';
import 'package:finality/core/notifier/computed_notifier.dart';
import 'package:finality/data/drift/entities/token.dart';
import 'package:finality/data/drift/user_preferences_database.dart';
import 'package:finality/data/model/network_address_pair.dart';
import 'package:finality/data/network/manic_trade_data_source.dart';
import 'package:finality/data/network/model/manic/withdraw_execute_request.dart';
import 'package:finality/data/network/solana_rpc_service.dart';
import 'package:finality/data/repository/holdings_data_repository.dart';
import 'package:finality/di/injector.dart';
import 'package:finality/domain/crypto/solana_address_verify.dart';
import 'package:finality/domain/crypto/solana_withdraw_builder.dart';
import 'package:finality/domain/wallet/entities/account_network.dart';
import 'package:finality/env/env_config.dart';
import 'package:finality/features/assets/transfer/execute_status.dart';
import 'package:finality/features/assets/transfer/transaction_status_poller.dart';
import 'package:finality/generated/l10n.dart';
import 'package:finality/services/turnkey/turnkey_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:turnkey_sdk_flutter/turnkey_sdk_flutter.dart';

class WithdrawExecuteLogic {
  final AccountNetwork accountNetwork;
  final Token token;
  final String amount;

  WithdrawExecuteLogic({
    required this.accountNetwork,
    required this.token,
    required this.amount,
  });

  // 共同的依赖注入
  final SolanaRpcService solanaRpcService = injector<SolanaRpcService>();
  final ManicTradeDataSource _manicTradeDataSource =
      injector<ManicTradeDataSource>();
  final HoldingsDataRepository _repository = injector<HoldingsDataRepository>();
  final UserPreferencesDatabase _userPreferencesDb =
      injector<UserPreferencesDatabase>();
  late final SolanaWithdrawBuilder _transactionBuilder =
      SolanaWithdrawBuilder(solanaRpcService);

  // 共同的状态管理
  ValueNotifier<ExecuteStatus?> statusNotifier = ValueNotifier(null);
  late ComputedNotifier<bool, ExecuteStatus?> isLoading =
      statusNotifier.computed((status) => status?.isLoading ?? false);

  String? _txId;
  StreamSubscription? _tradeConfirmedSubscription;
  Completer<void>? _executeCompleter;
  TransactionStatusPoller? _statusPoller;
  CancelToken? cancelToken;
  bool _isDisposed = false;

  String? _toAddress;

  Future<void> executeTransfer({required String toAddress}) async {
    if (toAddress.isEmpty) {
      throw Exception('To address is empty');
    }
    if (await SolanaAddressVerify.validate(toAddress) == false) {
      throw Exception('To address is invalid');
    }

    _toAddress = toAddress;
    await _executeTransaction();
  }

  // 模板方法 - 定义执行流程
  Future<void> _executeTransaction() async {
    await _executeTransactionInternal();
    _onTransactionComplete();
  }

  Future<void> _executeTransactionInternal() async {
    await preExecute();
    _resetStatus();
    try {
      cancelToken = CancelToken();

      // 构建交易（抽象方法，由子类实现）
      var signaturePayload = await buildTransaction();

      if (_isDisposed) {
        throw CancelError(message: S.current.message_transfer_cancelled);
      }

      var signedTransactionBase64 = await _signSignatureHash(signaturePayload);

      if (_isDisposed) {
        throw CancelError(message: S.current.message_transfer_cancelled);
      }

      statusNotifier.value = ExecuteStatus.pending;
      var signature = await _executeWithdraw(signedTransactionBase64);
      _txId = signature;
      statusNotifier.value = ExecuteStatus.success;
      _callComplete();
      return _executeCompleter!.future;
    } catch (e, st) {
      logger.e("executeTransactionInternal: $e", error: e, stackTrace: st);
      if (e is DioException && e.type == DioExceptionType.cancel) {
        throw CancelError(message: S.current.message_transfer_cancelled);
      }
      if (statusNotifier.value == ExecuteStatus.building) {
        statusNotifier.value = ExecuteStatus.buildFailure;
      } else {
        statusNotifier.value = ExecuteStatus.failed;
      }
      _callCompleteError(e);
      return _executeCompleter!.future;
    }
  }

  // 抽象方法 - 由子类实现具体的交易构建逻辑
  Future<List<int>> buildTransaction() async {
    // 使用 SolanaTransactionBuilder 构建交易
    final signaturePayload = await _transactionBuilder.buildWithdrawTransaction(
      fromAddress: accountNetwork.account.address,
      toAddress: _toAddress!,
      tokenAddress: Env.config.usdcMint,
      amountInLamports: amount.toBigIntWithDecimals(token.decimals).toInt(),
      feePayerAddress: "EJBWZ1gDNJtPZSxNVHsr8kSWji5wzgsewu5QSQXtSsu6",
    );
    return signaturePayload;
  }

  Future<void> preExecute() async {
    await _userPreferencesDb.recentSentAddressDao.insertItem(RecentSentAddress(
        networkCode: accountNetwork.network.networkCode,
        address: _toAddress!,
        lastUsedAt: DateTime.now()));
  }

  Future<void> _onTransactionComplete() async {
    await _refreshTokenAssets();
  }

  Future<void> _refreshTokenAssets() async {
    await Future.delayed(const Duration(seconds: 1));
    _repository.fetchAllTokenAssets([
      NetworkAddressPair(
          accountNetwork.network.networkCode, accountNetwork.account.address)
    ]);
  }

  //签名交易,返回 Base64 字符串（通过 Turnkey 签名）
  Future<String> _signSignatureHash(List<int> signaturePayload) async {
    var hexString = hex.encode(signaturePayload);
    logger.d("hexString: $hexString");
    var turnkeyManager = injector<TurnkeyManager>();
    var response = await turnkeyManager.signTransaction(
        signWith: accountNetwork.account.address,
        unsignedTransaction: hexString,
        type: v1TransactionType.transaction_type_solana);
    var signedTransactionHex = response.signedTransaction;
    var signedTransactionBytes = hex.decode(signedTransactionHex);
    return base64Encode(signedTransactionBytes);
  }

  //返回交易签名（Transaction Signature）
  Future<String> _executeWithdraw(String signedTransaction) async {
    final response = await _manicTradeDataSource.executeWithdraw(
      WithdrawExecuteRequest(
        transaction: signedTransaction,
        to: _toAddress!,
        amount: amount,
      ),
    );
    return response.signature;
  }

  void _resetStatus() {
    statusNotifier.value = ExecuteStatus.building;
    _txId = null;
    _tradeConfirmedSubscription?.cancel();
    _tradeConfirmedSubscription = null;
    _statusPoller?.cancel();
    _statusPoller = null;
    _executeCompleter = Completer<void>();
  }

  void _callComplete() {
    var completer = _executeCompleter;
    if (completer != null && completer.isCompleted == false) {
      completer.complete();
    }
  }

  void _callCompleteError(Object e) {
    var completer = _executeCompleter;
    if (completer != null && completer.isCompleted == false) {
      completer.completeError(e);
    }
  }

  String? get txId => _txId;

  void dispose() {
    _isDisposed = true;
    cancelToken?.cancel();
    isLoading.dispose();
    _tradeConfirmedSubscription?.cancel();
    _tradeConfirmedSubscription = null;
    _statusPoller?.cancel();
    _statusPoller = null;
    statusNotifier.dispose();
    if (statusNotifier.value == ExecuteStatus.pending) {
      _callCompleteError(
          CancelError(message: S.current.message_transfer_pending_toast));
    }
  }
}

// 用于返回交易构建结果的数据类
class TransactionBuildResponse {
  final String requestId;
  final String signaturePayload;

  TransactionBuildResponse({
    required this.requestId,
    required this.signaturePayload,
  });
}
