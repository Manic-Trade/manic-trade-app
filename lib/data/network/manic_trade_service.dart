import 'package:dio/dio.dart';
import 'package:finality/data/network/model/manic/airdrop_request.dart';
import 'package:finality/data/network/model/manic/airdrop_response.dart';
import 'package:finality/data/network/model/manic/deposit_item.dart';
import 'package:finality/data/network/model/manic/feedback_response.dart';
import 'package:finality/data/network/model/manic/notification_list_response.dart';
import 'package:finality/data/network/model/manic/close_position_request.dart';
import 'package:finality/data/network/model/manic/close_position_response.dart';
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
import 'package:retrofit/retrofit.dart';

part 'manic_trade_service.g.dart';

@RestApi()
abstract class ManicTradeService {
  factory ManicTradeService(
    Dio dio, {
    String? baseUrl,
  }) =>
      _ManicTradeService(dio, baseUrl: baseUrl ?? 'https://bo-server-api-stg.manic.trade');


  /// 5. Read wallet balance - 获取钱包余额
  @GET('/users/token-balance')
  Future<TokenBalanceResponse> getTokenBalance(
  );

  /// 6. User tx history - 获取用户交易历史
  @GET('/users/txns')
  Future<PagedResponse<UserTxnItem>> getUserTxns(
    @Query('page') int page,
    @Query('limit') int limit,
  );

  /// 8. Airdrop test token (only staging) - 空投测试代币
  @POST('/users/trigger-airdrop')
  Future<AirdropResponse> triggerAirdrop(@Body() AirdropRequest request);

  /// 9. Withdraw token info - 获取提现信息
  @GET('/users/withdraw/info')
  Future<WithdrawInfoResponse> getWithdrawInfo();

  /// 10. Withdraw from turnkey wallet - 执行提现
  @POST('/users/withdraw/execute')
  Future<WithdrawExecuteResponse> executeWithdraw(
    @Body() WithdrawExecuteRequest request,
  );

  /// 11. Withdraw history - 获取提现历史
  @GET('/users/withdraws')
  Future<PagedResponse<WithdrawItem>> getWithdraws(
    @Query('page') int page,
    @Query('limit') int limit,
  );

  /// 12. Trade history - 获取交易历史
  @GET('/users/position-history')
  Future<PagedResponse<PositionHistoryItem>> getPositionHistory(
    @Query('page') int page,
    @Query('limit') int limit,
  );

  /// 13. Deposit history - 获取充值历史
  @GET('/users/deposits')
  Future<PagedResponse<DepositItem>> getDeposits(
    @Query('page') int page,
    @Query('limit') int limit,
  );

  /// 14. Feedback - 提交反馈
  @POST('/feedback/submit')
  @MultiPart()
  Future<FeedbackResponse> submitFeedback(
    @Part(name: 'content') String content,
    @Part(name: 'images') List<MultipartFile>? images,
  );

  /// 15. Get usdc mint - 获取 USDC 代币地址
  @POST('/users/open-position')
  Future<OpenPositionResponse> openPosition(@Body() OpenPositionRequest request);

  /// 15a. 开仓 - prepare 阶段（仅 fee_payer 签名，返回 unsigned_tx + request_id）
  @POST('/users/prepare-position')
  Future<PreparePositionResponse> preparePosition(
    @Body() OpenPositionRequest request,
  );

  /// 15b. 开仓 - submit 阶段（回传用户签名，服务端补签 + send_and_confirm 上链）
  ///
  /// 服务端 send_and_confirm 会阻塞等待 Solana 确认，最长可能 30s+。
  /// 默认 receiveTimeout 通过 [options] 设为 60s，避免 Solana 拥堵时客户端先超时
  /// 造成 "toast failed 但仓位实际已上链" 的状态不一致。
  @POST('/users/submit-position')
  Future<SubmitPositionResponse> submitPosition(
    @Body() SubmitPositionRequest request, {
    @DioOptions() Options? options,
  });

  /// 16. Get pending positions - 获取待定仓位
  @GET('/users/pending-positions')
  Future<PendingPositionsResponse> getPendingPositions();

  /// 17. Close position - 提前平仓
  @POST('/users/close-position')
  Future<ClosePositionResponse> closePosition(
    @Body() ClosePositionRequest request, {
    @CancelRequest() CancelToken? cancelToken,
  });

  /// 17a. 平仓 - prepare 阶段（仅 fee_payer 签名）
  @POST('/users/prepare-close-position')
  Future<PrepareClosePositionResponse> prepareClosePosition(
    @Body() ClosePositionRequest request, {
    @CancelRequest() CancelToken? cancelToken,
  });

  /// 17b. 平仓 - submit 阶段（回传用户签名，服务端补签 + send_and_confirm 上链）
  ///
  /// 同 [submitPosition]，需要拉长 receiveTimeout 以覆盖 Solana 确认窗口。
  ///
  /// **这里不接收 CancelToken**：
  /// retrofit_generator 在同时存在 `@DioOptions` + `@CancelRequest` 时不会把 token
  /// 接到 Dio 上（生成代码走 `newRequestOptions`，丢失 `cancelToken`）。另外此时服务端
  /// 已经 `send_and_confirm_transaction` 广播出去了，即使客户端取消也撤销不了上链，
  /// cancel 的语义价值仅为"停止等待响应"。因此干脆不暴露 cancelToken，避免误导调用方。
  /// settle 事件在 prepare 阶段仍能正常打断平仓流程。
  @POST('/users/submit-close-position')
  Future<SubmitClosePositionResponse> submitClosePosition(
    @Body() SubmitClosePositionRequest request, {
    @DioOptions() Options? options,
  });

  /// 18. 获取通知消息列表
  @GET('/users/messages')
  Future<NotificationListResponse> getNotificationMessages(
    @Query('page') int page,
    @Query('limit') int limit,
  );

  /// 19. 标记单条通知为已读
  @POST('/users/messages/read')
  Future<void> markNotificationRead(@Body() Map<String, dynamic> body);

  /// 20. 标记所有通知为已读
  @POST('/users/messages/read-all')
  Future<void> markAllNotificationsRead();

  /// 21. 获取 Twitter 绑定状态与授权链接
  @GET('/users/twitter/status')
  Future<TwitterStatusResponse> getTwitterStatus(
    @Query('wallet') String wallet,
  );

  /// 22. 提交 Twitter OAuth 授权码完成验证
  @POST('/users/twitter/follow')
  Future<TwitterFollowResponse> twitterFollow(
    @Body() TwitterFollowRequest request,
  );

  /// 22.1 通过 Turnkey X provider 绑定 X 账号
  ///
  /// 用户在 Turnkey 上挂好 X provider 之后，调用此接口同步到后端。
  /// `twitter_id` 取 Turnkey X provider 的 `subject`。
  @POST('/users/twitter/bind')
  Future<TwitterBindResponse> twitterBind(
    @Body() TwitterBindRequest request,
  );

  /// 23. 获取邀请码与邀请统计
  @GET('/users/referral/info')
  Future<ReferralInfoResponse> getReferralInfo();

  /// 24. 获取被邀请人列表
  @GET('/users/referral/invitees')
  Future<ReferralInviteesResponse> getReferralInvitees();

  /// 25. 获取交易分析概览
  @GET('/users/pnl/overview')
  Future<PnlOverviewResponse> getPnlOverview(
    @Query('time_range') String timeRange, {
    @Query('asset') String? asset,
    @Query('mode') String? mode,
  });

  /// 26. Premium 分析 - 摘要数据
  @GET('/users/pnl/premium/summary')
  Future<PremiumSummaryResponse> getPremiumSummary(
    @Query('time_range') String timeRange, {
    @Query('asset') String? asset,
    @Query('mode') String? mode,
  });

  /// 27. Premium 分析 - 行为维度数据
  @GET('/users/pnl/premium/analysis')
  Future<PremiumAnalysisResponse> getPremiumAnalysis(
    @Query('time_range') String timeRange, {
    @Query('asset') String? asset,
    @Query('mode') String? mode,
  });

  /// 28. Premium 分析 - 活动热力图数据
  @GET('/users/pnl/premium/activity')
  Future<PremiumActivityResponse> getPremiumActivity(
    @Query('time_range') String timeRange, {
    @Query('asset') String? asset,
    @Query('mode') String? mode,
  });
}
