import 'package:flutter/material.dart';

extension ContentTypeColorExtension on num {
  Color get typeColor {
    switch (this) {
      case 0:
        return const Color(0xFF1A1A1A);
      case 1:
        return const Color(0xFF9DA2A7);
      case 2:
        return const Color(0xFF10BD71);
      case 3:
        return const Color(0xFFE43C69);
      default:
        return const Color(0xFF1A1A1A); // 默认颜色
    }
  }

  Color get changeTypeColor {
    switch (this) {
      case == 0:
        return const Color(0xFF9DA2A7);
      case > 0:
        return const Color(0xFF10BD71);
      case < 0:
        return const Color(0xFFE43C69);
      case double():
        return const Color(0xFF9DA2A7);
      case int():
        return const Color(0xFF9DA2A7);
    }
  }


}


