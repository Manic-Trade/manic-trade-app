import 'package:deriv_chart/deriv_chart.dart';
import 'package:finality/data/network/model/manic/candle_response.dart';
import 'package:finality/data/socket/manic/manic_price_data.dart';

extension CandleItemToCandleMapper on CandleItem {
  Candle toDerivCandle() {
    return Candle(
      epoch: timestamp * 1000,
      open: open,
      high: high,
      low: low,
      close: close,
      currentEpoch: null,
    );
  }
}

extension ManicPriceDataToCandleMapper on ManicPriceData {
  Candle toDerivCandle() {
    return Candle(
      epoch: timestamp * 1000,
      open: open,
      high: high,
      low: low,
      close: close,
      currentEpoch: beat * 1000,
    );
  }
}
