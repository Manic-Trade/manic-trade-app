import 'package:finality/common/utils/token_image_utils.dart';
import 'package:finality/data/drift/entities/explorer_links.dart';
import 'package:finality/data/drift/entities/network.dart';
import 'package:finality/data/drift/entities/token.dart';
import 'package:finality/data/drift/entities/token_unit.dart';

class NetworkCodes {
  NetworkCodes._();

  static const String solana = "solana";
  static const String ethereum = "ethereum";
}

class TokenSymbols {
  TokenSymbols._();

  static const String sol = "SOL";
  static const String usdc = "USDC";
  static const String usdt = "USDT";
  static const String eth = "ETH";

  static const List<String> nativeTokens = [sol];
}

class Networks {
  Networks._();

  static const Network solana = Network(
    networkCode: NetworkCodes.solana,
    name: "Solana",
    derivationPath: "m/44'/501'/0'/0'",
    platform: NetworkPlatform.solana,
    nativeTokenUnit: TokenUnit(TokenSymbols.sol, 9),
    enabled: true,
    createdAt: null,
    updatedAt: null,
    iconUrl: TokenImageUtils.solImageUrl,
    links: ExplorerLinks(
      "https://solscan.io/tx/{0}?cluster=devnet", //TODO 正式上线要替换为正式网
      "https://solscan.io/address/{0}?cluster=devnet", //TODO 正式上线要替换为正式网
    ),
  );

  static const List<Network> all = [solana];

  static String getNetworkName(String networkCode) {
    switch (networkCode) {
      case NetworkCodes.solana:
        return solana.name;
      case NetworkCodes.ethereum:
        return "Ethereum";
      default:
        return networkCode;
    }
  }

  static Network? getNetwork(String networkCode) {
    switch (networkCode) {
      case NetworkCodes.solana:
        return solana;
    }
    return null;
  }
}

class Tokens {
  Tokens._();

  static const Token sol = Token(
    symbol: TokenSymbols.sol,
    name: "Solana",
    networkCode: NetworkCodes.solana,
    contractAddress: "0",
    tokenCreated: null,
    updatedAt: null,
    iconUrl: TokenImageUtils.solImageUrl,
    decimals: 9,
  );

  static const Token wsol = Token(
    symbol: TokenSymbols.sol,
    name: "Solana",
    networkCode: NetworkCodes.solana,
    contractAddress: "So11111111111111111111111111111111111111112",
    tokenCreated: null,
    updatedAt: null,
    iconUrl: TokenImageUtils.solImageUrl,
    decimals: 9,
  );

  static const Token usdc = Token(
    symbol: TokenSymbols.usdc,
    name: "USD Coin",
    networkCode: NetworkCodes.solana,
    contractAddress: "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v",
    tokenCreated: null,
    updatedAt: null,
    iconUrl: TokenImageUtils.usdcImageUrl,
    decimals: 6,
  );

  static const Token usdt = Token(
    symbol: TokenSymbols.usdt,
    name: "USDT",
    networkCode: NetworkCodes.solana,
    contractAddress: "Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB",
    tokenCreated: null,
    updatedAt: null,
    iconUrl: TokenImageUtils.usdtImageUrl,
    decimals: 6,
  );

  static const List<Token> all = [sol, usdc, usdt];

  static String? getIconAssetPath(Token token) {
    if (_isSame(token, sol) || _isSame(token, wsol)) {
      return TokenImageUtils.solAssetPath;
    } else if (_isSame(token, usdc)) {
      return TokenImageUtils.usdcAssetPath;
    } else if (_isSame(token, usdt)) {
      return TokenImageUtils.usdtAssetPath;
    }
    return null;
  }

  static bool _isSame(Token token, Token other) {
    return token.networkCode == other.networkCode &&
        token.contractAddress == other.contractAddress;
  }
}
