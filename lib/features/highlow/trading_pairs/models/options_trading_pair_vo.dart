import 'package:equatable/equatable.dart';
import 'package:finality/domain/options/entities/options_trading_pair_detail.dart';

/// 资产类型枚举

/// 资产 UI Model
class OptionsTradingPairVO extends Equatable {
  final String feedId;
  final String baseAsset;
  final String name;
  final String ticker; // 如 "BTC/USD"
  final String iconUrl;
  final String payout; // 如 "102%"
  final String multiplier; // 如 "1-900x"
  final String type;
  final bool isActive;
  final String? inactiveSinceTime; // 如 "14:00 UTC"

  const OptionsTradingPairVO({
    required this.feedId,
    required this.baseAsset,
    required this.name,
    required this.ticker,
    required this.iconUrl,
    required this.payout,
    required this.multiplier,
    required this.type,
    required this.isActive,
    this.inactiveSinceTime,
  });

  factory OptionsTradingPairVO.fromOptionsTradingPairDetail(
      OptionsTradingPairDetail detail) {
    return OptionsTradingPairVO(
      feedId: detail.pair.feedId,
      baseAsset: detail.pair.baseAsset,
      name: detail.pair.baseAssetName,
      ticker: detail.pair.pairName,
      iconUrl: detail.pair.iconUrl,
      payout: _formatPayout(detail.tick?.payout),
      multiplier:
          _formatMultiplier(detail.pair.leverageMin, detail.pair.leverageMax),
      type: detail.pair.type,
      isActive: detail.pair.isActive,
    );
  }

  static OptionsTradingPairVO placeholder = OptionsTradingPairVO(
    feedId: 'placeholder',
    baseAsset: 'btc',
    name: 'BTC',
    ticker: 'BTC/USD',
    iconUrl: 'btc',
    payout: '00%',
    multiplier: '1-100x',
    type: 'crypto',
    isActive: true,
  );

  static String _formatPayout(double? payout) {
    if (payout == null) {
      return '0%';
    }
    return '${(payout * 100).toStringAsFixed(0)}%';
  }

  static String _formatMultiplier(int leverageMin, int leverageMax) {
    return '$leverageMin-${leverageMax}x';
  }

  @override
  List<Object?> get props => [
        feedId,
        baseAsset,
        name,
        ticker,
        iconUrl,
        payout,
        multiplier,
        type,
        isActive,
        inactiveSinceTime
      ];
}
