import 'package:json_annotation/json_annotation.dart';

part 'transfer_response.g.dart';

@JsonSerializable()
class TransferResponse {
  @JsonKey(name: 'tx_hash')
  final String txHash;
  final String amount;
  final String direction;

  const TransferResponse({
    required this.txHash,
    required this.amount,
    required this.direction,
  });

  factory TransferResponse.fromJson(Map<String, dynamic> json) =>
      _$TransferResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TransferResponseToJson(this);
}
