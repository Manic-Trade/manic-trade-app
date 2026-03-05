import 'package:dio/dio.dart';
import 'package:finality/data/network/manic_trade_service.dart';
import 'package:finality/data/network/model/manic/airdrop_request.dart';
import 'package:finality/data/network/model/manic/airdrop_response.dart';
import 'package:finality/data/network/model/manic/deposit_item.dart';
import 'package:finality/data/network/model/manic/feedback_response.dart';
import 'package:finality/data/network/model/manic/open_position_request.dart';
import 'package:finality/data/network/model/manic/open_position_response.dart';
import 'package:finality/data/network/model/manic/paged_response.dart';
import 'package:finality/data/network/model/manic/pending_position_item_response.dart';
import 'package:finality/data/network/model/manic/position_history_item.dart';
import 'package:finality/data/network/model/manic/token_balance_response.dart';
import 'package:finality/data/network/model/manic/user_txn_item.dart';
import 'package:finality/data/network/model/manic/withdraw_execute_request.dart';
import 'package:finality/data/network/model/manic/withdraw_execute_response.dart';
import 'package:finality/data/network/model/manic/withdraw_info_response.dart';
import 'package:finality/data/network/model/manic/withdraw_item.dart';
import 'package:finality/env/env_config.dart';
import 'package:solana/base58.dart';

class ManicTradeDataSource {
  final ManicTradeService _service;

  ManicTradeDataSource(this._service);

  /// 获取钱包余额
  Future<TokenBalanceResponse> getTokenBalance() {
    return _service.getTokenBalance();
  }

  /// 获取用户交易历史
  Future<PagedResponse<UserTxnItem>> getUserTxns({
    required int page,
    required int limit,
  }) {
    return _service.getUserTxns(page, limit);
  }

  /// 空投测试代币（仅限测试环境）
  Future<AirdropResponse> triggerAirdrop(String walletAddress) {
    return _service.triggerAirdrop(AirdropRequest(wallet: walletAddress));
  }

  /// 获取提现信息
  Future<WithdrawInfoResponse> getWithdrawInfo() {
    return _service.getWithdrawInfo();
  }

  /// 执行提现
  Future<WithdrawExecuteResponse> executeWithdraw(
    WithdrawExecuteRequest request,
  ) {
    return _service.executeWithdraw(request);
  }

  /// 获取提现历史
  Future<PagedResponse<WithdrawItem>> getWithdraws({
    required int page,
    required int limit,
  }) {
    return _service.getWithdraws(page, limit);
  }

  /// 获取交易历史
  Future<PagedResponse<PositionHistoryItem>> getPositionHistory({
    required int page,
    required int limit,
  }) {
    return _service.getPositionHistory(page, limit);
  }

  /// 获取充值历史
  Future<PagedResponse<DepositItem>> getDeposits({
    required int page,
    required int limit,
  }) {
    return _service.getDeposits(page, limit);
  }

  /// 提交反馈
  Future<FeedbackResponse> submitFeedback({
    required String content,
    List<MultipartFile>? images,
  }) {
    return _service.submitFeedback(content, images);
  }

  /// 开仓
  Future<OpenPositionResponse> openPosition(OpenPositionRequest request) {
    return _service.openPosition(request);
  }

  Future<OpenPositionResponse> openRollingPosition(
      {required int amount,
      required String asset,
      required bool isHigh,
      required int duration,
      required int endTime,
      double targetMultiplier = 1,
      String? positionId}) {
    var usdcMint = Env.config.usdcMint;
    var mint = base58decode(usdcMint);
    return _service.openPosition(OpenPositionRequest(
        amount: amount,
        asset: asset,
        side: isHigh ? 'call' : 'put',
        mint: mint,
        strikePricePctDiffBps: 0,
        targetMultiplier: targetMultiplier,
        positionId: positionId,
        mode: OpenPositionMode(
          type: "Single",
          duration: duration,
          endTime: 0,
        )));
  }

  Future<OpenPositionResponse> openSinglePosition(
      {required int amount,
      required String asset,
      required bool isHigh,
      required int duration,
      required int endTime,
      double targetMultiplier = 1,
      String? positionId}) {
    var usdcMint = Env.config.usdcMint;
    var mint = base58decode(usdcMint);
    return _service.openPosition(OpenPositionRequest(
        amount: amount,
        asset: asset,
        side: isHigh ? 'call' : 'put',
        mint: mint,
        strikePricePctDiffBps: 0,
        targetMultiplier: targetMultiplier,
        positionId: positionId,
        mode: OpenPositionMode(
          type: "Batch",
          duration: duration,
          endTime: endTime,
        )));
  }

  Future<PendingPositionsResponse> getPendingPositions() {
    return _service.getPendingPositions();
  }

}
