import 'dart:typed_data';

import 'package:hex/hex.dart';

/// 从 Turnkey 已签名的 Solana 交易里提取用户自己的 64 字节签名。
///
/// 背景：prepare-position 返回的 `unsigned_tx` 已由服务端 fee_payer 签过，
/// user / back_authority 的 signature slot 还是 64 字节 0。
/// Turnkey 签名后得到的 `signed_tx` 里，只有用户所在的 slot 从全 0 变成了非 0
/// （back_authority 要等 submit 阶段服务端才签）。
///
/// 据此用 **diff 法** 定位用户的签名 slot：对比 unsigned 和 signed 的 signatures
/// 数组，找到"之前全 0、现在非 0"的那个 slot，即为用户的签名。
///
/// Solana Transaction 二进制格式（bincode 序列化，与 rust solana_sdk 一致）：
/// ```
/// [compact-u16 numSigs] [numSigs × 64B sigs] [Message ...]
/// ```
/// 本项目的 open/close 交易最多 3 个 signer（fee_payer / back_authority / user），
/// compact-u16 恒为 1 字节。
class SolanaTxSignatureExtractor {
  const SolanaTxSignatureExtractor._();

  /// 提取用户签名（64 字节），返回 hex 字符串（128 字符），供 submit 接口使用。
  ///
  /// 两参数均为 hex 编码的完整 Solana Transaction 字节流。
  ///
  /// 不符合预期时抛 [FormatException]（解析失败 / 签名数不匹配 / 找不到用户
  /// 签名），调用方应把错误上抛给用户，而不是吞掉重试。
  static String extractUserSignatureHex({
    required String unsignedTxHex,
    required String signedTxHex,
  }) {
    final unsigned = Uint8List.fromList(HEX.decode(unsignedTxHex));
    final signed = Uint8List.fromList(HEX.decode(signedTxHex));

    if (unsigned.isEmpty || signed.isEmpty) {
      throw const FormatException('Transaction bytes are empty');
    }

    // 本项目 signer 数量永远 < 128，compact-u16 退化为 1 字节。
    final numSigs = unsigned[0];
    if (signed[0] != numSigs) {
      throw FormatException(
        'Signature count mismatch: unsigned=$numSigs, signed=${signed[0]}',
      );
    }
    if (numSigs == 0) {
      throw const FormatException('Transaction has no signer slots');
    }

    final requiredLen = 1 + numSigs * 64;
    if (unsigned.length < requiredLen || signed.length < requiredLen) {
      throw FormatException(
        'Transaction shorter than expected: required $requiredLen bytes',
      );
    }

    int? userIndex;
    for (var i = 0; i < numSigs; i++) {
      final offset = 1 + i * 64;
      if (_isAllZero(unsigned, offset, 64) &&
          !_isAllZero(signed, offset, 64)) {
        if (userIndex != null) {
          // 理论不会发生：prepare 阶段只可能有一个 slot 还是全 0 并被 Turnkey 填充。
          // 若出现说明 tx 被篡改或 Turnkey 签了多于 1 个 slot，直接拒绝。
          throw const FormatException(
            'Multiple newly-signed slots detected; cannot disambiguate user signature',
          );
        }
        userIndex = i;
      }
    }

    if (userIndex == null) {
      throw const FormatException(
        'No user signature found (all signer slots unchanged after signing)',
      );
    }

    final sigOffset = 1 + userIndex * 64;
    final sigBytes = signed.sublist(sigOffset, sigOffset + 64);
    return HEX.encode(sigBytes);
  }

  static bool _isAllZero(Uint8List data, int offset, int length) {
    for (var i = 0; i < length; i++) {
      if (data[offset + i] != 0) return false;
    }
    return true;
  }
}
