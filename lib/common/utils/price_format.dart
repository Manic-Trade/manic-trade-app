import 'package:decimal/decimal.dart';
import 'package:intl/intl.dart';
import 'package:decimal/intl.dart';

extension PriceFormat on num {
  /// 智能格式化数字，对过小的数字进行显示优化
  ///
  /// [significantDigits] 有效小数位数，默认为4
  String formatPrice({
    bool fillZeros = false,
    String? currencySymbol,
    int significantDigits = 2,
  }) {
    return Decimal.parse(toString()).formatPrice(
      fillZeros: fillZeros,
      currencySymbol: currencySymbol,
      significantDigits: significantDigits,
    );
  }

  /// 获取价格显示的合适精度
  ///
  /// 规则：小数点后连续0的个数 + 有效数字的个数
  int getPrecision({int maxSignificantDigits = 4}) {
    return Decimal.parse(toString())
        .getPrecision(maxSignificantDigits: maxSignificantDigits);
  }
}

extension PriceStringFormat on String {
  /// 智能格式化数字，对过小的数字进行显示优化
  ///
  /// [significantDigits] 有效小数位数，默认为4
  String formatPrice({
    bool fillZeros = false,
    String? currencySymbol,
    int significantDigits = 2,
  }) {
    try {
      return Decimal.parse(trim()).formatPrice(
        fillZeros: fillZeros,
        currencySymbol: currencySymbol,
        significantDigits: significantDigits,
      );
    } catch (_) {
      return this;
    }
  }

  /// 获取价格显示的合适精度
  ///
  /// 规则：小数点后连续0的个数 + 有效数字的个数
  int getPrecision({int maxSignificantDigits = 4}) {
    try {
      return Decimal.parse(trim())
          .getPrecision(maxSignificantDigits: maxSignificantDigits);
    } catch (_) {
      return maxSignificantDigits;
    }
  }
}

/// Decimal 类型的扩展方法
extension DecimalPriceFormat on Decimal {
  static final smallNumChats = [
    "₀",
    "₁",
    "₂",
    "₃",
    "₄",
    "₅",
    "₆",
    "₇",
    "₈",
    "₉"
  ];

  static DecimalFormatter _makeFormatter(int digits, {bool fillZeros = false}) {
    return DecimalFormatter(NumberFormat()
      ..maximumFractionDigits = digits
      ..minimumFractionDigits = fillZeros ? digits : 0);
  }

  String formatPrice({
    bool fillZeros = false,
    String? currencySymbol,
    int significantDigits = 2,
  }) {
    // 处理负数情况
    bool isNegative = this < Decimal.zero;
    String formattedNumber = (isNegative ? -this : this)
        ._formatPrice(fillZeros: fillZeros, significantDigits: significantDigits);

    // 添加负号和货币符号
    if (currencySymbol != null) {
      formattedNumber = "$currencySymbol$formattedNumber";
    }
    return isNegative ? "-$formattedNumber" : formattedNumber;
  }

  /// 智能格式化数字，对过小的数字进行显示优化
  ///
  /// [significantDigits] 有效小数位数，默认为4
  ///
  /// 格式化规则：
  /// - 对于大于1的数字，保留最多 [significantDigits] 位小数
  /// - 对于极小的数字，显示格式为：0.0ₙ{0之后的最后 [significantDigits] 位}，其中n表示0的个数（使用下标数字表示）
  ///
  /// Example:
  /// ```dart
  /// 0.00000234.formatPrice() // returns "0.0₅234"
  /// 0.0000000000234.formatPrice() // returns "0.0₁₀234"
  /// 1.23456.formatPrice()    // returns "1.2346"
  /// ```
  String _formatPrice({bool fillZeros = false, int significantDigits = 2}) {
    if (this == Decimal.zero) {
      return "0";
    }
    if (this == Decimal.one) {
      return "1";
    }

    if (this > Decimal.one) {
      return _makeFormatter(significantDigits, fillZeros: fillZeros)
          .format(this);
    }

    // 获取字符串表示，Decimal 默认就是非科学计数法格式
    var nonScientificString = toString();
    final decimalIndex = nonScientificString.indexOf(".");

    if (decimalIndex <= 0) {
      return _makeFormatter(significantDigits, fillZeros: fillZeros)
          .format(this);
    }

    // 获取小数部分
    final decimalPart = nonScientificString.substring(decimalIndex + 1);
    //找到小数部分第一个不为0的数字
    final indexOfFirstNonZero = decimalPart.indexOf(RegExp(r"[1-9]"));

    if (indexOfFirstNonZero < significantDigits) {
      // 如果小数点后面的0不足 significantDigits 个，则不做省略，使用指定精度的格式化工具
      final fractionDigits = indexOfFirstNonZero + significantDigits;
      return _makeFormatter(fractionDigits, fillZeros: fillZeros).format(this);
    } else {
      //如果小数点后面的0超过 significantDigits 个，则显示格式为：0.0ₙ{0之后的最后几位}，其中n表示0的个数
      var endIndex = indexOfFirstNonZero + significantDigits;
      if (endIndex > decimalPart.length) {
        endIndex = decimalPart.length;
      }
      var truncatedDecimal = decimalPart
          .substring(indexOfFirstNonZero, endIndex)
          .replaceAll(RegExp(r"0*$"), "");

      // 如果需要补0且截取的数字不足 significantDigits 位
      if (fillZeros && truncatedDecimal.length < significantDigits) {
        truncatedDecimal =
            truncatedDecimal.padRight(significantDigits, '0');
      }

      // 获取0的个数
      final zeroCount = indexOfFirstNonZero;
      // 将数字转换为下标数字
      String subscriptZeros = zeroCount
          .toString()
          .split('')
          .map((digit) => smallNumChats[int.parse(digit)])
          .join('');

      return "0.0$subscriptZeros$truncatedDecimal";
    }
  }

  /// 获取价格显示的合适精度
  ///
  /// 规则：小数点后连续0的个数 + 有效数字的个数（默认最多4位）
  ///
  /// Example:
  /// ```dart
  /// Decimal.parse('0.012466361274745702').getPrecision() // returns 5 (0.01246)
  /// Decimal.parse('0.0008962760495019875').getPrecision() // returns 7 (0.0008962)
  /// Decimal.parse('1.23456').getPrecision() // returns 4 (1.2345)
  /// ```
  ///
  /// [maxSignificantDigits] 最大有效数字位数，默认为4
  int getPrecision({int maxSignificantDigits = 4}) {
    if (this >= Decimal.one || this == Decimal.zero) {
      return maxSignificantDigits;
    }

    // 获取字符串表示，Decimal 默认就是非科学计数法格式
    final nonScientificString = toString().replaceAll(RegExp(r"0*$"), "");
    final decimalIndex = nonScientificString.indexOf(".");

    if (decimalIndex < 0) {
      return maxSignificantDigits;
    }

    // 获取小数部分
    final decimalPart = nonScientificString.substring(decimalIndex + 1);
    // 找到第一个非0数字的位置
    final indexOfFirstNonZero = decimalPart.indexOf(RegExp(r"[1-9]"));

    if (indexOfFirstNonZero < 0) {
      return maxSignificantDigits;
    }
    // 计算精度：小数点后连续0的个数 + 最大有效数字位数
    return indexOfFirstNonZero + maxSignificantDigits;
  }
}
