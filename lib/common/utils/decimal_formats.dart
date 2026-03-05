import 'package:decimal/decimal.dart';
import 'package:flexi_formatter/flexi_formatter.dart' as flexi;
import 'package:intl/intl.dart';

extension DecimalFormats on num {
  static final _superBigChangeFormat = NumberFormat()
    ..maximumFractionDigits = 1;
  static final _bigChangeFormat = NumberFormat()..maximumFractionDigits = 2;
  static final _smallChangeFormat = NumberFormat('0.00');

  String formatAsChange() {
    var value = this;
    String format;

    if (value.abs() >= 1000000000000000) {
      // Q - 千万亿
      format = '${_superBigChangeFormat.format(value / 1000000000000000)}Q';
    } else if (value.abs() >= 1000000000000) {
      // T - 万亿
      format = '${_superBigChangeFormat.format(value / 1000000000000)}T';
    } else if (value.abs() >= 1000000000) {
      // B - 十亿
      format = '${_superBigChangeFormat.format(value / 1000000000)}B';
    } else if (value.abs() >= 1000000) {
      // M - 百万
      format = '${_superBigChangeFormat.format(value / 1000000)}M';
    } else if (value.abs() >= 1000) {
      // k - 千
      format = '${_superBigChangeFormat.format(value / 1000)}K';
    } else if (value.abs() >= 10) {
      format = _bigChangeFormat.format(value);
    } else {
      format = _smallChangeFormat.format(value);
    }
    if (value < 0 && format.startsWith("-100")) {
      format = "-99.99";
    }

    final chgString = (value >= 0) ? '+$format' : format;
    return '$chgString%';
  }

  String formatNum({String? symbol}) {
    final num = this;
    if (num == 0) {
      return symbol != null ? "${symbol}0" : "0";
    }
    if (num.isNaN) {
      return "--";
    }

    Decimal? decimal;
    if (num is int) {
      decimal = Decimal.fromInt(num);
    } else {
      decimal = Decimal.tryParse(num.toString());
    }
    if (decimal == null) {
      return "--";
    }
    var locale = Intl.getCurrentLocale();
    var isZh = locale.contains('zh');
    var formatNumber = flexi.formatNumber(
      decimal,
      precision: 2,
      cutInvalidZero: true,
      prefix: symbol ?? '',
      enableCompact: true,
      compactConverter: isZh ? flexi.simplifiedChineseCompactConverter : null,
    );
    return formatNumber;

    // String formatString;
    // final format = NumberFormat();
    // format.maximumFractionDigits = 2;
    // if (num < 1000) {
    //   formatString = format.format(num);
    // } else if (num < 1000000) {
    //   formatString = "${format.format(num / 1000)}K";
    // } else if (num < 1000000000) {
    //   formatString = "${format.format(num / 1000000)}M";
    // } else if (num < 1000000000000) {
    //   formatString = "${format.format(num / 1000000000)}B";
    // } else if (num < 1000000000000000) {
    //   formatString = "${format.format(num / 1000000000000)}T";
    // } else if (num < 1000000000000000000) {
    //   formatString = "${format.format(num / 1000000000000000)}Q";
    // } else {
    //   format.maximumFractionDigits = 0;
    //   formatString =
    //       "${format.format(num / 1000000000000000000)}S"; // Added support for Sextillions
    // }

    // return symbol != null ? "$symbol$formatString" : formatString;
  }
}
