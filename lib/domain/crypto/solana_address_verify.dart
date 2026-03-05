

import 'package:solana/base58.dart';

class SolanaAddressVerify {
    static final RegExp _solanaAddressRegex =
      RegExp(r'^[1-9A-HJ-NP-Za-km-z]{32,44}$');
      

  static Future<bool> validate(String text) async {
    if (text.isEmpty) return false;
    if (!_solanaAddressRegex.hasMatch(text)) return false;
    try {
      final decoded = base58decode(text);
      return decoded.length == 32;
    } catch (e) {
      return false;
    }
  }
}