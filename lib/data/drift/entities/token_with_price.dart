
import 'package:equatable/equatable.dart';

import 'token.dart';
import 'token_price.dart';


class TokenWithPrice extends Equatable {
  final Token token;
  final TokenPrice price;

  const TokenWithPrice(this.token, this.price);

  @override
  List<Object?> get props => [token, price];
}
