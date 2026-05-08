import 'package:equatable/equatable.dart';
import 'package:finality/data/drift/entities/token.dart';
import 'package:finality/data/drift/entities/token_with_network.dart';
import 'package:finality/data/realtime/model/token_holding_price.dart';


class TokenAsset extends Equatable {
  final Token token;
  final TokenHoldingPrice holdingPrice;

  const TokenAsset(this.token, this.holdingPrice);

  @override
  List<Object?> get props => [token, holdingPrice];
}

class TokenNetWorkAsset extends Equatable {
  final TokenWithNetwork tokenNetwork;
  final TokenHoldingPrice holdingPrice;

  const TokenNetWorkAsset(this.tokenNetwork, this.holdingPrice);

  @override
  List<Object?> get props => [tokenNetwork, holdingPrice];
}
