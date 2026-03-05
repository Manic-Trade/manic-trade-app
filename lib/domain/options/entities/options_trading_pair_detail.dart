import 'package:equatable/equatable.dart';
import 'package:finality/data/drift/options_database.dart';
import 'package:finality/domain/options/entities/options_trading_pair_tick.dart';

class OptionsTradingPairDetail extends Equatable {
  final OptionsTradingPair pair;
  final OptionsTradingPairTick? tick;

  const OptionsTradingPairDetail({required this.pair, this.tick});

  @override
  List<Object?> get props => [pair, tick];
}
