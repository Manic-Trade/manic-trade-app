import 'package:dio/dio.dart';
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

  /// 16. Get pending positions - 获取待定仓位
  @GET('/users/pending-positions')
  Future<PendingPositionsResponse> getPendingPositions();




}
