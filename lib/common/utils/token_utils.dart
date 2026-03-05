import 'package:finality/common/constants/blockchain.dart';

/// 根据代币USD价格粗略估计可能的decimals值
/// 注意：这只是一个估计，实际decimals值应通过链上数据获取
class TokenUtils {
  /// 根据代币USD价格估计可能的decimals值
  /// [price] 代币的USD价格
  /// 返回估计的decimals值
  static int estimateDecimalsFromPrice(double price) {
    if (price == 0) {
      return 0;
    }
// 基于价格范围的粗略估计
    double absPrice = price.abs();
    if (absPrice >= 100) {
      return 10;
    } else if (absPrice >= 10) {
      return 9; // 高价值代币通常需要更多小数位
    } else if (absPrice >= 1) {
      return 8; // 主流代币常用范围
    } else if (absPrice >= 0.0001) {
      return 6; // 中等价格代币
    } else {
      return 4; // 低价代币
    }
  }

  /// 根据字符串格式的代币USD价格估计可能的decimals值
  /// [priceString] 代币的USD价格字符串
  /// 返回估计的decimals值
  /// 如果字符串不能转换为有效数字，将抛出FormatException
  static int estimateDecimalsFromPriceString(String priceString) {
    final price = double.tryParse(priceString);
    if (price == null) {
      return 8;
    }
    return estimateDecimalsFromPrice(price);
  }

  /// 判断是否为原生代币地址
  /// [address] 代币地址
  /// 返回是否为原生代币地址
  static bool isNativeTokenAddress(String address) {
    return address == '0' ||
        address == '' ||
        address == 'So11111111111111111111111111111111111111112' ||
        address == '0x0';
  }

  static bool isStablecoinAddress(String networkCode, String contractAddress) {
    return isUsdt(networkCode, contractAddress) ||
        isUsdc(networkCode, contractAddress);
  }

  static bool isUsdt(String networkCode, String contractAddress) {
    return networkCode == Tokens.usdt.networkCode &&
        contractAddress == Tokens.usdt.contractAddress;
  }

  static bool isUsdc(String networkCode, String contractAddress) {
    return networkCode == Tokens.usdc.networkCode &&
        contractAddress == Tokens.usdc.contractAddress;
  }
}
