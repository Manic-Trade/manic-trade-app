import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter/foundation.dart' as foundation;

class SecureCryptoUtils {
  static const _iterations = 310000; // PBKDF2迭代次数
  static const _saltLength = 32; // 盐值长度

  /// 加密字节数组
  /// [password]: 密码
  /// [bytes]: 要加密的字节数组
  /// 返回加密后的字节数组
  static List<int> encrypt(String password, List<int> bytes) {
    // 生成随机盐值
    final salt =
        List<int>.generate(_saltLength, (_) => Random.secure().nextInt(256));

    // 生成密钥
    var key = _deriveKey(password, salt);

    // 使用AES-GCM加密，明确指定PKCS7填充
    final iv = IV.fromSecureRandom(16);
    final encrypter = Encrypter(AES(Key(Uint8List.fromList(key)),
        mode: AESMode.gcm, padding: 'PKCS7' // 明确指定PKCS7填充
        ));

    final encrypted = encrypter.encryptBytes(bytes, iv: iv);

    // 组合所有需要的数据：salt + iv + encrypted
    return [...salt, ...iv.bytes, ...encrypted.bytes];
  }

  /// 解密字节数组
  /// [password]: 密码
  /// [encryptedBytes]: 加密后的字节数组
  /// 返回原始字节数组
  static List<int> decrypt(String password, List<int> encryptedBytes) {
    // 提取各个部分
    final salt = encryptedBytes.sublist(0, _saltLength);
    final iv = encryptedBytes.sublist(_saltLength, _saltLength + 16);
    final encrypted = encryptedBytes.sublist(_saltLength + 16);

    // 生成密钥
    var key = _deriveKey(password, salt);

    // 解密，使用相同的配置
    final encrypter = Encrypter(AES(Key(Uint8List.fromList(key)),
        mode: AESMode.gcm, padding: 'PKCS7' // 明确指定PKCS7填充
        ));

    return encrypter.decryptBytes(Encrypted(Uint8List.fromList(encrypted)),
        iv: IV(Uint8List.fromList(iv)));
  }

  /// 使用PBKDF2派生密钥
  static List<int> _deriveKey(String password, List<int> salt) {
    var hmac = Hmac(sha256, utf8.encode(password));
    var key = List<int>.from(utf8.encode(password));

    // 进行多轮迭代
    for (var i = 0; i < _iterations; i++) {
      key = hmac.convert([...salt, ...key]).bytes;
    }

    return key.sublist(0, 32); // 返回256位密钥
  }

  /// 在后台线程中加密字节数组
  /// [password]: 密码
  /// [bytes]: 要加密的字节数组
  /// 返回加密后的字节数组
  static Future<List<int>> encryptAsync(String password, List<int> bytes) {
    return foundation.compute(
      (Map<String, dynamic> args) => encrypt(
        args['password'] as String,
        args['bytes'] as List<int>,
      ),
      {
        'password': password,
        'bytes': bytes,
      },
    );
  }

  /// 在后台线程中解密字节数组
  /// [password]: 密码
  /// [encryptedBytes]: 加密后的字节数组
  /// 返回原始字节数组
  static Future<List<int>> decryptAsync(
      String password, List<int> encryptedBytes) {
    return foundation.compute(
      (Map<String, dynamic> args) => decrypt(
        args['password'] as String,
        args['encryptedBytes'] as List<int>,
      ),
      {
        'password': password,
        'encryptedBytes': encryptedBytes,
      },
    );
  }
}
