/// Vault 活动记录
class VaultActivity {
  final String id;

  /// 活动类型：deposit, request_withdraw, claim, cancel_withdraw
  final String activityType;

  /// 金额（单位：lamports，DECIMALS = 1e9）
  final int amount;

  /// 状态：pending, processing, completed, cancelled
  final String status;

  /// 交易哈希
  final String hash;

  /// 创建时间（Unix 时间戳，秒）
  final int createAt;

  const VaultActivity({
    required this.id,
    required this.activityType,
    required this.amount,
    required this.status,
    required this.hash,
    required this.createAt,
  });

  factory VaultActivity.fromJson(Map<String, dynamic> json) {
    return VaultActivity(
      id: json['id']?.toString() ?? '',
      activityType: json['activity_type'] as String? ?? '',
      amount: (json['amount'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? '',
      hash: json['hash'] as String? ?? '',
      createAt: (json['create_at'] as num?)?.toInt() ?? 0,
    );
  }

  /// 格式化的活动类型标签
  String get typeLabel {
    switch (activityType) {
      case 'deposit':
        return 'Invest';
      case 'request_withdraw':
        return 'Request Redeem';
      case 'claim':
        return 'Claim';
      case 'cancel_withdraw':
        return 'Cancel Redeem';
      default:
        return activityType;
    }
  }

  /// 是否为入金类型
  bool get isDeposit => activityType == 'deposit';

  /// 是否为待处理或处理中状态
  bool get isPendingOrProcessing =>
      status == 'pending' || status == 'processing';
}

/// Vault 活动列表响应
class VaultActivityListResponse {
  final List<VaultActivity> list;
  final int totalCount;

  const VaultActivityListResponse({
    required this.list,
    required this.totalCount,
  });

  factory VaultActivityListResponse.fromJson(Map<String, dynamic> json) {
    return VaultActivityListResponse(
      list: (json['list'] as List<dynamic>?)
              ?.map((e) => VaultActivity.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      totalCount: (json['total_count'] as num?)?.toInt() ?? 0,
    );
  }
}
