import 'package:finality/data/network/model/manic/market_account_response.dart';
import 'package:json_annotation/json_annotation.dart';

part 'asset_market_account_response.g.dart';

@JsonSerializable()
class AssetMarketAccountResponse {
  @JsonKey(name: 'market_account_info')
  final MarketAccountResponse marketAccountInfo;

  const AssetMarketAccountResponse({
    required this.marketAccountInfo,
  });

  factory AssetMarketAccountResponse.fromJson(Map<String, dynamic> json) =>
      _$AssetMarketAccountResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AssetMarketAccountResponseToJson(this);
}
