// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_database.dart';

// ignore_for_file: type=lint
class $TokensTable extends Tokens with TableInfo<$TokensTable, Token> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TokensTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _networkCodeMeta =
      const VerificationMeta('networkCode');
  @override
  late final GeneratedColumn<String> networkCode = GeneratedColumn<String>(
      'network_code', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _contractAddressMeta =
      const VerificationMeta('contractAddress');
  @override
  late final GeneratedColumn<String> contractAddress = GeneratedColumn<String>(
      'contract_address', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _symbolMeta = const VerificationMeta('symbol');
  @override
  late final GeneratedColumn<String> symbol = GeneratedColumn<String>(
      'symbol', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _decimalsMeta =
      const VerificationMeta('decimals');
  @override
  late final GeneratedColumn<int> decimals = GeneratedColumn<int>(
      'decimals', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _iconUrlMeta =
      const VerificationMeta('iconUrl');
  @override
  late final GeneratedColumn<String> iconUrl = GeneratedColumn<String>(
      'icon_url', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tokenCreatedMeta =
      const VerificationMeta('tokenCreated');
  @override
  late final GeneratedColumn<DateTime> tokenCreated = GeneratedColumn<DateTime>(
      'token_created', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        networkCode,
        contractAddress,
        symbol,
        name,
        decimals,
        iconUrl,
        tokenCreated,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tokens';
  @override
  VerificationContext validateIntegrity(Insertable<Token> instance,
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
    if (data.containsKey('contract_address')) {
      context.handle(
          _contractAddressMeta,
          contractAddress.isAcceptableOrUnknown(
              data['contract_address']!, _contractAddressMeta));
    } else if (isInserting) {
      context.missing(_contractAddressMeta);
    }
    if (data.containsKey('symbol')) {
      context.handle(_symbolMeta,
          symbol.isAcceptableOrUnknown(data['symbol']!, _symbolMeta));
    } else if (isInserting) {
      context.missing(_symbolMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('decimals')) {
      context.handle(_decimalsMeta,
          decimals.isAcceptableOrUnknown(data['decimals']!, _decimalsMeta));
    } else if (isInserting) {
      context.missing(_decimalsMeta);
    }
    if (data.containsKey('icon_url')) {
      context.handle(_iconUrlMeta,
          iconUrl.isAcceptableOrUnknown(data['icon_url']!, _iconUrlMeta));
    } else if (isInserting) {
      context.missing(_iconUrlMeta);
    }
    if (data.containsKey('token_created')) {
      context.handle(
          _tokenCreatedMeta,
          tokenCreated.isAcceptableOrUnknown(
              data['token_created']!, _tokenCreatedMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {networkCode, contractAddress};
  @override
  Token map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Token(
      networkCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}network_code'])!,
      contractAddress: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}contract_address'])!,
      symbol: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}symbol'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      decimals: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}decimals'])!,
      iconUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}icon_url'])!,
      tokenCreated: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}token_created']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
    );
  }

  @override
  $TokensTable createAlias(String alias) {
    return $TokensTable(attachedDatabase, alias);
  }
}

class TokensCompanion extends UpdateCompanion<Token> {
  final Value<String> networkCode;
  final Value<String> contractAddress;
  final Value<String> symbol;
  final Value<String> name;
  final Value<int> decimals;
  final Value<String> iconUrl;
  final Value<DateTime?> tokenCreated;
  final Value<DateTime?> updatedAt;
  final Value<int> rowid;
  const TokensCompanion({
    this.networkCode = const Value.absent(),
    this.contractAddress = const Value.absent(),
    this.symbol = const Value.absent(),
    this.name = const Value.absent(),
    this.decimals = const Value.absent(),
    this.iconUrl = const Value.absent(),
    this.tokenCreated = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TokensCompanion.insert({
    required String networkCode,
    required String contractAddress,
    required String symbol,
    required String name,
    required int decimals,
    required String iconUrl,
    this.tokenCreated = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : networkCode = Value(networkCode),
        contractAddress = Value(contractAddress),
        symbol = Value(symbol),
        name = Value(name),
        decimals = Value(decimals),
        iconUrl = Value(iconUrl);
  static Insertable<Token> custom({
    Expression<String>? networkCode,
    Expression<String>? contractAddress,
    Expression<String>? symbol,
    Expression<String>? name,
    Expression<int>? decimals,
    Expression<String>? iconUrl,
    Expression<DateTime>? tokenCreated,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (networkCode != null) 'network_code': networkCode,
      if (contractAddress != null) 'contract_address': contractAddress,
      if (symbol != null) 'symbol': symbol,
      if (name != null) 'name': name,
      if (decimals != null) 'decimals': decimals,
      if (iconUrl != null) 'icon_url': iconUrl,
      if (tokenCreated != null) 'token_created': tokenCreated,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TokensCompanion copyWith(
      {Value<String>? networkCode,
      Value<String>? contractAddress,
      Value<String>? symbol,
      Value<String>? name,
      Value<int>? decimals,
      Value<String>? iconUrl,
      Value<DateTime?>? tokenCreated,
      Value<DateTime?>? updatedAt,
      Value<int>? rowid}) {
    return TokensCompanion(
      networkCode: networkCode ?? this.networkCode,
      contractAddress: contractAddress ?? this.contractAddress,
      symbol: symbol ?? this.symbol,
      name: name ?? this.name,
      decimals: decimals ?? this.decimals,
      iconUrl: iconUrl ?? this.iconUrl,
      tokenCreated: tokenCreated ?? this.tokenCreated,
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
    if (contractAddress.present) {
      map['contract_address'] = Variable<String>(contractAddress.value);
    }
    if (symbol.present) {
      map['symbol'] = Variable<String>(symbol.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (decimals.present) {
      map['decimals'] = Variable<int>(decimals.value);
    }
    if (iconUrl.present) {
      map['icon_url'] = Variable<String>(iconUrl.value);
    }
    if (tokenCreated.present) {
      map['token_created'] = Variable<DateTime>(tokenCreated.value);
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
    return (StringBuffer('TokensCompanion(')
          ..write('networkCode: $networkCode, ')
          ..write('contractAddress: $contractAddress, ')
          ..write('symbol: $symbol, ')
          ..write('name: $name, ')
          ..write('decimals: $decimals, ')
          ..write('iconUrl: $iconUrl, ')
          ..write('tokenCreated: $tokenCreated, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TokenHoldingsTable extends TokenHoldings
    with TableInfo<$TokenHoldingsTable, TokenHolding> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TokenHoldingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _networkCodeMeta =
      const VerificationMeta('networkCode');
  @override
  late final GeneratedColumn<String> networkCode = GeneratedColumn<String>(
      'network_code', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _contractAddressMeta =
      const VerificationMeta('contractAddress');
  @override
  late final GeneratedColumn<String> contractAddress = GeneratedColumn<String>(
      'contract_address', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _holderAddressMeta =
      const VerificationMeta('holderAddress');
  @override
  late final GeneratedColumn<String> holderAddress = GeneratedColumn<String>(
      'holder_address', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _balanceMeta =
      const VerificationMeta('balance');
  @override
  late final GeneratedColumn<String> balance = GeneratedColumn<String>(
      'balance', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [networkCode, contractAddress, holderAddress, balance, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'token_holdings';
  @override
  VerificationContext validateIntegrity(Insertable<TokenHolding> instance,
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
    if (data.containsKey('contract_address')) {
      context.handle(
          _contractAddressMeta,
          contractAddress.isAcceptableOrUnknown(
              data['contract_address']!, _contractAddressMeta));
    } else if (isInserting) {
      context.missing(_contractAddressMeta);
    }
    if (data.containsKey('holder_address')) {
      context.handle(
          _holderAddressMeta,
          holderAddress.isAcceptableOrUnknown(
              data['holder_address']!, _holderAddressMeta));
    } else if (isInserting) {
      context.missing(_holderAddressMeta);
    }
    if (data.containsKey('balance')) {
      context.handle(_balanceMeta,
          balance.isAcceptableOrUnknown(data['balance']!, _balanceMeta));
    } else if (isInserting) {
      context.missing(_balanceMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey =>
      {contractAddress, networkCode, holderAddress};
  @override
  TokenHolding map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TokenHolding(
      networkCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}network_code'])!,
      contractAddress: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}contract_address'])!,
      holderAddress: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}holder_address'])!,
      balance: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}balance'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
    );
  }

  @override
  $TokenHoldingsTable createAlias(String alias) {
    return $TokenHoldingsTable(attachedDatabase, alias);
  }
}

class TokenHoldingsCompanion extends UpdateCompanion<TokenHolding> {
  final Value<String> networkCode;
  final Value<String> contractAddress;
  final Value<String> holderAddress;
  final Value<String> balance;
  final Value<DateTime?> updatedAt;
  final Value<int> rowid;
  const TokenHoldingsCompanion({
    this.networkCode = const Value.absent(),
    this.contractAddress = const Value.absent(),
    this.holderAddress = const Value.absent(),
    this.balance = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TokenHoldingsCompanion.insert({
    required String networkCode,
    required String contractAddress,
    required String holderAddress,
    required String balance,
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : networkCode = Value(networkCode),
        contractAddress = Value(contractAddress),
        holderAddress = Value(holderAddress),
        balance = Value(balance);
  static Insertable<TokenHolding> custom({
    Expression<String>? networkCode,
    Expression<String>? contractAddress,
    Expression<String>? holderAddress,
    Expression<String>? balance,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (networkCode != null) 'network_code': networkCode,
      if (contractAddress != null) 'contract_address': contractAddress,
      if (holderAddress != null) 'holder_address': holderAddress,
      if (balance != null) 'balance': balance,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TokenHoldingsCompanion copyWith(
      {Value<String>? networkCode,
      Value<String>? contractAddress,
      Value<String>? holderAddress,
      Value<String>? balance,
      Value<DateTime?>? updatedAt,
      Value<int>? rowid}) {
    return TokenHoldingsCompanion(
      networkCode: networkCode ?? this.networkCode,
      contractAddress: contractAddress ?? this.contractAddress,
      holderAddress: holderAddress ?? this.holderAddress,
      balance: balance ?? this.balance,
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
    if (contractAddress.present) {
      map['contract_address'] = Variable<String>(contractAddress.value);
    }
    if (holderAddress.present) {
      map['holder_address'] = Variable<String>(holderAddress.value);
    }
    if (balance.present) {
      map['balance'] = Variable<String>(balance.value);
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
    return (StringBuffer('TokenHoldingsCompanion(')
          ..write('networkCode: $networkCode, ')
          ..write('contractAddress: $contractAddress, ')
          ..write('holderAddress: $holderAddress, ')
          ..write('balance: $balance, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TokenPricesTable extends TokenPrices
    with TableInfo<$TokenPricesTable, TokenPrice> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TokenPricesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _networkCodeMeta =
      const VerificationMeta('networkCode');
  @override
  late final GeneratedColumn<String> networkCode = GeneratedColumn<String>(
      'network_code', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _contractAddressMeta =
      const VerificationMeta('contractAddress');
  @override
  late final GeneratedColumn<String> contractAddress = GeneratedColumn<String>(
      'contract_address', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _currencyMeta =
      const VerificationMeta('currency');
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
      'currency', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<String> price = GeneratedColumn<String>(
      'price', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _change24hMeta =
      const VerificationMeta('change24h');
  @override
  late final GeneratedColumn<double> change24h = GeneratedColumn<double>(
      'change24h', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _timeMeta = const VerificationMeta('time');
  @override
  late final GeneratedColumn<DateTime> time = GeneratedColumn<DateTime>(
      'time', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [networkCode, contractAddress, currency, price, change24h, time];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'token_prices';
  @override
  VerificationContext validateIntegrity(Insertable<TokenPrice> instance,
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
    if (data.containsKey('contract_address')) {
      context.handle(
          _contractAddressMeta,
          contractAddress.isAcceptableOrUnknown(
              data['contract_address']!, _contractAddressMeta));
    } else if (isInserting) {
      context.missing(_contractAddressMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(_currencyMeta,
          currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta));
    } else if (isInserting) {
      context.missing(_currencyMeta);
    }
    if (data.containsKey('price')) {
      context.handle(
          _priceMeta, price.isAcceptableOrUnknown(data['price']!, _priceMeta));
    } else if (isInserting) {
      context.missing(_priceMeta);
    }
    if (data.containsKey('change24h')) {
      context.handle(_change24hMeta,
          change24h.isAcceptableOrUnknown(data['change24h']!, _change24hMeta));
    }
    if (data.containsKey('time')) {
      context.handle(
          _timeMeta, time.isAcceptableOrUnknown(data['time']!, _timeMeta));
    } else if (isInserting) {
      context.missing(_timeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey =>
      {contractAddress, networkCode, currency};
  @override
  TokenPrice map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TokenPrice(
      networkCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}network_code'])!,
      contractAddress: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}contract_address'])!,
      currency: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}currency'])!,
      price: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}price'])!,
      change24h: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}change24h']),
      time: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}time'])!,
    );
  }

  @override
  $TokenPricesTable createAlias(String alias) {
    return $TokenPricesTable(attachedDatabase, alias);
  }
}

class TokenPricesCompanion extends UpdateCompanion<TokenPrice> {
  final Value<String> networkCode;
  final Value<String> contractAddress;
  final Value<String> currency;
  final Value<String> price;
  final Value<double?> change24h;
  final Value<DateTime> time;
  final Value<int> rowid;
  const TokenPricesCompanion({
    this.networkCode = const Value.absent(),
    this.contractAddress = const Value.absent(),
    this.currency = const Value.absent(),
    this.price = const Value.absent(),
    this.change24h = const Value.absent(),
    this.time = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TokenPricesCompanion.insert({
    required String networkCode,
    required String contractAddress,
    required String currency,
    required String price,
    this.change24h = const Value.absent(),
    required DateTime time,
    this.rowid = const Value.absent(),
  })  : networkCode = Value(networkCode),
        contractAddress = Value(contractAddress),
        currency = Value(currency),
        price = Value(price),
        time = Value(time);
  static Insertable<TokenPrice> custom({
    Expression<String>? networkCode,
    Expression<String>? contractAddress,
    Expression<String>? currency,
    Expression<String>? price,
    Expression<double>? change24h,
    Expression<DateTime>? time,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (networkCode != null) 'network_code': networkCode,
      if (contractAddress != null) 'contract_address': contractAddress,
      if (currency != null) 'currency': currency,
      if (price != null) 'price': price,
      if (change24h != null) 'change24h': change24h,
      if (time != null) 'time': time,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TokenPricesCompanion copyWith(
      {Value<String>? networkCode,
      Value<String>? contractAddress,
      Value<String>? currency,
      Value<String>? price,
      Value<double?>? change24h,
      Value<DateTime>? time,
      Value<int>? rowid}) {
    return TokenPricesCompanion(
      networkCode: networkCode ?? this.networkCode,
      contractAddress: contractAddress ?? this.contractAddress,
      currency: currency ?? this.currency,
      price: price ?? this.price,
      change24h: change24h ?? this.change24h,
      time: time ?? this.time,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (networkCode.present) {
      map['network_code'] = Variable<String>(networkCode.value);
    }
    if (contractAddress.present) {
      map['contract_address'] = Variable<String>(contractAddress.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (price.present) {
      map['price'] = Variable<String>(price.value);
    }
    if (change24h.present) {
      map['change24h'] = Variable<double>(change24h.value);
    }
    if (time.present) {
      map['time'] = Variable<DateTime>(time.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TokenPricesCompanion(')
          ..write('networkCode: $networkCode, ')
          ..write('contractAddress: $contractAddress, ')
          ..write('currency: $currency, ')
          ..write('price: $price, ')
          ..write('change24h: $change24h, ')
          ..write('time: $time, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$TokenDatabase extends GeneratedDatabase {
  _$TokenDatabase(QueryExecutor e) : super(e);
  $TokenDatabaseManager get managers => $TokenDatabaseManager(this);
  late final $TokensTable tokens = $TokensTable(this);
  late final $TokenHoldingsTable tokenHoldings = $TokenHoldingsTable(this);
  late final $TokenPricesTable tokenPrices = $TokenPricesTable(this);
  late final TokenDao tokenDao = TokenDao(this as TokenDatabase);
  late final TokenHolderDao tokenHolderDao =
      TokenHolderDao(this as TokenDatabase);
  late final TokenPriceDao tokenPriceDao = TokenPriceDao(this as TokenDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [tokens, tokenHoldings, tokenPrices];
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$TokensTableCreateCompanionBuilder = TokensCompanion Function({
  required String networkCode,
  required String contractAddress,
  required String symbol,
  required String name,
  required int decimals,
  required String iconUrl,
  Value<DateTime?> tokenCreated,
  Value<DateTime?> updatedAt,
  Value<int> rowid,
});
typedef $$TokensTableUpdateCompanionBuilder = TokensCompanion Function({
  Value<String> networkCode,
  Value<String> contractAddress,
  Value<String> symbol,
  Value<String> name,
  Value<int> decimals,
  Value<String> iconUrl,
  Value<DateTime?> tokenCreated,
  Value<DateTime?> updatedAt,
  Value<int> rowid,
});

class $$TokensTableFilterComposer
    extends Composer<_$TokenDatabase, $TokensTable> {
  $$TokensTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get networkCode => $composableBuilder(
      column: $table.networkCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get contractAddress => $composableBuilder(
      column: $table.contractAddress,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get symbol => $composableBuilder(
      column: $table.symbol, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get decimals => $composableBuilder(
      column: $table.decimals, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get iconUrl => $composableBuilder(
      column: $table.iconUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get tokenCreated => $composableBuilder(
      column: $table.tokenCreated, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$TokensTableOrderingComposer
    extends Composer<_$TokenDatabase, $TokensTable> {
  $$TokensTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get networkCode => $composableBuilder(
      column: $table.networkCode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get contractAddress => $composableBuilder(
      column: $table.contractAddress,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get symbol => $composableBuilder(
      column: $table.symbol, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get decimals => $composableBuilder(
      column: $table.decimals, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get iconUrl => $composableBuilder(
      column: $table.iconUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get tokenCreated => $composableBuilder(
      column: $table.tokenCreated,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$TokensTableAnnotationComposer
    extends Composer<_$TokenDatabase, $TokensTable> {
  $$TokensTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get networkCode => $composableBuilder(
      column: $table.networkCode, builder: (column) => column);

  GeneratedColumn<String> get contractAddress => $composableBuilder(
      column: $table.contractAddress, builder: (column) => column);

  GeneratedColumn<String> get symbol =>
      $composableBuilder(column: $table.symbol, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get decimals =>
      $composableBuilder(column: $table.decimals, builder: (column) => column);

  GeneratedColumn<String> get iconUrl =>
      $composableBuilder(column: $table.iconUrl, builder: (column) => column);

  GeneratedColumn<DateTime> get tokenCreated => $composableBuilder(
      column: $table.tokenCreated, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$TokensTableTableManager extends RootTableManager<
    _$TokenDatabase,
    $TokensTable,
    Token,
    $$TokensTableFilterComposer,
    $$TokensTableOrderingComposer,
    $$TokensTableAnnotationComposer,
    $$TokensTableCreateCompanionBuilder,
    $$TokensTableUpdateCompanionBuilder,
    (Token, BaseReferences<_$TokenDatabase, $TokensTable, Token>),
    Token,
    PrefetchHooks Function()> {
  $$TokensTableTableManager(_$TokenDatabase db, $TokensTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TokensTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TokensTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TokensTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> networkCode = const Value.absent(),
            Value<String> contractAddress = const Value.absent(),
            Value<String> symbol = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> decimals = const Value.absent(),
            Value<String> iconUrl = const Value.absent(),
            Value<DateTime?> tokenCreated = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TokensCompanion(
            networkCode: networkCode,
            contractAddress: contractAddress,
            symbol: symbol,
            name: name,
            decimals: decimals,
            iconUrl: iconUrl,
            tokenCreated: tokenCreated,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String networkCode,
            required String contractAddress,
            required String symbol,
            required String name,
            required int decimals,
            required String iconUrl,
            Value<DateTime?> tokenCreated = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TokensCompanion.insert(
            networkCode: networkCode,
            contractAddress: contractAddress,
            symbol: symbol,
            name: name,
            decimals: decimals,
            iconUrl: iconUrl,
            tokenCreated: tokenCreated,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TokensTableProcessedTableManager = ProcessedTableManager<
    _$TokenDatabase,
    $TokensTable,
    Token,
    $$TokensTableFilterComposer,
    $$TokensTableOrderingComposer,
    $$TokensTableAnnotationComposer,
    $$TokensTableCreateCompanionBuilder,
    $$TokensTableUpdateCompanionBuilder,
    (Token, BaseReferences<_$TokenDatabase, $TokensTable, Token>),
    Token,
    PrefetchHooks Function()>;
typedef $$TokenHoldingsTableCreateCompanionBuilder = TokenHoldingsCompanion
    Function({
  required String networkCode,
  required String contractAddress,
  required String holderAddress,
  required String balance,
  Value<DateTime?> updatedAt,
  Value<int> rowid,
});
typedef $$TokenHoldingsTableUpdateCompanionBuilder = TokenHoldingsCompanion
    Function({
  Value<String> networkCode,
  Value<String> contractAddress,
  Value<String> holderAddress,
  Value<String> balance,
  Value<DateTime?> updatedAt,
  Value<int> rowid,
});

class $$TokenHoldingsTableFilterComposer
    extends Composer<_$TokenDatabase, $TokenHoldingsTable> {
  $$TokenHoldingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get networkCode => $composableBuilder(
      column: $table.networkCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get contractAddress => $composableBuilder(
      column: $table.contractAddress,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get holderAddress => $composableBuilder(
      column: $table.holderAddress, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get balance => $composableBuilder(
      column: $table.balance, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$TokenHoldingsTableOrderingComposer
    extends Composer<_$TokenDatabase, $TokenHoldingsTable> {
  $$TokenHoldingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get networkCode => $composableBuilder(
      column: $table.networkCode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get contractAddress => $composableBuilder(
      column: $table.contractAddress,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get holderAddress => $composableBuilder(
      column: $table.holderAddress,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get balance => $composableBuilder(
      column: $table.balance, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$TokenHoldingsTableAnnotationComposer
    extends Composer<_$TokenDatabase, $TokenHoldingsTable> {
  $$TokenHoldingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get networkCode => $composableBuilder(
      column: $table.networkCode, builder: (column) => column);

  GeneratedColumn<String> get contractAddress => $composableBuilder(
      column: $table.contractAddress, builder: (column) => column);

  GeneratedColumn<String> get holderAddress => $composableBuilder(
      column: $table.holderAddress, builder: (column) => column);

  GeneratedColumn<String> get balance =>
      $composableBuilder(column: $table.balance, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$TokenHoldingsTableTableManager extends RootTableManager<
    _$TokenDatabase,
    $TokenHoldingsTable,
    TokenHolding,
    $$TokenHoldingsTableFilterComposer,
    $$TokenHoldingsTableOrderingComposer,
    $$TokenHoldingsTableAnnotationComposer,
    $$TokenHoldingsTableCreateCompanionBuilder,
    $$TokenHoldingsTableUpdateCompanionBuilder,
    (
      TokenHolding,
      BaseReferences<_$TokenDatabase, $TokenHoldingsTable, TokenHolding>
    ),
    TokenHolding,
    PrefetchHooks Function()> {
  $$TokenHoldingsTableTableManager(
      _$TokenDatabase db, $TokenHoldingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TokenHoldingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TokenHoldingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TokenHoldingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> networkCode = const Value.absent(),
            Value<String> contractAddress = const Value.absent(),
            Value<String> holderAddress = const Value.absent(),
            Value<String> balance = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TokenHoldingsCompanion(
            networkCode: networkCode,
            contractAddress: contractAddress,
            holderAddress: holderAddress,
            balance: balance,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String networkCode,
            required String contractAddress,
            required String holderAddress,
            required String balance,
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TokenHoldingsCompanion.insert(
            networkCode: networkCode,
            contractAddress: contractAddress,
            holderAddress: holderAddress,
            balance: balance,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TokenHoldingsTableProcessedTableManager = ProcessedTableManager<
    _$TokenDatabase,
    $TokenHoldingsTable,
    TokenHolding,
    $$TokenHoldingsTableFilterComposer,
    $$TokenHoldingsTableOrderingComposer,
    $$TokenHoldingsTableAnnotationComposer,
    $$TokenHoldingsTableCreateCompanionBuilder,
    $$TokenHoldingsTableUpdateCompanionBuilder,
    (
      TokenHolding,
      BaseReferences<_$TokenDatabase, $TokenHoldingsTable, TokenHolding>
    ),
    TokenHolding,
    PrefetchHooks Function()>;
typedef $$TokenPricesTableCreateCompanionBuilder = TokenPricesCompanion
    Function({
  required String networkCode,
  required String contractAddress,
  required String currency,
  required String price,
  Value<double?> change24h,
  required DateTime time,
  Value<int> rowid,
});
typedef $$TokenPricesTableUpdateCompanionBuilder = TokenPricesCompanion
    Function({
  Value<String> networkCode,
  Value<String> contractAddress,
  Value<String> currency,
  Value<String> price,
  Value<double?> change24h,
  Value<DateTime> time,
  Value<int> rowid,
});

class $$TokenPricesTableFilterComposer
    extends Composer<_$TokenDatabase, $TokenPricesTable> {
  $$TokenPricesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get networkCode => $composableBuilder(
      column: $table.networkCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get contractAddress => $composableBuilder(
      column: $table.contractAddress,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get currency => $composableBuilder(
      column: $table.currency, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get price => $composableBuilder(
      column: $table.price, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get change24h => $composableBuilder(
      column: $table.change24h, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get time => $composableBuilder(
      column: $table.time, builder: (column) => ColumnFilters(column));
}

class $$TokenPricesTableOrderingComposer
    extends Composer<_$TokenDatabase, $TokenPricesTable> {
  $$TokenPricesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get networkCode => $composableBuilder(
      column: $table.networkCode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get contractAddress => $composableBuilder(
      column: $table.contractAddress,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get currency => $composableBuilder(
      column: $table.currency, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get price => $composableBuilder(
      column: $table.price, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get change24h => $composableBuilder(
      column: $table.change24h, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get time => $composableBuilder(
      column: $table.time, builder: (column) => ColumnOrderings(column));
}

class $$TokenPricesTableAnnotationComposer
    extends Composer<_$TokenDatabase, $TokenPricesTable> {
  $$TokenPricesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get networkCode => $composableBuilder(
      column: $table.networkCode, builder: (column) => column);

  GeneratedColumn<String> get contractAddress => $composableBuilder(
      column: $table.contractAddress, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<String> get price =>
      $composableBuilder(column: $table.price, builder: (column) => column);

  GeneratedColumn<double> get change24h =>
      $composableBuilder(column: $table.change24h, builder: (column) => column);

  GeneratedColumn<DateTime> get time =>
      $composableBuilder(column: $table.time, builder: (column) => column);
}

class $$TokenPricesTableTableManager extends RootTableManager<
    _$TokenDatabase,
    $TokenPricesTable,
    TokenPrice,
    $$TokenPricesTableFilterComposer,
    $$TokenPricesTableOrderingComposer,
    $$TokenPricesTableAnnotationComposer,
    $$TokenPricesTableCreateCompanionBuilder,
    $$TokenPricesTableUpdateCompanionBuilder,
    (
      TokenPrice,
      BaseReferences<_$TokenDatabase, $TokenPricesTable, TokenPrice>
    ),
    TokenPrice,
    PrefetchHooks Function()> {
  $$TokenPricesTableTableManager(_$TokenDatabase db, $TokenPricesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TokenPricesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TokenPricesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TokenPricesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> networkCode = const Value.absent(),
            Value<String> contractAddress = const Value.absent(),
            Value<String> currency = const Value.absent(),
            Value<String> price = const Value.absent(),
            Value<double?> change24h = const Value.absent(),
            Value<DateTime> time = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TokenPricesCompanion(
            networkCode: networkCode,
            contractAddress: contractAddress,
            currency: currency,
            price: price,
            change24h: change24h,
            time: time,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String networkCode,
            required String contractAddress,
            required String currency,
            required String price,
            Value<double?> change24h = const Value.absent(),
            required DateTime time,
            Value<int> rowid = const Value.absent(),
          }) =>
              TokenPricesCompanion.insert(
            networkCode: networkCode,
            contractAddress: contractAddress,
            currency: currency,
            price: price,
            change24h: change24h,
            time: time,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TokenPricesTableProcessedTableManager = ProcessedTableManager<
    _$TokenDatabase,
    $TokenPricesTable,
    TokenPrice,
    $$TokenPricesTableFilterComposer,
    $$TokenPricesTableOrderingComposer,
    $$TokenPricesTableAnnotationComposer,
    $$TokenPricesTableCreateCompanionBuilder,
    $$TokenPricesTableUpdateCompanionBuilder,
    (
      TokenPrice,
      BaseReferences<_$TokenDatabase, $TokenPricesTable, TokenPrice>
    ),
    TokenPrice,
    PrefetchHooks Function()>;

class $TokenDatabaseManager {
  final _$TokenDatabase _db;
  $TokenDatabaseManager(this._db);
  $$TokensTableTableManager get tokens =>
      $$TokensTableTableManager(_db, _db.tokens);
  $$TokenHoldingsTableTableManager get tokenHoldings =>
      $$TokenHoldingsTableTableManager(_db, _db.tokenHoldings);
  $$TokenPricesTableTableManager get tokenPrices =>
      $$TokenPricesTableTableManager(_db, _db.tokenPrices);
}
