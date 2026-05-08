import 'package:equatable/equatable.dart';

class OptionsTradingPairTick extends Equatable {
  final String feedId;
  final String baseAsset;
  final double payout;
  final String price;
  final int timestamp;

  const OptionsTradingPairTick(
      {required this.feedId,
      required this.baseAsset,
      required this.payout,
      required this.price,
      required this.timestamp});

  @override
  List<Object?> get props => [feedId, baseAsset, payout, price, timestamp];
}
