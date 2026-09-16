import 'package:finality/common/constants/blockchain.dart';
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

  static String getTokenImageUrl(String tokenAddress) {
    if (tokenAddress == "0" || tokenAddress == "") {
      return solImageUrl;
    }
    return _getTokenImageUrl(tokenAddress);
  }

  static String _getTokenImageUrl(String tokenAddress) {
    //return 'https://image.bullx.io/1399811149/$tokenAddress';
    return 'https://api.swing.cash/v1/images/tokens/$tokenAddress';
  }

  static final String _solTokenIconUrl =
      _getTokenImageUrl(Tokens.sol.contractAddress);

  static String? getTokenIconAssetPathByUrl(String iconUrl) {
    // SOL: 使用预计算的字符串
    if (iconUrl == solImageUrl || iconUrl == _solTokenIconUrl) {
      return solAssetPath;
    }

    // WSOL/USDC/USDT: 使用 contains，更灵活
    if (iconUrl.contains(Tokens.wsol.contractAddress)) {
      return solAssetPath;
    } else if (iconUrl == usdcImageUrl ||
        iconUrl.contains(Tokens.usdc.contractAddress)) {
      return usdcAssetPath;
    } else if (iconUrl == usdtImageUrl ||
        iconUrl.contains(Tokens.usdt.contractAddress)) {
      return usdtAssetPath;
    }

    return null;
  }

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
