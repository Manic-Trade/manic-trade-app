// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ua_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UAAddressInfo _$UAAddressInfoFromJson(Map<String, dynamic> json) =>
    UAAddressInfo(
      evmAddress: json['evm_address'] as String? ?? '',
      solanaAddress: json['solana_address'] as String? ?? '',
    );

Map<String, dynamic> _$UAAddressInfoToJson(UAAddressInfo instance) =>
    <String, dynamic>{
      'evm_address': instance.evmAddress,
      'solana_address': instance.solanaAddress,
    };

UAAccountData _$UAAccountDataFromJson(Map<String, dynamic> json) =>
    UAAccountData(
      owner: UAAddressInfo.fromJson(json['owner'] as Map<String, dynamic>),
      ua: UAAddressInfo.fromJson(json['ua'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UAAccountDataToJson(UAAccountData instance) =>
    <String, dynamic>{
      'owner': instance.owner,
      'ua': instance.ua,
    };

UAAccountApiResponse _$UAAccountApiResponseFromJson(
        Map<String, dynamic> json) =>
    UAAccountApiResponse(
      data: UAAccountData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UAAccountApiResponseToJson(
        UAAccountApiResponse instance) =>
    <String, dynamic>{
      'data': instance.data,
    };

UAAsset _$UAAssetFromJson(Map<String, dynamic> json) => UAAsset(
      symbol: json['symbol'] as String? ?? '',
      name: json['name'] as String? ?? '',
      icon: json['icon'] as String? ?? '',
      decimals: (json['decimals'] as num?)?.toInt() ?? 6,
    );

Map<String, dynamic> _$UAAssetToJson(UAAsset instance) => <String, dynamic>{
      'symbol': instance.symbol,
      'name': instance.name,
      'icon': instance.icon,
      'decimals': instance.decimals,
    };

UAChain _$UAChainFromJson(Map<String, dynamic> json) => UAChain(
      chain: json['chain'] as String? ?? '',
      chainId: (json['chain_id'] as num?)?.toInt() ?? 0,
      chainIcon: json['chain_icon'] as String? ?? '',
      isEvm: json['is_evm'] as bool? ?? false,
      nativeToken: json['native_token'] as String? ?? '',
      assets: (json['assets'] as List<dynamic>?)
          ?.map((e) => UAAsset.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$UAChainToJson(UAChain instance) => <String, dynamic>{
      'chain': instance.chain,
      'chain_id': instance.chainId,
      'chain_icon': instance.chainIcon,
      'is_evm': instance.isEvm,
      'native_token': instance.nativeToken,
      'assets': instance.assets?.map((e) => e.toJson()).toList(),
    };

UAAssetsApiResponse _$UAAssetsApiResponseFromJson(Map<String, dynamic> json) =>
    UAAssetsApiResponse(
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => UAChain.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$UAAssetsApiResponseToJson(
        UAAssetsApiResponse instance) =>
    <String, dynamic>{
      'data': instance.data?.map((e) => e.toJson()).toList(),
    };

UAAssetItem _$UAAssetItemFromJson(Map<String, dynamic> json) => UAAssetItem(
      tokenType: json['tokenType'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      amountInUSD: (json['amountInUSD'] as num?)?.toDouble() ?? 0.0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      chainId: (json['chainId'] as num?)?.toInt() ?? 0,
      address: json['address'] as String? ?? '',
      decimals: (json['decimals'] as num?)?.toInt() ?? 6,
      realDecimals: (json['realDecimals'] as num?)?.toInt() ?? 6,
    );

Map<String, dynamic> _$UAAssetItemToJson(UAAssetItem instance) =>
    <String, dynamic>{
      'tokenType': instance.tokenType,
      'amount': instance.amount,
      'amountInUSD': instance.amountInUSD,
      'price': instance.price,
      'chainId': instance.chainId,
      'address': instance.address,
      'decimals': instance.decimals,
      'realDecimals': instance.realDecimals,
    };

UABalance _$UABalanceFromJson(Map<String, dynamic> json) => UABalance(
      totalUsd: (json['total_usd'] as num?)?.toDouble() ?? 0.0,
      minProcess: (json['min_process'] as num?)?.toDouble() ?? 10.0,
      largestAsset: json['largest_asset'] == null
          ? null
          : UAAssetItem.fromJson(json['largest_asset'] as Map<String, dynamic>),
      assets: (json['assets'] as List<dynamic>?)
          ?.map((e) => UAAssetItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$UABalanceToJson(UABalance instance) => <String, dynamic>{
      'total_usd': instance.totalUsd,
      'min_process': instance.minProcess,
      'largest_asset': instance.largestAsset?.toJson(),
      'assets': instance.assets?.map((e) => e.toJson()).toList(),
    };

UABalanceData _$UABalanceDataFromJson(Map<String, dynamic> json) =>
    UABalanceData(
      balance: UABalance.fromJson(json['balance'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UABalanceDataToJson(UABalanceData instance) =>
    <String, dynamic>{
      'balance': instance.balance.toJson(),
    };

UABalanceApiResponse _$UABalanceApiResponseFromJson(
        Map<String, dynamic> json) =>
    UABalanceApiResponse(
      data: UABalanceData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UABalanceApiResponseToJson(
        UABalanceApiResponse instance) =>
    <String, dynamic>{
      'data': instance.data.toJson(),
    };

UASolanaBalanceData _$UASolanaBalanceDataFromJson(Map<String, dynamic> json) =>
    UASolanaBalanceData(
      address: json['address'] as String? ?? '',
      usdcBalance: (json['usdc_balance'] as num?)?.toDouble() ?? 0.0,
      usdcBalanceRaw: json['usdc_balance_raw'] as String? ?? '',
    );

Map<String, dynamic> _$UASolanaBalanceDataToJson(
        UASolanaBalanceData instance) =>
    <String, dynamic>{
      'address': instance.address,
      'usdc_balance': instance.usdcBalance,
      'usdc_balance_raw': instance.usdcBalanceRaw,
    };

UASolanaBalanceApiResponse _$UASolanaBalanceApiResponseFromJson(
        Map<String, dynamic> json) =>
    UASolanaBalanceApiResponse(
      data: UASolanaBalanceData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UASolanaBalanceApiResponseToJson(
        UASolanaBalanceApiResponse instance) =>
    <String, dynamic>{
      'data': instance.data,
    };

UASweepData _$UASweepDataFromJson(Map<String, dynamic> json) => UASweepData(
      transferAmount: (json['transfer_amount'] as num?)?.toDouble() ?? 0.0,
      transactionId: json['transaction_id'] as String? ?? '',
      explorerUrl: json['explorer_url'] as String? ?? '',
      targetAddress: json['target_address'] as String? ?? '',
      solanaTxHash: json['solana_tx_hash'] as String? ?? '',
    );

Map<String, dynamic> _$UASweepDataToJson(UASweepData instance) =>
    <String, dynamic>{
      'transfer_amount': instance.transferAmount,
      'transaction_id': instance.transactionId,
      'explorer_url': instance.explorerUrl,
      'target_address': instance.targetAddress,
      'solana_tx_hash': instance.solanaTxHash,
    };

UASweepApiResponse _$UASweepApiResponseFromJson(Map<String, dynamic> json) =>
    UASweepApiResponse(
      data: UASweepData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UASweepApiResponseToJson(UASweepApiResponse instance) =>
    <String, dynamic>{
      'data': instance.data.toJson(),
    };
