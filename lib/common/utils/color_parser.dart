import 'dart:collection';
import 'dart:ui';

Color parseColor(String colorString) {
  if (colorString.startsWith('#')) {
    // Use a BigInt to avoid rollovers on #ffXXXXXX
    var color = BigInt.parse(colorString.substring(1), radix: 16);
    if (colorString.length == 7) {
      // Set the alpha value
      color |= BigInt.from(0xff000000);
    } else if (colorString.length != 9) {
      throw ArgumentError('Unknown color');
    }
    return Color(color.toInt());
  } else {
    final color = _sColorNameMap[colorString.toLowerCase()];
    if (color != null) {
      return Color(color);
    }
  }
  throw ArgumentError('Unknown color');
}

final Map<String, int> _sColorNameMap = HashMap<String, int>.from({
  'black': 0xFF000000,
  'darkgray': 0xFF444444,
  'gray': 0xFF888888,
  'lightgray': 0xFFCCCCCC,
  'white': 0xFFFFFFFF,

  // Add more predefined colors here...
});
