/// Vault 待赎回记录
class VaultPendingWithdrawal {
  final String id;

  /// 批次索引
  final int batchIndex;

  /// 赎回索引
  final int withdrawIndex;

  /// 金额（单位：lamports，DECIMALS = 1e9）
  final int amount;

  /// 状态：pending, processing, completed
  final String status;

  /// 是否可领取
  final bool canWithdraw;

  /// 是否可取消
  final bool canCancel;

  /// 处理时间（Unix 时间戳，秒）
  final int processedAt;

  const VaultPendingWithdrawal({
    required this.id,
    required this.batchIndex,
    required this.withdrawIndex,
    required this.amount,
    required this.status,
    required this.canWithdraw,
    required this.canCancel,
    required this.processedAt,
  });

  factory VaultPendingWithdrawal.fromJson(Map<String, dynamic> json) {
    return VaultPendingWithdrawal(
      id: json['id']?.toString() ?? '',
      batchIndex: (json['batch_index'] as num?)?.toInt() ?? 0,
      withdrawIndex: (json['withdraw_index'] as num?)?.toInt() ?? 0,
      amount: (json['amount'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? '',
      canWithdraw: json['can_withdraw'] as bool? ?? false,
      canCancel: json['can_cancel'] as bool? ?? false,
      processedAt: (json['processed_at'] as num?)?.toInt() ?? 0,
    );
  }

  /// 状态标签
  String get statusLabel {
    switch (status) {
      case 'wait':
      case 'pending':
        return 'Pending';
      case 'processing':
        return 'Processing';
      case 'completed':
        return 'Available';
      default:
        return status;
    }
  }
}

/// 待赎回列表响应
class VaultPendingWithdrawalListResponse {
  final List<VaultPendingWithdrawal> list;
  final int totalCount;

  const VaultPendingWithdrawalListResponse({
    required this.list,
    required this.totalCount,
  });

  factory VaultPendingWithdrawalListResponse.fromJson(
      Map<String, dynamic> json) {
    return VaultPendingWithdrawalListResponse(
      list: (json['list'] as List<dynamic>?)
              ?.map((e) =>
                  VaultPendingWithdrawal.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      totalCount: (json['total_count'] as num?)?.toInt() ?? 0,
    );
  }
}
