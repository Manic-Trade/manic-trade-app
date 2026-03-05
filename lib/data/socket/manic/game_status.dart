import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:solana/base58.dart';

/// WebSocket 游戏状态事件
class GameStatusEvent {
  final String flag;
  final PositionEvent event;

  const GameStatusEvent({
    required this.flag,
    required this.event,
  });

  factory GameStatusEvent.fromJson(Map<String, dynamic> json) =>
      GameStatusEvent(
        flag: json['flag'] as String,
        event: PositionEvent.fromJson(json['event'] as Map<String, dynamic>),
      );

  bool get isOpenPosition => flag == 'open_position';
  bool get isSettle => flag == 'settle';
}

/// 仓位事件 - 同时用于 open_position 和 settle
class PositionEvent {
  // 共有字段
  final double boundaryPrice;
  final String id; // 服务端返回字节数组，解析为 base58 字符串
  final num premium; // open_position 是 double，settle 是 int
  final String side;
  final double spotPrice;
  final String user; // 服务端返回字节数组，解析为 base58 字符串

  // open_position 独有字段
  final int? amount;
  final int? endTime;
  final String? feedId; // 服务端返回字节数组，解析为 base58 字符串
  final String? mode;
  final int? premiumAmount;
  final int? startTime;

  // settle 独有字段
  final double? finalPrice;
  final int? payout;
  final String? result;

  const PositionEvent({
    required this.boundaryPrice,
    required this.id,
    required this.premium,
    required this.side,
    required this.spotPrice,
    required this.user,
    this.amount,
    this.endTime,
    this.feedId,
    this.mode,
    this.premiumAmount,
    this.startTime,
    this.finalPrice,
    this.payout,
    this.result,
  });

  bool get isHigh => side == 'call';

  bool get isWin => result == 'Won';

  /// 是否是定时器模式
  bool get isTimerMode => mode == "single";

  /// 是否是时钟模式
  bool get isClockMode => !isTimerMode;

  /// 将服务端返回的字节数组转换为 base58 字符串
  static String _bytesToHexString(List<dynamic> bytes) {
    final intList = bytes.map((e) => (e as num).toInt()).toList();
    return hex.encode(intList);
  }

  static String _bytesToBase58(List<dynamic> bytes) {
    final intList = bytes.map((e) => (e as num).toInt()).toList();
    return base58encode(Uint8List.fromList(intList));
  }

  factory PositionEvent.fromJson(Map<String, dynamic> json) => PositionEvent(
        boundaryPrice: (json['boundary_price'] as num).toDouble(),
        id: _bytesToBase58(json['id'] as List<dynamic>),
        premium: json['premium'] as num,
        side: json['side'] as String,
        spotPrice: (json['spot_price'] as num).toDouble(),
        user: _bytesToBase58(json['user'] as List<dynamic>),
        amount: (json['amount'] as num?)?.toInt(),
        endTime: (json['end_time'] as num?)?.toInt(),
        feedId: json['feed_id'] != null
            ? _bytesToHexString(json['feed_id'] as List<dynamic>)
            : null,
        mode: json['mode'] as String?,
        premiumAmount: (json['premium_amount'] as num?)?.toInt(),
        startTime: (json['start_time'] as num?)?.toInt(),
        finalPrice: (json['final_price'] as num?)?.toDouble(),
        payout: (json['payout'] as num?)?.toInt(),
        result: json['result'] as String?,
      );
}
