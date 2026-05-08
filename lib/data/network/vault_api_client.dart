import 'package:dio/dio.dart';
import 'package:finality/data/network/model/vault/vault_activity.dart';
import 'package:finality/data/network/model/vault/vault_chart_point.dart';
import 'package:finality/data/network/model/vault/vault_pending_withdrawal.dart';
import 'package:finality/data/network/model/vault/vault_performance.dart';
import 'package:finality/data/network/model/vault/vault_tx_response.dart';
import 'package:finality/data/network/model/vault/vault_user_detail.dart';
import 'package:intl/intl.dart';

/// Vault API 精度：1e9
const int vaultDecimals = 1000000000;

/// Vault API 客户端
/// 响应格式：{ "code": 0, "data": {...}, "err_msg": "" }
class VaultApiClient {
  final Dio _dio;

  VaultApiClient(this._dio);

  /// 通用请求，自动解包 code/data
  Future<dynamic> _request(
    String path, {
    String method = 'GET',
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? data,
  }) async {
    final response = await _dio.request(
      path,
      options: Options(method: method),
      queryParameters: queryParameters,
      data: data,
    );

    final result = response.data as Map<String, dynamic>;
    final code = result['code'] as int?;
    if (code != 0) {
      final errMsg =
          result['err_msg'] ?? result['msg'] ?? 'Vault API Error';
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: errMsg.toString(),
      );
    }
    return result['data'];
  }

  /// 注册用户
  Future<void> registerUser(String walletAddress) async {
    await _request('/api/register_user',
        method: 'POST', data: {'user': walletAddress});
  }

  /// 获取用户持仓详情
  Future<VaultUserDetail> getUserDetailInfo(String walletAddress) async {
    final data = await _request('/api/get_user_detail_info',
        queryParameters: {'user': walletAddress});
    if (data == null) return VaultUserDetail.placeholder();
    return VaultUserDetail.fromJson(data as Map<String, dynamic>);
  }

  /// 获取全局性能指标
  Future<VaultPerformance> getPerformanceDetailInfo() async {
    final data = await _request('/api/get_performance_detail_info');
    if (data == null) return VaultPerformance.placeholder();
    return VaultPerformance.fromJson(data as Map<String, dynamic>);
  }

  /// 获取 TVL 历史数据
  Future<List<VaultChartPoint>> getTVLHistory(
    int startTime,
    int endTime, {
    required String timeRange,
  }) async {
    final data = await _request('/api/get_tvl_history',
        queryParameters: {'start_time': startTime, 'end_time': endTime});
    if (data == null) return [];
    final list = data as List<dynamic>;
    return _mapChartData(
      list,
      timeRange: timeRange,
      valueMapper: (item) =>
          ((item['amount'] as num?)?.toDouble() ?? 0) / vaultDecimals,
    );
  }

  /// 获取 APY 历史数据
  Future<List<VaultChartPoint>> getAPYHistory(
    int startTime,
    int endTime, {
    required String timeRange,
  }) async {
    final data = await _request('/api/get_apy_history',
        queryParameters: {'start_time': startTime, 'end_time': endTime});
    if (data == null) return [];
    final list = data as List<dynamic>;
    return _mapChartData(
      list,
      timeRange: timeRange,
      valueMapper: (item) =>
          ((item['apy'] as num?)?.toDouble() ?? 0) * 100,
    );
  }

  /// 获取活动列表
  Future<VaultActivityListResponse> getActivity(
    String walletAddress,
    int page,
    int pageSize,
  ) async {
    final data = await _request('/api/get_activity', queryParameters: {
      'user': walletAddress,
      'page': page,
      'page_size': pageSize,
    });
    if (data == null) {
      return const VaultActivityListResponse(list: [], totalCount: 0);
    }
    return VaultActivityListResponse.fromJson(data as Map<String, dynamic>);
  }

  /// 获取用户待赎回列表
  Future<VaultPendingWithdrawalListResponse> getUserPendingWithdraw(
    String walletAddress, {
    int page = 0,
    int pageSize = 50,
  }) async {
    final data = await _request('/api/get_user_pending_withdraw',
        queryParameters: {
          'user': walletAddress,
          'page': page,
          'page_size': pageSize,
        });
    if (data == null) {
      return const VaultPendingWithdrawalListResponse(
          list: [], totalCount: 0);
    }
    return VaultPendingWithdrawalListResponse.fromJson(
        data as Map<String, dynamic>);
  }

  // ========== 交易接口 ==========

  /// 生成投资（质押）交易
  Future<VaultTxResponse> genStakeTx(String owner, int amount) async {
    final data = await _request('/api/gen_stake_tx',
        method: 'POST',
        data: {'owner': owner, 'amount': amount, 'payer': owner});
    return VaultTxResponse.fromJson(data as Map<String, dynamic>);
  }

  /// 提交已签名的投资交易
  Future<void> processStakeTx(
      String base64Tx, String extraData, String signData) async {
    await _request('/api/process_stake_tx', method: 'POST', data: {
      'base64_tx': base64Tx,
      'extra_data': extraData,
      'sign_data': signData,
    });
  }

  /// 生成赎回交易
  Future<VaultTxResponse> genWithdrawTx(String owner, int amount) async {
    final data = await _request('/api/gen_withdraw_tx',
        method: 'POST',
        data: {'owner': owner, 'amount': amount, 'payer': owner});
    return VaultTxResponse.fromJson(data as Map<String, dynamic>);
  }

  /// 提交已签名的赎回交易
  Future<void> processWithdrawTx(
      String base64Tx, String extraData, String signData) async {
    await _request('/api/process_withdraw_tx', method: 'POST', data: {
      'base64_tx': base64Tx,
      'extra_data': extraData,
      'sign_data': signData,
    });
  }

  /// 生成取消赎回交易
  Future<VaultTxResponse> genCancelWithdrawTx(
      String owner, int withdrawIndex) async {
    final data = await _request('/api/gen_cancel_withdraw_tx',
        method: 'POST',
        data: {
          'owner': owner,
          'withdraw_index': withdrawIndex,
          'payer': owner,
        });
    return VaultTxResponse.fromJson(data as Map<String, dynamic>);
  }

  /// 提交已签名的取消赎回交易
  Future<void> processCancelWithdrawTx(
      String base64Tx, String extraData, String signData) async {
    await _request('/api/process_cancel_withdraw_tx', method: 'POST', data: {
      'base64_tx': base64Tx,
      'extra_data': extraData,
      'sign_data': signData,
    });
  }

  /// 生成领取赎回交易
  Future<VaultTxResponse> genUserClaimTx(
      String owner, int batchIndex, int withdrawIndex) async {
    final data = await _request('/api/gen_user_claim',
        method: 'POST',
        data: {
          'owner': owner,
          'batch_index': batchIndex,
          'withdraw_index': withdrawIndex,
          'payer': owner,
        });
    return VaultTxResponse.fromJson(data as Map<String, dynamic>);
  }

  /// 提交已签名的领取赎回交易
  Future<void> processUserClaimTx(
      String base64Tx, String extraData, String signData) async {
    await _request('/api/process_user_claim', method: 'POST', data: {
      'base64_tx': base64Tx,
      'extra_data': extraData,
      'sign_data': signData,
    });
  }

  /// 将原始图表数据映射为 VaultChartPoint 列表，按日期去重取最大值
  List<VaultChartPoint> _mapChartData(
    List<dynamic> list, {
    required String timeRange,
    required double Function(Map<String, dynamic>) valueMapper,
  }) {
    final mapped = list.map((item) {
      final map = item as Map<String, dynamic>;
      final timestamp = (map['create_at'] as num).toInt();
      final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
      return VaultChartPoint(
        date: _formatDate(date, timeRange),
        value: valueMapper(map),
        timestamp: timestamp,
      );
    }).toList();

    // 按日期去重，保留最大值
    final byDate = <String, VaultChartPoint>{};
    for (final pt in mapped) {
      final existing = byDate[pt.date];
      if (existing == null || pt.value > existing.value) {
        byDate[pt.date] = pt;
      }
    }

    final result = byDate.values.toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return result;
  }

  String _formatDate(DateTime date, String timeRange) {
    switch (timeRange) {
      case 'All':
        return DateFormat("MMM ''yy").format(date);
      case '90d':
        return DateFormat('MMM d').format(date);
      default:
        return '${date.month}/${date.day}';
    }
  }
}
