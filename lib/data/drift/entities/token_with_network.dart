import 'package:equatable/equatable.dart';
import 'package:finality/data/drift/entities/network.dart';

import 'token.dart';



class TokenWithNetwork extends Equatable {
  final Token token;
  final Network network;

  const TokenWithNetwork(this.token, this.network);

  @override
  List<Object> get props => [token, network];
}