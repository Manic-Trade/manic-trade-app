import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:finality/common/toast/app_toast_manager.dart';
import 'package:finality/core/logger.dart';
import 'package:finality/core/state/ui_state.dart';
import 'package:finality/data/network/manic_trade_data_source.dart';
import 'package:finality/data/network/solana_rpc_service.dart';
import 'package:finality/di/injector.dart';
import 'package:finality/domain/crypto/solana_tx_signature_extractor.dart';
import 'package:finality/features/positions/vm/opened_positions_vm.dart';
import 'package:finality/services/turnkey/turnkey_manager.dart';
import 'package:finality/services/wallet/wallet_service.dart';
import 'package:flutter/foundation.dart';
import 'package:hex/hex.dart';
import 'package:store_scope/store_scope.dart';
import 'package:turnkey_sdk_flutter/turnkey_sdk_flutter.dart';

class CloseAllResult {
  final List<String> succeededIds;
  final List<String> failedIds;

  const CloseAllResult({required this.succeededIds, required this.failedIds});

  int get succeededCount => succeededIds.length;
  int get failedCount => failedIds.length;
  bool get allSucceeded => failedIds.isEmpty;
}

final closePositionVMProvider = ViewModelProvider<ClosePositionVM>((ref) {
  return ClosePositionVM(
    injector<ManicTradeDataSource>(),
    injector<WalletService>(),
    injector<TurnkeyManager>(),
    injector<SolanaRpcService>(),
    ref.bind(openedPositionsVMProvider),
  );
});

class ClosePositionVM extends ViewModel {
  final ManicTradeDataSource _dataSource;
  final WalletService _walletService;
  final TurnkeyManager _turnkeyManager;
  final SolanaRpcService _solanaRpcService;
  final OpenedPositionsVM _openedPositionsVM;

  ClosePositionVM(
    this._dataSource,
    this._walletService,
    this._turnkeyManager,
    this._solanaRpcService,
    this._openedPositionsVM,
  );

  /// 每个仓位独立的平仓状态
  final Map<String, ValueNotifier<UiState<void>>> _positionStates = {};

  /// 飞行中的平仓请求 CancelToken（按 positionId 索引）
  final Map<String, CancelToken> _cancelTokens = {};

  /// 已被结算事件取消的仓位 ID（用于 step 2/3 的 guard check）
  final Set<String> _cancelledIds = {};

  StreamSubscription<String>? _settleSubscription;

  @override
  void init() {
    super.init();
    // 订阅结算事件，取消对应飞行中的平仓请求
    _settleSubscription =
        _openedPositionsVM.onPositionSettled.listen((positionId) {
      _cancelledIds.add(positionId);
      _cancelTokens[positionId]?.cancel('Position already settled');
    });
  }

  /// 获取指定仓位的状态 Notifier（懒创建）
  ValueNotifier<UiState<void>> getStateNotifier(String positionId) {
    return _positionStates.putIfAbsent(
      positionId,
      () => ValueNotifier(UiState.initial()),
    );
  }



  /// 提前平仓
  ///
  /// [positionId] 仓位 base58 ID
  /// [asset] 资产名称（如 btc, sol, eth）
  Future<void> closePosition({
    required String positionId,
    required String asset,
    bool refreshBalance = true,
    bool notifySuccess = false,
    bool notifyError = true,
    bool blockOtherPrompts = false,
  }) async {
    if (getStateNotifier(positionId).value.isLoading) {
      return;
    }
    try {
      if (blockOtherPrompts) {
        _openedPositionsVM.markClosing(positionId);
      }
      await _internalClosePosition(positionId: positionId, asset: asset);
      if (blockOtherPrompts) {
        _openedPositionsVM.callOnPositionClosed(positionId,
            refreshBalance: refreshBalance);
      }
      removePosition(positionId);
      if (notifySuccess) {
        AppToastManager.showSuccess(
          title: 'Position closed successfully',
        );
      }
    } catch (error, stackTrace) {
      logger.e('Failed to close position: $error', stackTrace: stackTrace);
      if (blockOtherPrompts) {
        _openedPositionsVM.unmarkClosing(positionId);
      }
      if (notifyError) {
        AppToastManager.showFailed(
          title: 'Failed to close position',
        );
      }
      rethrow;
    }
  }

  /// 提前平仓（prepare → sign → submit 两阶段流程）
  ///
  /// [positionId] 仓位 base58 ID
  /// [asset] 资产名称（如 btc, sol, eth）
  Future<void> _internalClosePosition({
    required String positionId,
    required String asset,
  }) async {
    final notifier = getStateNotifier(positionId);
    notifier.value = UiState.loading();
    final cancelToken = CancelToken();
    _cancelTokens[positionId] = cancelToken;
    try {
      // 1. prepare：服务端仅 fee_payer 签名，返回 unsigned_tx
      final prepareResp = await _dataSource.prepareClosePosition(
        positionId: positionId,
        asset: asset,
        cancelToken: cancelToken,
      );

      // guard: 结算事件已取消
      if (_cancelledIds.contains(positionId)) {
        notifier.value = UiState.initial();
        return;
      }

      // 2. Turnkey 用 user key 签名 unsigned_tx
      final signedTx = await _signTransaction(prepareResp.unsignedTx);

      // guard: 签名期间被取消
      if (_cancelledIds.contains(positionId)) {
        notifier.value = UiState.initial();
        return;
      }

      // 3. 从 signedTx diff 出用户 64B 签名
      final userSignature = SolanaTxSignatureExtractor.extractUserSignatureHex(
        unsignedTxHex: prepareResp.unsignedTx,
        signedTxHex: signedTx,
      );

      // 4. submit：服务端补签 back_authority + send_and_confirm 上链
      //    注意：submit 需在 prepare 后 5s 内完成，否则 400 Request expired
      //    submit 阶段不传 cancelToken：服务端已经在广播，取消只能停止等待响应，
      //    无法撤销上链。settle 事件只会在 prepare / 签名阶段生效。
      final submitResp = await _dataSource.submitClosePosition(
        requestId: prepareResp.requestId,
        userSignature: userSignature,
      );
      debugPrint('Close position tx confirmed: ${submitResp.txHash}');

      notifier.value = UiState.success(null);
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        // 仓位已结算，静默取消，不上报错误
        logger.d('ClosePositionVM: 平仓请求已取消（仓位已结算）: $positionId');
        notifier.value = UiState.initial();
        return;
      }
      notifier.value = UiState.failure(e);
      rethrow;
    } catch (e) {
      debugPrint('Failed to close position: $e');
      notifier.value = UiState.failure(e);
      rethrow;
    } finally {
      _cancelTokens.remove(positionId);
      _cancelledIds.remove(positionId);
    }
  }

  /// 清理指定仓位的状态（仓位关闭后调用）
  void removePosition(String positionId) {
    _positionStates.remove(positionId)?.dispose();
  }

  Future<String> _signTransaction(String transaction) async {
    final walletAccounts = _walletService.walletAccounts.value;
    if (walletAccounts == null) {
      throw Exception('No wallet accounts found');
    }

    final solanaAccount = walletAccounts.getSolanaAccount();
    if (solanaAccount == null) {
      throw Exception('No solana account found');
    }

    final response = await _turnkeyManager.signTransaction(
      signWith: solanaAccount.address,
      unsignedTransaction: transaction,
      type: v1TransactionType.transaction_type_solana,
    );

    return response.signedTransaction;
  }

  // 保留：配合 DataSource 的旧 closePosition 方法，方便需要时回滚到客户端广播流程
  // ignore: unused_element
  Future<String> _broadcastTransaction(String signedTransactionHex) async {
    final base64Tx = _hexToBase64(signedTransactionHex);
    return await _solanaRpcService.sendTransaction(base64Tx);
  }

  String _hexToBase64(String hexString) {
    final bytes = Uint8List.fromList(HEX.decode(hexString));
    return base64Encode(bytes);
  }

  @override
  void dispose() {
    _settleSubscription?.cancel();
    _positionStates.clear();
    super.dispose();
  }
}
