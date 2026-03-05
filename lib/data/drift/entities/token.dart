import 'package:drift/drift.dart';
import 'package:finality/common/utils/token_utils.dart';
import 'package:finality/data/drift/token_database.dart';

class Token extends DataClass implements Insertable<Token> {
  final String networkCode;
  final String contractAddress;
  final String symbol;
  final String name;
  final int decimals;
  final String iconUrl;
  final DateTime? tokenCreated;
  final DateTime? updatedAt;
  const Token(
      {required this.networkCode,
      required this.contractAddress,
      required this.symbol,
      required this.name,
      required this.decimals,
      required this.iconUrl,
      this.tokenCreated,
      this.updatedAt});

  bool get isNativeToken => TokenUtils.isNativeTokenAddress(contractAddress);

  bool get isStablecoin =>
      TokenUtils.isStablecoinAddress(networkCode, contractAddress);

  bool get isUsdt => TokenUtils.isUsdt(networkCode, contractAddress);

  bool get isUsdc => TokenUtils.isUsdc(networkCode, contractAddress);

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['network_code'] = Variable<String>(networkCode);
    map['contract_address'] = Variable<String>(contractAddress);
    map['symbol'] = Variable<String>(symbol);
    map['name'] = Variable<String>(name);
    map['decimals'] = Variable<int>(decimals);
    map['icon_url'] = Variable<String>(iconUrl);
    if (!nullToAbsent || tokenCreated != null) {
      map['token_created'] = Variable<DateTime>(tokenCreated);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  TokensCompanion toCompanion(bool nullToAbsent) {
    return TokensCompanion(
      networkCode: Value(networkCode),
      contractAddress: Value(contractAddress),
      symbol: Value(symbol),
      name: Value(name),
      decimals: Value(decimals),
      iconUrl: Value(iconUrl),
      tokenCreated: tokenCreated == null && nullToAbsent
          ? const Value.absent()
          : Value(tokenCreated),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory Token.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Token(
      networkCode: serializer.fromJson<String>(json['networkCode']),
      contractAddress: serializer.fromJson<String>(json['contractAddress']),
      symbol: serializer.fromJson<String>(json['symbol']),
      name: serializer.fromJson<String>(json['name']),
      decimals: serializer.fromJson<int>(json['decimals']),
      iconUrl: serializer.fromJson<String>(json['iconUrl']),
      tokenCreated: serializer.fromJson<DateTime?>(json['tokenCreated']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'networkCode': serializer.toJson<String>(networkCode),
      'contractAddress': serializer.toJson<String>(contractAddress),
      'symbol': serializer.toJson<String>(symbol),
      'name': serializer.toJson<String>(name),
      'decimals': serializer.toJson<int>(decimals),
      'iconUrl': serializer.toJson<String>(iconUrl),
      'tokenCreated': serializer.toJson<DateTime?>(tokenCreated),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  Token copyWith(
          {String? networkCode,
          String? contractAddress,
          String? symbol,
          String? name,
          int? decimals,
          String? iconUrl,
          Value<DateTime?> tokenCreated = const Value.absent(),
          Value<DateTime?> updatedAt = const Value.absent()}) =>
      Token(
        networkCode: networkCode ?? this.networkCode,
        contractAddress: contractAddress ?? this.contractAddress,
        symbol: symbol ?? this.symbol,
        name: name ?? this.name,
        decimals: decimals ?? this.decimals,
        iconUrl: iconUrl ?? this.iconUrl,
        tokenCreated:
            tokenCreated.present ? tokenCreated.value : this.tokenCreated,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
      );
  Token copyWithCompanion(TokensCompanion data) {
    return Token(
      networkCode:
          data.networkCode.present ? data.networkCode.value : networkCode,
      contractAddress: data.contractAddress.present
          ? data.contractAddress.value
          : contractAddress,
      symbol: data.symbol.present ? data.symbol.value : symbol,
      name: data.name.present ? data.name.value : name,
      decimals: data.decimals.present ? data.decimals.value : decimals,
      iconUrl: data.iconUrl.present ? data.iconUrl.value : iconUrl,
      tokenCreated: data.tokenCreated.present
          ? data.tokenCreated.value
          : tokenCreated,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Token(')
          ..write('networkCode: $networkCode, ')
          ..write('contractAddress: $contractAddress, ')
          ..write('symbol: $symbol, ')
          ..write('name: $name, ')
          ..write('decimals: $decimals, ')
          ..write('iconUrl: $iconUrl, ')
          ..write('tokenCreated: $tokenCreated, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(networkCode, contractAddress, symbol, name,
      decimals, iconUrl, tokenCreated);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Token &&
          other.networkCode == networkCode &&
          other.contractAddress == contractAddress &&
          other.symbol == symbol &&
          other.name == name &&
          other.decimals == decimals &&
          other.iconUrl == iconUrl &&
          other.tokenCreated == tokenCreated);
}
