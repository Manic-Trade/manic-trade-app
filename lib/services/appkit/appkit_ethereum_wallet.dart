import 'dart:typed_data';

import 'package:finality/core/logger.dart';
import 'package:pointycastle/export.dart';
import 'package:reown_appkit/reown_appkit.dart';
import 'package:turnkey_sdk_flutter/turnkey_sdk_flutter.dart';

/// 使用 AppKit（Reown）连接的 Ethereum 钱包实现
///
/// 该类实现了 Turnkey SDK 的 [EthereumWalletInterface]，
/// 用于通过外部 Ethereum 钱包（如 MetaMask、OKX Wallet、Binance Wallet）
/// 进行 Turnkey 认证。
class AppKitEthereumWallet implements EthereumWalletInterface {
  final ReownAppKitModal _appKitModal;
  final String _walletAddress;
  final String _chainId;

  /// 缓存的公钥（十六进制格式）
  String? _cachedPublicKeyHex;

  AppKitEthereumWallet({
    required ReownAppKitModal appKitModal,
    required String walletAddress,
    required String chainId,
  })  : _appKitModal = appKitModal,
        _walletAddress = walletAddress,
        _chainId = chainId;

  @override
  WalletType get type => WalletType.ethereum;

  @override
  String get address => _walletAddress;

  /// 签名消息
  ///
  /// 使用 AppKit 调用外部钱包进行 personal_sign，返回十六进制格式的签名
  @override
  Future<String> signMessage(String message) async {
    logger.d('AppKitEthereumWallet: Signing message: $message');

    if (!_appKitModal.isConnected) {
      throw StateError('Wallet not connected');
    }

    final chainId = _chainId;

    final topic = _appKitModal.session?.topic;
    if (topic == null) {
      throw Exception('No session topic');
    }

    // 使用 personal_sign 方法签名
    // 参数顺序: [message, address]
    final result = await _appKitModal.request(
      topic: topic,
      chainId: chainId,
      request: SessionRequestParams(
        method: 'personal_sign',
        params: [message, _walletAddress],
      ),
    );

    if (result == null) {
      throw Exception('Failed to sign message: empty result');
    }

    logger.d('AppKitEthereumWallet: Sign result: $result');

    // 解析签名结果
    String signatureStr = result.toString();

    // 移除 0x 前缀（如果有）
    if (signatureStr.startsWith('0x')) {
      signatureStr = signatureStr.substring(2);
    }

    logger.d('AppKitEthereumWallet: Signature hex: $signatureStr');
    return signatureStr;
  }

  /// 获取钱包公钥
  ///
  /// Ethereum 钱包需要通过签名来恢复公钥。
  /// 这个方法会请求用户签名一条消息，然后从签名中恢复公钥。
  ///
  /// 注意：如果之前已经通过 [setCachedPublicKey] 设置了缓存，则直接返回缓存值，
  /// 不需要额外的签名请求。
  @override
  Future<String> getPublicKey() async {
    if (_cachedPublicKeyHex != null) {
      return _cachedPublicKeyHex!;
    }

    // 需要签名一条消息来恢复公钥
    const message = 'Sign this message to verify your wallet ownership';
    final signature = await signMessage(message);
    _cachedPublicKeyHex = await recoverPublicKey(message, signature);

    logger
        .d('AppKitEthereumWallet: Recovered public key: $_cachedPublicKeyHex');
    return _cachedPublicKeyHex!;
  }

  /// 设置缓存的公钥
  ///
  /// 由 WalletStamper 在从签名恢复公钥后调用，
  /// 这样后续调用 [getPublicKey] 就不需要额外的签名请求了。
  @override
  void setCachedPublicKey(String publicKey) {
    _cachedPublicKeyHex = publicKey;
    logger.d('AppKitEthereumWallet: Cached public key set: $publicKey');
  }

  /// 从签名中恢复 secp256k1 公钥（压缩格式）
  ///
  /// [message] 原始消息
  /// [signature] 签名（十六进制格式，包含 r, s, v）
  /// Returns 恢复的公钥（压缩格式，33 字节十六进制）
  @override
  Future<String> recoverPublicKey(String message, String signature) async {
    logger.d('AppKitEthereumWallet: Recovering public key from signature');

    // 解析签名 (r, s, v)
    final sigBytes = _hexToBytes(signature);
    if (sigBytes.length != 65) {
      throw Exception(
          'Invalid signature length: ${sigBytes.length}, expected 65');
    }

    final r = BigInt.parse(_bytesToHex(sigBytes.sublist(0, 32)), radix: 16);
    final s = BigInt.parse(_bytesToHex(sigBytes.sublist(32, 64)), radix: 16);
    var v = sigBytes[64];

    // 处理 v 值（可能是 0/1 或 27/28）
    if (v >= 27) {
      v -= 27;
    }

    // 计算消息哈希（EIP-191 personal_sign 格式）
    final messageBytes = message.codeUnits;
    final prefix = '\x19Ethereum Signed Message:\n${messageBytes.length}';
    final prefixedMessage = [...prefix.codeUnits, ...messageBytes];
    final messageHash = _keccak256(Uint8List.fromList(prefixedMessage));

    // 从签名恢复公钥
    final publicKey = _recoverPublicKeyFromSignature(
      messageHash,
      ECSignature(r, s),
      v,
    );

    if (publicKey == null) {
      throw Exception('Failed to recover public key from signature');
    }

    // 转换为压缩格式的公钥（33 字节）
    // 压缩公钥格式：前缀 02（y 是偶数）或 03（y 是奇数）+ x 坐标
    final x = publicKey.Q!.x!.toBigInteger()!;
    final y = publicKey.Q!.y!.toBigInteger()!;
    final compressedPrefix = y.isOdd ? '03' : '02';
    final xHex = x.toRadixString(16).padLeft(64, '0');
    final compressedPublicKeyHex = '$compressedPrefix$xHex';

    logger.d(
        'AppKitEthereumWallet: Recovered compressed public key: $compressedPublicKeyHex');
    return compressedPublicKeyHex;
  }

  /// 将签名转换为 DER 格式
  ///
  /// Turnkey API 需要 DER 格式的签名
  String signatureToDer(String signature) {
    final sigBytes = _hexToBytes(signature);
    if (sigBytes.length < 64) {
      throw Exception('Invalid signature length');
    }

    final r = sigBytes.sublist(0, 32);
    final s = sigBytes.sublist(32, 64);

    // 移除 r 和 s 的前导零，但如果最高位是 1 则需要添加 0x00 前缀
    List<int> encodeInteger(List<int> bytes) {
      // 移除前导零
      var start = 0;
      while (start < bytes.length - 1 && bytes[start] == 0) {
        start++;
      }
      var trimmed = bytes.sublist(start);

      // 如果最高位是 1，需要添加 0x00 前缀（表示正数）
      if (trimmed[0] & 0x80 != 0) {
        trimmed = [0x00, ...trimmed];
      }

      return [0x02, trimmed.length, ...trimmed];
    }

    final rEncoded = encodeInteger(r);
    final sEncoded = encodeInteger(s);
    final sequence = [...rEncoded, ...sEncoded];

    final der = [0x30, sequence.length, ...sequence];
    return _bytesToHex(der);
  }

  /// 从签名恢复公钥
  ECPublicKey? _recoverPublicKeyFromSignature(
    Uint8List messageHash,
    ECSignature signature,
    int recId,
  ) {
    final params = ECDomainParameters('secp256k1');
    final n = params.n;
    final i = BigInt.from(recId ~/ 2);
    final x = signature.r + (i * n);

    // 检查 x 是否在有效范围内
    // secp256k1 的 p 值
    final prime = BigInt.parse(
      'FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F',
      radix: 16,
    );
    if (x >= prime) {
      return null;
    }

    // 计算 R 点
    final R = _decompressKey(x, (recId & 1) == 1, params.curve);
    if (R == null) {
      return null;
    }

    // 验证 R 点
    if (!(R * n)!.isInfinity) {
      return null;
    }

    final e = _bytesToBigInt(messageHash);
    final eInv = (BigInt.zero - e) % n;
    final rInv = signature.r.modInverse(n);
    final srInv = (rInv * signature.s) % n;
    final eInvrInv = (rInv * eInv) % n;

    final q = _sumOfTwoMultiplies(params.G, eInvrInv, R, srInv, params);
    if (q == null) {
      return null;
    }

    return ECPublicKey(q, params);
  }

  ECPoint? _decompressKey(BigInt xBN, bool yBit, ECCurve curve) {
    final compEnc = _bigIntToBytes(xBN, 32);
    final encoded = Uint8List(33);
    encoded[0] = yBit ? 0x03 : 0x02;
    encoded.setRange(1, 33, compEnc);
    return curve.decodePoint(encoded);
  }

  ECPoint? _sumOfTwoMultiplies(
    ECPoint? P,
    BigInt? k,
    ECPoint? Q,
    BigInt? l,
    ECDomainParameters params,
  ) {
    final m = (P! * k)!;
    final n = (Q! * l)!;
    return m + n;
  }

  Uint8List _keccak256(Uint8List data) {
    final digest = KeccakDigest(256);
    return digest.process(data);
  }

  Uint8List _hexToBytes(String hex) {
    if (hex.startsWith('0x')) {
      hex = hex.substring(2);
    }
    final result = Uint8List(hex.length ~/ 2);
    for (var i = 0; i < hex.length; i += 2) {
      result[i ~/ 2] = int.parse(hex.substring(i, i + 2), radix: 16);
    }
    return result;
  }

  String _bytesToHex(List<int> bytes) {
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  BigInt _bytesToBigInt(Uint8List bytes) {
    return BigInt.parse(_bytesToHex(bytes), radix: 16);
  }

  Uint8List _bigIntToBytes(BigInt number, int length) {
    final hex = number.toRadixString(16).padLeft(length * 2, '0');
    return _hexToBytes(hex);
  }
}
