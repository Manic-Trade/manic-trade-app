import 'package:dart_extensions_methods/dart_extension_methods.dart';
import 'package:drift/drift.dart';
import 'package:equatable/equatable.dart';

import '../token_database.dart';

class TokenPrice extends DataClass
    with EquatableMixin
    implements Insertable<TokenPrice> {
  final String networkCode;
  final String contractAddress;
  final String currency;
  final String price;
  final double? change24h;
  final DateTime time;
  const TokenPrice(
      {required this.networkCode,
      required this.contractAddress,
      required this.currency,
      required this.price,
      this.change24h,
      required this.time});

  bool isSame(TokenPrice other) {
    return contractAddress == other.contractAddress &&
        networkCode == other.networkCode &&
        currency == other.currency;
  }

  bool isNewer(TokenPrice? before) {
    if (before == null) {
      return true;
    }
    return (time.isAfter(before.time) &&
        (price != before.price || change24h != before.change24h));
  }

  TokenPrice mergePrice(TokenPrice? local) {
    var item = this;
    if (local == null) {
      return item;
    }
    double? change24h;
    if (item.change24h == null && local.change24h != null) {
      var oldPrice = local.price.toDoubleOrNull();
      var oldChange24h = local.change24h!;
      var newPrice = item.price.toDoubleOrNull();
      if (oldPrice == null || newPrice == null) {
        return item;
      }

      // 通过老价格和老涨跌幅计算24小时前价格
      var price24hAgo = oldPrice / (1 + oldChange24h / 100);

      // 用新价格和24小时前价格计算新的24小时涨跌幅
      change24h = (newPrice - price24hAgo) / price24hAgo * 100;
    }

    if (item.change24h == null && change24h != null) {
      return item.copyWith(
        price: item.price,
        change24h: Value(change24h),
      );
    }
    return item;
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['network_code'] = Variable<String>(networkCode);
    map['contract_address'] = Variable<String>(contractAddress);
    map['currency'] = Variable<String>(currency);
    map['price'] = Variable<String>(price);
    if (!nullToAbsent || change24h != null) {
      map['change24h'] = Variable<double>(change24h);
    }
    map['time'] = Variable<DateTime>(time);
    return map;
  }

  TokenPricesCompanion toCompanion(bool nullToAbsent) {
    return TokenPricesCompanion(
      networkCode: Value(networkCode),
      contractAddress: Value(contractAddress),
      currency: Value(currency),
      price: Value(price),
      change24h: change24h == null && nullToAbsent
          ? const Value.absent()
          : Value(change24h),
      time: Value(time),
    );
  }

  factory TokenPrice.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TokenPrice(
      networkCode: serializer.fromJson<String>(json['networkCode']),
      contractAddress: serializer.fromJson<String>(json['contractAddress']),
      currency: serializer.fromJson<String>(json['currency']),
      price: serializer.fromJson<String>(json['price']),
      change24h: serializer.fromJson<double?>(json['change24h']),
      time: serializer.fromJson<DateTime>(json['time']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'networkCode': serializer.toJson<String>(networkCode),
      'contractAddress': serializer.toJson<String>(contractAddress),
      'currency': serializer.toJson<String>(currency),
      'price': serializer.toJson<String>(price),
      'change24h': serializer.toJson<double?>(change24h),
      'time': serializer.toJson<DateTime>(time),
    };
  }

  TokenPrice copyWith(
          {String? networkCode,
          String? contractAddress,
          String? currency,
          String? price,
          Value<double?> change24h = const Value.absent(),
          DateTime? time}) =>
      TokenPrice(
        networkCode: networkCode ?? this.networkCode,
        contractAddress: contractAddress ?? this.contractAddress,
        currency: currency ?? this.currency,
        price: price ?? this.price,
        change24h: change24h.present ? change24h.value : this.change24h,
        time: time ?? this.time,
      );
  TokenPrice copyWithCompanion(TokenPricesCompanion data) {
    return TokenPrice(
      networkCode:
          data.networkCode.present ? data.networkCode.value : networkCode,
      contractAddress: data.contractAddress.present
          ? data.contractAddress.value
          : contractAddress,
      currency: data.currency.present ? data.currency.value : currency,
      price: data.price.present ? data.price.value : price,
      change24h: data.change24h.present ? data.change24h.value : change24h,
      time: data.time.present ? data.time.value : time,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TokenPrice(')
          ..write('networkCode: $networkCode, ')
          ..write('contractAddress: $contractAddress, ')
          ..write('currency: $currency, ')
          ..write('price: $price, ')
          ..write('change24h: $change24h, ')
          ..write('time: $time')
          ..write(')'))
        .toString();
  }

  @override
  List<Object?> get props => [
        contractAddress,
        networkCode,
        currency.toUpperCase(),
        price,
        change24h,
        time
      ];
}
