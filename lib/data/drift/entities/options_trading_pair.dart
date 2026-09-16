import 'package:drift/drift.dart';
import 'package:finality/data/drift/entities/options_trading_schedule.dart';
import 'package:finality/data/drift/options_database.dart';

class OptionsTradingPair extends DataClass
    implements Insertable<OptionsTradingPair> {
  /// 交易对ID
  final String feedId;

  /// 基础资产符号
  final String baseAsset;

  /// 交易对名称，如：BTC/USD
  final String pairName;

  /// 基础资产名称，如：BTC
  final String baseAssetName;

  /// 报价资产名称，如：USD
  final String quoteAssetName;

  /// 图标URL
  final String iconUrl;

  /// 类型，如：Crypto
  final String type;

  /// 是否激活
  final bool isActive;

  /// 时间戳
  final int timestamp;

  /// 交易时间表
  final OptionsTradingSchedule? tradingSchedule;

  /// 保留几位小数
  final int pipSize;

  /// 最小杠杆倍数
  final int leverageMin;

  /// 最大杠杆倍数
  final int leverageMax;

  /// 是否置顶
  final bool isPinned;

  const OptionsTradingPair({
    required this.feedId,
    required this.baseAsset,
    required this.pairName,
    required this.baseAssetName,
    required this.quoteAssetName,
    required this.iconUrl,
    required this.type,
    required this.isActive,
    required this.timestamp,
    this.tradingSchedule,
    required this.pipSize,
    required this.leverageMin,
    required this.leverageMax,
    required this.isPinned,
  });

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['feed_id'] = Variable<String>(feedId);
    map['base_asset'] = Variable<String>(baseAsset);
    map['pair_name'] = Variable<String>(pairName);
    map['base_asset_name'] = Variable<String>(baseAssetName);
    map['quote_asset_name'] = Variable<String>(quoteAssetName);
    map['icon_url'] = Variable<String>(iconUrl);
    map['type'] = Variable<String>(type);
    map['is_active'] = Variable<bool>(isActive);
    map['timestamp'] = Variable<int>(timestamp);
    if (!nullToAbsent || tradingSchedule != null) {
      map['trading_schedule'] = Variable<String>($OptionsTradingPairsTable
          .$convertertradingSchedule
          .toSql(tradingSchedule));
    }
    map['pip_size'] = Variable<int>(pipSize);
    map['leverage_min'] = Variable<int>(leverageMin);
    map['leverage_max'] = Variable<int>(leverageMax);
    map['is_pinned'] = Variable<bool>(isPinned);
    return map;
  }

  OptionsTradingPairsCompanion toCompanion(bool nullToAbsent) {
    return OptionsTradingPairsCompanion(
      feedId: Value(feedId),
      baseAsset: Value(baseAsset),
      pairName: Value(pairName),
      baseAssetName: Value(baseAssetName),
      quoteAssetName: Value(quoteAssetName),
      iconUrl: Value(iconUrl),
      type: Value(type),
      isActive: Value(isActive),
      timestamp: Value(timestamp),
      tradingSchedule: tradingSchedule == null && nullToAbsent
          ? const Value.absent()
          : Value(tradingSchedule),
      pipSize: Value(pipSize),
      leverageMin: Value(leverageMin),
      leverageMax: Value(leverageMax),
      isPinned: Value(isPinned),
    );
  }

  factory OptionsTradingPair.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OptionsTradingPair(
      feedId: serializer.fromJson<String>(json['feedId']),
      baseAsset: serializer.fromJson<String>(json['baseAsset']),
      pairName: serializer.fromJson<String>(json['pairName']),
      baseAssetName: serializer.fromJson<String>(json['baseAssetName']),
      quoteAssetName: serializer.fromJson<String>(json['quoteAssetName']),
      iconUrl: serializer.fromJson<String>(json['iconUrl']),
      type: serializer.fromJson<String>(json['type']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      timestamp: serializer.fromJson<int>(json['timestamp']),
      tradingSchedule:
          serializer.fromJson<OptionsTradingSchedule?>(json['tradingSchedule']),
      pipSize: serializer.fromJson<int>(json['pipSize']),
      leverageMin: serializer.fromJson<int>(json['leverageMin']),
      leverageMax: serializer.fromJson<int>(json['leverageMax']),
      isPinned: serializer.fromJson<bool>(json['isPinned']),
    );
  }

  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'feedId': serializer.toJson<String>(feedId),
      'baseAsset': serializer.toJson<String>(baseAsset),
      'pairName': serializer.toJson<String>(pairName),
      'baseAssetName': serializer.toJson<String>(baseAssetName),
      'quoteAssetName': serializer.toJson<String>(quoteAssetName),
      'iconUrl': serializer.toJson<String>(iconUrl),
      'type': serializer.toJson<String>(type),
      'isActive': serializer.toJson<bool>(isActive),
      'timestamp': serializer.toJson<int>(timestamp),
      'tradingSchedule':
          serializer.toJson<OptionsTradingSchedule?>(tradingSchedule),
      'pipSize': serializer.toJson<int>(pipSize),
      'leverageMin': serializer.toJson<int>(leverageMin),
      'leverageMax': serializer.toJson<int>(leverageMax),
      'isPinned': serializer.toJson<bool>(isPinned),
    };
  }

  OptionsTradingPair copyWith({
    String? feedId,
    String? baseAsset,
    String? pairName,
    String? baseAssetName,
    String? quoteAssetName,
    String? iconUrl,
    String? type,
    bool? isActive,
    int? timestamp,
    Value<OptionsTradingSchedule?> tradingSchedule = const Value.absent(),
    int? pipSize,
    int? leverageMin,
    int? leverageMax,
    bool? isPinned,
  }) =>
      OptionsTradingPair(
        feedId: feedId ?? this.feedId,
        baseAsset: baseAsset ?? this.baseAsset,
        pairName: pairName ?? this.pairName,
        baseAssetName: baseAssetName ?? this.baseAssetName,
        quoteAssetName: quoteAssetName ?? this.quoteAssetName,
        iconUrl: iconUrl ?? this.iconUrl,
        type: type ?? this.type,
        isActive: isActive ?? this.isActive,
        timestamp: timestamp ?? this.timestamp,
        tradingSchedule: tradingSchedule.present
            ? tradingSchedule.value
            : this.tradingSchedule,
        pipSize: pipSize ?? this.pipSize,
        leverageMin: leverageMin ?? this.leverageMin,
        leverageMax: leverageMax ?? this.leverageMax,
        isPinned: isPinned ?? this.isPinned,
      );

  OptionsTradingPair copyWithCompanion(OptionsTradingPairsCompanion data) {
    return OptionsTradingPair(
      feedId: data.feedId.present ? data.feedId.value : feedId,
      baseAsset: data.baseAsset.present ? data.baseAsset.value : baseAsset,
      pairName: data.pairName.present ? data.pairName.value : pairName,
      baseAssetName:
          data.baseAssetName.present ? data.baseAssetName.value : baseAssetName,
      quoteAssetName: data.quoteAssetName.present
          ? data.quoteAssetName.value
          : quoteAssetName,
      iconUrl: data.iconUrl.present ? data.iconUrl.value : iconUrl,
      type: data.type.present ? data.type.value : type,
      isActive: data.isActive.present ? data.isActive.value : isActive,
      timestamp: data.timestamp.present ? data.timestamp.value : timestamp,
      tradingSchedule: data.tradingSchedule.present
          ? data.tradingSchedule.value
          : tradingSchedule,
      pipSize: data.pipSize.present ? data.pipSize.value : pipSize,
      leverageMin:
          data.leverageMin.present ? data.leverageMin.value : leverageMin,
      leverageMax:
          data.leverageMax.present ? data.leverageMax.value : leverageMax,
      isPinned: data.isPinned.present ? data.isPinned.value : isPinned,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OptionsTradingPair(')
          ..write('feedId: $feedId, ')
          ..write('baseAsset: $baseAsset, ')
          ..write('pairName: $pairName, ')
          ..write('baseAssetName: $baseAssetName, ')
          ..write('quoteAssetName: $quoteAssetName, ')
          ..write('iconUrl: $iconUrl, ')
          ..write('type: $type, ')
          ..write('isActive: $isActive, ')
          ..write('timestamp: $timestamp, ')
          ..write('tradingSchedule: $tradingSchedule, ')
          ..write('pipSize: $pipSize, ')
          ..write('leverageMin: $leverageMin, ')
          ..write('leverageMax: $leverageMax, ')
          ..write('isPinned: $isPinned')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      feedId,
      baseAsset,
      pairName,
      baseAssetName,
      quoteAssetName,
      iconUrl,
      type,
      isActive,
      tradingSchedule,
      pipSize,
      leverageMin,
      leverageMax,
      isPinned);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OptionsTradingPair &&
          other.feedId == feedId &&
          other.baseAsset == baseAsset &&
          other.pairName == pairName &&
          other.baseAssetName == baseAssetName &&
          other.quoteAssetName == quoteAssetName &&
          other.iconUrl == iconUrl &&
          other.type == type &&
          other.isActive == isActive &&
          other.tradingSchedule == tradingSchedule &&
          other.pipSize == pipSize &&
          other.leverageMin == leverageMin &&
          other.leverageMax == leverageMax &&
          other.isPinned == isPinned);
}
