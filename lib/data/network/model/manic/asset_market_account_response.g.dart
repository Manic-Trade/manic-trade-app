// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'asset_market_account_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssetMarketAccountResponse _$AssetMarketAccountResponseFromJson(
        Map<String, dynamic> json) =>
    AssetMarketAccountResponse(
      marketAccountInfo: MarketAccountResponse.fromJson(
          json['market_account_info'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AssetMarketAccountResponseToJson(
        AssetMarketAccountResponse instance) =>
    <String, dynamic>{
      'market_account_info': instance.marketAccountInfo,
    };
