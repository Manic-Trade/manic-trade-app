// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_preferences_database.dart';

// ignore_for_file: type=lint
class $RecentSentAddressesTable extends RecentSentAddresses
    with TableInfo<$RecentSentAddressesTable, RecentSentAddress> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecentSentAddressesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _networkCodeMeta =
      const VerificationMeta('networkCode');
  @override
  late final GeneratedColumn<String> networkCode = GeneratedColumn<String>(
      'network_code', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _addressMeta =
      const VerificationMeta('address');
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
      'address', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _lastUsedAtMeta =
      const VerificationMeta('lastUsedAt');
  @override
  late final GeneratedColumn<DateTime> lastUsedAt = GeneratedColumn<DateTime>(
      'last_used_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [networkCode, address, lastUsedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recent_sent_addresses';
  @override
  VerificationContext validateIntegrity(Insertable<RecentSentAddress> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('network_code')) {
      context.handle(
          _networkCodeMeta,
          networkCode.isAcceptableOrUnknown(
              data['network_code']!, _networkCodeMeta));
    } else if (isInserting) {
      context.missing(_networkCodeMeta);
    }
    if (data.containsKey('address')) {
      context.handle(_addressMeta,
          address.isAcceptableOrUnknown(data['address']!, _addressMeta));
    } else if (isInserting) {
      context.missing(_addressMeta);
    }
    if (data.containsKey('last_used_at')) {
      context.handle(
          _lastUsedAtMeta,
          lastUsedAt.isAcceptableOrUnknown(
              data['last_used_at']!, _lastUsedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {networkCode, address};
  @override
  RecentSentAddress map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecentSentAddress(
      networkCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}network_code'])!,
      address: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}address'])!,
      lastUsedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_used_at'])!,
    );
  }

  @override
  $RecentSentAddressesTable createAlias(String alias) {
    return $RecentSentAddressesTable(attachedDatabase, alias);
  }
}

class RecentSentAddress extends DataClass
    implements Insertable<RecentSentAddress> {
  final String networkCode;
  final String address;
  final DateTime lastUsedAt;
  const RecentSentAddress(
      {required this.networkCode,
      required this.address,
      required this.lastUsedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['network_code'] = Variable<String>(networkCode);
    map['address'] = Variable<String>(address);
    map['last_used_at'] = Variable<DateTime>(lastUsedAt);
    return map;
  }

  RecentSentAddressesCompanion toCompanion(bool nullToAbsent) {
    return RecentSentAddressesCompanion(
      networkCode: Value(networkCode),
      address: Value(address),
      lastUsedAt: Value(lastUsedAt),
    );
  }

  factory RecentSentAddress.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecentSentAddress(
      networkCode: serializer.fromJson<String>(json['networkCode']),
      address: serializer.fromJson<String>(json['address']),
      lastUsedAt: serializer.fromJson<DateTime>(json['lastUsedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'networkCode': serializer.toJson<String>(networkCode),
      'address': serializer.toJson<String>(address),
      'lastUsedAt': serializer.toJson<DateTime>(lastUsedAt),
    };
  }

  RecentSentAddress copyWith(
          {String? networkCode, String? address, DateTime? lastUsedAt}) =>
      RecentSentAddress(
        networkCode: networkCode ?? this.networkCode,
        address: address ?? this.address,
        lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      );
  RecentSentAddress copyWithCompanion(RecentSentAddressesCompanion data) {
    return RecentSentAddress(
      networkCode:
          data.networkCode.present ? data.networkCode.value : this.networkCode,
      address: data.address.present ? data.address.value : this.address,
      lastUsedAt:
          data.lastUsedAt.present ? data.lastUsedAt.value : this.lastUsedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecentSentAddress(')
          ..write('networkCode: $networkCode, ')
          ..write('address: $address, ')
          ..write('lastUsedAt: $lastUsedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(networkCode, address, lastUsedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecentSentAddress &&
          other.networkCode == this.networkCode &&
          other.address == this.address &&
          other.lastUsedAt == this.lastUsedAt);
}

class RecentSentAddressesCompanion extends UpdateCompanion<RecentSentAddress> {
  final Value<String> networkCode;
  final Value<String> address;
  final Value<DateTime> lastUsedAt;
  final Value<int> rowid;
  const RecentSentAddressesCompanion({
    this.networkCode = const Value.absent(),
    this.address = const Value.absent(),
    this.lastUsedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecentSentAddressesCompanion.insert({
    required String networkCode,
    required String address,
    this.lastUsedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : networkCode = Value(networkCode),
        address = Value(address);
  static Insertable<RecentSentAddress> custom({
    Expression<String>? networkCode,
    Expression<String>? address,
    Expression<DateTime>? lastUsedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (networkCode != null) 'network_code': networkCode,
      if (address != null) 'address': address,
      if (lastUsedAt != null) 'last_used_at': lastUsedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecentSentAddressesCompanion copyWith(
      {Value<String>? networkCode,
      Value<String>? address,
      Value<DateTime>? lastUsedAt,
      Value<int>? rowid}) {
    return RecentSentAddressesCompanion(
      networkCode: networkCode ?? this.networkCode,
      address: address ?? this.address,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (networkCode.present) {
      map['network_code'] = Variable<String>(networkCode.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (lastUsedAt.present) {
      map['last_used_at'] = Variable<DateTime>(lastUsedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecentSentAddressesCompanion(')
          ..write('networkCode: $networkCode, ')
          ..write('address: $address, ')
          ..write('lastUsedAt: $lastUsedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SavedAddressesTable extends SavedAddresses
    with TableInfo<$SavedAddressesTable, SavedAddress> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SavedAddressesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _networkCodeMeta =
      const VerificationMeta('networkCode');
  @override
  late final GeneratedColumn<String> networkCode = GeneratedColumn<String>(
      'network_code', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _addressMeta =
      const VerificationMeta('address');
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
      'address', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
      'label', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [networkCode, address, label, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'saved_addresses';
  @override
  VerificationContext validateIntegrity(Insertable<SavedAddress> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('network_code')) {
      context.handle(
          _networkCodeMeta,
          networkCode.isAcceptableOrUnknown(
              data['network_code']!, _networkCodeMeta));
    } else if (isInserting) {
      context.missing(_networkCodeMeta);
    }
    if (data.containsKey('address')) {
      context.handle(_addressMeta,
          address.isAcceptableOrUnknown(data['address']!, _addressMeta));
    } else if (isInserting) {
      context.missing(_addressMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
          _labelMeta, label.isAcceptableOrUnknown(data['label']!, _labelMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {networkCode, address};
  @override
  SavedAddress map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SavedAddress(
      networkCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}network_code'])!,
      address: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}address'])!,
      label: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}label']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $SavedAddressesTable createAlias(String alias) {
    return $SavedAddressesTable(attachedDatabase, alias);
  }
}

class SavedAddress extends DataClass implements Insertable<SavedAddress> {
  final String networkCode;
  final String address;
  final String? label;
  final DateTime createdAt;
  final DateTime updatedAt;
  const SavedAddress(
      {required this.networkCode,
      required this.address,
      this.label,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['network_code'] = Variable<String>(networkCode);
    map['address'] = Variable<String>(address);
    if (!nullToAbsent || label != null) {
      map['label'] = Variable<String>(label);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SavedAddressesCompanion toCompanion(bool nullToAbsent) {
    return SavedAddressesCompanion(
      networkCode: Value(networkCode),
      address: Value(address),
      label:
          label == null && nullToAbsent ? const Value.absent() : Value(label),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory SavedAddress.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SavedAddress(
      networkCode: serializer.fromJson<String>(json['networkCode']),
      address: serializer.fromJson<String>(json['address']),
      label: serializer.fromJson<String?>(json['label']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'networkCode': serializer.toJson<String>(networkCode),
      'address': serializer.toJson<String>(address),
      'label': serializer.toJson<String?>(label),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SavedAddress copyWith(
          {String? networkCode,
          String? address,
          Value<String?> label = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      SavedAddress(
        networkCode: networkCode ?? this.networkCode,
        address: address ?? this.address,
        label: label.present ? label.value : this.label,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  SavedAddress copyWithCompanion(SavedAddressesCompanion data) {
    return SavedAddress(
      networkCode:
          data.networkCode.present ? data.networkCode.value : this.networkCode,
      address: data.address.present ? data.address.value : this.address,
      label: data.label.present ? data.label.value : this.label,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SavedAddress(')
          ..write('networkCode: $networkCode, ')
          ..write('address: $address, ')
          ..write('label: $label, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(networkCode, address, label, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SavedAddress &&
          other.networkCode == this.networkCode &&
          other.address == this.address &&
          other.label == this.label &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SavedAddressesCompanion extends UpdateCompanion<SavedAddress> {
  final Value<String> networkCode;
  final Value<String> address;
  final Value<String?> label;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SavedAddressesCompanion({
    this.networkCode = const Value.absent(),
    this.address = const Value.absent(),
    this.label = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SavedAddressesCompanion.insert({
    required String networkCode,
    required String address,
    this.label = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : networkCode = Value(networkCode),
        address = Value(address);
  static Insertable<SavedAddress> custom({
    Expression<String>? networkCode,
    Expression<String>? address,
    Expression<String>? label,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (networkCode != null) 'network_code': networkCode,
      if (address != null) 'address': address,
      if (label != null) 'label': label,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SavedAddressesCompanion copyWith(
      {Value<String>? networkCode,
      Value<String>? address,
      Value<String?>? label,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return SavedAddressesCompanion(
      networkCode: networkCode ?? this.networkCode,
      address: address ?? this.address,
      label: label ?? this.label,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (networkCode.present) {
      map['network_code'] = Variable<String>(networkCode.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SavedAddressesCompanion(')
          ..write('networkCode: $networkCode, ')
          ..write('address: $address, ')
          ..write('label: $label, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$UserPreferencesDatabase extends GeneratedDatabase {
  _$UserPreferencesDatabase(QueryExecutor e) : super(e);
  $UserPreferencesDatabaseManager get managers =>
      $UserPreferencesDatabaseManager(this);
  late final $RecentSentAddressesTable recentSentAddresses =
      $RecentSentAddressesTable(this);
  late final $SavedAddressesTable savedAddresses = $SavedAddressesTable(this);
  late final RecentSentAddressDao recentSentAddressDao =
      RecentSentAddressDao(this as UserPreferencesDatabase);
  late final SavedAddressDao savedAddressDao =
      SavedAddressDao(this as UserPreferencesDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [recentSentAddresses, savedAddresses];
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$RecentSentAddressesTableCreateCompanionBuilder
    = RecentSentAddressesCompanion Function({
  required String networkCode,
  required String address,
  Value<DateTime> lastUsedAt,
  Value<int> rowid,
});
typedef $$RecentSentAddressesTableUpdateCompanionBuilder
    = RecentSentAddressesCompanion Function({
  Value<String> networkCode,
  Value<String> address,
  Value<DateTime> lastUsedAt,
  Value<int> rowid,
});

class $$RecentSentAddressesTableFilterComposer
    extends Composer<_$UserPreferencesDatabase, $RecentSentAddressesTable> {
  $$RecentSentAddressesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get networkCode => $composableBuilder(
      column: $table.networkCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastUsedAt => $composableBuilder(
      column: $table.lastUsedAt, builder: (column) => ColumnFilters(column));
}

class $$RecentSentAddressesTableOrderingComposer
    extends Composer<_$UserPreferencesDatabase, $RecentSentAddressesTable> {
  $$RecentSentAddressesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get networkCode => $composableBuilder(
      column: $table.networkCode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastUsedAt => $composableBuilder(
      column: $table.lastUsedAt, builder: (column) => ColumnOrderings(column));
}

class $$RecentSentAddressesTableAnnotationComposer
    extends Composer<_$UserPreferencesDatabase, $RecentSentAddressesTable> {
  $$RecentSentAddressesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get networkCode => $composableBuilder(
      column: $table.networkCode, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUsedAt => $composableBuilder(
      column: $table.lastUsedAt, builder: (column) => column);
}

class $$RecentSentAddressesTableTableManager extends RootTableManager<
    _$UserPreferencesDatabase,
    $RecentSentAddressesTable,
    RecentSentAddress,
    $$RecentSentAddressesTableFilterComposer,
    $$RecentSentAddressesTableOrderingComposer,
    $$RecentSentAddressesTableAnnotationComposer,
    $$RecentSentAddressesTableCreateCompanionBuilder,
    $$RecentSentAddressesTableUpdateCompanionBuilder,
    (
      RecentSentAddress,
      BaseReferences<_$UserPreferencesDatabase, $RecentSentAddressesTable,
          RecentSentAddress>
    ),
    RecentSentAddress,
    PrefetchHooks Function()> {
  $$RecentSentAddressesTableTableManager(
      _$UserPreferencesDatabase db, $RecentSentAddressesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecentSentAddressesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecentSentAddressesTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecentSentAddressesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> networkCode = const Value.absent(),
            Value<String> address = const Value.absent(),
            Value<DateTime> lastUsedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RecentSentAddressesCompanion(
            networkCode: networkCode,
            address: address,
            lastUsedAt: lastUsedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String networkCode,
            required String address,
            Value<DateTime> lastUsedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RecentSentAddressesCompanion.insert(
            networkCode: networkCode,
            address: address,
            lastUsedAt: lastUsedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$RecentSentAddressesTableProcessedTableManager = ProcessedTableManager<
    _$UserPreferencesDatabase,
    $RecentSentAddressesTable,
    RecentSentAddress,
    $$RecentSentAddressesTableFilterComposer,
    $$RecentSentAddressesTableOrderingComposer,
    $$RecentSentAddressesTableAnnotationComposer,
    $$RecentSentAddressesTableCreateCompanionBuilder,
    $$RecentSentAddressesTableUpdateCompanionBuilder,
    (
      RecentSentAddress,
      BaseReferences<_$UserPreferencesDatabase, $RecentSentAddressesTable,
          RecentSentAddress>
    ),
    RecentSentAddress,
    PrefetchHooks Function()>;
typedef $$SavedAddressesTableCreateCompanionBuilder = SavedAddressesCompanion
    Function({
  required String networkCode,
  required String address,
  Value<String?> label,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$SavedAddressesTableUpdateCompanionBuilder = SavedAddressesCompanion
    Function({
  Value<String> networkCode,
  Value<String> address,
  Value<String?> label,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$SavedAddressesTableFilterComposer
    extends Composer<_$UserPreferencesDatabase, $SavedAddressesTable> {
  $$SavedAddressesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get networkCode => $composableBuilder(
      column: $table.networkCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get label => $composableBuilder(
      column: $table.label, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$SavedAddressesTableOrderingComposer
    extends Composer<_$UserPreferencesDatabase, $SavedAddressesTable> {
  $$SavedAddressesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get networkCode => $composableBuilder(
      column: $table.networkCode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get label => $composableBuilder(
      column: $table.label, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$SavedAddressesTableAnnotationComposer
    extends Composer<_$UserPreferencesDatabase, $SavedAddressesTable> {
  $$SavedAddressesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get networkCode => $composableBuilder(
      column: $table.networkCode, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SavedAddressesTableTableManager extends RootTableManager<
    _$UserPreferencesDatabase,
    $SavedAddressesTable,
    SavedAddress,
    $$SavedAddressesTableFilterComposer,
    $$SavedAddressesTableOrderingComposer,
    $$SavedAddressesTableAnnotationComposer,
    $$SavedAddressesTableCreateCompanionBuilder,
    $$SavedAddressesTableUpdateCompanionBuilder,
    (
      SavedAddress,
      BaseReferences<_$UserPreferencesDatabase, $SavedAddressesTable,
          SavedAddress>
    ),
    SavedAddress,
    PrefetchHooks Function()> {
  $$SavedAddressesTableTableManager(
      _$UserPreferencesDatabase db, $SavedAddressesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SavedAddressesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SavedAddressesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SavedAddressesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> networkCode = const Value.absent(),
            Value<String> address = const Value.absent(),
            Value<String?> label = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SavedAddressesCompanion(
            networkCode: networkCode,
            address: address,
            label: label,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String networkCode,
            required String address,
            Value<String?> label = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SavedAddressesCompanion.insert(
            networkCode: networkCode,
            address: address,
            label: label,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SavedAddressesTableProcessedTableManager = ProcessedTableManager<
    _$UserPreferencesDatabase,
    $SavedAddressesTable,
    SavedAddress,
    $$SavedAddressesTableFilterComposer,
    $$SavedAddressesTableOrderingComposer,
    $$SavedAddressesTableAnnotationComposer,
    $$SavedAddressesTableCreateCompanionBuilder,
    $$SavedAddressesTableUpdateCompanionBuilder,
    (
      SavedAddress,
      BaseReferences<_$UserPreferencesDatabase, $SavedAddressesTable,
          SavedAddress>
    ),
    SavedAddress,
    PrefetchHooks Function()>;

class $UserPreferencesDatabaseManager {
  final _$UserPreferencesDatabase _db;
  $UserPreferencesDatabaseManager(this._db);
  $$RecentSentAddressesTableTableManager get recentSentAddresses =>
      $$RecentSentAddressesTableTableManager(_db, _db.recentSentAddresses);
  $$SavedAddressesTableTableManager get savedAddresses =>
      $$SavedAddressesTableTableManager(_db, _db.savedAddresses);
}
