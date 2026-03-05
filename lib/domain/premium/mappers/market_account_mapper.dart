import 'dart:typed_data';

import 'package:finality/data/network/model/manic/market_account_response.dart';
import 'package:finality/domain/premium/entities/market_account.dart';

extension MarketAccountMapper on MarketAccountResponse {
  MarketAccount toMarketAccount() {
    // 将 hex feedId 转换为字节列表
    final feedIdBytes = _hexTo32Bytes(feedId).toList();

    return MarketAccount(
      operator: operator,
      backAuthority: backAuthority,
      bump: bump,
      minSettleDelayEpochsSecs: minSettleDelayEpochsSecs,
      maxSettleDelayEpochsSecs: maxSettleDelayEpochsSecs,
      feeBps: feeBps,
      minStake: BigInt.from(minStake),
      maxStake: BigInt.from(maxStake),
      minPremiumBps: minPremiumBps,
      callLambda: callLambda,
      putLambda: putLambda,
      vegaBuffer: vegaBuffer,
      feedId: feedIdBytes,
      stalenessMaxSec: stalenessMaxSec,
      priceExponent: priceExponent,
      lastPrice: lastPrice,
      lastTs: lastTs,
      callSigma2: callSigma2,
      putSigma2: putSigma2,
      minSigma2: minSigma2,
      maxSigma2: maxSigma2,
      halfLifeSecs: halfLifeSecs,
      vault: vault,
      pool: pool,
      treasury: treasury,
      paused: paused,
      closePositionMinDelaySecs: closePositionMinDelaySecs,
      closePositionBeforeSettleSecs: closePositionBeforeSettleSecs,
      deductedFeeBps: deductedFeeBps,
      maxBufferMultiplier: maxBufferMultiplier,
      bufferPercent: bufferPercent,
      highestCandleChangeBps: highestCandleChangeBps,
    );
  }

  /// 将 hex 字符串转换为 32 字节数组
  Uint8List _hexTo32Bytes(String hexString) {
    // 移除 '0x' 前缀（如果有）
    final cleanHex =
        hexString.startsWith('0x') ? hexString.substring(2) : hexString;

    if (cleanHex.length != 64) {
      throw ArgumentError('Hex string must be 64 characters (32 bytes)');
    }

    final bytes = <int>[];
    for (var i = 0; i < cleanHex.length; i += 2) {
      bytes.add(int.parse(cleanHex.substring(i, i + 2), radix: 16));
    }

    return Uint8List.fromList(bytes);
  }
}
