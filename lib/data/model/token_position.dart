import 'package:equatable/equatable.dart';
import 'package:finality/data/drift/entities/token.dart';
import 'package:finality/data/realtime/model/token_holding_price.dart';

class TokenPosition extends Equatable {
  final Token token;
  final TokenHoldingPrice holdingPrice;

  const TokenPosition(this.token, this.holdingPrice);

  @override
  List<Object?> get props => [token, holdingPrice];
}
