import 'dart:convert';
import 'dart:math';

import 'package:finality/data/network/manic_trade_data_source.dart';
import 'package:finality/data/network/model/manic/open_position_response.dart';
import 'package:finality/data/network/model/manic/prepare_position_response.dart';
import 'package:finality/data/network/model/manic/submit_position_response.dart';
import 'package:finality/data/network/solana_rpc_service.dart';
import 'package:finality/di/injector.dart';
import 'package:finality/domain/crypto/solana_tx_signature_extractor.dart';
import 'package:finality/domain/options/entities/options_time_mode.dart';
import 'package:finality/services/turnkey/turnkey_manager.dart';
import 'package:finality/services/wallet/wallet_service.dart';
import 'package:flutter/foundation.dart';
import 'package:hex/hex.dart';
import 'package:solana/base58.dart';
import 'package:store_scope/store_scope.dart';
import 'package:turnkey_sdk_flutter/turnkey_sdk_flutter.dart';

/// 生成唯一的 Position ID（Base58 编码，与 Web 端兼容）
String generatePositionId() {
  final random = Random.secure();
  final bytes = List<int>.generate(32, (_) => random.nextInt(256));
  return base58encode(bytes);
}

final placeOrderVMProvider = ViewModelProvider<PlaceOrderVM>((ref) {
  return PlaceOrderVM(
    injector<ManicTradeDataSource>(),
    injector<WalletService>(),
    injector<TurnkeyManager>(),
    injector<SolanaRpcService>(),
  );
});

class PlaceOrderVM extends ViewModel {
  final ManicTradeDataSource _dataSource;
  final WalletService _walletService;
  final TurnkeyManager _turnkeyManager;
  final SolanaRpcService _solanaRpcService;

  PlaceOrderVM(
    this._dataSource,
    this._walletService,
    this._turnkeyManager,
    this._solanaRpcService,
  );

  /// 下单（统一入口）
  /// [data] 交易面板数据
  /// [asset] 资产名称（如 btc）
  /// [isHigh] true = HIGHER (call), false = LOWER (put)
  Future<OpenPositionResponse> openPosition({
    required OptionsTimeMode expiryType,
    required int durationSeconds,
    required DateTime? settleTime,
    required double payoutMultiplier,
    required double amount,
    required String asset,
    required bool isHigh,
    String? positionId,
  }) async {
    // amount 需要乘以 10^6（USDC 精度）
    final int amountInt = (amount * 1000000).toInt();

    if (expiryType == OptionsTimeMode.timer) {
      return await _openRollingPosition(
        amount: amountInt,
        asset: asset,
        isHigh: isHigh,
        duration: durationSeconds,
        targetMultiplier: payoutMultiplier,
        positionId: positionId,
      );
    } else {
      return await _openSinglePosition(
        amount: amountInt,
        asset: asset,
        isHigh: isHigh,
        settleTime: settleTime!,
        targetMultiplier: payoutMultiplier,
        positionId: positionId,
      );
    }
  }

  /// Rolling 模式下单
  Future<OpenPositionResponse> _openRollingPosition({
    required int amount,
    required String asset,
    required bool isHigh,
    required int duration,
    required double targetMultiplier,
    String? positionId,
  }) async {
    // end_time: 当前时间戳 + duration（秒）
    final endTime = (DateTime.now().millisecondsSinceEpoch ~/ 1000) + duration;

    final response = await _dataSource.openRollingPosition(
      amount: amount,
      asset: asset,
      isHigh: isHigh,
      duration: duration,
      endTime: endTime,
      targetMultiplier: targetMultiplier,
      positionId: positionId,
    );
    debugPrint('Rolling position opened: ${response.toJson()}');
    return response;
  }

  /// Single 模式下单
  Future<OpenPositionResponse> _openSinglePosition({
    required int amount,
    required String asset,
    required bool isHigh,
    required DateTime settleTime,
    required double targetMultiplier,
    String? positionId,
  }) async {
    // Single 模式的 endTime 使用用户选择的 settleTime
    final endTime = settleTime.millisecondsSinceEpoch ~/ 1000;
    // duration 计算为 settleTime 与当前时间的差值
    final duration = endTime - (DateTime.now().millisecondsSinceEpoch ~/ 1000);

    final response = await _dataSource.openSinglePosition(
      amount: amount,
      asset: asset,
      isHigh: isHigh,
      duration: duration,
      endTime: endTime,
      targetMultiplier: targetMultiplier,
      positionId: positionId,
    );
    debugPrint('Single position opened: ${response.toJson()}');
    return response;
  }

  /// 开仓 prepare 阶段（新流程）
  ///
  /// 返回的 [PreparePositionResponse.unsignedTx] 只由 fee_payer 签名，
  /// 客户端需在 [PreparePositionResponse.expiresIn] 秒内调用
  /// [signTransaction] + [submitPosition] 完成上链，否则服务端会拒绝。
  ///
  /// 参数语义同 [openPosition]。
  Future<PreparePositionResponse> preparePosition({
    required OptionsTimeMode expiryType,
    required int durationSeconds,
    required DateTime? settleTime,
    required double payoutMultiplier,
    required double amount,
    required String asset,
    required bool isHigh,
    String? positionId,
  }) async {
    final amountInt = (amount * 1000000).toInt();

    if (expiryType == OptionsTimeMode.timer) {
      // Rolling：server 端 mode.type = "Single"，endTime 置 0（server 内部据 duration 计算）
      final endTime =
          (DateTime.now().millisecondsSinceEpoch ~/ 1000) + durationSeconds;
      return _dataSource.preparePosition(
        amount: amountInt,
        asset: asset,
        isHigh: isHigh,
        duration: durationSeconds,
        endTime: endTime,
        targetMultiplier: payoutMultiplier,
        positionId: positionId,
        modeType: 'Single',
      );
    } else {
      // Batch：server 端 mode.type = "Batch"，endTime 用用户选择的结算时间
      final endTime = settleTime!.millisecondsSinceEpoch ~/ 1000;
      final duration =
          endTime - (DateTime.now().millisecondsSinceEpoch ~/ 1000);
      return _dataSource.preparePosition(
        amount: amountInt,
        asset: asset,
        isHigh: isHigh,
        duration: duration,
        endTime: endTime,
        targetMultiplier: payoutMultiplier,
        positionId: positionId,
        modeType: 'Batch',
      );
    }
  }

  /// 开仓 submit 阶段（新流程）
  ///
  /// 从 [signedTxHex] 里提取用户的 64 字节签名，回传服务端补签 back_authority
  /// 并广播。服务端用 `send_and_confirm_transaction` 阻塞到 Solana 确认后返回。
  ///
  /// 超过 prepare 响应中的 `expires_in`（5s）后调用会得到
  /// `400 Request expired`。本层不自动重试，由调用方决定 UX。
  Future<SubmitPositionResponse> submitPosition({
    required String requestId,
    required String unsignedTxHex,
    required String signedTxHex,
  }) async {
    final userSignature = SolanaTxSignatureExtractor.extractUserSignatureHex(
      unsignedTxHex: unsignedTxHex,
      signedTxHex: signedTxHex,
    );
    return _dataSource.submitPosition(
      requestId: requestId,
      userSignature: userSignature,
    );
  }

/// 签名交易
  Future<v1SignTransactionResult> signTransaction(String transaction) async {
    var walletAccounts = _walletService.walletAccounts.value;
    if (walletAccounts == null) {
      throw Exception('No wallet accounts found');
    }

    var solanaAccount = walletAccounts.getSolanaAccount();
    if (solanaAccount == null) {
      throw Exception('No solana account found');
    }

    var response = await _turnkeyManager.signTransaction(
      signWith: solanaAccount.address,
      unsignedTransaction: transaction,
      type: v1TransactionType.transaction_type_solana,
    );

    return response;
  }

  /// 广播交易到 Solana 网络
  ///
  /// [signedTransactionHex] 已签名的交易（十六进制编码）
  /// 返回交易签名（Transaction Signature）
  Future<String> broadcastTransaction(String signedTransactionHex) async {
    final base64Tx = _hexToBase64(signedTransactionHex);
    return await _solanaRpcService.sendTransaction(base64Tx);
  }

  /// 广播交易并等待确认
  ///
  /// [signedTransactionHex] 已签名的交易（十六进制编码）
  /// [timeout] 超时时间，默认 30 秒
  /// 返回交易签名（Transaction Signature）
  Future<String> sendTransaction(String signedTransactionHex) async {
    final base64Tx = _hexToBase64(signedTransactionHex);
    return await _solanaRpcService.sendTransaction(
      base64Tx,
    );
  }

  /// 将十六进制字符串转换为 base64 编码
  String _hexToBase64(String hexString) {
    final bytes = Uint8List.fromList(HEX.decode(hexString));
    return base64Encode(bytes);
  }
}
