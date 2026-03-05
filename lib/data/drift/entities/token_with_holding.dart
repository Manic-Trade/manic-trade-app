import 'package:equatable/equatable.dart';

import 'token.dart';
import 'token_holding.dart';

class TokenWithHolding extends Equatable {
  final Token token;
  final TokenHolding holding;

  const TokenWithHolding(this.token, this.holding);

  @override
  List<Object?> get props => [token, holding];
}
