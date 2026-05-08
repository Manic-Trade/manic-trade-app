import 'package:equatable/equatable.dart';
import 'package:finality/data/drift/entities/token_holding.dart';
import 'package:finality/data/drift/entities/token_price.dart';

// ignore: must_be_immutable
class TokenHoldingPrice extends Equatable {
  final TokenHolding holding;
  final TokenPrice? price;

  TokenHoldingPrice(this.holding, this.price);

  double? _currencyValue;

  /// 获取代币的货币价值
  /// 如果持有量为0或价格为null，返回0
  double get currencyValue {
    if (_currencyValue != null) return _currencyValue!;
    var balance = double.tryParse(holding.balance) ?? 0;
    if (balance == 0 || price == null) {
      _currencyValue = 0;
      return 0;
    }

    var priceDouble = double.tryParse(price!.price) ?? 0;
    _currencyValue = balance * priceDouble;
    return _currencyValue!;
  }

  TokenHoldingPrice copyWith({
    TokenHolding? holding,
    TokenPrice? price,
  }) {
    return TokenHoldingPrice(
      holding ?? this.holding,
      price ?? this.price,
    );
  }

  @override
  List<Object?> get props => [holding, price];
}
