import 'dart:math';

import 'package:decimal/decimal.dart';

extension DecimalFormat on num {
  /// 格式化数字，保留指定的小数位数
  String formatWithDecimals(int decimals,
      {String? symbol, int? validDecimals = 4}) {
    if (this == 0) {
      return symbol != null ? "0 $symbol" : "0";
    }
    final decimal = Decimal.parse(toString());
    return decimal.formatWithDecimals(decimals,
        symbol: symbol, validDecimals: validDecimals);
  }

  /// Converts a decimal string to a BigInt based on the given decimals
  /// Example:
  /// - "1.23".toBigIntWithDecimals(6) => 1230000
  /// - "0.000123".toBigIntWithDecimals(6) => 123
  /// - "1".toBigIntWithDecimals(6) => 1000000
  BigInt toBigIntWithDecimals(int decimals) {
    if (this == 0) return BigInt.zero;
    // 获取数值的以10为底的对数，即数值的位数
    final magnitude = (log(abs()) / ln10).floor();
    // 如果 数值的位数 + decimals 接近 double.maxFinite 的限制(308)，就使用 Decimal 进行计算
    if (magnitude + decimals > 308) {
      final decimal = Decimal.parse(toString()).toRational();
      final multiplier = Decimal.ten.pow(decimals);
      return (decimal * multiplier).toBigInt();
    } else {
      // 在安全范围内可以使用 pow
      final multiplier = pow(10, decimals);
      return BigInt.from((this * multiplier).round());
    }
  }

  /// Converts a number to a decimal by dividing it by 10^decimals
  /// Example:
  /// - 1230000.fromNumWithDecimals(6) => 1.23
  /// - 123.fromNumWithDecimals(6) => 0.000123
  /// - 1000000.fromNumWithDecimals(6) => 1.0
  double divByDecimals(int decimals) {
    if (this == 0) return 0;
    if (decimals < 0) return toDouble(); // 防止负数精度
    if (decimals > 308) {
      // double.maxFinite 的指数限制是 308
      return 0; // 或者抛出异常，取决于业务需求
    }
    return this / pow(10, decimals);
  }

  /// Converts a number to a decimal by dividing it by 10^decimals and then formats it
  /// Example:
  /// - 1230000.fromNumWithDecimals(6) => "1.23"
  /// - 123.fromNumWithDecimals(6) => "0.000123"
  /// - 1000000.fromNumWithDecimals(6) => "1"
  String divAndFormat(int decimals, {String? symbol}) {
    return divByDecimals(decimals).formatWithDecimals(decimals, symbol: symbol);
  }
}

extension DecimalStringFormat on String {
  /// 格式化数字，保留指定的小数位数
  String formatWithDecimals(int decimals,
      {String? symbol, int? validDecimals = 4}) {
    var decimal = Decimal.tryParse(this);
    if (decimal != null) {
      return decimal.formatWithDecimals(decimals,
          symbol: symbol, validDecimals: validDecimals);
    } else {
      return symbol != null ? "$this $symbol" : this;
    }
  }

  /// Converts a decimal string to a BigInt based on the given decimals
  /// Example:
  /// - "1.23".toBigIntWithDecimals(6) => 1230000
  /// - "0.000123".toBigIntWithDecimals(6) => 123
  /// - "1".toBigIntWithDecimals(6) => 1000000
  BigInt toBigIntWithDecimals(int decimals) {
    if (isEmpty) return BigInt.zero;
    final decimal = Decimal.parse(this).toRational();
    final multiplier = Decimal.ten.pow(decimals);
    return (decimal * multiplier).toBigInt();
  }

  /// Converts a decimal string to a decimal by dividing it by 10^decimals
  /// Example:
  /// - "1.23".divByDecimals(6) => "0.00123"
  /// - "0.000123".divByDecimals(6) => "0.000000123"
  /// - "1".divByDecimals(6) => "0.000001"
  String divByDecimals(int decimals) {
    return _divAndFormatInternal(decimals, format: false);
  }

  /// Converts a decimal string to a decimal by dividing it by 10^decimals and then formats it
  /// Example:
  /// - "1.23".divAndFormat(6) => "0.00123"
  /// - "0.000123".divAndFormat(6) => "0.000000123"
  /// - "1".divAndFormat(6) => "0.000001"
  String divAndFormat(int decimals, {String? symbol}) {
    return _divAndFormatInternal(decimals, format: true, symbol: symbol);
  }

  String _divAndFormatInternal(int decimals,
      {bool format = false, String? symbol}) {
    if (isEmpty) return "0";
    if (this == "0") return "0";
    if (decimals < 0) return this; // 防止负数精度
    if (format) {
      return Decimal.parse(this)
          .divByDecimals(decimals)
          .formatWithDecimals(decimals, symbol: symbol, validDecimals: null);
    } else {
      return Decimal.parse(this).divByDecimals(decimals).toString();
    }
  }
}

extension DecimalDecimalFormat on Decimal {
  String formatWithDecimals(int decimals,
      {String? symbol, int? validDecimals = 4}) {
    if (this == Decimal.zero) {
      return symbol != null ? "0 $symbol" : "0";
    }

    // 当数字大于1且设置了maxDecimalsWhenGreaterThanOne时，使用较小的小数位数
    int effectiveDecimals = decimals;
    if (abs() >= Decimal.one && validDecimals != null) {
      effectiveDecimals = min(decimals, validDecimals);
    }

    if (scale > effectiveDecimals) {
      return symbol != null
          ? "${truncate(scale: effectiveDecimals)} $symbol"
          : truncate(scale: effectiveDecimals).toString();
    } else {
      return symbol != null ? "$this $symbol" : toString();
    }
  }

  /// Converts a decimal string to a decimal by dividing it by 10^decimals
  /// Example:
  /// - "1.23".divByDecimals(6) => "0.00123"
  /// - "0.000123".divByDecimals(6) => "0.000000123"
  /// - "1".divByDecimals(6) => "0.000001"
  Decimal divByDecimals(int decimals) {
    var rational = toRational() / Decimal.ten.pow(decimals);
    return rational.toDecimal(scaleOnInfinitePrecision: decimals);
  }

  /// Converts a decimal string to a decimal by dividing it by 10^decimals and then formats it
  /// Example:
  /// - "1.23".divAndFormat(6) => "0.00123"
  /// - "0.000123".divAndFormat(6) => "0.000000123"
  /// - "1".divAndFormat(6) => "0.000001"
  String divAndFormat(int decimals, {String? symbol}) {
    return divByDecimals(decimals).formatWithDecimals(decimals, symbol: symbol);
  }
}

extension DoubleFormat on double {
  /// 格式化 double，去除末尾多余的 0
  /// 例如：
  /// - 1.2300 -> "1.23"
  /// - 1.0000 -> "1"
  /// - 1.2000 -> "1.2"
  String noEndZero() {
    String str = toString();
    return Decimal.parse(str).toString();
  }
}
