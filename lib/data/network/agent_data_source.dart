import 'package:finality/data/network/agent_service.dart';
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

class AgentDataSource {
  final AgentService _service;

  AgentDataSource(this._service);

  /// 创建 Agent 账户
  Future<AgentCreateResponse> createAgent({String keyName = 'Default'}) {
    return _service.createAgent(AgentCreateRequest(keyName: keyName));
  }

  /// 获取 Agent 信息
  Future<AgentInfoResponse> getAgentInfo() {
    return _service.getAgentInfo();
  }

  /// 重新生成 API Key
  Future<AgentRegenerateKeyResponse> regenerateKey(
      {String keyName = 'Default'}) {
    return _service.regenerateKey(AgentKeyRequest(keyName: keyName));
  }

  /// 重命名 API Key
  Future<AgentRenameKeyResponse> renameKey({required String keyName}) {
    return _service.renameKey(AgentKeyRequest(keyName: keyName));
  }

  /// 删除 API Key
  Future<AgentDeleteKeyResponse> deleteKey() {
    return _service.deleteKey();
  }

  /// 主账户→Agent 转账
  Future<TransferResponse> transferToAgent({
    required String amount,
    String? transaction,
  }) {
    return _service.transferToAgent(
      TransferToAgentRequest(amount: amount, transaction: transaction),
    );
  }

  /// Agent→主账户 转账
  Future<TransferResponse> transferFromAgent({required String amount}) {
    return _service.transferFromAgent(
      TransferFromAgentRequest(amount: amount),
    );
  }

  /// 获取转账历史
  Future<PagedResponse<TransferItem>> getTransferHistory({
    required int page,
    required int limit,
  }) {
    return _service.getTransferHistory(page, limit);
  }

  /// 获取 Agent 交易历史
  Future<PagedResponse<PositionHistoryItem>> getAgentPositionHistory({
    required int page,
    required int limit,
  }) {
    return _service.getAgentPositionHistory(page, limit);
  }
}
