import 'package:json_annotation/json_annotation.dart';

part 'transfer_request.g.dart';

/// 主账户→Agent 转账请求
@JsonSerializable()
class TransferToAgentRequest {
  /// Decimal string，例如 "10.500000"
  final String amount;
  /// Base64 编码的用户签名 Solana 交易（可选）
  final String? transaction;

  const TransferToAgentRequest({
    required this.amount,
    this.transaction,
  });

  factory TransferToAgentRequest.fromJson(Map<String, dynamic> json) =>
      _$TransferToAgentRequestFromJson(json);

  Map<String, dynamic> toJson() => _$TransferToAgentRequestToJson(this);
}

/// Agent→主账户 转账请求
@JsonSerializable()
class TransferFromAgentRequest {
  /// Decimal string，例如 "5.000000"
  final String amount;

  const TransferFromAgentRequest({required this.amount});

  factory TransferFromAgentRequest.fromJson(Map<String, dynamic> json) =>
      _$TransferFromAgentRequestFromJson(json);

  Map<String, dynamic> toJson() => _$TransferFromAgentRequestToJson(this);
}
