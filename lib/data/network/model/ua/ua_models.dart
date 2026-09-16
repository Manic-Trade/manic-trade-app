// UA（Universal Account）跨链充值相关数据模型
import 'package:json_annotation/json_annotation.dart';

part 'ua_models.g.dart';

// ── 地址信息 ──────────────────────────────────────────────

@JsonSerializable()
class UAAddressInfo {
  @JsonKey(name: 'evm_address', defaultValue: '')
  final String evmAddress;

  @JsonKey(name: 'solana_address', defaultValue: '')
  final String solanaAddress;

  const UAAddressInfo({
    required this.evmAddress,
    required this.solanaAddress,
  });

  factory UAAddressInfo.fromJson(Map<String, dynamic> json) =>
      _$UAAddressInfoFromJson(json);

  Map<String, dynamic> toJson() => _$UAAddressInfoToJson(this);
}

// ── /api/ua/account ──────────────────────────────────────

/// 账户数据（owner = 真实 Turnkey 地址，ua = 中间充值地址）
@JsonSerializable()
class UAAccountData {
  @JsonKey(name: 'owner')
  final UAAddressInfo owner;

  @JsonKey(name: 'ua')
  final UAAddressInfo ua;

  const UAAccountData({required this.owner, required this.ua});

  factory UAAccountData.fromJson(Map<String, dynamic> json) =>
      _$UAAccountDataFromJson(json);

  Map<String, dynamic> toJson() => _$UAAccountDataToJson(this);
}

/// GET /api/ua/account 完整响应（{success, data: UAAccountData}）
@JsonSerializable()
class UAAccountApiResponse {
  @JsonKey(name: 'data')
  final UAAccountData data;

  const UAAccountApiResponse({required this.data});

  factory UAAccountApiResponse.fromJson(Map<String, dynamic> json) =>
      _$UAAccountApiResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UAAccountApiResponseToJson(this);
}

// ── /api/assets ──────────────────────────────────────────

@JsonSerializable()
class UAAsset {
  @JsonKey(name: 'symbol', defaultValue: '')
  final String symbol;

  @JsonKey(name: 'name', defaultValue: '')
  final String name;

  @JsonKey(name: 'icon', defaultValue: '')
  final String icon;

  @JsonKey(name: 'decimals', defaultValue: 6)
  final int decimals;

  const UAAsset({
    required this.symbol,
    required this.name,
    required this.icon,
    required this.decimals,
  });

  factory UAAsset.fromJson(Map<String, dynamic> json) =>
      _$UAAssetFromJson(json);

  Map<String, dynamic> toJson() => _$UAAssetToJson(this);
}

@JsonSerializable(explicitToJson: true)
class UAChain {
  @JsonKey(name: 'chain', defaultValue: '')
  final String chain;

  @JsonKey(name: 'chain_id', defaultValue: 0)
  final int chainId;

  @JsonKey(name: 'chain_icon', defaultValue: '')
  final String chainIcon;

  @JsonKey(name: 'is_evm', defaultValue: false)
  final bool isEvm;

  @JsonKey(name: 'native_token', defaultValue: '')
  final String nativeToken;

  @JsonKey(name: 'assets')
  final List<UAAsset>? assets;

  List<UAAsset> get assetList => assets ?? [];

  const UAChain({
    required this.chain,
    required this.chainId,
    required this.chainIcon,
    required this.isEvm,
    required this.nativeToken,
    this.assets,
  });

  factory UAChain.fromJson(Map<String, dynamic> json) =>
      _$UAChainFromJson(json);

  Map<String, dynamic> toJson() => _$UAChainToJson(this);
}

/// GET /api/assets 完整响应（{success, data: List<UAChain>}）
@JsonSerializable(explicitToJson: true)
class UAAssetsApiResponse {
  @JsonKey(name: 'data')
  final List<UAChain>? data;

  List<UAChain> get chains => data ?? [];

  const UAAssetsApiResponse({this.data});

  factory UAAssetsApiResponse.fromJson(Map<String, dynamic> json) =>
      _$UAAssetsApiResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UAAssetsApiResponseToJson(this);
}

// ── /api/ua/balance ──────────────────────────────────────

@JsonSerializable()
class UAAssetItem {
  @JsonKey(name: 'tokenType', defaultValue: '')
  final String tokenType;

  @JsonKey(name: 'amount', defaultValue: 0.0)
  final double amount;

  @JsonKey(name: 'amountInUSD', defaultValue: 0.0)
  final double amountInUSD;

  @JsonKey(name: 'price', defaultValue: 0.0)
  final double price;

  @JsonKey(name: 'chainId', defaultValue: 0)
  final int chainId;

  @JsonKey(name: 'address', defaultValue: '')
  final String address;

  @JsonKey(name: 'decimals', defaultValue: 6)
  final int decimals;

  @JsonKey(name: 'realDecimals', defaultValue: 6)
  final int realDecimals;

  const UAAssetItem({
    required this.tokenType,
    required this.amount,
    required this.amountInUSD,
    required this.price,
    required this.chainId,
    required this.address,
    required this.decimals,
    required this.realDecimals,
  });

  factory UAAssetItem.fromJson(Map<String, dynamic> json) =>
      _$UAAssetItemFromJson(json);

  Map<String, dynamic> toJson() => _$UAAssetItemToJson(this);
}

@JsonSerializable(explicitToJson: true)
class UABalance {
  @JsonKey(name: 'total_usd', defaultValue: 0.0)
  final double totalUsd;

  @JsonKey(name: 'min_process', defaultValue: 10.0)
  final double minProcess;

  @JsonKey(name: 'largest_asset')
  final UAAssetItem? largestAsset;

  @JsonKey(name: 'assets')
  final List<UAAssetItem>? assets;

  List<UAAssetItem> get assetList => assets ?? [];

  const UABalance({
    required this.totalUsd,
    required this.minProcess,
    this.largestAsset,
    this.assets,
  });

  factory UABalance.fromJson(Map<String, dynamic> json) =>
      _$UABalanceFromJson(json);

  Map<String, dynamic> toJson() => _$UABalanceToJson(this);
}

/// /api/ua/balance 的 data 字段内容
@JsonSerializable(explicitToJson: true)
class UABalanceData {
  @JsonKey(name: 'balance')
  final UABalance balance;

  const UABalanceData({required this.balance});

  factory UABalanceData.fromJson(Map<String, dynamic> json) =>
      _$UABalanceDataFromJson(json);

  Map<String, dynamic> toJson() => _$UABalanceDataToJson(this);
}

/// GET /api/ua/balance 完整响应（{success, data: UABalanceData}）
@JsonSerializable(explicitToJson: true)
class UABalanceApiResponse {
  @JsonKey(name: 'data')
  final UABalanceData data;

  const UABalanceApiResponse({required this.data});

  factory UABalanceApiResponse.fromJson(Map<String, dynamic> json) =>
      _$UABalanceApiResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UABalanceApiResponseToJson(this);
}

// ── /api/ua/solana/balance ────────────────────────────────

/// GET /api/ua/solana/balance 响应 data 字段
@JsonSerializable()
class UASolanaBalanceData {
  @JsonKey(name: 'address', defaultValue: '')
  final String address;

  @JsonKey(name: 'usdc_balance', defaultValue: 0.0)
  final double usdcBalance;

  @JsonKey(name: 'usdc_balance_raw', defaultValue: '')
  final String usdcBalanceRaw;

  const UASolanaBalanceData({
    required this.address,
    required this.usdcBalance,
    required this.usdcBalanceRaw,
  });

  factory UASolanaBalanceData.fromJson(Map<String, dynamic> json) =>
      _$UASolanaBalanceDataFromJson(json);

  Map<String, dynamic> toJson() => _$UASolanaBalanceDataToJson(this);
}

/// GET /api/ua/solana/balance 完整响应
@JsonSerializable()
class UASolanaBalanceApiResponse {
  @JsonKey(name: 'data')
  final UASolanaBalanceData data;

  const UASolanaBalanceApiResponse({required this.data});

  factory UASolanaBalanceApiResponse.fromJson(Map<String, dynamic> json) =>
      _$UASolanaBalanceApiResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UASolanaBalanceApiResponseToJson(this);
}

// ── /api/ua/sweep ─────────────────────────────────────────

@JsonSerializable()
class UASweepData {
  @JsonKey(name: 'transfer_amount', defaultValue: 0.0)
  final double transferAmount;

  @JsonKey(name: 'transaction_id', defaultValue: '')
  final String transactionId;

  @JsonKey(name: 'explorer_url', defaultValue: '')
  final String explorerUrl;

  @JsonKey(name: 'target_address', defaultValue: '')
  final String targetAddress;

  @JsonKey(name: 'solana_tx_hash', defaultValue: '')
  final String solanaTxHash;

  const UASweepData({
    required this.transferAmount,
    required this.transactionId,
    required this.explorerUrl,
    required this.targetAddress,
    required this.solanaTxHash,
  });

  factory UASweepData.fromJson(Map<String, dynamic> json) =>
      _$UASweepDataFromJson(json);

  Map<String, dynamic> toJson() => _$UASweepDataToJson(this);
}

/// POST /api/ua/sweep 完整响应（{success, data: UASweepData}）
@JsonSerializable(explicitToJson: true)
class UASweepApiResponse {
  @JsonKey(name: 'data')
  final UASweepData data;

  const UASweepApiResponse({required this.data});

  factory UASweepApiResponse.fromJson(Map<String, dynamic> json) =>
      _$UASweepApiResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UASweepApiResponseToJson(this);
}
