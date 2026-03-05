import 'package:json_annotation/json_annotation.dart';

part 'airdrop_request.g.dart';

@JsonSerializable()
class AirdropRequest {
  final String wallet;

  const AirdropRequest({
    required this.wallet,
  });

  factory AirdropRequest.fromJson(Map<String, dynamic> json) =>
      _$AirdropRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AirdropRequestToJson(this);
}

