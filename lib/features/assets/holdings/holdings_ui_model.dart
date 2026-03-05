import 'package:finality/data/model/token_position.dart';

class CashTokenPostions {
  final List<TokenPosition> tokenPositions;
  final double totalValue;

  CashTokenPostions({required this.tokenPositions, required this.totalValue});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CashTokenPostions &&
          runtimeType == other.runtimeType &&
          tokenPositions == other.tokenPositions &&
          totalValue == other.totalValue;

  @override
  int get hashCode => Object.hash(tokenPositions, totalValue);
}
