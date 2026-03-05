extension IntToHex62 on int {
  String uIntToHex62() {
    if (this < 0) {
      throw ArgumentError('number cannot be less than 0');
    }
    var rest = toUnsigned(64);
    var stack = <String>[];
    var result = StringBuffer();
    final charSet =
        '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
            .split('');
    var charSize = charSet.length;
    while (rest != 0) {
      stack.add(charSet[rest - (rest ~/ charSize) * charSize]);
      rest ~/= charSize;
    }
    while (stack.isNotEmpty) {
      result.write(stack.removeLast());
    }
    return result.toString();
  }
}

extension Hex62ToInt on String {
  int hex62ToInt() {
    var dst = 0;
    final charSet =
        '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
            .split('');
    for (var element in split('')) {
      var c = element;
      for (var j = 0; j < charSet.length; j++) {
        if (c == charSet[j]) {
          dst = dst * charSet.length + j;
          break;
        }
      }
    }
    return dst;
  }

  int? hex62ToIntOrNull() {
    try {
      return hex62ToInt();
    } catch (e) {
      return null;
    }
  }
}
