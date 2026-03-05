import 'package:equatable/equatable.dart';

class TokenUnit extends Equatable {
  final String symbol;
  final int decimals;

  const TokenUnit(this.symbol, this.decimals);

  @override
  List<Object> get props => [symbol, decimals];
}