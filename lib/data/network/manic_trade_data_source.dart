import 'package:dio/dio.dart';
import 'package:finality/data/network/manic_trade_service.dart';
import 'package:finality/data/network/model/manic/airdrop_request.dart';
import 'package:finality/data/network/model/manic/airdrop_response.dart';
import 'package:finality/data/network/model/manic/close_position_request.dart';
import 'package:finality/data/network/model/manic/close_position_response.dart';
import 'package:finality/data/network/model/manic/deposit_item.dart';
import 'package:finality/data/network/model/manic/feedback_response.dart';
import 'package:finality/data/network/model/manic/notification_list_response.dart';
import 'package:finality/data/network/model/manic/open_position_request.dart';
import 'package:finality/data/network/model/manic/open_position_response.dart';
import 'package:finality/data/network/model/manic/paged_response.dart';
import 'package:finality/data/network/model/manic/prepare_close_position_response.dart';
import 'package:finality/data/network/model/manic/prepare_position_response.dart';
import 'package:finality/data/network/model/manic/submit_close_position_request.dart';
import 'package:finality/data/network/model/manic/submit_close_position_response.dart';
import 'package:finality/data/network/model/manic/submit_position_request.dart';
import 'package:finality/data/network/model/manic/submit_position_response.dart';
import 'package:finality/data/network/model/manic/pnl_overview_response.dart';
import 'package:finality/data/network/model/manic/premium_activity_response.dart';
import 'package:finality/data/network/model/manic/premium_analysis_response.dart';
import 'package:finality/data/network/model/manic/premium_summary_response.dart';
import 'package:finality/data/network/model/manic/pending_position_item_response.dart';
import 'package:finality/data/network/model/manic/position_history_item.dart';
import 'package:finality/data/network/model/manic/referral_info_response.dart';
import 'package:finality/data/network/model/manic/referral_invitees_response.dart';
import 'package:finality/data/network/model/manic/token_balance_response.dart';
import 'package:finality/data/network/model/manic/twitter_bind_request.dart';
import 'package:finality/data/network/model/manic/twitter_bind_response.dart';
import 'package:finality/data/network/model/manic/twitter_follow_request.dart';
import 'package:finality/data/network/model/manic/twitter_follow_response.dart';
import 'package:finality/data/network/model/manic/twitter_status_response.dart';
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
    return _service.openPosition(_buildOpenPositionRequest(
      amount: amount,
      asset: asset,
      isHigh: isHigh,
      duration: duration,
      endTime: 0,
      targetMultiplier: targetMultiplier,
      positionId: positionId,
      modeType: 'Single',
    ));
  }

  Future<OpenPositionResponse> openSinglePosition(
      {required int amount,
      required String asset,
      required bool isHigh,
      required int duration,
      required int endTime,
      double targetMultiplier = 1,
      String? positionId}) {
    return _service.openPosition(_buildOpenPositionRequest(
      amount: amount,
      asset: asset,
      isHigh: isHigh,
      duration: duration,
      endTime: endTime,
      targetMultiplier: targetMultiplier,
      positionId: positionId,
      modeType: 'Batch',
    ));
  }

  /// 开仓 prepare 阶段：仅 fee_payer 签名，返回 unsigned_tx + request_id。
  ///
  /// 参数与 [openRollingPosition] / [openSinglePosition] 等价，[modeType] 必须
  /// 与旧接口保持一致："Single"（Rolling 滚动）或 "Batch"（Single 定时结算）。
  Future<PreparePositionResponse> preparePosition({
    required int amount,
    required String asset,
    required bool isHigh,
    required int duration,
    required int endTime,
    double targetMultiplier = 1,
    String? positionId,
    required String modeType,
  }) {
    return _service.preparePosition(_buildOpenPositionRequest(
      amount: amount,
      asset: asset,
      isHigh: isHigh,
      duration: duration,
      endTime: modeType == 'Single' ? 0 : endTime,
      targetMultiplier: targetMultiplier,
      positionId: positionId,
      modeType: modeType,
      includeMint: false,
    ));
  }

  /// 开仓 submit 阶段：回传用户签名，服务端补签 + send_and_confirm 上链。
  ///
  /// 服务端会阻塞等待链上确认（可能 2~30s），这里放宽 receiveTimeout 到 60s，
  /// 避免 Solana 拥堵时客户端先 timeout、但交易实际已广播的状态不一致问题。
  Future<SubmitPositionResponse> submitPosition({
    required String requestId,
    required String userSignature,
  }) {
    return _service.submitPosition(
      SubmitPositionRequest(
        requestId: requestId,
        userSignature: userSignature,
      ),
      options: Options(
        receiveTimeout: const Duration(seconds: 60),
        // retrofit `@DioOptions` 路径不会自动补 Content-Type（`.compose()` 路径才会），
        // 必须手动显式声明，否则服务端直接 400 "Expected request with Content-Type: application/json"
        contentType: Headers.jsonContentType,
      ),
    );
  }

  OpenPositionRequest _buildOpenPositionRequest({
    required int amount,
    required String asset,
    required bool isHigh,
    required int duration,
    required int endTime,
    required double targetMultiplier,
    required String? positionId,
    required String modeType,
    bool includeMint = true,
  }) {
    return OpenPositionRequest(
      amount: amount,
      asset: asset,
      side: isHigh ? 'call' : 'put',
      // 老接口 `/open_position` 仍需 mint；`/prepare_position` 不需要。
      mint: includeMint ? base58decode(Env.config.usdcMint) : null,
      strikePricePctDiffBps: 0,
      targetMultiplier: targetMultiplier,
      positionId: positionId,
      mode: OpenPositionMode(
        type: modeType,
        duration: duration,
        endTime: endTime,
      ),
    );
  }

  Future<PendingPositionsResponse> getPendingPositions() {
    return _service.getPendingPositions();
  }

  /// 获取通知消息列表
  Future<NotificationListResponse> getNotificationMessages({
    required int page,
    required int limit,
  }) {
    return _service.getNotificationMessages(page, limit);
  }

  /// 标记单条通知为已读
  Future<void> markNotificationRead(int messageTargetId) {
    return _service.markNotificationRead({
      'message_target_id': messageTargetId,
    });
  }

  /// 标记所有通知为已读
  Future<void> markAllNotificationsRead() async {
    await _service.markAllNotificationsRead();
  }

  /// 提前平仓
  Future<ClosePositionResponse> closePosition({
    required String positionId,
    required String asset,
    CancelToken? cancelToken,
  }) {
    return _service.closePosition(
      _buildClosePositionRequest(positionId: positionId, asset: asset),
      cancelToken: cancelToken,
    );
  }

  /// 平仓 prepare 阶段：仅 fee_payer 签名，返回 unsigned_tx + request_id。
  Future<PrepareClosePositionResponse> prepareClosePosition({
    required String positionId,
    required String asset,
    CancelToken? cancelToken,
  }) {
    return _service.prepareClosePosition(
      _buildClosePositionRequest(positionId: positionId, asset: asset),
      cancelToken: cancelToken,
    );
  }

  /// 平仓 submit 阶段：回传用户签名，服务端补签 + send_and_confirm 上链。
  /// 同 [submitPosition] 放宽 receiveTimeout 到 60s。
  ///
  /// 不支持 cancelToken，详见 [ManicTradeService.submitClosePosition] 注释。
  Future<SubmitClosePositionResponse> submitClosePosition({
    required String requestId,
    required String userSignature,
  }) {
    return _service.submitClosePosition(
      SubmitClosePositionRequest(
        requestId: requestId,
        userSignature: userSignature,
      ),
      options: Options(
        receiveTimeout: const Duration(seconds: 60),
        // retrofit `@DioOptions` 路径不会自动补 Content-Type（`.compose()` 路径才会），
        // 必须手动显式声明，否则服务端直接 400 "Expected request with Content-Type: application/json"
        contentType: Headers.jsonContentType,
      ),
    );
  }

  ClosePositionRequest _buildClosePositionRequest({
    required String positionId,
    required String asset,
  }) {
    final mint = base58decode(Env.config.usdcMint);
    return ClosePositionRequest(
      positionId: positionId,
      asset: asset,
      mint: mint,
    );
  }

  /// 获取 Twitter 绑定状态与授权链接
  Future<TwitterStatusResponse> getTwitterStatus(String wallet) {
    return _service.getTwitterStatus(wallet);
  }

  /// 提交 Twitter OAuth 授权码完成验证
  Future<TwitterFollowResponse> twitterFollow({
    required String code,
    required String state,
  }) {
    return _service.twitterFollow(TwitterFollowRequest(
      code: code,
      state: state,
    ));
  }

  /// 通过 Turnkey X provider 绑定 X 账号
  ///
  /// [twitterId] 取 Turnkey X provider 的 `subject` 字段。
  /// [userId] 取 Turnkey `v1User.userId`，后端用它把 provider 查询限定到具体 user。
  Future<TwitterBindResponse> twitterBind({
    required String userId,
    required String subOrgId,
    required String wallet,
    required String twitterId,
    String? twitterUsername,
    String? avatarUrl,
  }) {
    return _service.twitterBind(TwitterBindRequest(
      userId: userId,
      subOrgId: subOrgId,
      wallet: wallet,
      twitterId: twitterId,
      twitterUsername: twitterUsername,
      avatarUrl: avatarUrl,
    ));
  }

  /// 获取邀请码与邀请统计
  Future<ReferralInfoResponse> getReferralInfo() {
    return _service.getReferralInfo();
  }

  /// 获取被邀请人列表
  Future<ReferralInviteesResponse> getReferralInvitees() {
    return _service.getReferralInvitees();
  }

  /// 获取交易分析概览
  Future<PnlOverviewResponse> getPnlOverview({
    required String timeRange,
    String? asset,
    String? mode,
  }) {
    return _service.getPnlOverview(timeRange, asset: asset, mode: mode);
  }

  /// Premium 分析 - 摘要数据
  Future<PremiumSummaryResponse> getPremiumSummary({
    required String timeRange,
    String? asset,
    String? mode,
  }) {
    return _service.getPremiumSummary(timeRange, asset: asset, mode: mode);
  }

  /// Premium 分析 - 行为维度数据
  Future<PremiumAnalysisResponse> getPremiumAnalysis({
    required String timeRange,
    String? asset,
    String? mode,
  }) {
    return _service.getPremiumAnalysis(timeRange, asset: asset, mode: mode);
  }

  /// Premium 分析 - 活动热力图数据
  Future<PremiumActivityResponse> getPremiumActivity({
    required String timeRange,
    String? asset,
    String? mode,
  }) {
    return _service.getPremiumActivity(timeRange, asset: asset, mode: mode);
  }
}
