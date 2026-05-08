import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:solana/base58.dart';

class PendingPositionsResponse {
  final List<PendingPositionItemResponse> positions;

  const PendingPositionsResponse({
    required this.positions,
  });

  factory PendingPositionsResponse.fromJson(Map<String, dynamic> json) =>
      PendingPositionsResponse(
        positions: (json['positions'] as List<dynamic>)
            .map((e) =>
                PendingPositionItemResponse.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class PendingPositionItemResponse {
  final String id;
  final String? feedId;
  final String? user;
  final String side;
  final int amount;
  final double premium;
  final int premiumAmount;
  final double boundaryPrice;
  final double spotPrice;
  final int startTime;
  final int endTime;
  final String mode;
  final int multiplier;

  const PendingPositionItemResponse({
    required this.id,
    required this.feedId,
    required this.user,
    required this.side,
    required this.amount,
    required this.premium,
    required this.premiumAmount,
    required this.boundaryPrice,
    required this.spotPrice,
    required this.startTime,
    required this.endTime,
    required this.mode,
    required this.multiplier,
  });

  bool get isHigher => side == 'call';

  /// 是否是定时器模式
  bool get isTimerMode => mode == "single";

  /// 是否是时钟模式
  bool get isClockMode => !isTimerMode;

  factory PendingPositionItemResponse.fromJson(Map<String, dynamic> json) =>
      PendingPositionItemResponse(
        id: _bytesToBase58(json['id'] as List<dynamic>),
        feedId: json['feed_id'] != null
            ? _bytesToHexString(json['feed_id'] as List<dynamic>)
            : null,
        user: json['user'] != null
            ? _bytesToBase58(json['user'] as List<dynamic>)
            : null,
        side: json['side'] as String,
        amount: (json['amount'] as num).toInt(),
        premium: (json['premium'] as num).toDouble(),
        premiumAmount: (json['premium_amount'] as num).toInt(),
        boundaryPrice: (json['boundary_price'] as num).toDouble(),
        spotPrice: (json['spot_price'] as num).toDouble(),
        startTime: (json['start_time'] as num).toInt(),
        endTime: (json['end_time'] as num).toInt(),
        mode: json['mode'] as String,
        multiplier: (json['multiplier'] as num).toInt(),
      );

  static String _bytesToBase58(List<dynamic> bytes) {
    final intList = bytes.map((e) => (e as num).toInt()).toList();
    return base58encode(Uint8List.fromList(intList));
  }

  static String _bytesToHexString(List<dynamic> bytes) {
    final intList = bytes.map((e) => (e as num).toInt()).toList();
    return hex.encode(intList);
  }
}
