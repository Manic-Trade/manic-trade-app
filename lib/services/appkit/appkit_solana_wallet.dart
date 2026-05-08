import 'dart:convert';

import 'package:finality/core/logger.dart';
import 'package:reown_appkit/reown_appkit.dart';
import 'package:solana/base58.dart';
import 'package:turnkey_sdk_flutter/turnkey_sdk_flutter.dart';

/// 使用 AppKit（Reown）连接的 Solana 钱包实现
///
/// 该类实现了 Turnkey SDK 的 [SolanaWalletInterface]，
/// 用于通过外部 Solana 钱包（如 Phantom、Solflare）进行 Turnkey 认证。
class AppKitSolanaWallet implements SolanaWalletInterface {
  final ReownAppKitModal _appKitModal;
  final String _walletAddress;
  final String _chainId;

  /// 缓存的公钥（十六进制格式）
  String? _cachedPublicKeyHex;

  AppKitSolanaWallet({
    required ReownAppKitModal appKitModal,
    required String walletAddress,
    required String chainId,
  })  : _appKitModal = appKitModal,
        _walletAddress = walletAddress,
        _chainId = chainId;

  @override
  WalletType get type => WalletType.solana;

  @override
  String get address => _walletAddress;

  /// 签名消息
  ///
  /// 使用 AppKit 调用外部钱包进行签名，返回十六进制格式的签名
  @override
  Future<String> signMessage(String message) async {
    logger.d('AppKitSolanaWallet: Signing message: $message');

    if (!_appKitModal.isConnected) {
      throw StateError('Wallet not connected');
    }

    final chainId = _chainId;

    final topic = _appKitModal.session?.topic;
    if (topic == null) {
      throw Exception('No session topic');
    }

    // 将消息转换为 UTF-8 字节，然后 base58 编码
    // WalletConnect Solana 规范要求 message 是 base58 编码的字节
    final messageBytes = utf8.encode(message);
    final messageBase58 = base58encode(messageBytes);

    logger.d('AppKitSolanaWallet: Message base58: $messageBase58');

    // 发送签名请求
    final result = await _appKitModal.request(
      topic: topic,
      chainId: chainId,
      request: SessionRequestParams(
        method: 'solana_signMessage',
        params: {
          'message': messageBase58,
          'pubkey': _walletAddress,
        },
      ),
    );

    if (result == null) {
      throw Exception('Failed to sign message: empty result');
    }

    logger.d('AppKitSolanaWallet: Sign result: $result');

    // 解析签名结果
    // 结果可能是 Map 或直接是签名字符串
    String signatureStr;
    if (result is Map) {
      // 某些钱包返回 {"signature": "..."} 格式
      signatureStr = (result['signature'] ?? result.values.first).toString();
    } else {
      signatureStr = result.toString();
    }

    // 移除可能的前缀
    signatureStr = signatureStr.replaceFirst('0x', '');

    // 如果签名是 base58 编码，转换为十六进制
    if (_isBase58(signatureStr)) {
      final signatureBytes = base58decode(signatureStr);
      signatureStr = _bytesToHex(signatureBytes);
    }

    logger.d('AppKitSolanaWallet: Signature hex: $signatureStr');
    return signatureStr;
  }

  /// 获取钱包公钥（十六进制格式）
  ///
  /// Solana 钱包地址就是公钥的 base58 编码，
  /// 直接将其解码并转换为十六进制即可
  @override
  Future<String> getPublicKey() async {
    if (_cachedPublicKeyHex != null) {
      return _cachedPublicKeyHex!;
    }

    // Solana 地址就是公钥的 base58 编码
    final publicKeyBytes = base58decode(_walletAddress);
    _cachedPublicKeyHex = _bytesToHex(publicKeyBytes);

    logger.d('AppKitSolanaWallet: Public key hex: $_cachedPublicKeyHex');
    return _cachedPublicKeyHex!;
  }

  /// 检查字符串是否是有效的 base58 编码
  bool _isBase58(String str) {
    // Base58 字符集（不包含 0, O, I, l）
    const base58Chars =
        '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';
    for (final char in str.split('')) {
      if (!base58Chars.contains(char)) {
        return false;
      }
    }
    // 如果字符串长度小于 100 且只包含 base58 字符，可能是 base58 编码
    // 十六进制签名通常是 128 字符（64 字节），base58 编码会更短
    return str.length < 100;
  }

  /// 将字节数组转换为十六进制字符串
  String _bytesToHex(List<int> bytes) {
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
}
