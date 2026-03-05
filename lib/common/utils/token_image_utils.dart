import 'package:finality/generated/assets.dart';

class TokenImageUtils {
  static const String solImageUrl =
      "https://image.bullx.io/1399811149/So11111111111111111111111111111111111111112";
  static const String usdcImageUrl =
      "https://image.bullx.io/1399811149/EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v";
  static const String usdtImageUrl =
      "https://image.bullx.io/1399811149/Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB";

  static String get solAssetPath => Assets.tokenIconSol;
  static String get usdcAssetPath => Assets.tokenIconUsdc;
  static String get usdtAssetPath => Assets.tokenIconUsdt;
  static String get ethAssetPath => Assets.tokenIconEth;
  static String get btcAssetPath => Assets.tokenIconBtc;

  static String? getTokenIconAssetPathBySymbol(String symbol) {
    return switch (symbol) {
      'SOL' => solAssetPath,
      'sol' => solAssetPath,
      'WSOL' => solAssetPath,
      'wsol' => solAssetPath,
      'USDC' => usdcAssetPath,
      'usdc' => usdcAssetPath,
      'USDT' => usdtAssetPath,
      'usdt' => usdtAssetPath,
      'ETH' => ethAssetPath,
      'eth' => ethAssetPath,
      'BTC' => btcAssetPath,
      'btc' => btcAssetPath,
      _ => null,
    };
  }
}
