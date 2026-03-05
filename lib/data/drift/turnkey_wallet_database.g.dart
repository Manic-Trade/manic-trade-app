// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'turnkey_wallet_database.dart';

// ignore_for_file: type=lint
class $TurnkeyUsersTable extends TurnkeyUsers
    with TableInfo<$TurnkeyUsersTable, TurnkeyUser> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TurnkeyUsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
      'phone', aliasedName, true,
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
      [id, name, email, phone, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'turnkey_users';
  @override
  VerificationContext validateIntegrity(Insertable<TurnkeyUser> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    }
    if (data.containsKey('phone')) {
      context.handle(
          _phoneMeta, phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta));
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
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TurnkeyUser map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TurnkeyUser(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email']),
      phone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $TurnkeyUsersTable createAlias(String alias) {
    return $TurnkeyUsersTable(attachedDatabase, alias);
  }
}

class TurnkeyUser extends DataClass implements Insertable<TurnkeyUser> {
  final String id;
  final String name;
  final String? email;
  final String? phone;
  final DateTime createdAt;
  final DateTime updatedAt;
  const TurnkeyUser(
      {required this.id,
      required this.name,
      this.email,
      this.phone,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  TurnkeyUsersCompanion toCompanion(bool nullToAbsent) {
    return TurnkeyUsersCompanion(
      id: Value(id),
      name: Value(name),
      email:
          email == null && nullToAbsent ? const Value.absent() : Value(email),
      phone:
          phone == null && nullToAbsent ? const Value.absent() : Value(phone),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory TurnkeyUser.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TurnkeyUser(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      email: serializer.fromJson<String?>(json['email']),
      phone: serializer.fromJson<String?>(json['phone']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'email': serializer.toJson<String?>(email),
      'phone': serializer.toJson<String?>(phone),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  TurnkeyUser copyWith(
          {String? id,
          String? name,
          Value<String?> email = const Value.absent(),
          Value<String?> phone = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      TurnkeyUser(
        id: id ?? this.id,
        name: name ?? this.name,
        email: email.present ? email.value : this.email,
        phone: phone.present ? phone.value : this.phone,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  TurnkeyUser copyWithCompanion(TurnkeyUsersCompanion data) {
    return TurnkeyUser(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      email: data.email.present ? data.email.value : this.email,
      phone: data.phone.present ? data.phone.value : this.phone,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TurnkeyUser(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('phone: $phone, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, email, phone, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TurnkeyUser &&
          other.id == this.id &&
          other.name == this.name &&
          other.email == this.email &&
          other.phone == this.phone &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TurnkeyUsersCompanion extends UpdateCompanion<TurnkeyUser> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> email;
  final Value<String?> phone;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const TurnkeyUsersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.email = const Value.absent(),
    this.phone = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TurnkeyUsersCompanion.insert({
    required String id,
    required String name,
    this.email = const Value.absent(),
    this.phone = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name);
  static Insertable<TurnkeyUser> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? email,
    Expression<String>? phone,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TurnkeyUsersCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String?>? email,
      Value<String?>? phone,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return TurnkeyUsersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
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
    return (StringBuffer('TurnkeyUsersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('phone: $phone, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TurnkeyWalletsTable extends TurnkeyWallets
    with TableInfo<$TurnkeyWalletsTable, TurnkeyWallet> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TurnkeyWalletsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES turnkey_users (id)'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _exportedMeta =
      const VerificationMeta('exported');
  @override
  late final GeneratedColumn<bool> exported = GeneratedColumn<bool>(
      'exported', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("exported" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _importedMeta =
      const VerificationMeta('imported');
  @override
  late final GeneratedColumn<bool> imported = GeneratedColumn<bool>(
      'imported', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("imported" IN (0, 1))'),
      defaultValue: const Constant(false));
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
      [id, userId, name, exported, imported, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'turnkey_wallets';
  @override
  VerificationContext validateIntegrity(Insertable<TurnkeyWallet> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('exported')) {
      context.handle(_exportedMeta,
          exported.isAcceptableOrUnknown(data['exported']!, _exportedMeta));
    }
    if (data.containsKey('imported')) {
      context.handle(_importedMeta,
          imported.isAcceptableOrUnknown(data['imported']!, _importedMeta));
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
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TurnkeyWallet map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TurnkeyWallet(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      exported: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}exported'])!,
      imported: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}imported'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $TurnkeyWalletsTable createAlias(String alias) {
    return $TurnkeyWalletsTable(attachedDatabase, alias);
  }
}

class TurnkeyWallet extends DataClass implements Insertable<TurnkeyWallet> {
  final String id;
  final String userId;
  final String name;

  /// True when a given Wallet is exported, false otherwise.
  final bool exported;

  /// True when a given Wallet is imported, false otherwise.
  final bool imported;
  final DateTime createdAt;
  final DateTime updatedAt;
  const TurnkeyWallet(
      {required this.id,
      required this.userId,
      required this.name,
      required this.exported,
      required this.imported,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['name'] = Variable<String>(name);
    map['exported'] = Variable<bool>(exported);
    map['imported'] = Variable<bool>(imported);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  TurnkeyWalletsCompanion toCompanion(bool nullToAbsent) {
    return TurnkeyWalletsCompanion(
      id: Value(id),
      userId: Value(userId),
      name: Value(name),
      exported: Value(exported),
      imported: Value(imported),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory TurnkeyWallet.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TurnkeyWallet(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      name: serializer.fromJson<String>(json['name']),
      exported: serializer.fromJson<bool>(json['exported']),
      imported: serializer.fromJson<bool>(json['imported']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'name': serializer.toJson<String>(name),
      'exported': serializer.toJson<bool>(exported),
      'imported': serializer.toJson<bool>(imported),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  TurnkeyWallet copyWith(
          {String? id,
          String? userId,
          String? name,
          bool? exported,
          bool? imported,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      TurnkeyWallet(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        name: name ?? this.name,
        exported: exported ?? this.exported,
        imported: imported ?? this.imported,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  TurnkeyWallet copyWithCompanion(TurnkeyWalletsCompanion data) {
    return TurnkeyWallet(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      name: data.name.present ? data.name.value : this.name,
      exported: data.exported.present ? data.exported.value : this.exported,
      imported: data.imported.present ? data.imported.value : this.imported,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TurnkeyWallet(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('exported: $exported, ')
          ..write('imported: $imported, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, userId, name, exported, imported, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TurnkeyWallet &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.name == this.name &&
          other.exported == this.exported &&
          other.imported == this.imported &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TurnkeyWalletsCompanion extends UpdateCompanion<TurnkeyWallet> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> name;
  final Value<bool> exported;
  final Value<bool> imported;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const TurnkeyWalletsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.name = const Value.absent(),
    this.exported = const Value.absent(),
    this.imported = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TurnkeyWalletsCompanion.insert({
    required String id,
    required String userId,
    required String name,
    this.exported = const Value.absent(),
    this.imported = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        userId = Value(userId),
        name = Value(name);
  static Insertable<TurnkeyWallet> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? name,
    Expression<bool>? exported,
    Expression<bool>? imported,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (name != null) 'name': name,
      if (exported != null) 'exported': exported,
      if (imported != null) 'imported': imported,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TurnkeyWalletsCompanion copyWith(
      {Value<String>? id,
      Value<String>? userId,
      Value<String>? name,
      Value<bool>? exported,
      Value<bool>? imported,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return TurnkeyWalletsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      exported: exported ?? this.exported,
      imported: imported ?? this.imported,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (exported.present) {
      map['exported'] = Variable<bool>(exported.value);
    }
    if (imported.present) {
      map['imported'] = Variable<bool>(imported.value);
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
    return (StringBuffer('TurnkeyWalletsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('exported: $exported, ')
          ..write('imported: $imported, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TurnkeyAccountsTable extends TurnkeyAccounts
    with TableInfo<$TurnkeyAccountsTable, TurnkeyAccount> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TurnkeyAccountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _walletIdMeta =
      const VerificationMeta('walletId');
  @override
  late final GeneratedColumn<String> walletId = GeneratedColumn<String>(
      'wallet_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES turnkey_wallets (id)'));
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
  static const VerificationMeta _publicKeyMeta =
      const VerificationMeta('publicKey');
  @override
  late final GeneratedColumn<String> publicKey = GeneratedColumn<String>(
      'public_key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _derivationPathMeta =
      const VerificationMeta('derivationPath');
  @override
  late final GeneratedColumn<String> derivationPath = GeneratedColumn<String>(
      'derivation_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _keyIndexMeta =
      const VerificationMeta('keyIndex');
  @override
  late final GeneratedColumn<int> keyIndex = GeneratedColumn<int>(
      'key_index', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, walletId, networkCode, address, publicKey, derivationPath, keyIndex];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'turnkey_accounts';
  @override
  VerificationContext validateIntegrity(Insertable<TurnkeyAccount> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('wallet_id')) {
      context.handle(_walletIdMeta,
          walletId.isAcceptableOrUnknown(data['wallet_id']!, _walletIdMeta));
    } else if (isInserting) {
      context.missing(_walletIdMeta);
    }
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
    if (data.containsKey('public_key')) {
      context.handle(_publicKeyMeta,
          publicKey.isAcceptableOrUnknown(data['public_key']!, _publicKeyMeta));
    } else if (isInserting) {
      context.missing(_publicKeyMeta);
    }
    if (data.containsKey('derivation_path')) {
      context.handle(
          _derivationPathMeta,
          derivationPath.isAcceptableOrUnknown(
              data['derivation_path']!, _derivationPathMeta));
    } else if (isInserting) {
      context.missing(_derivationPathMeta);
    }
    if (data.containsKey('key_index')) {
      context.handle(_keyIndexMeta,
          keyIndex.isAcceptableOrUnknown(data['key_index']!, _keyIndexMeta));
    } else if (isInserting) {
      context.missing(_keyIndexMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TurnkeyAccount map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TurnkeyAccount(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      walletId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}wallet_id'])!,
      networkCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}network_code'])!,
      address: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}address'])!,
      publicKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}public_key'])!,
      derivationPath: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}derivation_path'])!,
      keyIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}key_index'])!,
    );
  }

  @override
  $TurnkeyAccountsTable createAlias(String alias) {
    return $TurnkeyAccountsTable(attachedDatabase, alias);
  }
}

class TurnkeyAccount extends DataClass implements Insertable<TurnkeyAccount> {
  final String id;
  final String walletId;
  final String networkCode;
  final String address;
  final String publicKey;
  final String derivationPath;
  final int keyIndex;
  const TurnkeyAccount(
      {required this.id,
      required this.walletId,
      required this.networkCode,
      required this.address,
      required this.publicKey,
      required this.derivationPath,
      required this.keyIndex});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['wallet_id'] = Variable<String>(walletId);
    map['network_code'] = Variable<String>(networkCode);
    map['address'] = Variable<String>(address);
    map['public_key'] = Variable<String>(publicKey);
    map['derivation_path'] = Variable<String>(derivationPath);
    map['key_index'] = Variable<int>(keyIndex);
    return map;
  }

  TurnkeyAccountsCompanion toCompanion(bool nullToAbsent) {
    return TurnkeyAccountsCompanion(
      id: Value(id),
      walletId: Value(walletId),
      networkCode: Value(networkCode),
      address: Value(address),
      publicKey: Value(publicKey),
      derivationPath: Value(derivationPath),
      keyIndex: Value(keyIndex),
    );
  }

  factory TurnkeyAccount.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TurnkeyAccount(
      id: serializer.fromJson<String>(json['id']),
      walletId: serializer.fromJson<String>(json['walletId']),
      networkCode: serializer.fromJson<String>(json['networkCode']),
      address: serializer.fromJson<String>(json['address']),
      publicKey: serializer.fromJson<String>(json['publicKey']),
      derivationPath: serializer.fromJson<String>(json['derivationPath']),
      keyIndex: serializer.fromJson<int>(json['keyIndex']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'walletId': serializer.toJson<String>(walletId),
      'networkCode': serializer.toJson<String>(networkCode),
      'address': serializer.toJson<String>(address),
      'publicKey': serializer.toJson<String>(publicKey),
      'derivationPath': serializer.toJson<String>(derivationPath),
      'keyIndex': serializer.toJson<int>(keyIndex),
    };
  }

  TurnkeyAccount copyWith(
          {String? id,
          String? walletId,
          String? networkCode,
          String? address,
          String? publicKey,
          String? derivationPath,
          int? keyIndex}) =>
      TurnkeyAccount(
        id: id ?? this.id,
        walletId: walletId ?? this.walletId,
        networkCode: networkCode ?? this.networkCode,
        address: address ?? this.address,
        publicKey: publicKey ?? this.publicKey,
        derivationPath: derivationPath ?? this.derivationPath,
        keyIndex: keyIndex ?? this.keyIndex,
      );
  TurnkeyAccount copyWithCompanion(TurnkeyAccountsCompanion data) {
    return TurnkeyAccount(
      id: data.id.present ? data.id.value : this.id,
      walletId: data.walletId.present ? data.walletId.value : this.walletId,
      networkCode:
          data.networkCode.present ? data.networkCode.value : this.networkCode,
      address: data.address.present ? data.address.value : this.address,
      publicKey: data.publicKey.present ? data.publicKey.value : this.publicKey,
      derivationPath: data.derivationPath.present
          ? data.derivationPath.value
          : this.derivationPath,
      keyIndex: data.keyIndex.present ? data.keyIndex.value : this.keyIndex,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TurnkeyAccount(')
          ..write('id: $id, ')
          ..write('walletId: $walletId, ')
          ..write('networkCode: $networkCode, ')
          ..write('address: $address, ')
          ..write('publicKey: $publicKey, ')
          ..write('derivationPath: $derivationPath, ')
          ..write('keyIndex: $keyIndex')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, walletId, networkCode, address, publicKey, derivationPath, keyIndex);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TurnkeyAccount &&
          other.id == this.id &&
          other.walletId == this.walletId &&
          other.networkCode == this.networkCode &&
          other.address == this.address &&
          other.publicKey == this.publicKey &&
          other.derivationPath == this.derivationPath &&
          other.keyIndex == this.keyIndex);
}

class TurnkeyAccountsCompanion extends UpdateCompanion<TurnkeyAccount> {
  final Value<String> id;
  final Value<String> walletId;
  final Value<String> networkCode;
  final Value<String> address;
  final Value<String> publicKey;
  final Value<String> derivationPath;
  final Value<int> keyIndex;
  final Value<int> rowid;
  const TurnkeyAccountsCompanion({
    this.id = const Value.absent(),
    this.walletId = const Value.absent(),
    this.networkCode = const Value.absent(),
    this.address = const Value.absent(),
    this.publicKey = const Value.absent(),
    this.derivationPath = const Value.absent(),
    this.keyIndex = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TurnkeyAccountsCompanion.insert({
    required String id,
    required String walletId,
    required String networkCode,
    required String address,
    required String publicKey,
    required String derivationPath,
    required int keyIndex,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        walletId = Value(walletId),
        networkCode = Value(networkCode),
        address = Value(address),
        publicKey = Value(publicKey),
        derivationPath = Value(derivationPath),
        keyIndex = Value(keyIndex);
  static Insertable<TurnkeyAccount> custom({
    Expression<String>? id,
    Expression<String>? walletId,
    Expression<String>? networkCode,
    Expression<String>? address,
    Expression<String>? publicKey,
    Expression<String>? derivationPath,
    Expression<int>? keyIndex,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (walletId != null) 'wallet_id': walletId,
      if (networkCode != null) 'network_code': networkCode,
      if (address != null) 'address': address,
      if (publicKey != null) 'public_key': publicKey,
      if (derivationPath != null) 'derivation_path': derivationPath,
      if (keyIndex != null) 'key_index': keyIndex,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TurnkeyAccountsCompanion copyWith(
      {Value<String>? id,
      Value<String>? walletId,
      Value<String>? networkCode,
      Value<String>? address,
      Value<String>? publicKey,
      Value<String>? derivationPath,
      Value<int>? keyIndex,
      Value<int>? rowid}) {
    return TurnkeyAccountsCompanion(
      id: id ?? this.id,
      walletId: walletId ?? this.walletId,
      networkCode: networkCode ?? this.networkCode,
      address: address ?? this.address,
      publicKey: publicKey ?? this.publicKey,
      derivationPath: derivationPath ?? this.derivationPath,
      keyIndex: keyIndex ?? this.keyIndex,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (walletId.present) {
      map['wallet_id'] = Variable<String>(walletId.value);
    }
    if (networkCode.present) {
      map['network_code'] = Variable<String>(networkCode.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (publicKey.present) {
      map['public_key'] = Variable<String>(publicKey.value);
    }
    if (derivationPath.present) {
      map['derivation_path'] = Variable<String>(derivationPath.value);
    }
    if (keyIndex.present) {
      map['key_index'] = Variable<int>(keyIndex.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TurnkeyAccountsCompanion(')
          ..write('id: $id, ')
          ..write('walletId: $walletId, ')
          ..write('networkCode: $networkCode, ')
          ..write('address: $address, ')
          ..write('publicKey: $publicKey, ')
          ..write('derivationPath: $derivationPath, ')
          ..write('keyIndex: $keyIndex, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$TurnkeyWalletDatabase extends GeneratedDatabase {
  _$TurnkeyWalletDatabase(QueryExecutor e) : super(e);
  $TurnkeyWalletDatabaseManager get managers =>
      $TurnkeyWalletDatabaseManager(this);
  late final $TurnkeyUsersTable turnkeyUsers = $TurnkeyUsersTable(this);
  late final $TurnkeyWalletsTable turnkeyWallets = $TurnkeyWalletsTable(this);
  late final $TurnkeyAccountsTable turnkeyAccounts =
      $TurnkeyAccountsTable(this);
  late final TurnkeyUserDao turnkeyUserDao =
      TurnkeyUserDao(this as TurnkeyWalletDatabase);
  late final TurnkeyWalletDao turnkeyWalletDao =
      TurnkeyWalletDao(this as TurnkeyWalletDatabase);
  late final TurnkeyAccountDao turnkeyAccountDao =
      TurnkeyAccountDao(this as TurnkeyWalletDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [turnkeyUsers, turnkeyWallets, turnkeyAccounts];
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$TurnkeyUsersTableCreateCompanionBuilder = TurnkeyUsersCompanion
    Function({
  required String id,
  required String name,
  Value<String?> email,
  Value<String?> phone,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$TurnkeyUsersTableUpdateCompanionBuilder = TurnkeyUsersCompanion
    Function({
  Value<String> id,
  Value<String> name,
  Value<String?> email,
  Value<String?> phone,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$TurnkeyUsersTableReferences extends BaseReferences<
    _$TurnkeyWalletDatabase, $TurnkeyUsersTable, TurnkeyUser> {
  $$TurnkeyUsersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TurnkeyWalletsTable, List<TurnkeyWallet>>
      _turnkeyWalletsRefsTable(_$TurnkeyWalletDatabase db) =>
          MultiTypedResultKey.fromTable(db.turnkeyWallets,
              aliasName: $_aliasNameGenerator(
                  db.turnkeyUsers.id, db.turnkeyWallets.userId));

  $$TurnkeyWalletsTableProcessedTableManager get turnkeyWalletsRefs {
    final manager = $$TurnkeyWalletsTableTableManager($_db, $_db.turnkeyWallets)
        .filter((f) => f.userId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_turnkeyWalletsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$TurnkeyUsersTableFilterComposer
    extends Composer<_$TurnkeyWalletDatabase, $TurnkeyUsersTable> {
  $$TurnkeyUsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> turnkeyWalletsRefs(
      Expression<bool> Function($$TurnkeyWalletsTableFilterComposer f) f) {
    final $$TurnkeyWalletsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.turnkeyWallets,
        getReferencedColumn: (t) => t.userId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TurnkeyWalletsTableFilterComposer(
              $db: $db,
              $table: $db.turnkeyWallets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$TurnkeyUsersTableOrderingComposer
    extends Composer<_$TurnkeyWalletDatabase, $TurnkeyUsersTable> {
  $$TurnkeyUsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$TurnkeyUsersTableAnnotationComposer
    extends Composer<_$TurnkeyWalletDatabase, $TurnkeyUsersTable> {
  $$TurnkeyUsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> turnkeyWalletsRefs<T extends Object>(
      Expression<T> Function($$TurnkeyWalletsTableAnnotationComposer a) f) {
    final $$TurnkeyWalletsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.turnkeyWallets,
        getReferencedColumn: (t) => t.userId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TurnkeyWalletsTableAnnotationComposer(
              $db: $db,
              $table: $db.turnkeyWallets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$TurnkeyUsersTableTableManager extends RootTableManager<
    _$TurnkeyWalletDatabase,
    $TurnkeyUsersTable,
    TurnkeyUser,
    $$TurnkeyUsersTableFilterComposer,
    $$TurnkeyUsersTableOrderingComposer,
    $$TurnkeyUsersTableAnnotationComposer,
    $$TurnkeyUsersTableCreateCompanionBuilder,
    $$TurnkeyUsersTableUpdateCompanionBuilder,
    (TurnkeyUser, $$TurnkeyUsersTableReferences),
    TurnkeyUser,
    PrefetchHooks Function({bool turnkeyWalletsRefs})> {
  $$TurnkeyUsersTableTableManager(
      _$TurnkeyWalletDatabase db, $TurnkeyUsersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TurnkeyUsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TurnkeyUsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TurnkeyUsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> email = const Value.absent(),
            Value<String?> phone = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TurnkeyUsersCompanion(
            id: id,
            name: name,
            email: email,
            phone: phone,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String?> email = const Value.absent(),
            Value<String?> phone = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TurnkeyUsersCompanion.insert(
            id: id,
            name: name,
            email: email,
            phone: phone,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$TurnkeyUsersTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({turnkeyWalletsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (turnkeyWalletsRefs) db.turnkeyWallets
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (turnkeyWalletsRefs)
                    await $_getPrefetchedData<TurnkeyUser, $TurnkeyUsersTable,
                            TurnkeyWallet>(
                        currentTable: table,
                        referencedTable: $$TurnkeyUsersTableReferences
                            ._turnkeyWalletsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TurnkeyUsersTableReferences(db, table, p0)
                                .turnkeyWalletsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.userId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$TurnkeyUsersTableProcessedTableManager = ProcessedTableManager<
    _$TurnkeyWalletDatabase,
    $TurnkeyUsersTable,
    TurnkeyUser,
    $$TurnkeyUsersTableFilterComposer,
    $$TurnkeyUsersTableOrderingComposer,
    $$TurnkeyUsersTableAnnotationComposer,
    $$TurnkeyUsersTableCreateCompanionBuilder,
    $$TurnkeyUsersTableUpdateCompanionBuilder,
    (TurnkeyUser, $$TurnkeyUsersTableReferences),
    TurnkeyUser,
    PrefetchHooks Function({bool turnkeyWalletsRefs})>;
typedef $$TurnkeyWalletsTableCreateCompanionBuilder = TurnkeyWalletsCompanion
    Function({
  required String id,
  required String userId,
  required String name,
  Value<bool> exported,
  Value<bool> imported,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$TurnkeyWalletsTableUpdateCompanionBuilder = TurnkeyWalletsCompanion
    Function({
  Value<String> id,
  Value<String> userId,
  Value<String> name,
  Value<bool> exported,
  Value<bool> imported,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$TurnkeyWalletsTableReferences extends BaseReferences<
    _$TurnkeyWalletDatabase, $TurnkeyWalletsTable, TurnkeyWallet> {
  $$TurnkeyWalletsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $TurnkeyUsersTable _userIdTable(_$TurnkeyWalletDatabase db) =>
      db.turnkeyUsers.createAlias(
          $_aliasNameGenerator(db.turnkeyWallets.userId, db.turnkeyUsers.id));

  $$TurnkeyUsersTableProcessedTableManager get userId {
    final $_column = $_itemColumn<String>('user_id')!;

    final manager = $$TurnkeyUsersTableTableManager($_db, $_db.turnkeyUsers)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$TurnkeyAccountsTable, List<TurnkeyAccount>>
      _turnkeyAccountsRefsTable(_$TurnkeyWalletDatabase db) =>
          MultiTypedResultKey.fromTable(db.turnkeyAccounts,
              aliasName: $_aliasNameGenerator(
                  db.turnkeyWallets.id, db.turnkeyAccounts.walletId));

  $$TurnkeyAccountsTableProcessedTableManager get turnkeyAccountsRefs {
    final manager = $$TurnkeyAccountsTableTableManager(
            $_db, $_db.turnkeyAccounts)
        .filter((f) => f.walletId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_turnkeyAccountsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$TurnkeyWalletsTableFilterComposer
    extends Composer<_$TurnkeyWalletDatabase, $TurnkeyWalletsTable> {
  $$TurnkeyWalletsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get exported => $composableBuilder(
      column: $table.exported, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get imported => $composableBuilder(
      column: $table.imported, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$TurnkeyUsersTableFilterComposer get userId {
    final $$TurnkeyUsersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.turnkeyUsers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TurnkeyUsersTableFilterComposer(
              $db: $db,
              $table: $db.turnkeyUsers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> turnkeyAccountsRefs(
      Expression<bool> Function($$TurnkeyAccountsTableFilterComposer f) f) {
    final $$TurnkeyAccountsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.turnkeyAccounts,
        getReferencedColumn: (t) => t.walletId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TurnkeyAccountsTableFilterComposer(
              $db: $db,
              $table: $db.turnkeyAccounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$TurnkeyWalletsTableOrderingComposer
    extends Composer<_$TurnkeyWalletDatabase, $TurnkeyWalletsTable> {
  $$TurnkeyWalletsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get exported => $composableBuilder(
      column: $table.exported, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get imported => $composableBuilder(
      column: $table.imported, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$TurnkeyUsersTableOrderingComposer get userId {
    final $$TurnkeyUsersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.turnkeyUsers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TurnkeyUsersTableOrderingComposer(
              $db: $db,
              $table: $db.turnkeyUsers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TurnkeyWalletsTableAnnotationComposer
    extends Composer<_$TurnkeyWalletDatabase, $TurnkeyWalletsTable> {
  $$TurnkeyWalletsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<bool> get exported =>
      $composableBuilder(column: $table.exported, builder: (column) => column);

  GeneratedColumn<bool> get imported =>
      $composableBuilder(column: $table.imported, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$TurnkeyUsersTableAnnotationComposer get userId {
    final $$TurnkeyUsersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.turnkeyUsers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TurnkeyUsersTableAnnotationComposer(
              $db: $db,
              $table: $db.turnkeyUsers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> turnkeyAccountsRefs<T extends Object>(
      Expression<T> Function($$TurnkeyAccountsTableAnnotationComposer a) f) {
    final $$TurnkeyAccountsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.turnkeyAccounts,
        getReferencedColumn: (t) => t.walletId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TurnkeyAccountsTableAnnotationComposer(
              $db: $db,
              $table: $db.turnkeyAccounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$TurnkeyWalletsTableTableManager extends RootTableManager<
    _$TurnkeyWalletDatabase,
    $TurnkeyWalletsTable,
    TurnkeyWallet,
    $$TurnkeyWalletsTableFilterComposer,
    $$TurnkeyWalletsTableOrderingComposer,
    $$TurnkeyWalletsTableAnnotationComposer,
    $$TurnkeyWalletsTableCreateCompanionBuilder,
    $$TurnkeyWalletsTableUpdateCompanionBuilder,
    (TurnkeyWallet, $$TurnkeyWalletsTableReferences),
    TurnkeyWallet,
    PrefetchHooks Function({bool userId, bool turnkeyAccountsRefs})> {
  $$TurnkeyWalletsTableTableManager(
      _$TurnkeyWalletDatabase db, $TurnkeyWalletsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TurnkeyWalletsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TurnkeyWalletsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TurnkeyWalletsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<bool> exported = const Value.absent(),
            Value<bool> imported = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TurnkeyWalletsCompanion(
            id: id,
            userId: userId,
            name: name,
            exported: exported,
            imported: imported,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String userId,
            required String name,
            Value<bool> exported = const Value.absent(),
            Value<bool> imported = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TurnkeyWalletsCompanion.insert(
            id: id,
            userId: userId,
            name: name,
            exported: exported,
            imported: imported,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$TurnkeyWalletsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {userId = false, turnkeyAccountsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (turnkeyAccountsRefs) db.turnkeyAccounts
              ],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (userId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.userId,
                    referencedTable:
                        $$TurnkeyWalletsTableReferences._userIdTable(db),
                    referencedColumn:
                        $$TurnkeyWalletsTableReferences._userIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (turnkeyAccountsRefs)
                    await $_getPrefetchedData<TurnkeyWallet,
                            $TurnkeyWalletsTable, TurnkeyAccount>(
                        currentTable: table,
                        referencedTable: $$TurnkeyWalletsTableReferences
                            ._turnkeyAccountsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TurnkeyWalletsTableReferences(db, table, p0)
                                .turnkeyAccountsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.walletId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$TurnkeyWalletsTableProcessedTableManager = ProcessedTableManager<
    _$TurnkeyWalletDatabase,
    $TurnkeyWalletsTable,
    TurnkeyWallet,
    $$TurnkeyWalletsTableFilterComposer,
    $$TurnkeyWalletsTableOrderingComposer,
    $$TurnkeyWalletsTableAnnotationComposer,
    $$TurnkeyWalletsTableCreateCompanionBuilder,
    $$TurnkeyWalletsTableUpdateCompanionBuilder,
    (TurnkeyWallet, $$TurnkeyWalletsTableReferences),
    TurnkeyWallet,
    PrefetchHooks Function({bool userId, bool turnkeyAccountsRefs})>;
typedef $$TurnkeyAccountsTableCreateCompanionBuilder = TurnkeyAccountsCompanion
    Function({
  required String id,
  required String walletId,
  required String networkCode,
  required String address,
  required String publicKey,
  required String derivationPath,
  required int keyIndex,
  Value<int> rowid,
});
typedef $$TurnkeyAccountsTableUpdateCompanionBuilder = TurnkeyAccountsCompanion
    Function({
  Value<String> id,
  Value<String> walletId,
  Value<String> networkCode,
  Value<String> address,
  Value<String> publicKey,
  Value<String> derivationPath,
  Value<int> keyIndex,
  Value<int> rowid,
});

final class $$TurnkeyAccountsTableReferences extends BaseReferences<
    _$TurnkeyWalletDatabase, $TurnkeyAccountsTable, TurnkeyAccount> {
  $$TurnkeyAccountsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $TurnkeyWalletsTable _walletIdTable(_$TurnkeyWalletDatabase db) =>
      db.turnkeyWallets.createAlias($_aliasNameGenerator(
          db.turnkeyAccounts.walletId, db.turnkeyWallets.id));

  $$TurnkeyWalletsTableProcessedTableManager get walletId {
    final $_column = $_itemColumn<String>('wallet_id')!;

    final manager = $$TurnkeyWalletsTableTableManager($_db, $_db.turnkeyWallets)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_walletIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$TurnkeyAccountsTableFilterComposer
    extends Composer<_$TurnkeyWalletDatabase, $TurnkeyAccountsTable> {
  $$TurnkeyAccountsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get networkCode => $composableBuilder(
      column: $table.networkCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get publicKey => $composableBuilder(
      column: $table.publicKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get derivationPath => $composableBuilder(
      column: $table.derivationPath,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get keyIndex => $composableBuilder(
      column: $table.keyIndex, builder: (column) => ColumnFilters(column));

  $$TurnkeyWalletsTableFilterComposer get walletId {
    final $$TurnkeyWalletsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.walletId,
        referencedTable: $db.turnkeyWallets,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TurnkeyWalletsTableFilterComposer(
              $db: $db,
              $table: $db.turnkeyWallets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TurnkeyAccountsTableOrderingComposer
    extends Composer<_$TurnkeyWalletDatabase, $TurnkeyAccountsTable> {
  $$TurnkeyAccountsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get networkCode => $composableBuilder(
      column: $table.networkCode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get publicKey => $composableBuilder(
      column: $table.publicKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get derivationPath => $composableBuilder(
      column: $table.derivationPath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get keyIndex => $composableBuilder(
      column: $table.keyIndex, builder: (column) => ColumnOrderings(column));

  $$TurnkeyWalletsTableOrderingComposer get walletId {
    final $$TurnkeyWalletsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.walletId,
        referencedTable: $db.turnkeyWallets,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TurnkeyWalletsTableOrderingComposer(
              $db: $db,
              $table: $db.turnkeyWallets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TurnkeyAccountsTableAnnotationComposer
    extends Composer<_$TurnkeyWalletDatabase, $TurnkeyAccountsTable> {
  $$TurnkeyAccountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get networkCode => $composableBuilder(
      column: $table.networkCode, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get publicKey =>
      $composableBuilder(column: $table.publicKey, builder: (column) => column);

  GeneratedColumn<String> get derivationPath => $composableBuilder(
      column: $table.derivationPath, builder: (column) => column);

  GeneratedColumn<int> get keyIndex =>
      $composableBuilder(column: $table.keyIndex, builder: (column) => column);

  $$TurnkeyWalletsTableAnnotationComposer get walletId {
    final $$TurnkeyWalletsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.walletId,
        referencedTable: $db.turnkeyWallets,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TurnkeyWalletsTableAnnotationComposer(
              $db: $db,
              $table: $db.turnkeyWallets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TurnkeyAccountsTableTableManager extends RootTableManager<
    _$TurnkeyWalletDatabase,
    $TurnkeyAccountsTable,
    TurnkeyAccount,
    $$TurnkeyAccountsTableFilterComposer,
    $$TurnkeyAccountsTableOrderingComposer,
    $$TurnkeyAccountsTableAnnotationComposer,
    $$TurnkeyAccountsTableCreateCompanionBuilder,
    $$TurnkeyAccountsTableUpdateCompanionBuilder,
    (TurnkeyAccount, $$TurnkeyAccountsTableReferences),
    TurnkeyAccount,
    PrefetchHooks Function({bool walletId})> {
  $$TurnkeyAccountsTableTableManager(
      _$TurnkeyWalletDatabase db, $TurnkeyAccountsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TurnkeyAccountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TurnkeyAccountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TurnkeyAccountsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> walletId = const Value.absent(),
            Value<String> networkCode = const Value.absent(),
            Value<String> address = const Value.absent(),
            Value<String> publicKey = const Value.absent(),
            Value<String> derivationPath = const Value.absent(),
            Value<int> keyIndex = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TurnkeyAccountsCompanion(
            id: id,
            walletId: walletId,
            networkCode: networkCode,
            address: address,
            publicKey: publicKey,
            derivationPath: derivationPath,
            keyIndex: keyIndex,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String walletId,
            required String networkCode,
            required String address,
            required String publicKey,
            required String derivationPath,
            required int keyIndex,
            Value<int> rowid = const Value.absent(),
          }) =>
              TurnkeyAccountsCompanion.insert(
            id: id,
            walletId: walletId,
            networkCode: networkCode,
            address: address,
            publicKey: publicKey,
            derivationPath: derivationPath,
            keyIndex: keyIndex,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$TurnkeyAccountsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({walletId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (walletId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.walletId,
                    referencedTable:
                        $$TurnkeyAccountsTableReferences._walletIdTable(db),
                    referencedColumn:
                        $$TurnkeyAccountsTableReferences._walletIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$TurnkeyAccountsTableProcessedTableManager = ProcessedTableManager<
    _$TurnkeyWalletDatabase,
    $TurnkeyAccountsTable,
    TurnkeyAccount,
    $$TurnkeyAccountsTableFilterComposer,
    $$TurnkeyAccountsTableOrderingComposer,
    $$TurnkeyAccountsTableAnnotationComposer,
    $$TurnkeyAccountsTableCreateCompanionBuilder,
    $$TurnkeyAccountsTableUpdateCompanionBuilder,
    (TurnkeyAccount, $$TurnkeyAccountsTableReferences),
    TurnkeyAccount,
    PrefetchHooks Function({bool walletId})>;

class $TurnkeyWalletDatabaseManager {
  final _$TurnkeyWalletDatabase _db;
  $TurnkeyWalletDatabaseManager(this._db);
  $$TurnkeyUsersTableTableManager get turnkeyUsers =>
      $$TurnkeyUsersTableTableManager(_db, _db.turnkeyUsers);
  $$TurnkeyWalletsTableTableManager get turnkeyWallets =>
      $$TurnkeyWalletsTableTableManager(_db, _db.turnkeyWallets);
  $$TurnkeyAccountsTableTableManager get turnkeyAccounts =>
      $$TurnkeyAccountsTableTableManager(_db, _db.turnkeyAccounts);
}
