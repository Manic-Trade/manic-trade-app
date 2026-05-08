import 'package:drift/drift.dart';
import 'package:finality/data/drift/token_database.dart';

class TokenHolding extends DataClass implements Insertable<TokenHolding> {
  final String networkCode;
  final String contractAddress;
  final String holderAddress;
  final String balance;
  final DateTime? updatedAt;
  const TokenHolding(
      {required this.networkCode,
      required this.contractAddress,
      required this.holderAddress,
      required this.balance,
      this.updatedAt});

  const TokenHolding.createDefault(
      this.networkCode, this.contractAddress, this.holderAddress)
      : balance = "0",
        updatedAt = null;

  bool isSame(TokenHolding other) {
    return contractAddress == other.contractAddress &&
        networkCode == other.networkCode &&
        holderAddress == other.holderAddress;
  }

  bool isNewer(TokenHolding? before) {
    if (before == null) {
      return true;
    }
    var updatedTime = updatedAt;
    if (updatedTime != null) {
      return (before.updatedAt == null ||
          (updatedTime.isAfter(before.updatedAt!) &&
              balance != before.balance));
    }
    if (before.updatedAt != null) {
      return false;
    }
    return balance != before.balance;
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['network_code'] = Variable<String>(networkCode);
    map['contract_address'] = Variable<String>(contractAddress);
    map['holder_address'] = Variable<String>(holderAddress);
    map['balance'] = Variable<String>(balance);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  TokenHoldingsCompanion toCompanion(bool nullToAbsent) {
    return TokenHoldingsCompanion(
      networkCode: Value(networkCode),
      contractAddress: Value(contractAddress),
      holderAddress: Value(holderAddress),
      balance: Value(balance),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory TokenHolding.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TokenHolding(
      networkCode: serializer.fromJson<String>(json['networkCode']),
      contractAddress: serializer.fromJson<String>(json['contractAddress']),
      holderAddress: serializer.fromJson<String>(json['holderAddress']),
      balance: serializer.fromJson<String>(json['balance']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'networkCode': serializer.toJson<String>(networkCode),
      'contractAddress': serializer.toJson<String>(contractAddress),
      'holderAddress': serializer.toJson<String>(holderAddress),
      'balance': serializer.toJson<String>(balance),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  TokenHolding copyWith(
          {String? networkCode,
          String? contractAddress,
          String? holderAddress,
          String? balance,
          Value<DateTime?> updatedAt = const Value.absent()}) =>
      TokenHolding(
        networkCode: networkCode ?? this.networkCode,
        contractAddress: contractAddress ?? this.contractAddress,
        holderAddress: holderAddress ?? this.holderAddress,
        balance: balance ?? this.balance,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
      );
  TokenHolding copyWithCompanion(TokenHoldingsCompanion data) {
    return TokenHolding(
      networkCode:
          data.networkCode.present ? data.networkCode.value : networkCode,
      contractAddress: data.contractAddress.present
          ? data.contractAddress.value
          : contractAddress,
      holderAddress: data.holderAddress.present
          ? data.holderAddress.value
          : holderAddress,
      balance: data.balance.present ? data.balance.value : balance,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TokenHolding(')
          ..write('networkCode: $networkCode, ')
          ..write('contractAddress: $contractAddress, ')
          ..write('holderAddress: $holderAddress, ')
          ..write('balance: $balance, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(networkCode, contractAddress, holderAddress, balance);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TokenHolding &&
          other.networkCode == networkCode &&
          other.contractAddress == contractAddress &&
          other.holderAddress == holderAddress &&
          other.balance == balance);
}
