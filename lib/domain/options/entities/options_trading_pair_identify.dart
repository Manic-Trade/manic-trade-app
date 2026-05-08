import 'package:equatable/equatable.dart';

class OptionsTradingPairIdentify extends Equatable {
  final String feedId;
  final String baseAsset;

  const OptionsTradingPairIdentify(
      {required this.feedId, required this.baseAsset});

  @override
  List<Object?> get props => [feedId, baseAsset];

  static OptionsTradingPairIdentify? fromSerialized(String serialized) {
    if (serialized.isEmpty) {
      return null;
    }
    final parts = serialized.split('-');
    if (parts.length != 2) {
      return null;
    }
    return OptionsTradingPairIdentify(
      feedId: parts[0],
      baseAsset: parts[1],
    );
  }

  String toSerialized() {
    return '$feedId-$baseAsset';
  }

  @override
  String toString() {
    return '$feedId-$baseAsset';
  }

  static const defaultPair = OptionsTradingPairIdentify(
      feedId:
          'e62df6c8b4a85fe1a67db44dc12de5db330f7ac66b72dc658afedf0f4a415b43',
      baseAsset: 'btc');
}
