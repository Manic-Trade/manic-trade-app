import 'package:dio/dio.dart';
import 'package:finality/data/network/model/agent/agent_create_request.dart';
import 'package:finality/data/network/model/agent/agent_create_response.dart';
import 'package:finality/data/network/model/agent/agent_delete_key_response.dart';
import 'package:finality/data/network/model/agent/agent_info_response.dart';
import 'package:finality/data/network/model/agent/agent_key_request.dart';
import 'package:finality/data/network/model/agent/agent_regenerate_key_response.dart';
import 'package:finality/data/network/model/agent/agent_rename_key_response.dart';
import 'package:finality/data/network/model/agent/transfer_item.dart';
import 'package:finality/data/network/model/agent/transfer_request.dart';
import 'package:finality/data/network/model/agent/transfer_response.dart';
import 'package:finality/data/network/model/manic/paged_response.dart';
import 'package:finality/data/network/model/manic/position_history_item.dart';
import 'package:retrofit/retrofit.dart';

part 'agent_service.g.dart';

@RestApi()
abstract class AgentService {
  factory AgentService(Dio dio, {String? baseUrl}) = _AgentService;

  /// 创建 Agent 账户 + 初始 API Key
  @POST('/agent/create')
  Future<AgentCreateResponse> createAgent(@Body() AgentCreateRequest request);

  /// 获取 Agent 信息（余额、Key、交易统计）
  @GET('/agent/info')
  Future<AgentInfoResponse> getAgentInfo();

  /// 重新生成 API Key（旧 Key 立即失效）
  @POST('/agent/regenerate-key')
  Future<AgentRegenerateKeyResponse> regenerateKey(
      @Body() AgentKeyRequest request);

  /// 重命名 API Key
  @POST('/agent/rename-key')
  Future<AgentRenameKeyResponse> renameKey(@Body() AgentKeyRequest request);

  /// 删除 API Key
  @DELETE('/agent/delete-key')
  Future<AgentDeleteKeyResponse> deleteKey();

  /// 主账户→Agent 转账
  @POST('/transfer/to-agent')
  Future<TransferResponse> transferToAgent(
      @Body() TransferToAgentRequest request);

  /// Agent→主账户 转账
  @POST('/transfer/from-agent')
  Future<TransferResponse> transferFromAgent(
      @Body() TransferFromAgentRequest request);

  /// 转账历史（分页）
  @GET('/transfer/history')
  Future<PagedResponse<TransferItem>> getTransferHistory(
    @Query('page') int page,
    @Query('limit') int limit,
  );

  /// Agent 交易历史（分页）
  @GET('/agent/position-history')
  Future<PagedResponse<PositionHistoryItem>> getAgentPositionHistory(
    @Query('page') int page,
    @Query('limit') int limit,
  );
}
