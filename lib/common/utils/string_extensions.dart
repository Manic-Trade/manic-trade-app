import 'dart:io';

import 'package:url_launcher/url_launcher.dart';

extension StringExtensions on String {
  ///将输入字符串拆分成单词，然后将每个单词的首字母大写，并将其余字母转换为小写字母。
  ///最后，它将所有单词连接起来，形成一个PascalCase风格的字符串。
  String toPascalCase() {
    if (isEmpty) {
      return this;
    }
    String output = '';
    List<String> words = split(RegExp(r'[^\w]+'));
    for (String word in words) {
      if (word.isNotEmpty) {
        output += word[0].toUpperCase() + word.substring(1).toLowerCase();
      }
    }
    return output;
  }

  ///将字符串转换为以空格分隔的每个单词的首字母大写的标题格式字符串。
  String toTitleCaseWithSpaces() {
    if (isEmpty) {
      return '';
    }
    String output = '';
    List<String> words = split(RegExp(r'[^\w]+'));
    for (int i = 0; i < words.length; i++) {
      String word = words[i];
      if (word.isNotEmpty) {
        if (i > 0) {
          output += ' ';
        }
        output += word[0].toUpperCase() + word.substring(1).toLowerCase();
      }
    }

    return output;
  }

  String replacePlaceholders(List<String> values) {
    int index = 0;
    return replaceAllMapped(RegExp(r'{\d+}'), (match) => values[index++]);
  }

  bool isUrl() {
    Uri? uri = Uri.tryParse(this);
    return uri != null && uri.hasScheme && uri.hasAuthority;
  }

  bool isHexString() {
    return RegExp(r"(0[xX])?[0-9a-fA-F]*").hasMatch(this);
  }

  int hexStringToInt() {
    if (!isHexString()) {
      return throw const FormatException("Invalid hexadecimal value");
    }
    var hexString = this;
    if (hexString.startsWith("0x") || hexString.startsWith("0X")) {
      hexString = hexString.substring(2);
    }
    return int.parse(hexString, radix: 16);
  }

  int? hexStringToIntOrNull() {
    try {
      return hexStringToInt();
    } catch (error) {
      return null;
    }
  }

  BigInt hexStringToBigInt() {
    if (!isHexString()) {
      return throw const FormatException("Invalid hexadecimal value");
    }
    var hexString = this;
    if (hexString.startsWith("0x") || hexString.startsWith("0X")) {
      hexString = hexString.substring(2);
    }
    return BigInt.parse(hexString, radix: 16);
  }

  BigInt? hexStringToBigIntOrNull() {
    try {
      return hexStringToBigInt();
    } catch (error) {
      return null;
    }
  }

  bool isJsonArray() {
    var trim = this.trim();
    if (trim.isEmpty) {
      return false;
    }
    return trim[0] == '[' && trim[trim.length - 1] == ']';
  }

  bool isJsonObject() {
    var trim = this.trim();
    if (trim.isEmpty) {
      return false;
    }
    return trim[0] == '{' && trim[trim.length - 1] == '{';
  }

  Future<bool> openInBrowser() async {
    var url = this;
    if (url.isUrl()) {
      if (Platform.isAndroid) {
        try {
          return await launch(url);
        } catch (e) {}
      } else {
        var uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          return await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      }
    }
    return false;
  }

  String limitTextLength(int maxLength, {String? ellipsis}) {
    if (length <= maxLength) {
      return this;
    } else {
      if (ellipsis != null) {
        return substring(0, maxLength) + ellipsis;
      } else {
        return substring(0, maxLength);
      }
    }
  }

  /// Truncates a string (typically an address) by keeping the start and end parts
  /// while replacing the middle with an ellipsis.
  ///
  /// [prefixLength] - Number of characters to keep from the start
  /// [suffixLength] - Number of characters to keep from the end
  /// [ellipsis] - The string to use as ellipsis (default: '...')
  ///
  /// Throws [ArgumentError] if prefix or suffix lengths are negative
  String truncateWithEllipsis({
    int prefixLength = 8,
    int suffixLength = 6,
    String ellipsis = '...',
  }) {
    // Validate input parameters
    if (prefixLength < 0 || suffixLength < 0) {
      throw ArgumentError('Prefix and suffix lengths must be non-negative');
    }

    // Return original string if it's shorter than or equal to the sum of prefix and suffix
    if (length <= prefixLength + suffixLength) {
      return this;
    }

    return substring(0, prefixLength) +
        ellipsis +
        substring(length - suffixLength);
  }

  String formatTokenAddressString({int prefixLength = 6, int suffixLength = 4}) {
    if (length <= prefixLength + suffixLength) {
      return this;
    } else {
      return '${substring(0, prefixLength)}...${substring(length - suffixLength)}';
    }
  }

/// 获取邮箱用户名部分
/// 例如: "zchu8073@gmail.com" -> "zchu8073"
/// 如果字符串不包含 @，则返回原字符串
String get emailUsername {
  final atIndex = indexOf('@');
  return atIndex > 0 ? substring(0, atIndex) : this;
}
}
