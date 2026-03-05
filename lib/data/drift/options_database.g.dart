// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'options_database.dart';

// ignore_for_file: type=lint
class $OptionsTradingPairsTable extends OptionsTradingPairs
    with TableInfo<$OptionsTradingPairsTable, OptionsTradingPair> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OptionsTradingPairsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _feedIdMeta = const VerificationMeta('feedId');
  @override
  late final GeneratedColumn<String> feedId = GeneratedColumn<String>(
      'feed_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _baseAssetMeta =
      const VerificationMeta('baseAsset');
  @override
  late final GeneratedColumn<String> baseAsset = GeneratedColumn<String>(
      'base_asset', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _pairNameMeta =
      const VerificationMeta('pairName');
  @override
  late final GeneratedColumn<String> pairName = GeneratedColumn<String>(
      'pair_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _baseAssetNameMeta =
      const VerificationMeta('baseAssetName');
  @override
  late final GeneratedColumn<String> baseAssetName = GeneratedColumn<String>(
      'base_asset_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _quoteAssetNameMeta =
      const VerificationMeta('quoteAssetName');
  @override
  late final GeneratedColumn<String> quoteAssetName = GeneratedColumn<String>(
      'quote_asset_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _iconUrlMeta =
      const VerificationMeta('iconUrl');
  @override
  late final GeneratedColumn<String> iconUrl = GeneratedColumn<String>(
      'icon_url', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'));
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<int> timestamp = GeneratedColumn<int>(
      'timestamp', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<OptionsTradingSchedule?, String>
      tradingSchedule = GeneratedColumn<String>(
              'trading_schedule', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<OptionsTradingSchedule?>(
              $OptionsTradingPairsTable.$convertertradingSchedule);
  static const VerificationMeta _pipSizeMeta =
      const VerificationMeta('pipSize');
  @override
  late final GeneratedColumn<int> pipSize = GeneratedColumn<int>(
      'pip_size', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _leverageMinMeta =
      const VerificationMeta('leverageMin');
  @override
  late final GeneratedColumn<int> leverageMin = GeneratedColumn<int>(
      'leverage_min', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _leverageMaxMeta =
      const VerificationMeta('leverageMax');
  @override
  late final GeneratedColumn<int> leverageMax = GeneratedColumn<int>(
      'leverage_max', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _isPinnedMeta =
      const VerificationMeta('isPinned');
  @override
  late final GeneratedColumn<bool> isPinned = GeneratedColumn<bool>(
      'is_pinned', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_pinned" IN (0, 1))'));
  @override
  List<GeneratedColumn> get $columns => [
        feedId,
        baseAsset,
        pairName,
        baseAssetName,
        quoteAssetName,
        iconUrl,
        type,
        isActive,
        timestamp,
        tradingSchedule,
        pipSize,
        leverageMin,
        leverageMax,
        isPinned
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'options_trading_pairs';
  @override
  VerificationContext validateIntegrity(Insertable<OptionsTradingPair> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('feed_id')) {
      context.handle(_feedIdMeta,
          feedId.isAcceptableOrUnknown(data['feed_id']!, _feedIdMeta));
    } else if (isInserting) {
      context.missing(_feedIdMeta);
    }
    if (data.containsKey('base_asset')) {
      context.handle(_baseAssetMeta,
          baseAsset.isAcceptableOrUnknown(data['base_asset']!, _baseAssetMeta));
    } else if (isInserting) {
      context.missing(_baseAssetMeta);
    }
    if (data.containsKey('pair_name')) {
      context.handle(_pairNameMeta,
          pairName.isAcceptableOrUnknown(data['pair_name']!, _pairNameMeta));
    } else if (isInserting) {
      context.missing(_pairNameMeta);
    }
    if (data.containsKey('base_asset_name')) {
      context.handle(
          _baseAssetNameMeta,
          baseAssetName.isAcceptableOrUnknown(
              data['base_asset_name']!, _baseAssetNameMeta));
    } else if (isInserting) {
      context.missing(_baseAssetNameMeta);
    }
    if (data.containsKey('quote_asset_name')) {
      context.handle(
          _quoteAssetNameMeta,
          quoteAssetName.isAcceptableOrUnknown(
              data['quote_asset_name']!, _quoteAssetNameMeta));
    } else if (isInserting) {
      context.missing(_quoteAssetNameMeta);
    }
    if (data.containsKey('icon_url')) {
      context.handle(_iconUrlMeta,
          iconUrl.isAcceptableOrUnknown(data['icon_url']!, _iconUrlMeta));
    } else if (isInserting) {
      context.missing(_iconUrlMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    } else if (isInserting) {
      context.missing(_isActiveMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('pip_size')) {
      context.handle(_pipSizeMeta,
          pipSize.isAcceptableOrUnknown(data['pip_size']!, _pipSizeMeta));
    } else if (isInserting) {
      context.missing(_pipSizeMeta);
    }
    if (data.containsKey('leverage_min')) {
      context.handle(
          _leverageMinMeta,
          leverageMin.isAcceptableOrUnknown(
              data['leverage_min']!, _leverageMinMeta));
    } else if (isInserting) {
      context.missing(_leverageMinMeta);
    }
    if (data.containsKey('leverage_max')) {
      context.handle(
          _leverageMaxMeta,
          leverageMax.isAcceptableOrUnknown(
              data['leverage_max']!, _leverageMaxMeta));
    } else if (isInserting) {
      context.missing(_leverageMaxMeta);
    }
    if (data.containsKey('is_pinned')) {
      context.handle(_isPinnedMeta,
          isPinned.isAcceptableOrUnknown(data['is_pinned']!, _isPinnedMeta));
    } else if (isInserting) {
      context.missing(_isPinnedMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {feedId};
  @override
  OptionsTradingPair map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OptionsTradingPair(
      feedId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}feed_id'])!,
      baseAsset: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}base_asset'])!,
      pairName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}pair_name'])!,
      baseAssetName: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}base_asset_name'])!,
      quoteAssetName: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}quote_asset_name'])!,
      iconUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}icon_url'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}timestamp'])!,
      tradingSchedule: $OptionsTradingPairsTable.$convertertradingSchedule
          .fromSql(attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}trading_schedule'])),
      pipSize: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}pip_size'])!,
      leverageMin: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}leverage_min'])!,
      leverageMax: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}leverage_max'])!,
      isPinned: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_pinned'])!,
    );
  }

  @override
  $OptionsTradingPairsTable createAlias(String alias) {
    return $OptionsTradingPairsTable(attachedDatabase, alias);
  }

  static TypeConverter<OptionsTradingSchedule?, String?>
      $convertertradingSchedule = TradingScheduleConverter();
}

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

  /// 是否是是置顶
  final bool isPinned;
  const OptionsTradingPair(
      {required this.feedId,
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
      required this.isPinned});
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

  OptionsTradingPair copyWith(
          {String? feedId,
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
          bool? isPinned}) =>
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
      feedId: data.feedId.present ? data.feedId.value : this.feedId,
      baseAsset: data.baseAsset.present ? data.baseAsset.value : this.baseAsset,
      pairName: data.pairName.present ? data.pairName.value : this.pairName,
      baseAssetName: data.baseAssetName.present
          ? data.baseAssetName.value
          : this.baseAssetName,
      quoteAssetName: data.quoteAssetName.present
          ? data.quoteAssetName.value
          : this.quoteAssetName,
      iconUrl: data.iconUrl.present ? data.iconUrl.value : this.iconUrl,
      type: data.type.present ? data.type.value : this.type,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      tradingSchedule: data.tradingSchedule.present
          ? data.tradingSchedule.value
          : this.tradingSchedule,
      pipSize: data.pipSize.present ? data.pipSize.value : this.pipSize,
      leverageMin:
          data.leverageMin.present ? data.leverageMin.value : this.leverageMin,
      leverageMax:
          data.leverageMax.present ? data.leverageMax.value : this.leverageMax,
      isPinned: data.isPinned.present ? data.isPinned.value : this.isPinned,
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
      timestamp,
      tradingSchedule,
      pipSize,
      leverageMin,
      leverageMax,
      isPinned);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OptionsTradingPair &&
          other.feedId == this.feedId &&
          other.baseAsset == this.baseAsset &&
          other.pairName == this.pairName &&
          other.baseAssetName == this.baseAssetName &&
          other.quoteAssetName == this.quoteAssetName &&
          other.iconUrl == this.iconUrl &&
          other.type == this.type &&
          other.isActive == this.isActive &&
          other.timestamp == this.timestamp &&
          other.tradingSchedule == this.tradingSchedule &&
          other.pipSize == this.pipSize &&
          other.leverageMin == this.leverageMin &&
          other.leverageMax == this.leverageMax &&
          other.isPinned == this.isPinned);
}

class OptionsTradingPairsCompanion extends UpdateCompanion<OptionsTradingPair> {
  final Value<String> feedId;
  final Value<String> baseAsset;
  final Value<String> pairName;
  final Value<String> baseAssetName;
  final Value<String> quoteAssetName;
  final Value<String> iconUrl;
  final Value<String> type;
  final Value<bool> isActive;
  final Value<int> timestamp;
  final Value<OptionsTradingSchedule?> tradingSchedule;
  final Value<int> pipSize;
  final Value<int> leverageMin;
  final Value<int> leverageMax;
  final Value<bool> isPinned;
  final Value<int> rowid;
  const OptionsTradingPairsCompanion({
    this.feedId = const Value.absent(),
    this.baseAsset = const Value.absent(),
    this.pairName = const Value.absent(),
    this.baseAssetName = const Value.absent(),
    this.quoteAssetName = const Value.absent(),
    this.iconUrl = const Value.absent(),
    this.type = const Value.absent(),
    this.isActive = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.tradingSchedule = const Value.absent(),
    this.pipSize = const Value.absent(),
    this.leverageMin = const Value.absent(),
    this.leverageMax = const Value.absent(),
    this.isPinned = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OptionsTradingPairsCompanion.insert({
    required String feedId,
    required String baseAsset,
    required String pairName,
    required String baseAssetName,
    required String quoteAssetName,
    required String iconUrl,
    required String type,
    required bool isActive,
    required int timestamp,
    this.tradingSchedule = const Value.absent(),
    required int pipSize,
    required int leverageMin,
    required int leverageMax,
    required bool isPinned,
    this.rowid = const Value.absent(),
  })  : feedId = Value(feedId),
        baseAsset = Value(baseAsset),
        pairName = Value(pairName),
        baseAssetName = Value(baseAssetName),
        quoteAssetName = Value(quoteAssetName),
        iconUrl = Value(iconUrl),
        type = Value(type),
        isActive = Value(isActive),
        timestamp = Value(timestamp),
        pipSize = Value(pipSize),
        leverageMin = Value(leverageMin),
        leverageMax = Value(leverageMax),
        isPinned = Value(isPinned);
  static Insertable<OptionsTradingPair> custom({
    Expression<String>? feedId,
    Expression<String>? baseAsset,
    Expression<String>? pairName,
    Expression<String>? baseAssetName,
    Expression<String>? quoteAssetName,
    Expression<String>? iconUrl,
    Expression<String>? type,
    Expression<bool>? isActive,
    Expression<int>? timestamp,
    Expression<String>? tradingSchedule,
    Expression<int>? pipSize,
    Expression<int>? leverageMin,
    Expression<int>? leverageMax,
    Expression<bool>? isPinned,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (feedId != null) 'feed_id': feedId,
      if (baseAsset != null) 'base_asset': baseAsset,
      if (pairName != null) 'pair_name': pairName,
      if (baseAssetName != null) 'base_asset_name': baseAssetName,
      if (quoteAssetName != null) 'quote_asset_name': quoteAssetName,
      if (iconUrl != null) 'icon_url': iconUrl,
      if (type != null) 'type': type,
      if (isActive != null) 'is_active': isActive,
      if (timestamp != null) 'timestamp': timestamp,
      if (tradingSchedule != null) 'trading_schedule': tradingSchedule,
      if (pipSize != null) 'pip_size': pipSize,
      if (leverageMin != null) 'leverage_min': leverageMin,
      if (leverageMax != null) 'leverage_max': leverageMax,
      if (isPinned != null) 'is_pinned': isPinned,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OptionsTradingPairsCompanion copyWith(
      {Value<String>? feedId,
      Value<String>? baseAsset,
      Value<String>? pairName,
      Value<String>? baseAssetName,
      Value<String>? quoteAssetName,
      Value<String>? iconUrl,
      Value<String>? type,
      Value<bool>? isActive,
      Value<int>? timestamp,
      Value<OptionsTradingSchedule?>? tradingSchedule,
      Value<int>? pipSize,
      Value<int>? leverageMin,
      Value<int>? leverageMax,
      Value<bool>? isPinned,
      Value<int>? rowid}) {
    return OptionsTradingPairsCompanion(
      feedId: feedId ?? this.feedId,
      baseAsset: baseAsset ?? this.baseAsset,
      pairName: pairName ?? this.pairName,
      baseAssetName: baseAssetName ?? this.baseAssetName,
      quoteAssetName: quoteAssetName ?? this.quoteAssetName,
      iconUrl: iconUrl ?? this.iconUrl,
      type: type ?? this.type,
      isActive: isActive ?? this.isActive,
      timestamp: timestamp ?? this.timestamp,
      tradingSchedule: tradingSchedule ?? this.tradingSchedule,
      pipSize: pipSize ?? this.pipSize,
      leverageMin: leverageMin ?? this.leverageMin,
      leverageMax: leverageMax ?? this.leverageMax,
      isPinned: isPinned ?? this.isPinned,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (feedId.present) {
      map['feed_id'] = Variable<String>(feedId.value);
    }
    if (baseAsset.present) {
      map['base_asset'] = Variable<String>(baseAsset.value);
    }
    if (pairName.present) {
      map['pair_name'] = Variable<String>(pairName.value);
    }
    if (baseAssetName.present) {
      map['base_asset_name'] = Variable<String>(baseAssetName.value);
    }
    if (quoteAssetName.present) {
      map['quote_asset_name'] = Variable<String>(quoteAssetName.value);
    }
    if (iconUrl.present) {
      map['icon_url'] = Variable<String>(iconUrl.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<int>(timestamp.value);
    }
    if (tradingSchedule.present) {
      map['trading_schedule'] = Variable<String>($OptionsTradingPairsTable
          .$convertertradingSchedule
          .toSql(tradingSchedule.value));
    }
    if (pipSize.present) {
      map['pip_size'] = Variable<int>(pipSize.value);
    }
    if (leverageMin.present) {
      map['leverage_min'] = Variable<int>(leverageMin.value);
    }
    if (leverageMax.present) {
      map['leverage_max'] = Variable<int>(leverageMax.value);
    }
    if (isPinned.present) {
      map['is_pinned'] = Variable<bool>(isPinned.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OptionsTradingPairsCompanion(')
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
          ..write('isPinned: $isPinned, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$OptionsDatabase extends GeneratedDatabase {
  _$OptionsDatabase(QueryExecutor e) : super(e);
  $OptionsDatabaseManager get managers => $OptionsDatabaseManager(this);
  late final $OptionsTradingPairsTable optionsTradingPairs =
      $OptionsTradingPairsTable(this);
  late final OptionsTradingPairDao optionsTradingPairDao =
      OptionsTradingPairDao(this as OptionsDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [optionsTradingPairs];
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$OptionsTradingPairsTableCreateCompanionBuilder
    = OptionsTradingPairsCompanion Function({
  required String feedId,
  required String baseAsset,
  required String pairName,
  required String baseAssetName,
  required String quoteAssetName,
  required String iconUrl,
  required String type,
  required bool isActive,
  required int timestamp,
  Value<OptionsTradingSchedule?> tradingSchedule,
  required int pipSize,
  required int leverageMin,
  required int leverageMax,
  required bool isPinned,
  Value<int> rowid,
});
typedef $$OptionsTradingPairsTableUpdateCompanionBuilder
    = OptionsTradingPairsCompanion Function({
  Value<String> feedId,
  Value<String> baseAsset,
  Value<String> pairName,
  Value<String> baseAssetName,
  Value<String> quoteAssetName,
  Value<String> iconUrl,
  Value<String> type,
  Value<bool> isActive,
  Value<int> timestamp,
  Value<OptionsTradingSchedule?> tradingSchedule,
  Value<int> pipSize,
  Value<int> leverageMin,
  Value<int> leverageMax,
  Value<bool> isPinned,
  Value<int> rowid,
});

class $$OptionsTradingPairsTableFilterComposer
    extends Composer<_$OptionsDatabase, $OptionsTradingPairsTable> {
  $$OptionsTradingPairsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get feedId => $composableBuilder(
      column: $table.feedId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get baseAsset => $composableBuilder(
      column: $table.baseAsset, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get pairName => $composableBuilder(
      column: $table.pairName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get baseAssetName => $composableBuilder(
      column: $table.baseAssetName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get quoteAssetName => $composableBuilder(
      column: $table.quoteAssetName,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get iconUrl => $composableBuilder(
      column: $table.iconUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<OptionsTradingSchedule?,
          OptionsTradingSchedule, String>
      get tradingSchedule => $composableBuilder(
          column: $table.tradingSchedule,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<int> get pipSize => $composableBuilder(
      column: $table.pipSize, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get leverageMin => $composableBuilder(
      column: $table.leverageMin, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get leverageMax => $composableBuilder(
      column: $table.leverageMax, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isPinned => $composableBuilder(
      column: $table.isPinned, builder: (column) => ColumnFilters(column));
}

class $$OptionsTradingPairsTableOrderingComposer
    extends Composer<_$OptionsDatabase, $OptionsTradingPairsTable> {
  $$OptionsTradingPairsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get feedId => $composableBuilder(
      column: $table.feedId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get baseAsset => $composableBuilder(
      column: $table.baseAsset, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get pairName => $composableBuilder(
      column: $table.pairName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get baseAssetName => $composableBuilder(
      column: $table.baseAssetName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get quoteAssetName => $composableBuilder(
      column: $table.quoteAssetName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get iconUrl => $composableBuilder(
      column: $table.iconUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tradingSchedule => $composableBuilder(
      column: $table.tradingSchedule,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get pipSize => $composableBuilder(
      column: $table.pipSize, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get leverageMin => $composableBuilder(
      column: $table.leverageMin, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get leverageMax => $composableBuilder(
      column: $table.leverageMax, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isPinned => $composableBuilder(
      column: $table.isPinned, builder: (column) => ColumnOrderings(column));
}

class $$OptionsTradingPairsTableAnnotationComposer
    extends Composer<_$OptionsDatabase, $OptionsTradingPairsTable> {
  $$OptionsTradingPairsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get feedId =>
      $composableBuilder(column: $table.feedId, builder: (column) => column);

  GeneratedColumn<String> get baseAsset =>
      $composableBuilder(column: $table.baseAsset, builder: (column) => column);

  GeneratedColumn<String> get pairName =>
      $composableBuilder(column: $table.pairName, builder: (column) => column);

  GeneratedColumn<String> get baseAssetName => $composableBuilder(
      column: $table.baseAssetName, builder: (column) => column);

  GeneratedColumn<String> get quoteAssetName => $composableBuilder(
      column: $table.quoteAssetName, builder: (column) => column);

  GeneratedColumn<String> get iconUrl =>
      $composableBuilder(column: $table.iconUrl, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<int> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumnWithTypeConverter<OptionsTradingSchedule?, String>
      get tradingSchedule => $composableBuilder(
          column: $table.tradingSchedule, builder: (column) => column);

  GeneratedColumn<int> get pipSize =>
      $composableBuilder(column: $table.pipSize, builder: (column) => column);

  GeneratedColumn<int> get leverageMin => $composableBuilder(
      column: $table.leverageMin, builder: (column) => column);

  GeneratedColumn<int> get leverageMax => $composableBuilder(
      column: $table.leverageMax, builder: (column) => column);

  GeneratedColumn<bool> get isPinned =>
      $composableBuilder(column: $table.isPinned, builder: (column) => column);
}

class $$OptionsTradingPairsTableTableManager extends RootTableManager<
    _$OptionsDatabase,
    $OptionsTradingPairsTable,
    OptionsTradingPair,
    $$OptionsTradingPairsTableFilterComposer,
    $$OptionsTradingPairsTableOrderingComposer,
    $$OptionsTradingPairsTableAnnotationComposer,
    $$OptionsTradingPairsTableCreateCompanionBuilder,
    $$OptionsTradingPairsTableUpdateCompanionBuilder,
    (
      OptionsTradingPair,
      BaseReferences<_$OptionsDatabase, $OptionsTradingPairsTable,
          OptionsTradingPair>
    ),
    OptionsTradingPair,
    PrefetchHooks Function()> {
  $$OptionsTradingPairsTableTableManager(
      _$OptionsDatabase db, $OptionsTradingPairsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OptionsTradingPairsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OptionsTradingPairsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OptionsTradingPairsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> feedId = const Value.absent(),
            Value<String> baseAsset = const Value.absent(),
            Value<String> pairName = const Value.absent(),
            Value<String> baseAssetName = const Value.absent(),
            Value<String> quoteAssetName = const Value.absent(),
            Value<String> iconUrl = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<int> timestamp = const Value.absent(),
            Value<OptionsTradingSchedule?> tradingSchedule =
                const Value.absent(),
            Value<int> pipSize = const Value.absent(),
            Value<int> leverageMin = const Value.absent(),
            Value<int> leverageMax = const Value.absent(),
            Value<bool> isPinned = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              OptionsTradingPairsCompanion(
            feedId: feedId,
            baseAsset: baseAsset,
            pairName: pairName,
            baseAssetName: baseAssetName,
            quoteAssetName: quoteAssetName,
            iconUrl: iconUrl,
            type: type,
            isActive: isActive,
            timestamp: timestamp,
            tradingSchedule: tradingSchedule,
            pipSize: pipSize,
            leverageMin: leverageMin,
            leverageMax: leverageMax,
            isPinned: isPinned,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String feedId,
            required String baseAsset,
            required String pairName,
            required String baseAssetName,
            required String quoteAssetName,
            required String iconUrl,
            required String type,
            required bool isActive,
            required int timestamp,
            Value<OptionsTradingSchedule?> tradingSchedule =
                const Value.absent(),
            required int pipSize,
            required int leverageMin,
            required int leverageMax,
            required bool isPinned,
            Value<int> rowid = const Value.absent(),
          }) =>
              OptionsTradingPairsCompanion.insert(
            feedId: feedId,
            baseAsset: baseAsset,
            pairName: pairName,
            baseAssetName: baseAssetName,
            quoteAssetName: quoteAssetName,
            iconUrl: iconUrl,
            type: type,
            isActive: isActive,
            timestamp: timestamp,
            tradingSchedule: tradingSchedule,
            pipSize: pipSize,
            leverageMin: leverageMin,
            leverageMax: leverageMax,
            isPinned: isPinned,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$OptionsTradingPairsTableProcessedTableManager = ProcessedTableManager<
    _$OptionsDatabase,
    $OptionsTradingPairsTable,
    OptionsTradingPair,
    $$OptionsTradingPairsTableFilterComposer,
    $$OptionsTradingPairsTableOrderingComposer,
    $$OptionsTradingPairsTableAnnotationComposer,
    $$OptionsTradingPairsTableCreateCompanionBuilder,
    $$OptionsTradingPairsTableUpdateCompanionBuilder,
    (
      OptionsTradingPair,
      BaseReferences<_$OptionsDatabase, $OptionsTradingPairsTable,
          OptionsTradingPair>
    ),
    OptionsTradingPair,
    PrefetchHooks Function()>;

class $OptionsDatabaseManager {
  final _$OptionsDatabase _db;
  $OptionsDatabaseManager(this._db);
  $$OptionsTradingPairsTableTableManager get optionsTradingPairs =>
      $$OptionsTradingPairsTableTableManager(_db, _db.optionsTradingPairs);
}
